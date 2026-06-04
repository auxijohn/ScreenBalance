import { userIdentity } from './modules/UserIdentity.js';
import { interventionEngine } from './modules/InterventionEngine.js';
import { eventBus, EVENTS } from './core/EventBus.js';

const quizData = [
    {
        question: "When you pick up your phone, how often do you know exactly why you unlocked it?",
        options: ["Almost always", "Usually", "Sometimes", "Rarely"],
        weights: { "PhantomChecker": [0, 1, 2, 3] }
    },
    {
        question: "How soon after waking up do you usually check social media, news, or emails?",
        options: ["Immediately in bed", "Within 15 minutes", "During breakfast", "After I start my day"],
        weights: { "MorningScroller": [3, 2, 1, 0] }
    },
    {
        question: "Do you find yourself endlessly scrolling in bed, knowing you should be sleeping?",
        options: ["Every night", "Often", "Occasionally", "Rarely"],
        weights: { "EveningEscapist": [3, 2, 1, 0] }
    },
    {
        question: "Around 2-3 PM, do you reach for short-form video to fight off a drop in energy?",
        options: ["Yes, it's my caffeine", "Sometimes", "Rarely", "Never"],
        weights: { "MiddaySlumper": [3, 2, 0, 0] }
    },
    {
        question: "If you face a difficult or boring task, does your app-switching suddenly increase?",
        options: ["Always", "Often", "Sometimes", "No, I stay focused"],
        weights: { "TaskAvoidant": [3, 2, 1, 0] }
    },
    {
        question: "How often do you unlock your phone in an elevator or line, purely out of muscle memory?",
        options: ["Constantly", "Often", "Sometimes", "Rarely"],
        weights: { "PhantomChecker": [3, 2, 1, 0] }
    },
    {
        question: "When a notification pops up, how hard is it for you to ignore it and keep working?",
        options: ["Impossible", "Very hard", "Manageable", "Easy"],
        weights: { "NotificationReactive": [3, 2, 1, 0] }
    },
    {
        question: "Do you ever read negative news or endless feeds until you feel tense or 'zoned out'?",
        options: ["Frequently", "Sometimes", "Rarely", "Never"],
        weights: { "Doomscroller": [3, 2, 0, 0] }
    },
    {
        question: "After using specific apps, do you frequently feel drained, envious, or 'less than'?",
        options: ["Very often", "Often", "Sometimes", "Rarely"],
        weights: { "SocialComparer": [3, 2, 1, 0] }
    },
    {
        question: "If we could help you reclaim one thing, would you choose:",
        options: ["More Focus", "Better Sleep", "Less Anxiety", "More Intentionality"],
        weights: { "TaskAvoidant": [2, 0, 0, 0], "EveningEscapist": [0, 2, 0, 0], "Doomscroller": [0, 0, 2, 0], "PhantomChecker": [0, 0, 0, 2] }
    }
];

const profiles = {
    "EveningEscapist": { id: "EveningEscapist", icon: "🌙", title: "The Evening Escapist", insight: "You are highly intentional during the day, but use your phone to 'numb out' after 8 PM.", strategy: "We will set high-friction interventions triggered automatically in the evening." },
    "MorningScroller": { id: "MorningScroller", icon: "🌅", title: "The Morning Scroller", insight: "You wake up and immediately check feeds, spiking cortisol right at the start of your day.", strategy: "We will enforce a strict 'Morning Buffer Zone' to protect your first hour." },
    "MiddaySlumper": { id: "MiddaySlumper", icon: "☕", title: "The Midday Slumper", insight: "You experience an afternoon energy crash and use short-form video for quick dopamine.", strategy: "We will suggest physical movement during afternoon usage spikes." },
    "TaskAvoidant": { id: "TaskAvoidant", icon: "🏃", title: "The Task Avoidant", insight: "Your app-switching correlates heavily with facing stressful or boring tasks.", strategy: "We will interrupt rapid switching during 'Focus Hours' with CBT prompts." },
    "PhantomChecker": { id: "PhantomChecker", icon: "👻", title: "The Phantom Checker", insight: "You unlock your phone constantly out of pure muscle memory, even without notifications.", strategy: "We will place a mandatory 3-second breathing delay on trigger apps." },
    "NotificationReactive": { id: "NotificationReactive", icon: "🔔", title: "The Notification Reactive", insight: "You get derailed easily by a single ping, shifting your attention entirely.", strategy: "We will limit post-notification sessions to 60 seconds." },
    "Doomscroller": { id: "Doomscroller", icon: "🌀", title: "The Doomscroller", insight: "You endlessly scroll to numb anxiety, often entering a dissociative state.", strategy: "We will use strong somatic pattern interrupts to break the trance." },
    "SocialComparer": { id: "SocialComparer", icon: "⚖️", title: "The Social Comparer", insight: "Usage on specific platforms frequently triggers FOMO or emotional drainage.", strategy: "We will strictly cap session duration followed by emotional validation." },
    "Default": { id: "Default", icon: "🛡️", title: "The Seeker", insight: "You are seeking more intentionality in your digital life.", strategy: "We will build a customized boundary system to protect your focus." }
};

