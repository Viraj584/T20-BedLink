---
name: Clinical Dispatch
colors:
  surface: '#f0fbff'
  surface-dim: '#c8dee4'
  surface-bright: '#f0fbff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#e2f7fe'
  surface-container: '#dcf2f8'
  surface-container-high: '#d6ecf3'
  surface-container-highest: '#d1e6ed'
  on-surface: '#0a1e23'
  on-surface-variant: '#3e494a'
  inverse-surface: '#203339'
  inverse-on-surface: '#dff4fb'
  outline: '#6e797a'
  outline-variant: '#bdc9ca'
  surface-tint: '#006972'
  primary: '#00626a'
  on-primary: '#ffffff'
  primary-container: '#0e7c86'
  on-primary-container: '#ddfbff'
  inverse-primary: '#7cd4df'
  secondary: '#266772'
  on-secondary: '#ffffff'
  secondary-container: '#afedfa'
  on-secondary-container: '#2d6d78'
  tertiary: '#4a5a5c'
  on-tertiary: '#ffffff'
  tertiary-container: '#627375'
  on-tertiary-container: '#e6f8fa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#98f0fb'
  primary-fixed-dim: '#7cd4df'
  on-primary-fixed: '#001f23'
  on-primary-fixed-variant: '#004f56'
  secondary-fixed: '#afedfa'
  secondary-fixed-dim: '#93d0dd'
  on-secondary-fixed: '#001f25'
  on-secondary-fixed-variant: '#004e59'
  tertiary-fixed: '#d4e6e8'
  tertiary-fixed-dim: '#b8cacc'
  on-tertiary-fixed: '#0e1e20'
  on-tertiary-fixed-variant: '#394a4b'
  background: '#f0fbff'
  on-background: '#0a1e23'
  surface-variant: '#d1e6ed'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 22px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered specifically for emergency medical services, rapid hospital bed allocation, and inter-facility coordination. Built for ambulance paramedics en route and triage charge nurses managing ward surges, the interface prioritizes extreme clarity, cognitive ease under high stress, and operational speed. 

The aesthetic is Modern Clinical Material 3: structured, crisp, highly legible, and reassuringly deliberate. It eschews decorative fluff, gradients, and stock photography in favor of glanceable metrics, unmistakable status signifiers, and ergonomic tap safety. Visual hierarchy must calm chaotic environments while conveying urgency when triage status shifts. Every interaction must be executable one-handed in moving vehicles or while wearing nitrile gloves under direct sunlight or harsh ambulance cabin fluorescent lights.

## Colors

The palette balances authoritative medical trust with rapid-scan functional signaling:

- **Core Tones**:
  - Primary Clinical Teal (`#0E7C86`): Primary call-to-actions, prominent brand anchors, selected state fills.
  - Deep Teal (`#0A5560`): Pressed button states, high-contrast borders, critical operational highlights.
  - Mist Teal (`#E0F2F4`): Tinted badges, non-critical active indicator backgrounds, secondary chip fills.
  - Canvas Background (`#F5F9FA`): Glare-reducing, cool clinical backdrop that preserves high contrast without harsh pure white glare.
  - Surface Card White (`#FFFFFF`): Elevated content blocks and structural cards.
  - Text Primary (`#12262B`): Near-black deep slate exceeding AAA contrast ratios on card surfaces.
  - Text Secondary (`#55696E`): Metadata, timestamps, and descriptive subtitles maintaining strict AA contrast.
  - Structural Dividers (`#D5E2E5`): Clean, sharp delineation for list items and data grids.

- **Strict Status Semantics**:
  Status tokens are strictly reserved for operational bed availability and triage urgency—never for branding or decorative accents:
  - **Available / Clear**: Emerald (`#1E9E5A`), Tint Fill (`#E3F5EB`).
  - **Limited / Divert Warning**: Amber (`#E8A317`), Tint Fill (`#FFF4D9`), Text on Tint (`#7A5200`).
  - **Full / Critical Divert**: Crimson (`#D32F2F`), Tint Fill (`#FDE7E7`), Text on Tint (`#D32F2F`).

Every semantic status display must combine color, a distinct text label, and an associated universal iconography glyph to ensure zero misinterpretation.

## Typography

The type scale strictly enforces legibility rules:
- **No text below 14sp/px exists in the design system**, and critical metadata never falls below 16sp.
- **Inter** provides neutral, systematic letterforms with high x-height and open apertures, ideal for quick scanning in motion.
- **Metric Displays (`display-lg`, `display-md`)**: Reserved for bed count numbers (e.g., "04", "12"), ETA minutes, and critical triage capacities. These are rendered in bold weights with tabular figures enabled (`tnum`) to prevent jumping layouts during live syncs.
- **Headings**: Distinct, bold, and tightly tracked to allow high-density screen headers without text truncations.

