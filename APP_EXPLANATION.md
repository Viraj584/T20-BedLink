# T20-BedLink Codebase & Architecture Analysis

## 1. Overview & Stack
- **Framework**: Flutter / Dart
- **Backend Services**: Firebase (Authentication, Firestore / Realtime DB)
- **Context Source**: repomix-output.xml

## 2. Detected Dart Files (46 files in lib/)
- lib/core/utils/alert_sound.dart
- lib/core/utils/haversine.dart
- lib/core/utils/time_ago.dart
- lib/core/widgets/bed_tile.dart
- lib/core/widgets/countdown_ring.dart
- lib/core/widgets/freshness_badge.dart
- lib/core/constants.dart
- lib/core/router.dart
- lib/core/theme.dart
- lib/features/demo/demo_controls_screen.dart
- lib/features/dispatch/hold_status_screen.dart
- lib/features/dispatch/new_request_screen.dart
- lib/features/dispatch/results_screen.dart
- lib/features/dispatch/trip_complete_screen.dart
- lib/features/nurse/bed_update_screen.dart
- lib/features/nurse/hospital_login_screen.dart
- lib/features/nurse/incoming_request_screen.dart
- lib/features/nurse/request_history_screen.dart
- lib/features/patient/clinic_results_screen.dart
- lib/features/patient/clinic_search_screen.dart
- lib/features/patient/patient_hub_screen.dart
- lib/features/patient/report_analysis_screen.dart
- lib/features/patient/report_list_screen.dart
- lib/features/role_select/role_select_screen.dart
- lib/models/attempt.dart
- lib/models/bed_inventory.dart
- lib/models/clinic.dart
- lib/models/emergency_request.dart
- lib/models/hospital_rank_result.dart
- lib/models/hospital.dart
- lib/models/test_report.dart
- lib/providers/clinic_providers.dart
- lib/providers/hospital_providers.dart
- lib/providers/location_providers.dart
- lib/providers/report_providers.dart
- lib/providers/request_providers.dart
- lib/services/clinic_ranking_service.dart
- lib/services/firestore_service.dart
- lib/services/location_service.dart
- lib/services/openrouter_service.dart
- lib/services/ranking_service.dart
- lib/services/report_analysis_service.dart
- lib/services/routing_service.dart
- lib/firebase_options.dart
- lib/main.dart
- test/widget_test.dart

## 3. Key Modules & Services
- **UI Screens & Widgets**: Located under lib/
- **Firebase Integration**: Configurations present in firebase.json and pubspec.yaml
