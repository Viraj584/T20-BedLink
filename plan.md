1. Core decisions

One app, two roles. Build a single APK with a role selector on launch: Hospital (Nurse) and Ambulance (Dispatch). For the demo, run it on your phone as dispatch and on a second phone or emulator as the hospital, and judges see the real-time handshake live.

Backend: Firebase Firestore. It gives real-time listeners for free, so no server code is needed. The nurse's update appears on the dispatcher's screen instantly, and the accept/reject appears on the ambulance instantly.

Maps and ETA: no billing headaches.

flutter_map with OpenStreetMap tiles needs no API key.
The public OSRM API (router.project-osrm.org) returns driving time and needs no key.
If OSRM fails during the demo, fall back to a straight-line distance × a city speed factor. Always keep this fallback.

The 2-minute timer. Store offerExpiresAt (a server timestamp plus 120s) in Firestore. Both apps count down from that value. The dispatcher app drives the cascade (on reject or expiry, it writes the next offer). Cloud Functions need a paid plan, so for a prototype this is fine. Tell judges production would move it server-side.

2. Pages, features and buttons
A. Shared

1. Splash / Role Select

Logo and tagline
Button: I'm a Hospital Nurse
Button: I'm an Ambulance Crew
Hidden long-press on the logo opens Demo Controls
B. Hospital (nurse) side

2. Hospital Login

Dropdown to pick the hospital (seeded list), 4-digit PIN field (hardcoded per hospital for the prototype)
Button: Continue

