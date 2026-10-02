import 'async';

enum HoldStatus { pending, accepted, rejected, timedOut }

class HospitalHoldRequest {
  final String hospitalId;
  final String hospitalName;
  final int bedMatchScore;
  final int etaMinutes;
  HoldStatus status;

  HospitalHoldRequest({
    required this.hospitalId,
    required this.hospitalName,
    required this.bedMatchScore,
    required this.etaMinutes,
    this.status = HoldStatus.pending,
  });
}

class CascadeHoldController {
  final List<HospitalHoldRequest> rankedHospitals;
  int currentIndex = 0;
  int secondsRemaining = 120; // 2 minutes
  bool _isActive = false;

  CascadeHoldController({required this.rankedHospitals});

  HospitalHoldRequest? get currentHospital =>
      currentIndex < rankedHospitals.length ? rankedHospitals[currentIndex] : null;

  void startHoldTimer(Function(int secondsLeft, HospitalHoldRequest? hospital) onTick, Function(HospitalHoldRequest? finalHospital) onCompleted) {
    _isActive = true;
    secondsRemaining = 120;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isActive) return false;

      secondsRemaining--;
      onTick(secondsRemaining, currentHospital);

      if (secondsRemaining <= 0) {
        // Timeout reached -> Reject current and cascade to next best
        if (currentHospital != null) {
          currentHospital!.status = HoldStatus.timedOut;
        }
        return _cascadeToNext(onTick, onCompleted);
      }
      return _isActive;
    });
  }

  bool _cascadeToNext(Function(int, HospitalHoldRequest?) onTick, Function(HospitalHoldRequest?) onCompleted) {
    currentIndex++;
    if (currentIndex < rankedHospitals.length) {
      secondsRemaining = 120; // Reset 2-min timer for fallback hospital
      return true;
    } else {
      _isActive = false;
      onCompleted(null); // All hospitals exhausted/rejected
      return false;
    }
  }

  void respondToHold(bool accept, Function(HospitalHoldRequest?) onCompleted) {
    if (currentHospital == null) return;

    if (accept) {
      currentHospital!.status = HoldStatus.accepted;
      _isActive = false;
      onCompleted(currentHospital);
    } else {
      currentHospital!.status = HoldStatus.rejected;
      secondsRemaining = 0; // Force immediate cascade
    }
  }
}