let userProfile = profiles["Default"];

function calculateIntentionProfile() {
    const scores = { "MorningScroller": 0, "EveningEscapist": 0, "MiddaySlumper": 0, "TaskAvoidant": 0, "PhantomChecker": 0, "NotificationReactive": 0, "Doomscroller": 0, "SocialComparer": 0 };
    
    answers.forEach((ansIndex, qIndex) => {
        const weights = quizData[qIndex].weights;
        if(weights) {
            for (const profile in weights) {
                const points = Array.isArray(weights[profile]) ? weights[profile][ansIndex] : weights[profile];
                scores[profile] += points || 0;
            }
        }
    });

    let maxScore = -1;
    let dominantProfile = "Default";
    for (const profile in scores) {
        if (scores[profile] > maxScore) {
            maxScore = scores[profile];
            dominantProfile = profile;
        }
    }
    
    userProfile = profiles[maxScore > 0 ? dominantProfile : "Default"];
    
    // Save to UserIdentity Module
    userIdentity.updateIntentionCard(userProfile);
    
    // Inject into Step 2 UI
    document.getElementById('profile-icon').innerText = userProfile.icon;
    document.getElementById('profile-title').innerText = userProfile.title;
    document.getElementById('profile-insight').innerText = userProfile.insight;
    document.getElementById('profile-strategy').innerText = userProfile.strategy;
    
    return userProfile;
}

const scenarios = [
    { theme: "Focus", name: "Dopamine Loop", trigger: "3+ apps in <60 seconds.", message: "You're moving fast between apps. This rapid switching can fragment your focus. Ready for a quick reset?", intervention: "The Sky Reset: Step outside (or near a window), tilt your face toward the sky, and close your eyes for 60 seconds." },
    { theme: "Focus", name: "The Void", trigger: "20+ mins of continuous scrolling.", message: "You've been scrolling for a while. This can create a 'mental fog.' Let's pull your awareness back to the room.", intervention: "The 5-Object Scan: Look away from the screen and find 5 objects in the room that are the same color." },
    { theme: "Focus", name: "Reactive Mode", trigger: "5+ notification-driven opens in 10 mins.", message: "You're reacting to pings as they come. This high-alert mode increases cognitive load. Want to take back control?", intervention: "The Horizon View: Stand up and look at the furthest point you can see out a window for 60 seconds to reset your visual system." },
    { theme: "Social", name: "Social Spiral", trigger: "10+ rapid profile views on Social apps.", message: "You're looking at a lot of social profiles. This can sometimes trigger subconscious comparison stress. Shall we ground ourselves?", intervention: "The Heart-Hand Grounding: Place one hand on your heart and one on your belly. Feel your own breath for 30 seconds." },
    { theme: "Social", name: "Ghosting Tension", trigger: "Typing >100 chars, deleting all, and closing.", message: "It looks like you're hesitating on a message. Overthinking can build social tension. Let's take a breath before deciding.", intervention: "The 4-7-8 Breath: Inhale for 4s, hold for 7s, exhale for 8s to calm the mind and body." },
    { theme: "Rest", name: "Midnight Drift", trigger: "Usage 1 hour past Sleep Goal.", message: "It's past your quiet hour. Late-night light can trick your brain into staying 'alert' when it needs rest.", intervention: "Tactile Grounding: Put your phone down and touch 3 different textures (e.g., a cold table, a soft pillow, your own palms)." },
    { theme: "Rest", name: "Last Scroll Loop", trigger: "3+ Lock/Unlock cycles in <2 mins at night.", message: "You're trying to put the phone away, but the pull is strong. This 'last scroll' loop delays deep rest.", intervention: "The Darkroom Reset: Put the phone in a drawer, turn off the lights, and sit in silence for 60 seconds." },
    { theme: "Rest", name: "Work-Life Blur", trigger: "Opening Slack/Email during 'Digital Sunset'.", message: "Checking work apps now can prevent your brain from fully decompressing. Is this urgent, or can it wait for 'Future You'?", intervention: "The Physical Boundary: Walk to a different room or stand up and do a full-body stretch to mark the end of 'work mode.'" },
    { theme: "Novelty", name: "Phantom Check", trigger: "10+ unlocks in 15 mins (no pings).", message: "You've checked in 10 times with no alerts. This 'phantom checking' keeps your mind on high-alert.", intervention: "Physical Release: Roll your shoulders back 5 times and take one slow, deep breath with your eyes closed." },
    { theme: "Novelty", name: "Novelty Hunt", trigger: "5+ Shopping/Store apps in 10 mins.", message: "You're searching for something new. This 'novelty hunt' can be a sign of underlying restlessness.", intervention: "The Sensory Swap: Find a physical object near you (a pen, a stone, a glass) and notice its weight and temperature for 60 seconds." },
    { theme: "Stress", name: "Info Overload", trigger: "5+ news/high-intensity apps in 15 mins.", message: "You're processing a lot of high-intensity info. This can trigger a 'threat detection' state. Let's find some calm.", intervention: "The Cold Reset: Splash some cold water on your face or hold a cold object for 30 seconds to calm the Vagus nerve." },
    { theme: "Stress", name: "Interaction Spike", trigger: "Rapid scrolling speed (px/sec) doubling.", message: "Your scrolling speed has increased. This often happens when you are feeling overstimulated. Ready to slow down?", intervention: "The Weighted Reset: Sit down and press your feet firmly into the floor, feeling the support of the ground for 60 seconds." }
];

