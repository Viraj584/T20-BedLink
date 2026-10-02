# NOTE FOR THE AI AGENT: How to use the UI screen PNGs

Read this file completely BEFORE looking at the images or writing any code.

## 1. What these PNGs are

The PNG files in this folder are **visual design references** for **BedLink**, a Flutter (Android) hospital bed-availability app for ambulance crews and hospital nurses. They were generated in Google Stitch.

- They are **references, not assets.** Never import them into the app, never use them as backgrounds, and never try to convert them pixel by pixel.
- **Rebuild every screen with native Flutter Material 3 widgets** (Scaffold, AppBar, Card, FilledButton, OutlinedButton, FilterChip, SegmentedButton, NavigationBar, etc.).
- **Match** layout, visual hierarchy, spacing rhythm, color roles, and component sizes.
- **Do not match** exact pixels, exact fonts, or placeholder text and numbers. Names such as "Sunrise Heart & Critical Care" and counts such as "ICU 3" are sample data. Real values come from Firestore.
- If an image and the written spec in this note disagree, **the written spec wins.**

## 2. Image-to-screen mapping

> Update the filenames below to match the actual files in this folder.

| PNG file | Screen | Flutter route / file | Role |
|---|---|---|---|
| `01_nurse_bed_update.png` | Nurse bed-update screen (home) | `features/nurse/bed_update_screen.dart` | Nurse |
| `02_dispatch_form.png` | New Emergency form | `features/dispatch/new_request_screen.dart` | Ambulance |
| `03_ranked_results.png` | Ranked hospital results | `features/dispatch/results_screen.dart` | Ambulance |
| `04_hold_status.png` | Confirm & Hold status (waiting, accepted, all-failed states) | `features/dispatch/hold_status_screen.dart` | Ambulance |
| `05_incoming_request.png` | Incoming request alert (dark theme, plus reject sheet and expired state) | `features/nurse/incoming_request_screen.dart` | Nurse |

If a PNG contains several states of one screen (for example the waiting and accepted states of the hold screen), build them as **one screen widget that renders different states**, driven by the request status from Firestore. Do not build separate screens.

Screens with **no PNG** (splash/role select, hospital login, request history, trip complete, demo controls) should be built with plain Material 3 in the same visual language: same theme, same card style, same button sizes.

## 3. Design tokens (define ONCE in `lib/core/theme.dart`)

Never hardcode colors or sizes inside widgets. Create `AppColors`, `AppTheme.light`, and `AppTheme.urgentDark` (the last one is used only for the incoming request screen).

### Colors

| Token | Hex | Use |
|---|---|---|
| `primary` | `#0E7C86` | Main buttons, selected states, brand |
| `primaryDark` | `#0A5560` | App bars, pressed state |
| `primaryTint` | `#E0F2F4` | Selected chips, highlights, summary strips |
| `background` | `#F5F9FA` | Scaffold background |
| `surface` | `#FFFFFF` | Cards |
| `textPrimary` | `#12262B` | Main text |
| `textSecondary` | `#55696E` | Secondary text |
| `divider` | `#D5E2E5` | Borders and dividers |
| `success` | `#1E9E5A` (tint `#E3F5EB`) | Available, fresh data, accepted, low load |
| `warning` | `#E8A317` (tint `#FFF4D9`, text `#7A5200`) | Low stock, aging data, medium load |
| `danger` | `#D32F2F` (tint `#FDE7E7`) | Full, stale data, reject, critical, high load |
| `info` | `#2B7BD6` | Links, ambulance location dot |

**Urgent dark theme (incoming request screen only):**
background `#07262B`, card `#0F3A41`, text white, red `#FF5252`, green `#2ECC71`, amber `#FFC107`.

**Rule:** green, amber, and red are **status colors only**. Never use them for decoration.

### Typography and sizing

