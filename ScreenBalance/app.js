const quizData = [
    {
        question: "How many unlocks per hour is 'just right'?",
        options: ["Less than 2", "3 to 5", "6 to 10", "More than 10"],
        connection: "Intentionality Goal",
        metric: "Screen Unlock Frequency"
    },
    {
        question: "When switching apps, are you Bored or Working?",
        options: ["Mostly working", "Mixed", "Mostly bored", "I don't know"],
        connection: "Root Cause Analysis",
        metric: "App Switching Patterns"
    },
    {
        question: "Do you pick up your phone and forget why?",
        options: ["Never", "Rarely", "Often", "Constantly"],
        connection: "Dissociation Level",
        metric: "Intentionality Score"
    },
    {
        question: "Which app do you use to 'numb out'?",
        options: ["Instagram / TikTok", "Twitter / X", "YouTube / Netflix", "Games / Other"],
        connection: "Dopamine Source",
        metric: "Block/Disengage Priority"
    },
    {
        question: "When does your phone become an 'enemy of sleep'?",
        options: ["Before 10 PM", "11 PM - 12 AM", "After 1 AM", "It doesn't"],
        connection: "Circadian Boundary",
        metric: "Late Night Usage"
    },
    {
        question: "How soon do you feel the 'magnetic pull' after waking?",
        options: ["Instantly", "Within 15 mins", "After 1 hour", "I wait for breakfast"],
        connection: "Addiction Strength",
        metric: "Morning Frequency"
    },
    {
        question: "Do you feel anxious if you don't check for 2 hours?",
        options: ["No, it's a relief", "Slightly", "Yes, quite a bit", "I check every 15 mins"],
        connection: "Stress Baseline",
        metric: "Stress Floor Calibration"
    },
    {
        question: "Which app leaves you feeling 'drained'?",
        options: ["Social Media", "Work / Email", "News / High-Input", "Messaging / WhatsApp"],
        connection: "Post-Usage Affect",
        metric: "Blocking Strategy"
    },
    {
        question: "How long is your ideal 'Deep Work' silence?",
        options: ["30 mins", "1 hour", "2 hours+", "I can't work in silence"],
        connection: "Focus Goal",
        metric: "Timeout Duration"
    },
    {
        question: "When you are stressed, is your phone a way to escape or resolve?",
        options: ["Resolve (Utility)", "A mix of both", "Escape (Numbing)", "Mostly Avoidance"],
        connection: "Avoidance Behavior",
        metric: "Avoidance Baseline"
    }
];

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

    // Update background
    document.body.className = `step-${stepNum}-bg`;

    // Show target view
    document.getElementById(`step-${stepNum}`).classList.add('active');
    document.getElementById(`indicator-${stepNum}`).classList.add('active');

    if (stepNum === 3) {
        renderSettings();
    } else if (stepNum === 4) {
        renderScenarios();
    }
}

// Step 3 Logic: Settings
function renderSettings() {
    const settingsList = document.querySelector('.settings-list');
    settingsList.innerHTML = `
        <div class="setting-group">
            <h3>Disengage (The Nudge)</h3>
            <p>Gentle reminders for useful but slippery apps</p>
            <div class="app-chip">WhatsApp <i data-lucide="clock"></i></div>
            <div class="app-chip">Instagram <i data-lucide="clock"></i></div>
            <div class="app-chip">Twitter <i data-lucide="clock"></i></div>
        </div>
        <div class="setting-group" style="margin-top: 2rem;">
            <h3>Block (The Wall)</h3>
            <p>Requires a 1-minute reset to unlock</p>
            <div class="app-chip block">YouTube <i data-lucide="lock"></i></div>
            <div class="app-chip block">Facebook <i data-lucide="lock"></i></div>
        </div>
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
            document.getElementById('intervention-text').innerText = "Perspective Restored.";
        }
    }, 1000);
}

// Initialize
initQuiz();
