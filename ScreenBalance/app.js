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

function initQuiz() {
    showQuestion(currentQuestionIndex);
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

function goToStep(stepNum) {
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
        renderScenarios();
    }
}

// Step 3 Logic: Settings (Tiered)
function renderSettings() {
    const disengageList = document.getElementById('disengage-list');
    const blockList = document.getElementById('block-list');
    const utilityList = document.getElementById('utility-list');
    
    if(!disengageList) return;

    disengageList.innerHTML = `
        <div class="app-chip">WhatsApp <i data-lucide="clock"></i></div>
        <div class="app-chip">Instagram <i data-lucide="clock"></i></div>
        <div class="app-chip">Twitter <i data-lucide="clock"></i></div>
    `;
    
    blockList.innerHTML = `
        <div class="app-chip block">YouTube <i data-lucide="lock"></i></div>
        <div class="app-chip block">TikTok <i data-lucide="lock"></i></div>
        <div class="app-chip block">Facebook <i data-lucide="lock"></i></div>
    `;

    utilityList.innerHTML = `
        <div class="app-chip utility">Banking <i data-lucide="shield"></i></div>
        <div class="app-chip utility">Maps <i data-lucide="map"></i></div>
        <div class="app-chip utility">Calculator <i data-lucide="plus-circle"></i></div>
    `;
    
    lucide.createIcons();
}

// Step 4 Logic: Intervention Simulation
function renderScenarios() {
    const grid = document.getElementById('scenarios-grid');
    grid.innerHTML = '';
    
    scenarios.forEach((scenario, i) => {
        const btn = document.createElement('button');
        btn.classList.add('scenario-btn');
        btn.innerHTML = `
            <span class="scenario-theme">${scenario.theme}</span>
            <span class="scenario-name">${scenario.name}</span>
            <span class="scenario-trigger">${scenario.trigger}</span>
        `;
        btn.onclick = () => triggerNotification(i);
        grid.appendChild(btn);
    });
}

function triggerNotification(index) {
    const scenario = scenarios[index];
    currentInterventionText = scenario.intervention;
    
    const notif = document.getElementById('notification');
    notif.querySelector('.notif-content strong').innerText = scenario.name + " Detected";
    notif.querySelector('.notif-content p').innerText = scenario.message;
    
    notif.classList.remove('active'); // reset animation if already open
    setTimeout(() => {
        notif.classList.add('active');
    }, 50);
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

// Initialize
initQuiz();