let currentQuestionIndex = 0;
let answers = [];
let currentInterventionText = "Focus on the orb. Breathe with its rhythm.";
let localAppCategories = {};
let localAccountabilityContacts = [];

// DOM Elements
const step1 = document.getElementById('step-1');
const step2 = document.getElementById('step-2');
const step3 = document.getElementById('step-3');
const step4 = document.getElementById('step-4');
const questionText = document.getElementById('question-text');
const optionsContainer = document.getElementById('options-container');
const quizProgress = document.getElementById('quiz-progress');
const questionNumber = document.getElementById('question-number');
const nextBtn = document.getElementById('next-btn');
const prevBtn = document.getElementById('prev-btn');

export function initLegacyApp() {
    // If a profile exists with a card, load it
    const profile = userIdentity.getProfile();
    if (profile && profile.intentionCard) {
        userProfile = profile.intentionCard;
        document.getElementById('profile-icon').innerText = userProfile.icon;
        document.getElementById('profile-title').innerText = userProfile.title;
        document.getElementById('profile-insight').innerText = userProfile.insight;
        document.getElementById('profile-strategy').innerText = userProfile.strategy;
    }
    
    // Load initial settings into Step 3 inputs
    if (profile && profile.settings) {
        const settings = profile.settings;
        document.getElementById('input-bedtime').value = settings.targetBedtime || '22:00';
        document.getElementById('input-morning-buffer').value = settings.morningBufferMinutes || 30;
        document.getElementById('input-focus-start').value = settings.focusStart || '09:00';
        document.getElementById('input-focus-end').value = settings.focusEnd || '17:00';
        
        // Deep copy appCategories locally so we can cycle them before saving
        localAppCategories = JSON.parse(JSON.stringify(settings.appCategories || {}));
        
        // Deep copy accountabilityContacts locally
        localAccountabilityContacts = JSON.parse(JSON.stringify(settings.accountabilityContacts || []));
    }
    
    // Fallback defaults if they are empty
    if (!localAppCategories || Object.keys(localAppCategories).length === 0) {
        localAppCategories = {
            'WhatsApp': 'social',
            'Discord': 'social',
            'TikTok': 'emotional',
            'Instagram': 'emotional',
            'Notion': 'productivity',
            'Slack': 'productivity',
            'Spotify': 'entertainment',
            'YouTube': 'entertainment',
            'Banking': 'utility',
            'Maps': 'utility',
            'Calculator': 'utility'
        };
    }
    if (!localAccountabilityContacts) {
        localAccountabilityContacts = [];
    }
    
    // Render initial accountability contacts
    renderContacts();

    // Wire up Add Contact Button
    const btnAddContact = document.getElementById('btn-add-contact');
    if (btnAddContact) {
        btnAddContact.onclick = () => {
            const nameEl = document.getElementById('contact-name');
            const infoEl = document.getElementById('contact-info');
            const name = nameEl.value.trim();
            const info = infoEl.value.trim();
            
            if (name && info) {
                localAccountabilityContacts.push({ name, info });
                nameEl.value = '';
                infoEl.value = '';
                renderContacts();
                logToConsole(`Added accountability contact: ${name}`);
            }
        };
    }

    // Attach global remove contact handler
    window.removeContact = (idx) => {
        if (idx >= 0 && idx < localAccountabilityContacts.length) {
            const name = localAccountabilityContacts[idx].name;
            localAccountabilityContacts.splice(idx, 1);
            renderContacts();
            logToConsole(`Removed accountability contact: ${name}`);
        }
    };

    // Wire up Add Custom App Button
    const btnAddCustomApp = document.getElementById('btn-add-custom-app');
    if (btnAddCustomApp) {
        btnAddCustomApp.onclick = () => {
            const nameEl = document.getElementById('input-new-app-name');
            const catEl = document.getElementById('select-new-app-category');
            const name = nameEl.value.trim();
            const cat = catEl.value;

            if (name) {
                if (localAppCategories[name]) {
                    logToConsole(`⚠️ Warning: ${name} is already categorized.`);
                    return;
                }
                
                localAppCategories[name] = cat;
                nameEl.value = '';
                renderSettings();
                renderConsole();
                logToConsole(`Added custom app: ${name} mapped to ${cat}`);
            }
        };
    }

    // Wire up Save Boundaries button
    const btnSaveBoundaries = document.getElementById('btn-save-boundaries');
    if (btnSaveBoundaries) {
        btnSaveBoundaries.onclick = () => {
            const bedtime = document.getElementById('input-bedtime').value || '22:00';
            const morningBuffer = parseInt(document.getElementById('input-morning-buffer').value) || 30;
            const focusStart = document.getElementById('input-focus-start').value || '09:00';
            const focusEnd = document.getElementById('input-focus-end').value || '17:00';

            userIdentity.updateSettings({
                targetBedtime: bedtime,
                morningBufferMinutes: morningBuffer,
                focusStart: focusStart,
                focusEnd: focusEnd,
                appCategories: localAppCategories,
                accountabilityContacts: localAccountabilityContacts
            });

            // Show a visual success toast
            const notif = document.getElementById('notification');
            notif.querySelector('.notif-content strong').innerText = "Boundaries Saved";
            notif.querySelector('.notif-content p').innerText = "Your schedules, apps, and partners are stored locally.";
            notif.classList.remove('active');
            setTimeout(() => {
                notif.classList.add('active');
            }, 50);
            setTimeout(() => {
                notif.classList.remove('active');
            }, 3500);

            goToStep(4);
        };
    }

    // Subscribe to dynamic engine interventions
    eventBus.subscribe(EVENTS.INTERVENTION_TRIGGERED, (scenario) => {
        currentInterventionText = scenario.intervention;
        
        const notif = document.getElementById('notification');
        notif.querySelector('.notif-content strong').innerText = scenario.name + " Detected";
        notif.querySelector('.notif-content p').innerText = scenario.message;
        
        notif.classList.remove('active');
        setTimeout(() => {
            notif.classList.add('active');
        }, 50);

        logToConsole(`⚠️ Overload Pattern Matched: [${scenario.name}] triggered!`);
    });

    // Wire up Simulation Console Time Override
    const simTimeInput = document.getElementById('sim-time-input');
    const lblEffectiveTime = document.getElementById('lbl-effective-time');
    const btnResetTime = document.getElementById('btn-reset-time');

    if (simTimeInput) {
        simTimeInput.onchange = (e) => {
            const val = e.target.value;
            if (val) {
                const [h, m] = val.split(':').map(Number);
                interventionEngine.setSimulatedTime(h, m);
                lblEffectiveTime.innerText = `⏰ Override: ${val}`;
                logToConsole(`⏰ Time overridden to ${val}`);
            }
        };
    }

    if (btnResetTime) {
        btnResetTime.onclick = () => {
            interventionEngine.setSimulatedTime(null, null);
            if (simTimeInput) simTimeInput.value = '';
            lblEffectiveTime.innerText = "Live System Time";
            logToConsole("⏰ Simulated time reset to system real time");
        };
    }

    // Wire up Simulated Physical Actions
    const btnSimUnlock = document.getElementById('btn-sim-unlock');
    const btnSimLock = document.getElementById('btn-sim-lock');
    const btnSimScroll = document.getElementById('btn-sim-scroll');

    if (btnSimUnlock) {
        btnSimUnlock.onclick = () => {
            interventionEngine.triggerDeviceUnlock();
            logToConsole("📱 Simulated phone unlocked");
        };
    }
    if (btnSimLock) {
        btnSimLock.onclick = () => {
            interventionEngine.triggerDeviceLock();
            logToConsole("🔒 Simulated phone locked");
        };
    }
    if (btnSimScroll) {
        btnSimScroll.onclick = () => {
            interventionEngine.triggerContinuousScroll();
            logToConsole("📜 Simulated 20 mins of continuous scrolling");
        };
    }

    // Wire up Preset Scenario trigger buttons
    const presetDopamine = document.getElementById('preset-dopamine');
    const presetDrift = document.getElementById('preset-drift');
    const presetBlur = document.getElementById('preset-blur');
    const presetScrollLoop = document.getElementById('preset-scrollloop');

    if (presetDopamine) {
        presetDopamine.onclick = () => {
            logToConsole("🚀 Running Dopamine Loop sequence...");
            interventionEngine.triggerAppOpen('WhatsApp');
            setTimeout(() => interventionEngine.triggerAppOpen('Instagram'), 200);
            setTimeout(() => interventionEngine.triggerAppOpen('Slack'), 400);
        };
    }

    if (presetDrift) {
        presetDrift.onclick = () => {
            logToConsole("🚀 Running Midnight Drift sequence...");
            interventionEngine.setSimulatedTime(23, 45);
            if (simTimeInput) simTimeInput.value = "23:45";
            lblEffectiveTime.innerText = "⏰ Override: 23:45";
            setTimeout(() => interventionEngine.triggerAppOpen('Instagram'), 200);
        };
    }

    if (presetBlur) {
        presetBlur.onclick = () => {
            logToConsole("🚀 Running Work-Life Blur sequence...");
            interventionEngine.setSimulatedTime(18, 30);
            if (simTimeInput) simTimeInput.value = "18:30";
            lblEffectiveTime.innerText = "⏰ Override: 18:30";
            setTimeout(() => interventionEngine.triggerAppOpen('Slack'), 200);
        };
    }

    if (presetScrollLoop) {
        presetScrollLoop.onclick = () => {
            logToConsole("🚀 Running Last Scroll Loop sequence...");
            interventionEngine.setSimulatedTime(23, 50);
            if (simTimeInput) simTimeInput.value = "23:50";
            lblEffectiveTime.innerText = "⏰ Override: 23:50";
            
            // Rapid cycles
            setTimeout(() => {
                interventionEngine.triggerDeviceUnlock();
                interventionEngine.triggerDeviceLock();
            }, 100);
            setTimeout(() => {
                interventionEngine.triggerDeviceUnlock();
                interventionEngine.triggerDeviceLock();
            }, 300);
            setTimeout(() => {
                interventionEngine.triggerDeviceUnlock();
            }, 500);
        };
    }
    
    showQuestion(currentQuestionIndex);
    
    // Attach inline event handlers
    window.goToStep = goToStep;
    window.openReset = openReset;
    window.closeReset = closeReset;
    window.handleValidationResponse = handleValidationResponse;
    window.selectEntropy = selectEntropy;
}