- Font: **Inter** (use the `google_fonts` package, fall back to Roboto).
- Body text is at least 16sp. Headings are bold. Key numbers (bed counts, countdown) are 40-64sp bold.
- Minimum tap target is **56dp**. Primary action buttons are **64-72dp** tall. Accept/Reject buttons are 80dp.
- Corner radius: cards 16dp, buttons and chips 12-16dp.
- The design viewport is **360x800 dp**, portrait. Use flexible layouts (no fixed pixel widths) so it also works on small, cheap phones. Never overflow. Use `SingleChildScrollView` or slivers where the content can grow.

## 4. Business rules the UI must follow (these may not be obvious from the images)

### Data freshness badge (shown on every hospital listing)
Computed from `lastUpdated` (Firestore server timestamp) and refreshed every 30 seconds.
- Under 15 min: **green**, label "Updated X min ago"
- 15 to 45 min: **amber**
- Over 45 min: **red**, with a warning icon and "Stale data"
- Implement this as ONE reusable widget, `FreshnessBadge(DateTime lastUpdated)`, and use it everywhere. Put the thresholds in `core/constants.dart`.

### Bed tile state (nurse screen)
- Count > low threshold: green border and tint
- Count between 1 and the low threshold (default 1): amber border and a "LOW" pill
- Count = 0: red border and tint, a "FULL" pill, and a disabled "−" button
- Tapping the tile body toggles Available/Full. The + and − buttons change the count by 1.
- The "Everything is up to date" button only refreshes `lastUpdated` and does not change counts.
- "Save Update" is disabled until something has changed.

### Hospital card (results screen)
- Rank 1 gets the teal border and a "BEST MATCH" pill.
- Matching beds show as green badges ("✓ ICU 3"). Missing beds show as red badges ("✗ Cardiac 0"). Hospitals with a partial match show a "Partial match" label.
- Stale hospitals (over 60 min) appear faded and can be hidden by the toggle.
- "Why this rank?" opens a bottom sheet with the score breakdown (travel, staleness, load, partial penalties).

### Countdown
- Both the nurse and the ambulance apps show the 2-minute countdown computed from the Firestore field `offerExpiresAt`. Do not use a local 120-second timer that restarts when the screen opens.
- Use a `CircularProgressIndicator` or `CustomPainter` ring with a large time label in the middle.

### Never rely on color alone
Always pair a status color with an icon or text label (check, warning, clock, X).

## 5. Behavior and logic are NOT in the images

The images show static UI only. Behavior comes from the project spec (`PROJECT_SPEC.md` or the main prompt):
Firestore real-time listeners, the ranking service, hold transactions, auto-cascade on reject or timeout, GPS, and OSRM routing.

When you wire a screen to data:
1. Use the layout from the PNG.
2. Replace every sample value with live data from Riverpod providers.
3. Keep UI widgets free of business logic. Services and providers do the work.

## 6. How to work with these images (process)

1. Read this note, then open the PNGs one at a time.
2. Create `core/theme.dart` and the shared widgets FIRST: `FreshnessBadge`, `BedTile`, `StatusPill`, `CountdownRing`, `HospitalCard`, `PrimaryActionButton`.
3. Build the screens in this order: nurse bed update, dispatch form, results, hold status, incoming request.
4. After each screen, compare it against its PNG and fix big differences in layout, hierarchy, spacing, and color. Do not chase tiny pixel differences.
5. Stop and ask before changing the color palette, the screen list, or the navigation structure.

## 7. Do NOT

- Do not embed the PNGs in the app or add them to `pubspec.yaml` assets.
- Do not hardcode hex colors or font sizes inside screen widgets.
- Do not use stock photos or decorative illustrations.
- Do not use red, amber, or green for anything except status.
- Do not shrink tap targets or text to fit more on screen. Scroll instead.
- Do not add screens or features that are not in the spec.
- Do not use sample hospital names or numbers from the images in production code. Seed data lives in the demo seed function only.

## 8. Definition of done for the UI

- Each built screen clearly resembles its PNG (same structure, hierarchy, and colors) on a 360x800 phone.
- Every hospital listing shows how many minutes old its data is.
- The nurse can update a bed type with one tap.
- All colors come from the theme, and the app has no overflow errors.