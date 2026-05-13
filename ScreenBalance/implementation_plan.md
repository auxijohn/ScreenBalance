# Implementation Plan - Phase 2: Proactive Intervention Simulation

Building out Step 3 of the Digital Wellbeing Prototype: The Nervous System Reset and the Visual Mood Check.

## User Review Required

> [!IMPORTANT]
> This plan covers the logic and UI for the Somatic Interventions and the Visual Mood Check. Please review the proposed flow below and approve so I can begin generating the required image assets and coding the logic.

## Current Progress
- [x] Step 1: The Personal Awareness Quiz (Completed with premium UI and dynamic ZooZoo background)
- [x] Step 2: App Configuration & Settings (Completed with emotional boundary background)
- [ ] Step 3: Proactive Intervention Simulation (Next up)

## Proposed Changes

### 1. Randomized Somatic Interventions
I will update the reset overlay logic in `app.js` and `index.html` to randomly select and display one of the following interventions when the user clicks "Open Reset":
- **The Sky Reset**: "Step outside or near a window, tilt your face up, and close your eyes."
- **The 5-Object Scan**: "Look away from the screen and find 5 objects in the room that are the same color."
- **The 4-7-8 Breath**: "Inhale for 4s, hold for 7s, exhale for 8s to calm your nervous system."

### 2. The Visual Mood Check
After the 60-second reset timer finishes, the screen will transition to a **Post-Reset Validation** phase.
I will generate 3 custom images representing different entropy states:
- **Zone A (Calm)**: Someone sipping tea by a window.
- **Zone B (Order)**: Someone neatly organizing a bookshelf.
- **Zone C (High-Input)**: A crowded marathon finish line.

The user will be prompted to select the image they resonate with most. 
- If A or B is selected -> Reset Complete, close overlay.
- If C is selected -> Suggest another quick 30s reset.

### 3. UI/UX Enhancements
- Add CSS animations for the image selection.
- Update the "Glow Orb" to pulse according to the selected breathing or reset pacing.

## Verification Plan
1. Trigger the notification.
2. Verify the reset overlay displays a randomized intervention.
3. Wait for the timer to complete.
4. Verify the 3 mood-check images appear.
5. Test selecting Zone A (closes) vs Zone C (extends reset).