function showQuestion(index) {
    const question = quizData[index];
    questionText.innerText = question.question;
    optionsContainer.innerHTML = '';
    
    question.options.forEach((option, i) => {
        const btn = document.createElement('button');
        btn.classList.add('option-btn');
        btn.innerText = option;
        
        // Restore selection
        if (answers[index] === i) {
            btn.classList.add('selected');
        }
        
        btn.onclick = () => selectOption(i);
        optionsContainer.appendChild(btn);
    });

    // Update Progress
    const progress = ((index + 1) / quizData.length) * 100;
    quizProgress.style.width = `${progress}%`;
    questionNumber.innerText = `Question ${index + 1} of ${quizData.length}`;
    
    // Back button visibility
    if (index > 0) {
        prevBtn.style.visibility = 'visible';
    } else {
        prevBtn.style.visibility = 'hidden';
    }

    // Next button visibility & state
    if (index === quizData.length - 1) {
        nextBtn.style.visibility = 'visible';
        nextBtn.innerHTML = 'Complete Onboarding <i data-lucide="check"></i>';
        nextBtn.disabled = answers[index] === undefined;
    } else {
        if (answers[index] !== undefined) {
            nextBtn.style.visibility = 'visible';
            nextBtn.innerHTML = 'Next <i data-lucide="arrow-right"></i>';
            nextBtn.disabled = false;
        } else {
            nextBtn.style.visibility = 'hidden';
        }
    }
    lucide.createIcons();
}

