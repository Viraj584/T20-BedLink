import 'dart:async';
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueNotifier;
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BedLinkApp());
}

// =============================================================================
// COLOR PALETTE & CONSTANTS
// =============================================================================
const Color kInk = Color(0xFF102A43);
const Color kTeal = Color(0xFF00695C);
const Color kRed = Color(0xFFB71C1C);
const Color kAmberBg = Color(0xFFFFF3CD);
const Color kAmberText = Color(0xFF7A4B00);
const Color kGreenBg = Color(0xFFE0F2F1);
const Color kGreenText = Color(0xFF004D40);

String ageLabel(int minutes) =>
    minutes <= 0 ? 'Updated just now' : 'Updated $minutes min ago';

// =============================================================================
// CORE MODELS & ALGORITHM
// =============================================================================
class Bed {
  static const String icu = 'icu';
  static const String ventilator = 'ventilator';
  static const String oxygen = 'oxygen';
  static const String cardiac = 'cardiac';
  static const String burns = 'burns';

  static const List<String> all = [icu, ventilator, oxygen, cardiac, burns];
  static const Map<String, String> labels = {
    icu: 'ICU',
    ventilator: 'Ventilator',
    oxygen: 'Oxygen',
    cardiac: 'Cardiac',
    burns: 'Burns',
  };
}

