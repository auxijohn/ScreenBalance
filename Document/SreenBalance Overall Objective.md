# ScreenBalance: User Journey & Flow Architecture

This document outlines the step-by-step user journey for ScreenBalance, transitioning users from standard screen time tracking to proactive, predictive psychological wellbeing using a modular, event-driven architecture.

---

## Step 1: Identity & The 1-Minute Personal Awareness Quiz
**Details:**
The onboarding process begins with user profile creation and a quiz designed to establish the user's "Intentional vs. Emotional" baseline. We map their goals to psychological metrics to identify the root cause of their digital overload.

| # | Question | Psychological Connection | Intention Zone Target |
| :--- | :--- | :--- | :--- |
| 1 | "When you pick up your phone, how often do you know exactly why you unlocked it?" | Conscious vs. Unconscious Intent | Baseline Calibration |
| 2 | "How soon after waking up do you usually check social media, news, or emails?" | Morning Cortisol Spike / Reactive Start | 🌅 **The Morning Scroller** |
| 3 | "Do you find yourself endlessly scrolling in bed, knowing you should be sleeping?" | Revenge Bedtime Procrastination | 🌙 **The Evening Escapist** |
| 4 | "Around 2-3 PM, do you reach for short-form video to fight off a drop in energy?" | Circadian Energy Crash & Dopamine Relief | ☕ **The Midday Slumper** |
| 5 | "If you face a difficult or boring task, does your app-switching suddenly increase?" | Avoidance Coping Mechanism | 🏃 **The Task Avoidant** |
| 6 | "How often do you unlock your phone in an elevator or line, purely out of muscle memory?" | Unconscious Habit Loop & Muscle Memory | 👻 **The Phantom Checker** |
| 7 | "When a notification pops up, how hard is it for you to ignore it and keep working?" | Boundary Setting & Stimulus Reactivity | 🔔 **The Notification Reactive** |
| 8 | "Do you ever read negative news or endless feeds until you feel tense or 'zoned out'?" | Anxiety-Seeking & Trance State | 🌀 **The Doomscroller** |
| 9 | "After using specific apps, do you frequently feel drained, envious, or 'less than'?" | Emotional Dysregulation & FOMO | ⚖️ **The Social Comparer** |
| 10| "If we could help you reclaim one thing, would you choose 'More Focus', 'Better Sleep', or 'Less Anxiety'?" | Primary Motivational Goal | Overall Intervention Routing |

---

## Step 2: The Intention Zone Card
**Details:**
At the end of the quiz, the app synthesizes the data and attaches the primary **Intention Zone Profile Card** to the user's profile.

### Category 1: Time-Bound Profiles
*   🌙 **The Evening Escapist:** Highly intentional during the day, but uses the phone to "numb out" after 8 PM.
*   🌅 **The Morning Scroller:** Wakes up and immediately checks feeds, spiking cortisol.
*   ☕ **The Midday Slumper:** Experiences a 2-3 PM energy crash and uses short-form video for dopamine.

### Category 2: Emotion & Trigger-Bound Profiles
*   🏃 **The Task Avoidant:** App-switching correlates with facing stressful tasks.
*   👻 **The Phantom Checker:** Unlocks constantly out of muscle memory.
*   🔔 **The Notification Reactive:** Derails from a single ping.
*   🌀 **The Doomscroller:** Endlessly scrolls to numb anxiety, entering a "dissociative state."
*   ⚖️ **The Social Comparer:** Usage on specific platforms triggers FOMO.

---

## Step 3: App Configuration & Contextual Boundaries
**Details:**
Based on the Intention Card, the user sets up their specific boundaries using a tiered categorization and schedule system.

**Smart App Categorization:**
*   **Utility (Exempt):** Essential apps like Banking, Maps, or Calculator.
*   **Social (Disengage):** For useful but slippery apps (e.g., WhatsApp). Uses gentle prompts or grayscale filters.
*   **Emotional Distraction (Block):** Pure distraction (e.g., Facebook, TikTok). Requires a full 1-minute somatic reset to "unlock."
*   **Productivity:** Monitor only (e.g., Slack).

**Contextual Schedules (Overrides):**
*   **Target Bedtime:** Sets the anchor for the Staged Digital Sunset.
*   **Focus Mode Hours:** Stricter tracking during deep work.
*   **Morning Buffer:** 30-min block on social apps after waking.

---

## Step 4: Consent to the User
**Details:**
ScreenBalance requires deep system access (Screen Time API / Accessibility Services) to detect "frantic switching." This step frames consent around **nervous system protection**.

*   **Destigmatized Language:** *"We need permission to detect when your screen activity becomes frantic. We don't read your messages; we only monitor the pace of your app switching to protect your focus and calm."*
*   **Clear Privacy Promise:** Emphasizes that all behavioral analysis happens locally on the device, ensuring absolute privacy.

---

## Step 5: Screen Intervention & Scenario Notification
**Details:**
When the background engine detects a threshold event, the logic engine evaluates it against contextual overrides (like Digital Sunset) and routes a specific, compassionate intervention.