function selectOption(optionIndex) {
    // Clear previous selections
    const buttons = optionsContainer.querySelectorAll('.option-btn');
    buttons.forEach(btn => btn.classList.remove('selected'));
    
    // Select current
    buttons[optionIndex].classList.add('selected');
    answers[currentQuestionIndex] = optionIndex;
    
    if (currentQuestionIndex === quizData.length - 1) {
        nextBtn.disabled = false;
        nextBtn.style.visibility = 'visible';
    } else {
        // Auto-advance
        setTimeout(() => {
            currentQuestionIndex++;
            showQuestion(currentQuestionIndex);
        }, 300);
    }
}

nextBtn.onclick = () => {
    if (currentQuestionIndex < quizData.length - 1) {
        currentQuestionIndex++;
        showQuestion(currentQuestionIndex);
    } else {
        calculateIntentionProfile();
        goToStep(2);
    }
};

prevBtn.onclick = () => {
    if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        showQuestion(currentQuestionIndex);
    }
};

export function goToStep(stepNum) {
    // Hide all views
    document.querySelectorAll('.view').forEach(view => view.classList.remove('active'));
    document.querySelectorAll('.step').forEach(step => step.classList.remove('active'));

    // Update background (now 5 steps)
    document.body.className = `step-${stepNum}-bg`;

    // Show target view
    document.getElementById(`step-${stepNum}`).classList.add('active');
    
    // Activate all indicators up to the current step
    for(let i=1; i<=stepNum; i++) {
        const ind = document.getElementById(`indicator-${i}`);
        if(ind) ind.classList.add('active');
    }

    if (stepNum === 3) {
        renderSettings();
    } else if (stepNum === 5) {
        renderConsole();
    }
}