3. Bed Update Screen (the 10-second screen; the nurse's home)

Header: hospital name, "Last updated X min ago" badge (green/amber/red)
Large tiles, one per bed type: ICU, Ventilator, Oxygen, Cardiac, Burns, General
Each tile shows the available count, with a big + and − (one tap each)
Tap on the tile body toggles Available/Full (sets count to 0 or restores the last non-zero value)
Color: green if available, red if zero
Big sticky button: ✓ Everything is up to date (one tap refreshes the timestamp without changing counts, so nurses can keep data fresh in 1 second)
Button: Save Update (appears only after changes)
Optional ER load selector: Low / Medium / High (3 chips)
Bottom tab bar: Beds, Requests

4. Incoming Request Screen (full-screen alert, auto-opens with sound and vibration)

Patient needs (bed type chips), severity, ambulance ETA, patient summary
Large circular countdown (2:00)
Buttons: ACCEPT (hold bed) and REJECT, with a reject reason (No bed / Staff busy / Equipment down)
On timeout, a screen shows "Request expired"

5. Request History (nurse)

List of past requests with status (accepted, rejected, expired, arrived)
Button on an accepted hold: Patient Arrived (releases the hold and finalizes the bed count) and Release Hold
C. Dispatch (ambulance) side

6. Dispatch Home / New Emergency

Location: auto-detected via GPS, with a Use map pin override (tap on the map)
Bed type chips (multi-select): ICU, Ventilator, Oxygen, Cardiac, Burns
Severity: Critical / Serious / Stable
Optional patient note
Button: Find Hospitals
Shortcut: Recent requests

7. Ranked Results

Map at the top with the ambulance pin and hospital pins, plus a sortable list below
Each card shows:
Hospital name and rank number
Bed match badges (✓ ICU ✓ Ventilator, with ✗ for missing ones)
Travel time (min) and distance
Data age: "Updated 7 min ago" with a color code (green under 15, amber under 45, red beyond)
Load indicator (Low / Med / High)
Score (small, for transparency)
Per card: Select & Request button
Filter toggle: "Hide hospitals with stale data (>60 min)"
Info icon: Why this rank? (shows the score breakdown)

8. Confirm & Hold Status (the key demo screen)

Current hospital, status stepper: Requested → Accepted → Bed Held → En route → Arrived
Large 2:00 countdown
Live attempt log: "Hospital A rejected → Offered to Hospital B (waiting…)"
Auto-cascade on reject or timeout, with a toast "Offering to next best hospital"
Buttons: Cancel Request, Skip to next hospital (manual override), Call Hospital (dummy dialer)
When accepted: big green banner "BED HELD at Hospital X", plus Navigate (opens Google Maps via intent) and Mark Arrived
If all hospitals fail: "No hospital accepted" with Retry with broader criteria

9. Trip Complete

Summary: time to acceptance, hospital attempts, total time
Button: New Emergency
D. Demo and utility

10. Demo Controls (hidden)

Seed hospitals/beds, Reset all data, Age the data (make hospital X 50 min old), Auto-reject as hospital Y (so you can show a cascade with one phone if needed)
3. Architecture
┌───────────────┐        ┌────────────────────────┐        ┌───────────────┐
│ Nurse screens │◄──────►│   Firebase Firestore   │◄──────►│ Dispatch scr. │
│ (Flutter)     │ realtime│ hospitals / requests   │ realtime│ (Flutter)     │
└───────────────┘        └────────────────────────┘        └───────┬───────┘
                                                                   │
                                                  OSRM API (ETA)   │ GPS (geolocator)

Project structure (feature-first):

lib/
  main.dart
  core/        (theme, constants, utils: haversine, time_ago)
  models/      (hospital, bed_inventory, emergency_request, attempt)
  services/    (firestore_service, routing_service, location_service, ranking_service)
  providers/   (Riverpod providers)
  features/
    role_select/
    nurse/      (login, bed_update, incoming_request, history)
    dispatch/   (new_request, results, hold_status, complete)
    demo/

State management: Riverpod (StreamProvider fits Firestore snapshots well).

Firestore data model
hospitals/{id}
  name, lat, lng, phone, pin, loadLevel (low|med|high),
  beds: { icu:{available,total}, ventilator:{...}, oxygen:{...},
          cardiac:{...}, burns:{...}, general:{...} },
  lastUpdated (serverTimestamp)

requests/{id}
  patientLat, patientLng, needs[], severity, note,
  status: searching | offered | accepted | cancelled | failed | arrived
  rankedHospitalIds[], currentIndex, currentHospitalId,
  offerExpiresAt, createdAt
  attempts: [{hospitalId, result: pending|accepted|rejected|timeout, at}]
Ranking algorithm (in ranking_service.dart)
Hard filter: drop hospitals missing any required bed type (or show them as partial matches, ranked lower).
Score (lower is better), for example:
score = travelMin × 1.0 + stalenessPenalty + loadPenalty + partialMatchPenalty
stalenessPenalty: 0 if under 15 min old, then growing (e.g., +0.3 per extra minute, capped)
loadPenalty: Low 0, Med 5, High 12
Critical severity: weight travel time more heavily
Return the sorted list plus a per-hospital breakdown for the "Why this rank?" sheet.
Hold logic (use Firestore transactions)
On accept: transaction checks available > 0 for each needed bed type, decrements it, and sets the request to accepted. If a bed vanished meanwhile, it auto-fails and cascades.
On cancel / timeout / release: transaction increments the beds back.
On arrived: the hold becomes permanent (the bed stays decremented until the nurse updates).
4. Resources needed

Setup

Flutter SDK (stable), Android Studio with the Android SDK, USB debugging on your phone
A Firebase project, the Firebase CLI, and FlutterFire CLI (flutterfire configure)
Firestore in test mode for the hackathon (don't ship that way)

Packages
firebase_core, cloud_firestore, flutter_riverpod, go_router, geolocator, flutter_map, latlong2, http, intl, vibration, audioplayers (alert sound), url_launcher (navigate and call), shared_preferences (remember role and hospital)

Data

8 to 12 fake hospitals with real coordinates around your city (your demo area), with varied bed counts, load levels and data ages, ready to load from the seed button

Android permissions: INTERNET, ACCESS_FINE_LOCATION, VIBRATE

5. Tips for building with Antigravity
Feed it the spec in phases (models and services first, then nurse screens, then dispatch, then hold logic), not all at once.
Paste the Firestore data model and ranking formula exactly as written above so it doesn't invent its own.
Ask it to keep UI and logic separate (services and providers apart from widgets) so fixes stay easy.
Test on a real device after each phase.
6. Risks to handle
Demo internet failing: use a mobile hotspot, keep the OSRM fallback, and keep a screen recording as a backup.
Foreground-only alerts: the nurse app must be open to receive requests. State this as a known prototype limit and mention FCM push as the production step.
Clock skew: always use FieldValue.serverTimestamp() for lastUpdated and offer expiry, never device time.