class Hospital {
  Hospital({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.total,
    required this.available,
    required this.held,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final Map<String, int> total;
  final Map<String, int> available;
  final Map<String, int> held;
  DateTime updatedAt;

  int free(String type) {
    final int v = (available[type] ?? 0) - (held[type] ?? 0);
    return v < 0 ? 0 : v;
  }

  double load(List<String> needs) {
    int tot = 0;
    int used = 0;
    for (final String t in needs) {
      final int n = total[t] ?? 0;
      tot += n;
      used += n - free(t);
    }
    if (tot <= 0) return 1.0;
    final double r = used / tot;
    return r < 0 ? 0.0 : (r > 1 ? 1.0 : r);
  }
}

class RankedHospital {
  const RankedHospital({
    required this.hospital,
    required this.matchPercent,
    required this.etaMinutes,
    required this.dataAgeMinutes,
    required this.load,
    required this.isStale,
    required this.score,
  });

  final Hospital hospital;
  final int matchPercent;
  final int etaMinutes;
  final int dataAgeMinutes;
  final double load;
  final bool isStale;
  final double score;

  bool get isFullMatch => matchPercent == 100;
}

List<RankedHospital> rankHospitals({
  required List<Hospital> hospitals,
  required List<String> needs,
  required int Function(Hospital) etaMinutes,
  required DateTime now,
  Set<String> excludeIds = const <String>{},
  int staleAfterMinutes = 30,
}) {
  final List<RankedHospital> out = <RankedHospital>[];
  for (final Hospital h in hospitals) {
    if (excludeIds.contains(h.id)) continue;

    int matched = 0;
    for (final String t in needs) {
      if (h.free(t) > 0) matched++;
    }
    if (matched == 0) continue;
    final int matchPct = needs.isEmpty ? 100 : (matched * 100 ~/ needs.length);

    int age = now.difference(h.updatedAt).inMinutes;
    if (age < 0) age = 0;
    final bool stale = age >= staleAfterMinutes;
    final int eta = etaMinutes(h);
    final double load = h.load(needs);

    final double score = (100 - matchPct) * 1.0 +
        eta * 1.0 +
        load * 10.0 +
        (stale ? 15.0 : age * 0.2);

    out.add(RankedHospital(
      hospital: h,
      matchPercent: matchPct,
      etaMinutes: eta,
      dataAgeMinutes: age,
      load: load,
      isStale: stale,
      score: score,
    ));
  }
  out.sort((RankedHospital a, RankedHospital b) => a.score.compareTo(b.score));
  return out;
}

class HoldAttempt {
  const HoldAttempt(this.hospitalName, this.reason);
  final String hospitalName;
  final String reason;
}

class HoldController extends ChangeNotifier {
  HoldController({
    this.holdDuration = const Duration(minutes: 2),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final Duration holdDuration;
  final DateTime Function() _now;

  List<RankedHospital> _queue = <RankedHospital>[];
  final List<HoldAttempt> _attempts = <HoldAttempt>[];
  int _index = 0;
  DateTime? _deadline;
  Timer? _ticker;
  bool _disposed = false;

  String status = 'idle';

  final ValueNotifier<Duration> remaining = ValueNotifier<Duration>(Duration.zero);

  List<HoldAttempt> get attempts => List<HoldAttempt>.unmodifiable(_attempts);
  RankedHospital? get current =>
      status == 'pending' && _index < _queue.length ? _queue[_index] : null;
  RankedHospital? get accepted =>
      status == 'accepted' && _index < _queue.length ? _queue[_index] : null;
  int get position => _index + 1;
  int get totalOptions => _queue.length;

  void start(List<RankedHospital> ranked) {
    _queue = List<RankedHospital>.of(ranked);
    _attempts.clear();
    _index = 0;
    _offerCurrentOrExhaust();
  }

  void accept() {
    if (status != 'pending') return;
    _stop();
    status = 'accepted';
    _notify();
  }

  void reject() => _fail('rejected');

  void forceTimeout() {
    if (status != 'pending') return;
    _deadline = _now().subtract(const Duration(seconds: 1));
    _tick();
  }

  void reset() {
    _stop();
    _queue = <RankedHospital>[];
    _attempts.clear();
    _index = 0;
    status = 'idle';
    remaining.value = Duration.zero;
    _notify();
  }

  void _fail(String reason) {
    if (status != 'pending') return;
    _attempts.add(HoldAttempt(_queue[_index].hospital.name, reason));
    _index++;
    _offerCurrentOrExhaust();
  }

  void _offerCurrentOrExhaust() {
    _stop();
    if (_index >= _queue.length) {
      status = 'exhausted';
      remaining.value = Duration.zero;
    } else {
      status = 'pending';
      _deadline = _now().add(holdDuration);
      remaining.value = holdDuration;
      _ticker = Timer.periodic(const Duration(seconds: 1), (Timer _) => _tick());
    }
    _notify();
  }

  void _tick() {
    final DateTime? d = _deadline;
    if (d == null || status != 'pending') return;
    final Duration left = d.difference(_now());
    if (left <= Duration.zero) {
      _fail('timeout');
    } else {
      remaining.value = left;
    }
  }

  void _stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stop();
    remaining.dispose();
    super.dispose();
  }
}

// =============================================================================
// UI COMPONENTS
// =============================================================================
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({super.key, required this.minutes, required this.stale});

  final int minutes;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final Color bg = stale ? kAmberBg : kGreenBg;
    final Color fg = stale ? kAmberText : kGreenText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(stale ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              size: 16, color: fg),
          const SizedBox(width: 4),
          Text(
            stale ? 'STALE · ${ageLabel(minutes)}' : ageLabel(minutes),
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class HoldTimerRing extends StatelessWidget {
  const HoldTimerRing({
    super.key,
    required this.remaining,
    required this.total,
    this.size = 120,
  });

  final ValueNotifier<Duration> remaining;
  final Duration total;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<Duration>(
        valueListenable: remaining,
        builder: (BuildContext context, Duration left, Widget? _) {
          final int secs = left.inSeconds < 0 ? 0 : left.inSeconds;
          final bool urgent = secs <= 30;
          final Color c = urgent ? kRed : kTeal;
          final double progress =
              total.inSeconds == 0 ? 0.0 : secs / total.inSeconds;
          final String mm = (secs ~/ 60).toString().padLeft(2, '0');
          final String ss = (secs % 60).toString().padLeft(2, '0');
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    color: c,
                    backgroundColor: const Color(0xFFE0E0E0),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('$mm:$ss',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800, color: c)),
                    Text(urgent ? 'EXPIRING' : 'HOLD',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: c)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AllDeclinedPanel extends StatelessWidget {
  const AllDeclinedPanel({
    super.key,
    required this.attempts,
    required this.onReRank,
  });

  final List<HoldAttempt> attempts;
  final VoidCallback onReRank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kRed, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.error_outline, color: kRed),
              SizedBox(width: 8),
              Expanded(
                child: Text('No hospital accepted the hold',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: kRed)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final HoldAttempt a in attempts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${a.hospitalName}: ${a.reason == 'timeout' ? 'no response in 2 min' : 'rejected'}',
                style: const TextStyle(color: kInk, fontSize: 14),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Call the nearest hospital directly, or refresh and re-rank.',
              style: TextStyle(color: kInk, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onReRank,
              icon: const Icon(Icons.refresh),
              label: const Text('Re-rank hospitals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kRed,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HoldModalSheet extends StatefulWidget {
  final List<RankedHospital> ranked;
  final VoidCallback onReRank;

  const HoldModalSheet({Key? key, required this.ranked, required this.onReRank}) : super(key: key);

  @override
  State<HoldModalSheet> createState() => _HoldModalSheetState();
}

class _HoldModalSheetState extends State<HoldModalSheet> {
  late final HoldController _holdController;

  @override
  void initState() {
    super.initState();
    _holdController = HoldController();
    _holdController.start(widget.ranked);
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _holdController,
      builder: (context, _) {
        if (_holdController.status == 'exhausted') {
          return AllDeclinedPanel(
            attempts: _holdController.attempts,
            onReRank: () {
              Navigator.of(context).pop();
              widget.onReRank();
            },
          );
        }
        if (_holdController.status == 'accepted') {
          final h = _holdController.accepted;
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: kTeal, size: 56),
                const SizedBox(height: 12),
                Text('Bed Held at ${h?.hospital.name ?? ""}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kGreenText)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: kTeal, foregroundColor: Colors.white),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
        final h = _holdController.current;
        if (h == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Option ${_holdController.position} of ${_holdController.totalOptions}',
                  style: const TextStyle(color: kInk, fontSize: 13)),
              const SizedBox(height: 4),
              Text(h.hospital.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 8),
              FreshnessBadge(minutes: h.dataAgeMinutes, stale: h.isStale),
              const SizedBox(height: 16),
              HoldTimerRing(remaining: _holdController.remaining, total: _holdController.holdDuration),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _holdController.reject,
                        child: const Text('Simulate Reject'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _holdController.forceTimeout,
                        child: const Text('Force Timeout'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _holdController.accept,
                        style: ElevatedButton.styleFrom(backgroundColor: kTeal, foregroundColor: Colors.white),
                        child: const Text('Simulate Accept'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// MAIN SHELL & SCREENS
// =============================================================================
class BedLinkApp extends StatefulWidget {
  const BedLinkApp({Key? key}) : super(key: key);

  @override
  State<BedLinkApp> createState() => _BedLinkAppState();
}

class _BedLinkAppState extends State<BedLinkApp> {
  int _activeTab = 0;

  final List<Hospital> _hospitals = [
    Hospital(
      id: 'h1',
      name: 'City Care Hospital',
      lat: 19.0760,
      lng: 72.8777,
      total: {Bed.icu: 10, Bed.ventilator: 5, Bed.oxygen: 20, Bed.cardiac: 5, Bed.burns: 2},
      available: {Bed.icu: 4, Bed.ventilator: 2, Bed.oxygen: 12, Bed.cardiac: 3, Bed.burns: 1},
      held: {Bed.icu: 1, Bed.ventilator: 0, Bed.oxygen: 2, Bed.cardiac: 0, Bed.burns: 0},
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Hospital(
      id: 'h2',
      name: 'Apex Trauma Center',
      lat: 19.1136,
      lng: 72.8697,
      total: {Bed.icu: 15, Bed.ventilator: 8, Bed.oxygen: 25, Bed.cardiac: 10, Bed.burns: 5},
      available: {Bed.icu: 6, Bed.ventilator: 4, Bed.oxygen: 18, Bed.cardiac: 5, Bed.burns: 3},
      held: {Bed.icu: 0, Bed.ventilator: 1, Bed.oxygen: 3, Bed.cardiac: 1, Bed.burns: 0},
      updatedAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    Hospital(
      id: 'h3',
      name: 'St. Jude Specialty',
      lat: 19.2183,
      lng: 72.9781,
      total: {Bed.icu: 5, Bed.ventilator: 2, Bed.oxygen: 10, Bed.cardiac: 2, Bed.burns: 2},
      available: {Bed.icu: 1, Bed.ventilator: 0, Bed.oxygen: 5, Bed.cardiac: 1, Bed.burns: 1},
      held: {Bed.icu: 0, Bed.ventilator: 0, Bed.oxygen: 0, Bed.cardiac: 0, Bed.burns: 0},
      updatedAt: DateTime.now().subtract(const Duration(minutes: 42)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BedLink Healthtech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: Scaffold(
        body: IndexedStack(
          index: _activeTab,
          children: [
            NurseUpdateScreen(
              hospital: _hospitals[0],
              onUpdate: () => setState(() {}),
            ),
            DispatchRankingScreen(hospitals: _hospitals),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _activeTab,
          onTap: (index) => setState(() => _activeTab = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Nurse Station'),
            BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Ambulance Dispatch'),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// NURSE SCREEN
// ----------------------------------------------------
class NurseUpdateScreen extends StatefulWidget {
  final Hospital hospital;
  final VoidCallback onUpdate;

  const NurseUpdateScreen({Key? key, required this.hospital, required this.onUpdate}) : super(key: key);

  @override
  State<NurseUpdateScreen> createState() => _NurseUpdateScreenState();
}

class _NurseUpdateScreenState extends State<NurseUpdateScreen> {
  void _changeBedCount(String key, int delta) {
    setState(() {
      final current = widget.hospital.available[key] ?? 0;
      widget.hospital.available[key] = (current + delta).clamp(0, widget.hospital.total[key] ?? 99);
      widget.hospital.updatedAt = DateTime.now();
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final ageMins = DateTime.now().difference(widget.hospital.updatedAt).inMinutes;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hospital.name} — Nurse Station'),
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FreshnessBadge(minutes: ageMins, stale: ageMins >= 30),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: Bed.all.map((key) {
                  final freeCount = widget.hospital.free(key);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Bed.labels[key] ?? key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: kRed, size: 32),
                                onPressed: () => _changeBedCount(key, -1),
                              ),
                              Text('$freeCount Free', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: kTeal, size: 32),
                                onPressed: () => _changeBedCount(key, 1),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// DISPATCH SCREEN
// ----------------------------------------------------
class DispatchRankingScreen extends StatefulWidget {
  final List<Hospital> hospitals;
  const DispatchRankingScreen({Key? key, required this.hospitals}) : super(key: key);

  @override
  State<DispatchRankingScreen> createState() => _DispatchRankingScreenState();
}

class _DispatchRankingScreenState extends State<DispatchRankingScreen> {
  final List<String> _selectedNeeds = [Bed.icu, Bed.ventilator];

  void _startHold(List<RankedHospital> ranked) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HoldModalSheet(
        ranked: ranked,
        onReRank: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ranked = rankHospitals(
      hospitals: widget.hospitals,
      needs: _selectedNeeds,
      etaMinutes: (h) => h.id == 'h1' ? 8 : (h.id == 'h2' ? 14 : 22),
      now: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Dispatch Ranking'),
        backgroundColor: kInk,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              children: Bed.all.map((key) {
                final isSelected = _selectedNeeds.contains(key);
                return FilterChip(
                  label: Text(Bed.labels[key] ?? key),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedNeeds.add(key);
                      } else {
                        if (_selectedNeeds.length > 1) _selectedNeeds.remove(key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ranked.length,
              itemBuilder: (context, index) {
                final item = ranked[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(item.hospital.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ETA: ${item.etaMinutes} mins | Match: ${item.matchPercent}%'),
                        const SizedBox(height: 4),
                        FreshnessBadge(minutes: item.dataAgeMinutes, stale: item.isStale),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _startHold(ranked),
                      style: ElevatedButton.styleFrom(backgroundColor: kTeal, foregroundColor: Colors.white),
                      child: const Text('Hold Bed'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