// Step 3 Logic: Settings (Tiered cycling list)
function renderSettings() {
    const utilityList = document.getElementById('utility-list');
    const socialList = document.getElementById('social-list');
    const emotionalList = document.getElementById('emotional-list');
    const productivityList = document.getElementById('productivity-list');
    const entertainmentList = document.getElementById('entertainment-list');
    
    if(!utilityList || !socialList) return;

    // Clear lists
    utilityList.innerHTML = '';
    socialList.innerHTML = '';
    emotionalList.innerHTML = '';
    productivityList.innerHTML = '';
    entertainmentList.innerHTML = '';

    const nextCategory = {
        utility: 'social',
        social: 'emotional',
        emotional: 'productivity',
        productivity: 'entertainment',
        entertainment: 'utility'
    };

    const icons = {
        utility: 'tool',
        social: 'clock',
        emotional: 'lock',
        productivity: 'check-square',
        entertainment: 'play-circle'
    };

    // Populate app chips based on local categories
    for (const appName in localAppCategories) {
        const cat = localAppCategories[appName];
        
        const chip = document.createElement('div');
        chip.className = `app-chip`;
        
        // Dynamic styling for app chips based on standard theme
        if (cat === 'utility') {
            chip.style.borderColor = 'rgba(102, 126, 234, 0.4)';
            chip.style.background = 'linear-gradient(145deg, rgba(102, 126, 234, 0.1), rgba(102, 126, 234, 0.02))';
            chip.style.color = '#E2E8F0';
            chip.style.boxShadow = '0 4px 10px rgba(102, 126, 234, 0.1)';
        } else if (cat === 'social') {
            chip.style.borderColor = 'rgba(253, 219, 45, 0.4)';
            chip.style.background = 'linear-gradient(145deg, rgba(253, 219, 45, 0.15), rgba(253, 219, 45, 0.02))';
            chip.style.color = '#FFFBEB';
            chip.style.boxShadow = '0 4px 10px rgba(253, 219, 45, 0.1)';
        } else if (cat === 'emotional') {
            chip.className = `app-chip block`;
            chip.style.borderColor = 'rgba(240, 64, 64, 0.4)';
            chip.style.background = 'linear-gradient(145deg, rgba(240, 64, 64, 0.15), rgba(240, 64, 64, 0.02))';
            chip.style.color = '#FFF5F5';
            chip.style.boxShadow = '0 4px 10px rgba(240, 64, 64, 0.1)';
        } else if (cat === 'productivity') {
            chip.style.borderColor = 'rgba(72, 187, 120, 0.4)';
            chip.style.background = 'linear-gradient(145deg, rgba(72, 187, 120, 0.15), rgba(72, 187, 120, 0.02))';
            chip.style.color = '#F0FFF4';
            chip.style.boxShadow = '0 4px 10px rgba(72, 187, 120, 0.1)';
        } else if (cat === 'entertainment') {
            chip.style.borderColor = 'rgba(255, 255, 255, 0.2)';
            chip.style.background = 'linear-gradient(145deg, rgba(255, 255, 255, 0.05), rgba(255, 255, 255, 0.01))';
            chip.style.color = '#F7FAFC';
            chip.style.boxShadow = '0 4px 10px rgba(255, 255, 255, 0.05)';
        }

        chip.style.cursor = 'pointer';
        chip.innerHTML = `${appName} <i data-lucide="${icons[cat]}"></i>`;
        
        // Cycle category on click
        chip.onclick = () => {
            localAppCategories[appName] = nextCategory[cat];
            renderSettings();
        };

        if (cat === 'utility') utilityList.appendChild(chip);
        else if (cat === 'social') socialList.appendChild(chip);
        else if (cat === 'emotional') emotionalList.appendChild(chip);
        else if (cat === 'productivity') productivityList.appendChild(chip);
        else if (cat === 'entertainment') entertainmentList.appendChild(chip);
    }
    
    lucide.createIcons();
}

