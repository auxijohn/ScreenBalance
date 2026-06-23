# ScreenBalance: Feature Breakdown & Blueprint

## 1. Core Functionality Overview
ScreenBalance is a mindful digital wellbeing application designed to move beyond simple app blocking. Instead of rigid restrictions, it uses behavioral telemetry to detect subconscious, compulsive phone usage and gently interrupts these patterns with "Somatic Resets" (physical grounding exercises).

### Key Features
- **Mindful Telemetry Engine**: Analyzes phone usage in real-time (app opens, unlocks, scrolling speed, typing patterns) without sending data off-device.
- **Somatic Interventions**: When a compulsive pattern is detected, an un-dismissable overlay requires the user to complete a 30-60 second physical grounding exercise before continuing.
- **Digital Mindfulness Score**: A dynamic score (0-100) that reflects real-time digital presence, adjusting based on unlock counts and triggered interventions. The UI dynamically titles the user (e.g., "Zen Master", "Phantom Checker") based on recent behavior.
- **Identity & Boundaries**: Configurable Target Bedtimes, Focus Hours, Morning Buffers, and categorized app caps.

---

## 2. Intervention Details (The 13+ Triggers)

The `InterventionEngine` actively monitors behavior and triggers specific somatic resets.

1. **Dopamine Loop**
   - **Trigger**: Rapid switching between 4+ different apps within a short timeframe (chains of <10s between switches).
   - **Somatic Reset**: *The Sky Reset* - Step outside or look near a window, tilt face toward the sky, close eyes for 60s.

2. **The Void**
   - **Trigger**: Continuous, passive scrolling in a single app for over 20 minutes.
   - **Somatic Reset**: *The 5-Object Scan* - Look away and find 5 objects in the room of the same color.

3. **Reactive Mode**
   - **Trigger**: Opening 5+ apps within 30 minutes *immediately* (within 2 mins) after receiving a notification from them.
   - **Somatic Reset**: *The Horizon View* - Stand up and look at the furthest point out a window for 60s.

4. **Social Spiral**
   - **Trigger**: Rapid content/profile changing in Social apps (8+ changes in 2 mins).
   - **Somatic Reset**: *The Heart-Hand Grounding* - One hand on heart, one on belly. Feel breath for 30s.

5. **Ghosting Anxiety**
   - **Trigger**: High ratio of deleted characters to typed characters (e.g., typing 10+ chars and deleting 80%+ of them) in non-system apps.
   - **Somatic Reset**: *The 4-7-8 Breath* - Inhale 4s, hold 7s, exhale 8s.

6. **Midnight Drift**
   - **Trigger**: Opening non-utility apps past the configured Target Bedtime.
   - **Somatic Reset**: *Tactile Grounding* - Touch 3 different textures.

7. **Last Scroll Loop**
   - **Trigger**: Unlocking the phone 3+ times within 2 minutes after bedtime.
   - **Somatic Reset**: *The Darkroom Reset* - Put phone in a drawer, turn off lights, sit in silence for 60s.

8. **Work-Life Blur**
   - **Trigger**: Opening "Productivity" apps outside of configured Focus Hours.
   - **Somatic Reset**: *The Physical Boundary* - Walk to a different room or do a full-body stretch.

9. **Phantom Check**
   - **Trigger**: Unlocking the phone 10+ times within 15 minutes without any notifications.
   - **Somatic Reset**: *Somatic Release* - Roll shoulders back 5 times and take one deep breath.

10. **Novelty Hunt**
    - **Trigger**: Opening "Entertainment" apps 5+ times within 10 minutes.
    - **Somatic Reset**: *The Sensory Swap* - Notice the weight/temperature of a physical object for 60s.

11. **Info Overload**
    - **Trigger**: Opening "Social" apps 5+ times within 15 minutes.
    - **Somatic Reset**: *The Cold Reset* - Splash cold water on face or hold a cold object for 30s.

12. **Interaction Spike**
    - **Trigger**: Accelerated scrolling detected (e.g., older slow scrolls followed by 2x newer rapid bursts of scroll events).
    - **Somatic Reset**: *The Weighted Reset* - Press feet firmly into the floor for 60s.

