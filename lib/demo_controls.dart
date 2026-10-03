import 'package:flutter/material.dart';

enum DemoScenario { normal, simulateReject, simulateTimeout, simulateStale }

class DemoStateNotifier extends ChangeNotifier {
  DemoScenario _currentScenario = DemoScenario.normal;
  DemoScenario get currentScenario => _currentScenario;

  void setScenario(DemoScenario scenario) {
    _currentScenario = scenario;
    notifyListeners();
  }
}

class DemoWrapperScreen extends StatefulWidget {
  final Widget child;
  const DemoWrapperScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<DemoWrapperScreen> createState() => _DemoWrapperScreenState();
}

class _DemoWrapperScreenState extends State<DemoWrapperScreen> {
  bool _isMobileView = false;
  DemoScenario _activeScenario = DemoScenario.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isMobileView ? 375 : double.infinity,
              height: _isMobileView ? 812 : double.infinity,
              decoration: _isMobileView
                  ? BoxDecoration(
                      border: Border.all(color: Colors.black, width: 8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
                    )
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isMobileView ? 16 : 0),
                child: widget.child,
              ),
            ),
          ),
          // Judge Demo Controls (Top Right Overlay)
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF0F172A),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    const Text('Judge Demo Switcher:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    DropdownButton<DemoScenario>(
                      dropdownColor: const Color(0xFF1E293B),
                      value: _activeScenario,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      onChanged: (DemoScenario? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _activeScenario = newValue;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: DemoScenario.normal, child: Text('Normal Live State')),
                        DropdownMenuItem(value: DemoScenario.simulateReject, child: Text('Simulate Hospital Reject')),
                        DropdownMenuItem(value: DemoScenario.simulateTimeout, child: Text('Simulate 2-Min Timeout')),
                        DropdownMenuItem(value: DemoScenario.simulateStale, child: Text('Simulate Stale (>30m) Data')),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Toggle 375px Cheap Phone Frame',
                      icon: Icon(_isMobileView ? Icons.fullscreen : Icons.phone_android, color: Colors.white, size: 18),
                      onPressed: () {
                        setState(() {
                          _isMobileView = !_isMobileView;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