// Render Accountability Contacts
function renderContacts() {
    const list = document.getElementById('contacts-list');
    if (!list) return;
    list.innerHTML = '';
    
    if (localAccountabilityContacts.length === 0) {
        list.innerHTML = `<div style="font-size: 0.85rem; color: var(--text-secondary); font-style: italic; text-align: center; padding: 0.5rem;">No contacts added yet.</div>`;
        return;
    }
    
    localAccountabilityContacts.forEach((contact, idx) => {
        const row = document.createElement('div');
        row.style.display = 'flex';
        row.style.justifyContent = 'space-between';
        row.style.alignItems = 'center';
        row.style.background = 'rgba(255, 255, 255, 0.03)';
        row.style.border = '1px solid rgba(255, 255, 255, 0.08)';
        row.style.padding = '0.5rem 0.75rem';
        row.style.borderRadius = '10px';
        row.style.fontSize = '0.85rem';
        
        row.innerHTML = `
            <div>
                <strong style="color: #fff;">${contact.name}</strong> 
                <span style="color: var(--text-secondary); margin-left: 0.5rem;">(${contact.info})</span>
            </div>
            <button class="btn-secondary" style="padding: 0.2rem 0.5rem; font-size: 0.75rem; border-color: rgba(240,64,64,0.4); color: #f04040; border-radius: 6px; cursor: pointer;" onclick="removeContact(${idx})">Remove</button>
        `;
        list.appendChild(row);
    });
}