13. **Daily Cap Limit**
    - **Trigger**: Exceeding the daily duration allowance for a specific category (e.g., 15 mins for Social, 30 mins for Entertainment).
    - **Somatic Reset**: *The Horizon View*.

14. **Morning Mindfulness Buffer**
    - **Trigger**: Opening Social apps within the configured buffer minutes after the very first morning unlock (between 5 AM - 11 AM).
    - **Somatic Reset**: *Somatic Release*.

15. **Staged Digital Sunset**
    - **T-90 mins to Bedtime**: Emotional Distraction apps blocked.
    - **T-60 mins to Bedtime**: Social/Entertainment apps blocked.
    - **T-30 mins to Bedtime**: Only Utility apps allowed.
    - **T-0 (Bedtime)**: Total lock down (except Utility).

---

## 3. How to Test Manually (Using a Real Phone)

To test on a physical Android device without having to wait hours for organic triggers, use the built-in **Debug Simulation FAB** (Floating Action Button).

### Setup
1. Build and install the app on a physical Android device (`flutter run --release` or via your IDE).
2. Complete the onboarding flow (either via the 7-Day path or the Instant Quiz).
3. Grant **Usage Access** and **Accessibility Services** when prompted.
4. On the Home screen, ensure the "Mindful Telemetry Active" card shows a green active state.

### Using the Debug Simulator
1. Tap the **Bug Icon (FAB)** located at the bottom right of the Home screen.
2. A bottom sheet titled **Simulate Interventions** will appear.
3. Tap any of the 13+ triggers (e.g., "Trigger: Dopamine Loop").
4. The system will immediately broadcast the event and display the un-dismissable full-screen Intervention Overlay.
5. Wait for the somatic reset timer to complete (usually 30-60s) to dismiss the overlay.

### Organic Testing Examples
- **Phantom Check**: Lock and unlock your device 10 times consecutively within 15 minutes without interacting with notifications.
- **Ghosting Anxiety**: Open a messaging app (e.g., WhatsApp). Type a long sentence (>10 characters), then immediately hold the backspace key to delete almost all of it.
- **Daily Cap Limit**: Go to Boundaries -> Balanced Applications. The system automatically categorizes popular apps (e.g., WhatsApp -> Social). Keep a categorized app open in the foreground for its respective limit (15m for Social).
- **Interaction Spike**: Open an app that supports scrolling (e.g., Settings or Chrome). Scroll slowly twice, then immediately swipe to scroll very rapidly twice.

---

## 4. Technical Details

### Architecture & Data Flow
1. **NativeTracker (Accessibility & Usage Stats)**
   - Operates a native Android AccessibilityService (`TrackerService.kt`) which listens to `TYPE_WINDOW_STATE_CHANGED`, `TYPE_VIEW_SCROLLED`, and `TYPE_VIEW_TEXT_CHANGED`.
   - Passes events to Flutter via a `MethodChannel` (`com.example.screen_balance/tracker`).
2. **InterventionEngine (Core Logic)**
   - Subscribes to the native event stream (`NativeTracker.appOpenStream`).
   - Maintains state arrays (e.g., `_recentUnlocks`, `_recentAppOpens`) and evaluates them against the behavioral rules on every incoming event.
   - Tracks app usage durations (`_appUsageToday`) by diffing timestamps between `DEVICE_UNLOCK`/app open and `DEVICE_LOCK`/app background.
3. **Event Bus & UI Overlays**
   - When a rule is met, `_triggerIntervention()` adds data to the `interventionStream`.
   - The root widget (`OverlayManager`) listens to `interventionStream` and pushes a full-screen `InterventionOverlay` on top of the entire app stack.
   - The overlay blocks interaction until `completeSomaticReset()` is called.

### Data Privacy
- All telemetry data (`_recentScrolls`, `_recentTextChanges`, `behavioralHistory`) is kept entirely **in-memory** or in local storage (`shared_preferences`).
- No network requests are made with behavioral data. The app is fully offline.
- Text change events do not store the actual strings typed, only the *count* of added and deleted characters to calculate hesitation ratios.
