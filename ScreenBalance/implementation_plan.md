# Implementation Plan

This document outlines the technical steps required to build out the new onboarding flow for ScreenBalance, specifically focusing on the Personal Awareness Quiz and the Intention Zone logic.

## Current Progress
- [x] Step 1: The Personal Awareness Quiz (Completed)
- [x] Step 2: The Intention Zone Card (Completed)
- [x] Step 3: App Configuration Section (Completed)
- [x] Step 4: OS Consent & Privacy (Completed)
- [x] Step 5: Screen Intervention Simulation (Completed)
- [x] Step 6: Post-Reset Validation (Completed)

## User Review Required
> [!IMPORTANT]
> Please review the technical scoring logic proposed for Step 1 below. Once approved, I will immediately begin modifying the code in `app.js` and `index.html`.

---

## Step 1: The 1-Minute Personal Awareness Quiz

**Goal:** Establish the user's "Intentional vs. Emotional" baseline by mapping their quiz answers to specific psychological profiles.

### Technical Details:
1. **Data Structure (`app.js`)**: 
   *   Replace the current `quizData` array with the exact 10 questions defined in the architecture document (e.g., "When you pick up your phone, how often do you know exactly why?").
   *   Assign "Profile Weights" to each multiple-choice option.
2. **Scoring Algorithm (`app.js`)**:
   *   Create a new function `calculateIntentionProfile(answersArray)`.
   *   As the user completes the quiz, the function will tally the points. For example, if the user consistently selects options indicating high stress during work tasks, the algorithm will heavily weight the `Task Avoidant` profile.
   *   The function will return the dominant profile object containing the Title, Icon, and Intervention Strategy.

---

## Step 2: The Intention Zone Card

**Goal:** Present the calculated Intention Profile to the user before they configure the app.

### Technical Details:
1. **Presentation Layer (`index.html`)**:
   *   Inject a brand new `<section id="step-2" class="view">` directly after the quiz.
   *   It will contain dynamic HTML placeholders: `<h1 id="profile-title">`, `<p id="profile-insight">`, and `<div id="profile-strategy">`.
2. **State Management (`app.js`)**:
   *   When the quiz completes, `app.js` will call `goToStep(2)`.
   *   The DOM elements in Step 2 will be dynamically hydrated with the results from the `calculateIntentionProfile` function.
3. **Styling (`style.css`)**:
   *   Create a new `.intention-card` CSS class to ensure the profile reveal looks highly premium, utilizing dark glassmorphism and subtle glowing accents.

## Verification Plan
*   **Manual Testing**: Run through the 10-question quiz selecting options biased towards evening usage.
*   **Validation**: Ensure the algorithm correctly calculates and displays the **🌙 Evening Escapist** profile on the newly built Step 2 screen.

---

## Step 3: App Configuration Section & Step 4: Consent

**Goal:** Allow users to set up tiered boundaries and grant OS-level permissions using destigmatized language.

### Technical Details:
1. **Reorder Flow (`index.html`)**:
   *   Swap the current Privacy and Settings screens. Step 3 will now be App Configuration, and Step 4 will be OS Consent, matching the architecture exactly.
2. **Configuration UI (`index.html` & `style.css`)**:
   *   Update the configuration screen to clearly define the three tiers: **Disengage (The Nudge)**, **Block (The Wall)**, and **Utility**.
3. **Consent UI**:
   *   Update the text on the Consent screen to emphasize "Nervous System Protection" rather than "screen tracking."

---

## Step 5: Screen Intervention

**Goal:** Simulate the 12 predictive scenarios and trigger the immersive "Reset UI" with the Glow Orb.

### Technical Details:
1. **Data Model (`app.js`)**:
   *   Ensure the `scenarios` array contains all 12 specific scenarios (e.g., "The Void", "Midnight Drift", "Phantom Check") and their respective somatic interventions (e.g., "The 4-7-8 Breath").
2. **Reset Overlay (`index.html` & `app.js`)**:
   *   When a simulation is triggered, load the specific somatic instruction into the Reset UI overlay.
   *   Implement the 60-second countdown timer.

---

## Step 6: Post-Reset Validation

**Goal:** Implement the branching logic for the visual mood check or motivational quote once the 60-second reset completes.

### Technical Details:
1. **Branching UI (`index.html`)**:
   *   Create a hidden "Validation Container" inside the Reset Overlay that appears when the timer hits zero.
   *   It will ask: "Would you like to validate your state?" with YES / NO buttons.
2. **Logic (`app.js`)**:
   *   **If YES**: Render a grid of 3 "Entropy Images" (Low, Medium, High). Selecting Low entropy closes the overlay. Selecting High entropy suggests a further break.
   *   **If NO**: Pull the `insight` or a motivational quote from the user's calculated Intention Profile (from Step 2) and display it before closing the overlay.
3. **Styling (`style.css`)**:
   *   Style the entropy image cards with hover effects and smooth transitions for the final branching flow.