// Step 5 Logic: Live Overload Simulation Console
function renderConsole() {
    const appDrawer = document.getElementById('sim-app-drawer');
    if (!appDrawer) return;

    appDrawer.innerHTML = '';

    const colors = {
        utility: '#667eea',
        social: '#fdbb2d',
        emotional: '#f04040',
        productivity: '#48bb78',
        entertainment: '#a0aec0'
    };

    const icons = {
        utility: 'settings',
        social: 'message-circle',
        emotional: 'alert-triangle',
        productivity: 'briefcase',
        entertainment: 'play'
    };

    // Create a mock app button for each app
    for (const appName in localAppCategories) {
        const cat = localAppCategories[appName];
        const btn = document.createElement('button');
        btn.className = 'btn-secondary';
        btn.style.borderColor = colors[cat];
        btn.style.color = colors[cat];
        btn.style.background = `rgba(255, 255, 255, 0.02)`;
        btn.style.fontSize = '0.85rem';
        btn.style.padding = '0.4rem 0.8rem';
        btn.style.borderRadius = '10px';
        btn.style.display = 'flex';
        btn.style.alignItems = 'center';
        btn.style.gap = '0.35rem';
        btn.style.cursor = 'pointer';
        
        btn.innerHTML = `<i data-lucide="${icons[cat]}" style="width: 14px; height: 14px;"></i> ${appName}`;
        
        btn.onclick = () => {
            interventionEngine.triggerAppOpen(appName);
        };

        appDrawer.appendChild(btn);
    }

    lucide.createIcons();
}

// Simulated console logs helper
function logToConsole(msg) {
    const logsEl = document.getElementById('sim-logs');
    if (!logsEl) return;
    const item = document.createElement('div');
    item.style.padding = '0.1rem 0';
    item.style.borderBottom = '1px solid rgba(255,255,255,0.02)';
    item.innerHTML = `<span style="color: var(--text-secondary);">${new Date().toLocaleTimeString()}</span> ${msg}`;
    logsEl.appendChild(item);
    logsEl.scrollTop = logsEl.scrollHeight;
}

function openReset() {
    const overlay = document.getElementById('reset-overlay');
    document.getElementById('intervention-text').innerText = currentInterventionText;
    document.getElementById('reset-timer').innerText = "60s";
    
    // Reset any previous validation UI
    document.getElementById('validation-ui').style.display = 'none';
    document.getElementById('orb').style.display = 'block';
    document.getElementById('intervention-text').style.display = 'block';
    document.getElementById('reset-timer').style.display = 'block';
    
    overlay.classList.add('active');
    startResetTimer();
}

function closeReset() {
    document.getElementById('reset-overlay').classList.remove('active');
    document.getElementById('notification').classList.remove('active');
}

function startResetTimer() {
    let timeLeft = 60;
    const timerDisplay = document.getElementById('reset-timer');
    const interval = setInterval(() => {
        timeLeft--;
        timerDisplay.innerText = `${timeLeft}s`;
        if (timeLeft <= 0) {
            clearInterval(interval);
            showPostResetValidation();
        }
    }, 1000);
}

function showPostResetValidation() {
    document.getElementById('orb').style.display = 'none';
    document.getElementById('intervention-text').style.display = 'none';
    document.getElementById('reset-timer').style.display = 'none';
    
    const validationUI = document.getElementById('validation-ui');
    validationUI.style.display = 'block';
    lucide.createIcons();
}

function handleValidationResponse(wantsCheck) {
    const validationUI = document.getElementById('validation-ui');
    const moodCheckUI = document.getElementById('mood-check-ui');
    const quoteUI = document.getElementById('quote-ui');
    
    validationUI.style.display = 'none';
    
    if (wantsCheck) {
        moodCheckUI.style.display = 'block';
    } else {
        const quoteText = document.getElementById('motivational-quote');
        // Dynamic quote based on userProfile
        const quotes = {
            "EveningEscapist": "Rest is productive. Your worth isn't measured by your evening scroll.",
            "MorningScroller": "The first hour of the day belongs to you, not the algorithm.",
            "TaskAvoidant": "The hardest part is the first 5 minutes. You've got this.",
            "Doomscroller": "The world is big, and your peace is precious. Step back into the real room.",
            "Default": "You are in control of your attention. Breathe in the silence."
        };
        quoteText.innerText = quotes[userProfile.id] || quotes["Default"];
        quoteUI.style.display = 'block';
    }
}

function selectEntropy(level) {
    const quoteUI = document.getElementById('quote-ui');
    const moodCheckUI = document.getElementById('mood-check-ui');
    moodCheckUI.style.display = 'none';
    
    if (level === 'low') {
        document.getElementById('motivational-quote').innerText = "System Regulated. Your focus is restored.";
    } else {
        document.getElementById('motivational-quote').innerText = "High stimulus detected. Suggesting another 5 minutes away from the screen.";
    }
    quoteUI.style.display = 'block';
}

// Initialization is now handled by main.js
// initQuiz();
