# ScreenBalance — Research-Backed Feature Breakdown
### *Predictive Psychological Wellbeing for the Digital Age*

> **Design Philosophy**: Every feature is grounded in the paradigm shift from *"how long"* to *"how you feel"* — using behavioral micro-signals to intervene before burnout, not after.

---

## 🧠 The Problem This App Solves (Research Context)

The digital health crisis is measurable and well-documented:

- A 2024 meta-analysis of **1.1 million individuals** found that *problematic* smartphone use (not total screen time) robustly predicts anxiety, depression, and sleep disruption. [(Psychology Today, 2024)](https://www.psychologytoday.com)
- A 2026 *Computers in Human Behavior* study found a **single notification disrupts concentration for ~7 seconds**; users receiving 100–150 alerts/day face permanent cognitive fragmentation. [(PsyPost, 2026)](https://www.psypost.org)
- Doomscrolling is linked to **existential anxiety** in 800-adult study (*Computers in Human Behavior Reports*, 2024). [(Harvard Health, 2024)](https://www.health.harvard.edu)
- WHO's 2024 European Report documented a **"sharp rise" in problematic social media use among adolescents** with negative impact on social and mental wellbeing. [(WHO Europe, 2024)](https://www.who.int/europe)
- The brain's **"Popcorn Brain" effect**: rapid, continuous scrolling rewires neural pathways to expect constant stimulation, making slower, real-world engagement feel unbearable. [(NIH, 2024)](https://www.nih.gov)

---

## 🗂️ FEATURE PILLARS

---

## PILLAR 1 — Intelligent Onboarding & Intention Mapping

> *"The goal is not to restrict. It's to help you understand yourself."*

### 1.1 The Intention Baseline Quiz (10 Questions)
**What it is:** A conversational, psychology-mapped onboarding quiz that takes 60–90 seconds. Rather than asking time limits, it maps the user's *emotional relationship* with their phone.

**Why it works:** Research confirms that anxiety often *precedes* compulsive use as a coping mechanism. [(NIH, 2024 — Bidirectional Hypothesis)](https://pubmed.ncbi.nlm.nih.gov) Addressing root causes is more effective than hard limits.

**Questions & Mappings:**

| # | Question | What It Detects | Metric Powered |
|---|----------|-----------------|----------------|
| 1 | "How many unlocks per hour feels right to you?" | Intentionality baseline | Unlock frequency alert threshold |
| 2 | "When you switch apps rapidly, are you *working* or *bored*?" | Root cause of switching | Frantic score calibration |
| 3 | "Do you pick up your phone and forget why?" | Dissociation level | Phantom check detection |
| 4 | "Which app do you use to 'numb out'?" | Dopamine escape source | Block/Disengage priority list |
| 5 | "When does your phone become an enemy of sleep?" | Circadian boundary | Digital Sunset time |
| 6 | "How soon after waking do you feel the pull?" | Morning addiction strength | Morning Boundary timer |
| 7 | "Do you feel anxious after 2 hours offline?" | Anxiety baseline | Stress Floor calibration |
| 8 | "Which app leaves you feeling drained?" | Post-usage affect | Blocking strategy |
| 9 | "How long is your ideal deep work silence?" | Focus goal | Focus Mode timeout |
| 10 | "Is your phone how you *escape* stress, or *resolve* it?" | Avoidance behavior | Avoidance Index score |

### 1.2 Intention Zone Profile
After the quiz, user receives a **personalized archetype card**. This is not a clinical label but a compassionate, humanized self-portrait.

**Example Archetypes:**
- 🌙 **Evening Escapist** — "You're intentional by day, but drift after 9 PM. We'll watch your evening window."
- 📱 **Morning Phantom Checker** — "Your first 30 minutes after waking are high-risk. We'll gently hold that space."
- 🔔 **Reactive Responder** — "Notifications run your schedule. Let's take back control."
- 🔄 **Novelty Hunter** — "You crave new stimulation. Let's redirect that energy."
- 🧩 **Work-Life Blender** — "Your work bleeds into rest time. Let's build a clearer boundary."

**Why archetypes work:** Framing overuse as a *biological response*, not a character flaw, reduces shame and increases engagement. [(NIH, Destigmatization Research)](https://www.nih.gov)

### 1.3 7-Day Calibration Learning Phase
The first 7 days are "observe only" — the app silently builds the user's behavioral baseline before any intervention.

**Metrics collected passively:**
- Average unlock frequency (per hour, per day)
- Peak usage windows (morning, afternoon, night)
- App dwell time averages per category
- Scroll velocity patterns
- Notification response latency

**Why:** Personalized thresholds are more effective than generic ones. The app learns *your* normal before defining *your* frantic.

---

## PILLAR 2 — Predictive Overload Detection Engine

> *"Don't wait for the crash. Read the warning signs."*

### 2.1 The Behavioral State Machine (3-Minute Rolling Window)

The core AI engine categorizes user state continuously using a rolling 3-minute behavioral window.

| Zone | Signals | Label | App Response |
|------|---------|-------|--------------|
| 🟢 Zone 1: **Flow** | 1–2 apps, dwell >2 min | Intentional | No action |
| 🟡 Zone 2: **Shallow** | 3–4 apps, dwell 30–60s | Rising Stimulation | Silent log |
| 🔴 Zone 3: **Frantic** | 5+ switches, dwell <15s, loops detected | Overload | Trigger intervention |

**Utility App Exception:** Switches involving Bank, Calculator, Maps, Settings — resolved in <30 seconds — are excluded from the Frantic Score.

**Research basis:** Problematic use is defined by *compulsive, uncontrolled behavior*, not total duration. [(Psychology Today Meta-Analysis, 2024)](https://www.psychologytoday.com)

### 2.2 The 11 Overload Scenarios (Detection → Intervention)

Each scenario targets a *specific modern digital pathology*:

#### 🎯 FOCUS THEME
| Scenario | Trigger | Notification | Reset Technique |
|----------|---------|-------------|-----------------|
| **Dopamine Loop** | 3+ apps in <60 seconds | "You're moving fast between apps. This rapid switching can fragment your focus." | **Sky Reset** — Tilt face toward sky/window, eyes closed, 60 seconds |
| **The Void** | 20+ min continuous scroll | "Mental fog is setting in. Let's pull you back to the room." | **5-Object Scan** — Find 5 objects of the same color |
| **Reactive Mode** | 5+ notification-driven opens in 10 min | "You're in high-alert mode. Want to take back control?" | **Horizon View** — Look at furthest point through a window for 60s |

#### 👥 SOCIAL THEME
| Scenario | Trigger | Notification | Reset Technique |
|----------|---------|-------------|-----------------|
| **Social Spiral** | 10+ rapid profile views on social apps | "You're comparing a lot right now. Shall we ground ourselves?" | **Heart-Hand Grounding** — One hand on heart, one on belly, 30 seconds |
| **Ghosting Anxiety** | Type >100 chars, delete all, close app | "Overthinking a message. Let's breathe before deciding." | **4-7-8 Breathing** — Inhale 4s, hold 7s, exhale 8s |

#### 🌙 REST THEME
| Scenario | Trigger | Notification | Reset Technique |
|----------|---------|-------------|-----------------|
| **Midnight Drift** | Usage 1 hour past Sleep Goal | "Late-night light tricks your brain into staying alert when it needs rest." | **Tactile Grounding** — Touch 3 different textures |
| **Last Scroll Loop** | 3+ lock/unlock cycles in <2 min at night | "The 'last scroll' loop delays deep rest." | **Darkroom Reset** — Phone in drawer, lights off, silence 60s |
| **Work-Life Blur** | Opening Slack/Email during Digital Sunset | "Can this wait for 'Future You'?" | **Physical Boundary** — Walk to a different room |

#### ✨ NOVELTY THEME
| Scenario | Trigger | Notification | Reset Technique |
|----------|---------|-------------|-----------------|
| **Phantom Check** | 10+ unlocks in 15 min with no incoming alerts | "You've checked 10 times with no alerts. Your mind is on high-alert." | **Somatic Release** — Shoulder rolls × 5 + deep breath |
| **Novelty Hunt** | 5+ shopping/store apps in 10 min | "Searching for something new. This can signal underlying restlessness." | **Sensory Swap** — Hold a physical object, notice weight and temperature |

#### ⚡ STRESS THEME
| Scenario | Trigger | Notification | Reset Technique |
|----------|---------|-------------|-----------------|
| **Info Overload** | 5+ news/high-intensity apps in 15 min | "You're in 'threat detection' mode. Let's find some calm." | **Cold Reset** — Cold water on face (activates Vagus nerve) |
| **Interaction Spike** | Scroll velocity (px/sec) doubles | "Your scrolling speed has increased. Ready to slow down?" | **Weighted Reset** — Feet pressed firmly to floor for 60s |

---

## PILLAR 3 — The Somatic Reset Experience

> *"Your body holds the answer. Your app holds the door."*

### 3.1 The Immersive Reset Environment
**Design language:**
- **Glassmorphism UI** — Soft blurred layers, no hard edges
- **Dark Mode Default** — Scientifically reduces arousal levels
- **Pulsating Glow Orb** — Expands and contracts as a breathing anchor
- **Haptic Pacing** — Subtle taptic pulses synced to breathing rhythm
- **Minimalist Copy** — One instruction at a time

### 3.2 Reset Technique Library

| Technique | Physiological Mechanism | Research Backing |
|-----------|------------------------|-----------------|
| **4-7-8 Breathing** | Activates parasympathetic nervous system via vagus nerve | [NIH — Diaphragmatic Breathing](https://pubmed.ncbi.nlm.nih.gov) |
| **Box Breathing** | Equalizes sympathetic/parasympathetic balance | [NIH — Breathing & HRV](https://pubmed.ncbi.nlm.nih.gov) |
| **5-4-3-2-1 Grounding** | Interrupts rumination via multi-sensory grounding | CBT-validated technique |
| **Cold Stimulus (Vagus Reset)** | Activates dive reflex, rapidly calms heart rate | [Vagal Stimulation Research](https://pubmed.ncbi.nlm.nih.gov) |
| **Weighted Pressure** | Proprioceptive input signals safety to nervous system | Somatic Therapy Research |
| **Horizon View** | Resets visual focal length after close-screen viewing | Ophthalmology / Somatic Therapy |
| **Tactile Object Focus** | Anchors attention in the present moment | MBSR Research |

**Research basis:** Breathing interventions reduce cortisol by up to **23% in one month**. HRV improves significantly with exhale-focused breathing. [(NIH, 2024)](https://pubmed.ncbi.nlm.nih.gov)

### 3.3 Post-Reset Visual Mood Validation
**Non-verbal 3-image projective selection** — bypasses the "correct answer" cognitive bias.

| Theme Set | Zone A (Calm) | Zone B (Balanced) | Zone C (Still Activated) |
|-----------|--------------|------------------|--------------------------|
| Daily Activities | Tea by a window | Organizing a bookshelf | Crowded marathon finish |
| Fine Art | Monet's Water Lilies | Cubist architecture | Pollock action painting |
| Workspace | Clean desk with one plant | Library table, open book | Multi-monitor, many tabs |

**Entropy Engine:**
- Low Entropy → Reset Complete
- Medium Entropy → Ready to Focus
- High Entropy → Suggest additional 30s Sky Reset

---

## PILLAR 4 — App Boundary Intelligence

### 4.1 Dual-Mode Boundary System

| Mode | Philosophy | Mechanism | Best For |
|------|-----------|-----------|---------|
| **Disengage** | "Gently redirect" | Grayscale filter + countdown timer + soft nudge | WhatsApp, Twitter — useful but slippery |
| **Block** | "Earn your re-entry" | Full block + 60-second reset required to unlock | Facebook, TikTok — pure emotional distraction |

### 4.2 Smart App Categorization

| Category | Default Mode | Examples |
|----------|-------------|---------|
| 🔵 **Utility** | Exempt | Maps, Calculator, Bank, Settings |
| 🟡 **Social** | Disengage (15 min) | WhatsApp, iMessage, Discord |
| 🔴 **Emotional Distraction** | Block | TikTok, Instagram Reels, Facebook |
| 🟢 **Productivity** | Monitor only | Notion, Gmail, Slack |
| ⚪ **Entertainment** | Disengage (30 min) | Spotify, YouTube |

### 4.3 Contextual Override System
- **Focus Mode Hours** — Stricter rules during deep work windows
- **Digital Sunset** — No emotional distraction apps after wind-down time
- **Morning Buffer** — 30-min delay on social apps after waking
- **One-Time Override** — Bypass a block with a 30-second Somatic Reset

---

## PILLAR 5 — Sleep & Circadian Health Intelligence

### 5.1 Digital Sunset (Staged Wind-Down)
- **T-90 min:** Block emotional distraction apps. Soft reminder.
- **T-60 min:** News and high-intensity content blocked. Grayscale for all social.
- **T-30 min:** Only utility apps available. Full dark mode enforced.
- **T-0 (Bedtime):** Screen lock suggestion + optional night-mode soundscape.

**Research basis:** Mental stimulation from content (not blue light alone) is the primary driver of sleep onset delay. [(Time / NIH, 2024)](https://time.com)

### 5.2 Circadian Pattern Dashboard
- Average sleep/wake times (via morning first-unlock pattern)
- Late-night usage events (after Digital Sunset)
- "Last Scroll Loop" frequency
- Weekly sleep quality trend score

### 5.3 Morning Mindfulness Buffer
- 30-minute "No Social Apps" window after first unlock
- Daily morning intention micro-prompt
- **Research basis:** Checking social media immediately upon waking amplifies FOMO and existential anxiety. [(The Guardian, 2024)](https://www.theguardian.com)

---

## PILLAR 6 — Social Health & Comparison Awareness

### 6.1 Social Spiral Detection
- 10+ profile views in 5 minutes → Social Spiral alert
- Prolonged passive Instagram/TikTok → flags "Upward Comparison Risk"
- **Research basis:** Passive social media consumption (scrolling) drives FOMO → upward comparison → self-esteem decline. [(NIH, 2024)](https://pubmed.ncbi.nlm.nih.gov) | [(Frontiers in Psychology, 2024)](https://www.frontiersin.org)

### 6.2 Ghosting Anxiety Recognition
- Message typed >100 chars → deleted → app closed → compassionate nudge + breathing exercise

### 6.3 Social Savoring Reframe Prompts
- Micro-prompts reframe comparison into curiosity
- **Research basis:** "Social Savoring" is an evidence-based counter to comparison-driven self-esteem erosion. [(netpsychology.org, 2024)](https://netpsychology.org)

---

## PILLAR 7 — Attention & Focus Intelligence

### 7.1 Notification Audit Tool
Weekly report:
- Total notifications received vs. acted upon
- Notification-to-action ratio per app
- "Interruption Cost" — estimated time lost per week
- **Research basis:** Single notification disrupts focus for ~7 seconds; 100–150/day = permanent attention fragmentation. [(PsyPost / Computers in Human Behavior, 2026)](https://www.psypost.org)

### 7.2 Focus Mode (Deep Work Protection)
- Pomodoro-style sessions (25–90 min blocks)
- All non-utility apps silenced
- **Focus Integrity Score** — tracks completed vs. broken sessions

### 7.3 The Frantic Score (Live Metric)
- Real-time 0–100 score on the daily dashboard
- Increases: rapid app switching, high-velocity scrolling, phantom checks
- Decreases: long dwell times, focus sessions, completed resets
- 7-day trend line visible on home screen

---

## PILLAR 8 — Awareness & Insights Dashboard

### 8.1 Daily Digital Health Card
- Yesterday's Zone distribution (Flow / Shallow / Frantic %)
- Top 3 apps by dwell time
- Biggest attention disruptors
- Sleep-phone correlation

### 8.2 Weekly Wellbeing Report
- Frantic Score trend (7-day sparkline)
- Most frequent overload scenario
- Resets completed vs. triggered (Reset Compliance Rate)
- Avoidance Index trend

### 8.3 AI-Narrated Pattern Insights
One-sentence behavioral summaries in compassionate language:
- *"You tend to enter Frantic Mode on Tuesday evenings — often after work Slack messages."*
- *"Your Phantom Check rate drops 60% on days you complete a morning intention prompt."*

### 8.4 Avoidance Index Score
- Tracks emotional-escape usage vs. productive usage ratio
- High Avoidance Index → triggers a 3-question reflective journal prompt

---

## PILLAR 9 — Compassionate Gamification

### 9.1 Nervous System Streaks
- Daily Reset Streak, Focus Integrity Streak, Digital Sunset Streak
- Losing a streak shows: *"Streaks can be rebuilt. Today is a fresh start."*

### 9.2 Zone Balance Goal
- User sets weekly intention (e.g., "60% of time in Flow Zone")
- Progress ring on dashboard home

### 9.3 Archetype Evolution
- Detects genuine behavioral pattern shifts over time
- *"You were an Evening Escapist. Your 9–11 PM patterns improved 40% this month."*

### 9.4 Somatic Library (Unlockable Resets)
- Start with 3 reset techniques
- Unlock new exercises as streaks grow

---

## PILLAR 10 — Privacy & Ethical Design

### 10.1 On-Device Processing
- All behavioral data processed on-device (iOS Screen Time APIs / Android UsageStatsManager)
- No behavioral data sent to external servers
- Uses **Behavioral Reporting**, not clinical diagnosis

### 10.2 Compassionate Language Standard
- ❌ No guilt ("You've wasted 3 hours")
- ❌ No clinical labels
- ✅ Biological framing ("Your nervous system is in High-Stimulation Mode")
- ✅ Invitation language ("Ready for a quick reset?")

**Research basis:** Shame-based interventions reduce engagement and increase avoidance. [(NIH — Destigmatization, 2024)](https://pubmed.ncbi.nlm.nih.gov)

### 10.3 Transparency Report
- Weekly in-app summary of data collected, where stored, how used
- "Delete My Baseline" option — resets 7-day calibration without deleting the app

---

## 📋 Feature Priority Matrix

| Feature | Impact | Complexity | MVP? |
|---------|--------|-----------|------|
| Intention Baseline Quiz | 🔴 Critical | Low | ✅ Yes |
| 7-Day Calibration Phase | 🔴 Critical | Medium | ✅ Yes |
| Frantic Score Algorithm | 🔴 Critical | High | ✅ Yes |
| Somatic Reset Experience (3 techniques) | 🔴 Critical | Medium | ✅ Yes |
| Post-Reset Mood Validation (3-image) | 🟡 High | Medium | ✅ Yes |
| Digital Sunset System | 🟡 High | Medium | ✅ Yes |
| Block/Disengage Dual-Mode | 🟡 High | Medium | ✅ Yes |
| Privacy Transparency Report | 🔴 Critical | Low | ✅ Yes |
| Notification Audit Tool | 🟡 High | Low | 🔄 V2 |
| Social Spiral Detection | 🟡 High | High | 🔄 V2 |
| Ghosting Anxiety Detection | 🟠 Medium | High | 🔄 V2 |
| Archetype Evolution System | 🟠 Medium | Medium | 🔄 V2 |
| Weekly Wellbeing Report | 🟠 Medium | Medium | 🔄 V2 |
| Somatic Library (Unlockable) | 🟢 Nice | Low | 🔄 V3 |
| Morning Mindfulness Buffer | 🟢 Nice | Low | 🔄 V2 |

---

## 🔗 Key Research References

| Topic | Source | Link |
|-------|--------|------|
| Problematic smartphone use & mental health (1.1M meta-analysis) | Psychology Today / NIH, 2024 | [psychologytoday.com](https://www.psychologytoday.com) |
| Single notification disrupts focus for 7 seconds | PsyPost / Computers in Human Behavior, 2026 | [psypost.org](https://www.psypost.org) |
| Bidirectional anxiety–smartphone relationship | NIH PubMed, 2024 | [pubmed.ncbi.nlm.nih.gov](https://pubmed.ncbi.nlm.nih.gov) |
| Doomscrolling & existential anxiety (800-adult study) | Computers in Human Behavior Reports, 2024 | [journals.elsevier.com](https://www.journals.elsevier.com) |
| WHO adolescent social media concern report | WHO Europe, 2024 | [who.int/europe](https://www.who.int/europe) |
| FOMO → Social Comparison → Self-Esteem Decline | NIH / Frontiers in Psychology, 2024 | [frontiersin.org](https://www.frontiersin.org) |
| Passive vs. active social media use harm | NIH PubMed, 2024 | [pubmed.ncbi.nlm.nih.gov](https://pubmed.ncbi.nlm.nih.gov) |
| 4-7-8 breathing & vagus nerve regulation | NIH / Somatic Therapy Partners, 2024 | [pubmed.ncbi.nlm.nih.gov](https://pubmed.ncbi.nlm.nih.gov) |
| Cortisol reduction (23%) via breathing | NIH, 2024 | [pubmed.ncbi.nlm.nih.gov](https://pubmed.ncbi.nlm.nih.gov) |
| Sleep: Content stimulation > blue light | Time / NIH, 2024 | [time.com](https://time.com) |
| "Popcorn Brain" overstimulation effect | Harvard Health / NIH, 2024 | [health.harvard.edu](https://www.health.harvard.edu) |
| Phantom phone signals & hypervigilance | BrainFacts.org / Uni of Hawaii, 2024 | [brainfacts.org](https://www.brainfacts.org) |
| Social Savoring as counter to comparison | NetPsychology.org, 2024 | [netpsychology.org](https://netpsychology.org) |
| Variable-ratio reinforcement in infinite scroll | NIH PubMed, 2024 | [pubmed.ncbi.nlm.nih.gov](https://pubmed.ncbi.nlm.nih.gov) |

---
*ScreenBalance — Built on science, designed with compassion.*
*Last updated: May 2026*