## Layout & Spacing

Designed primarily for standard Android portrait viewports (360x800 dp):
- **Base Grid**: 4-column fluid layout with `16dp` outer margins and `16dp` gutters.
- **Vertical Spacing Rhythm**: Multiples of 8dp. Dense spacing inside cards uses 8dp or 12dp to maintain glanceability, while major content regions separate by 16dp or 24dp.
- **Touch Ergonomics**: All interactive elements are anchored within the thumb-zone bottom half of the screen wherever possible. Fixed bottom action bars provide steady targets during transit.

## Elevation & Depth

Depth is handled through crisp structural surfaces rather than deep theatrical shadows, avoiding screen dirt and maximizing bright-sunlight contrast:

- **Surface Level 0 (Background)**: `#F5F9FA`, completely flat.
- **Surface Level 1 (Cards & Modules)**: Solid `#FFFFFF` with a single subtle ambient drop: `0px 2px 6px rgba(18, 38, 43, 0.06)` combined with a 1dp crisp structural border using `#D5E2E5`.
- **Surface Level 2 (Floating Action Banners & Bottom Sheets)**: `#FFFFFF` resting at `0px 4px 16px rgba(18, 38, 43, 0.12)` with a top edge border of `#D5E2E5`.
- **States**: Pressed cards drop their subtle shadow and transition border color to `#0E7C86`.

## Shapes

The design system uses deliberate, disciplined corner radiuses to reflect Material 3 while preserving structural urgency:
- **Cards & Data Modules**: Exactly `16dp` corner radius.
- **Primary & Secondary Buttons**: `14dp` corner radius, creating solid, tactile landing zones.
- **Status Badges & Quick Chips**: `8dp` to `12dp` roundedness, ensuring clear distinction from primary action shapes.
- **Bottom Drawers**: `24dp` rounded top-left and top-right corners.

## Components

### Buttons
- **Primary Action (e.g., 'Request Bed Allocation', 'Confirm Handover')**:
  - Height: `64dp` to `72dp`.
  - Background: Primary Clinical Teal (`#0E7C86`), active/pressed Deep Teal (`#0A5560`).
  - Text: `16sp` Bold White (`#FFFFFF`).
  - Icons: Material Symbol (24dp) aligned leading or trailing with 12dp spacing.
  - Corner Radius: `14dp`.
- **Secondary Action (e.g., 'Call Charge Nurse', 'Reroute')**:
  - Height: `56dp`.
  - Border: 2dp solid Deep Teal (`#0A5560`), background transparent or White (`#FFFFFF`).
  - Text: `16sp` Bold Deep Teal (`#0A5560`).

### Cards & Bed Capacity Tiles
- Card background `#FFFFFF`, rounded `16dp`, border 1dp `#D5E2E5`.
- Inner layout features:
  - Top row: Department/Facility title (`title-lg`) paired with an unambiguous status chip.
  - Center/Primary metric: Hero bed count in `display-md` or `display-lg` (`40sp-56sp` Bold) paired with contextual unit label (e.g., "RESUS BEDS FREE").
  - Bottom row: ETA distance, nurse contact icon, and latest timestamp (`label-md`).

### Status Badges & Chips
- Minimum height `36dp`, horizontal padding `12dp`, rounded `8dp`.
- Always contains a Material icon (18dp) + Uppercase Label (e.g., `[✓ AVAILABLE]`, `[! LIMITED]`, `[✕ DIVERT]`).
- Visual variants:
  - Available: Fill `#E3F5EB`, Border `#1E9E5A`, Text `#1E9E5A`.
  - Divert Warning: Fill `#FFF4D9`, Border `#E8A317`, Text `#7A5200`.
  - Divert / Full: Fill `#FDE7E7`, Border `#D32F2F`, Text `#D32F2F`.

### Form Fields & Triage Inputs
- Field Height: `56dp` minimum.
- Border: 2dp `#D5E2E5`, active focus `#0E7C86`.
- Typography: `16sp` regular input, `14sp` permanent floating label above.
- Numeric Counter Steppers: 56x56dp minimum touch target controls for adjusting patient counts quickly.

### Selection Controls
- Checkboxes & Radios: `28dp` bounding box with `56dp` minimum invisible touch target padding.
- Selected state uses Primary Clinical Teal (`#0E7C86`) with high-contrast inner glyphs.