| Scenario | Behavioral Trigger | Suggested Notification Message | Somatic/CBT Intervention |
| :--- | :--- | :--- | :--- |
| **FOCUS THEME** | | | |
| **Dopamine Loop** | 3+ apps in <60 seconds. | "You're moving fast between apps. This rapid switching can fragment your focus. Ready for a quick reset?" | **The Sky Reset:** Step outside (or near a window), tilt your face toward the sky, and close your eyes for 60 seconds. |
| **The Void** | 20+ mins of continuous scrolling. | "You've been scrolling for a while. This can create a 'mental fog.' Let's pull your awareness back to the room." | **The 5-Object Scan:** Look away from the screen and find 5 objects in the room that are the same color. |
| **Reactive Mode** | 5+ notification-driven opens in 10 mins. | "You're reacting to pings as they come. This high-alert mode increases cognitive load. Want to take back control?" | **The Horizon View:** Stand up and look at the furthest point you can see out a window for 60 seconds to reset your visual system. |
| **SOCIAL THEME** | | | |
| **Social Spiral** | 10+ rapid profile views on Social apps. | "You're looking at a lot of social profiles. This can sometimes trigger subconscious comparison stress. Shall we ground ourselves?" | **The Heart-Hand Grounding:** Place one hand on your heart and one on your belly. Feel your own breath for 30 seconds. |
| **Ghosting Anxiety**| Typing >100 chars, deleting all, and closing. | "It looks like you're hesitating on a message. Overthinking can build social tension. Let's take a breath before deciding." | **The 4-7-8 Breath:** Inhale for 4s, hold for 7s, exhale for 8s to calm the nervous system. |
| **Upward Comparison Risk**| Prolonged passive scrolling on Image/Video Social apps. | "Notice how this content is making you feel. Can we reframe this comparison into curiosity?" | **Social Savoring Reframe:** A micro-prompt exercise to actively shift from FOMO to positive appreciation. |
| **REST THEME** | | | |
| **Midnight Drift** | Usage 1 hour past Sleep Goal. | "It's past your quiet hour. Late-night light can trick your brain into staying 'alert' when it needs rest." | **Tactile Grounding:** Put your phone down and touch 3 different textures (e.g., a cold table, a soft pillow, your own palms). |
| **Last Scroll Loop**| 3+ Lock/Unlock cycles in <2 mins at night. | "You're trying to put the phone away, but the pull is strong. This 'last scroll' loop delays deep rest." | **The Darkroom Reset:** Put the phone in a drawer, turn off the lights, and sit in silence for 60 seconds. |
| **Work-Life Blur** | Opening Slack/Email during 'Digital Sunset'. | "Checking work apps now can prevent your brain from fully decompressing. Is this urgent, or can it wait for 'Future You'?" | **The Physical Boundary:** Walk to a different room or stand up and do a full-body stretch to mark the end of 'work mode.' |
| **NOVELTY THEME** | | | |
| **Phantom Check** | 10+ unlocks in 15 mins (no pings). | "You've checked in 10 times with no alerts. This 'phantom checking' keeps your mind on high-alert." | **Somatic Release:** Roll your shoulders back 5 times and take one slow, deep breath with your eyes closed. |
| **Novelty Hunt** | 5+ Shopping/Store apps in 10 mins. | "You're searching for something new. This 'novelty hunt' can be a sign of underlying restlessness." | **The Sensory Swap:** Find a physical object near you (a pen, a stone, a glass) and notice its weight and temperature for 60 seconds. |
| **STRESS THEME** | | | |
| **Info Overload** | 5+ news/high-intensity apps in 15 mins. | "You're processing a lot of high-intensity info. This can trigger a 'threat detection' state. Let's find some calm." | **The Cold Reset:** Splash some cold water on your face or hold a cold object for 30 seconds to calm the Vagus nerve. |
| **Interaction Spike**| Rapid scrolling speed (px/sec) doubling. | "Your scrolling speed has increased. This often happens when the nervous system is revving up. Ready to slow down?" | **The Weighted Reset:** Sit down and press your feet firmly into the floor, feeling the support of the ground for 60 seconds. |

**Contextual Schedules Execution:**
*   **Staged Digital Sunset:** At T-90 min from bedtime, Emotional Distraction apps are blocked. At T-60, high-intensity apps block and social apps turn grayscale. At T-30, dark mode enforces. At T-0, screen locks.
*   **Morning Buffer:** First 30 mins after waking routes users to an intention micro-prompt instead of social apps.

**The "Nervous System Reset" UI:**
Clicking the notification takes the user to an immersive, dark-mode screen featuring a pulsating "Glow Orb" with haptic feedback to guide their breathing.

---

## Step 6: Post-Reset Validation
**Details:**
Once the 60-second somatic intervention is complete, the app performs a visual mood check.
*   **The Visual Mood Check:** The user is shown three dynamic images of varying "Entropy Levels". 
    *   *Low Entropy Choice:* User is seeking stillness. (Reset Complete).
    *   *High Entropy Choice:* User is still seeking high-input. (Suggest a further break).

---

## Step 7: Insights & Circadian Dashboards
**Details:**
Users can view read-only dashboards aggregating their behavioral history to foster self-awareness.
*   **Circadian Pattern Dashboard:** Shows average sleep/wake times, Last Scroll frequency, and weekly sleep quality trends.
*   **Zone Balance:** Displays how often they are in Flow, Shallow, or Frantic modes.

---

## Step 8: Adaptive Evolution & Accountability
**Details:**
ScreenBalance adapts over time and leverages community support.
*   **Adaptive Behavior Engine:** Every 7 days, the app reviews behavioral history and dynamically updates the user's Intention Card (e.g., shifting from Morning Scroller to Doomscroller) if habits change, alerting both the user and their partner.
*   **External Notification Dispatcher:** Real-time intervention triggers and weekly profile updates are instantly mirrored to a configured accountability partner via Push/SMS to support habit change.
