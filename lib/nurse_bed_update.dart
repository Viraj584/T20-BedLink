import 'package:flutter/material.dart';

class NurseBedUpdateScreen extends StatefulWidget {
  const NurseBedUpdateScreen({Key? key}) : super(key: key);

  @override
  State<NurseBedUpdateScreen> createState() => _NurseBedUpdateScreenState();
}

class _NurseBedUpdateScreenState extends State<NurseBedUpdateScreen> {
  DateTime _lastUpdated = DateTime.now();
  final Map<String, int> _beds = {
    'ICU': 4,
    'Ventilator': 2,
    'Oxygen': 12,
    'Cardiac': 3,
    'Burns': 1,
  };

  void _updateCount(String key, int delta) {
    setState(() {
      _beds[key] = ((_beds[key] ?? 0) + delta).clamp(0, 99);
      _lastUpdated = DateTime.now();
    });
  }

  String _getFreshnessText() {
    final diff = DateTime.now().difference(_lastUpdated).inMinutes;
    if (diff < 1) return 'Updated just now';
    return 'Updated $diff min ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('BedLink — Hospital Nurse Hub', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Text(
                _getFreshnessText(),
                style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _beds.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _updateCount(entry.key, -1),
                              icon: const Icon(Icons.remove_circle_outline, size: 32, color: Colors.redAccent),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${entry.value}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _updateCount(entry.key, 1),
                              icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
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
