import { userIdentity } from './modules/UserIdentity.js';
import { initLegacyApp, goToStep } from './app.js';

// Initialize the application
function init() {
    // Check if user profile exists
    const profile = userIdentity.init();

    const btnCreateProfile = document.getElementById('btn-create-profile');
    const nameInput = document.getElementById('user-name-input');
    const mainIndicator = document.getElementById('main-step-indicator');

    if (profile) {
        // User exists, skip Step 0, show indicators, go to Step 1
        console.log('Welcome back,', profile.name);
        if (mainIndicator) mainIndicator.style.display = 'flex';
        initLegacyApp();
        
        // If they already have an intention card, maybe skip to step 3?
        // For now, let's just go to step 1 (quiz) to replay, or step 3 directly.
        if (profile.intentionCard) {
            goToStep(3);
        } else {
            goToStep(1);
        }
    } else {
        // No user, stay on Step 0
        console.log('New user. Awaiting profile creation.');
        
        btnCreateProfile.addEventListener('click', () => {
            const name = nameInput.value.trim() || 'Traveler';
            userIdentity.createProfile(name);
            
            // Proceed to Step 1
            if (mainIndicator) mainIndicator.style.display = 'flex';
            initLegacyApp();
            goToStep(1);
        });
    }

    // Initialize lucide icons for whatever is currently on screen
    if (window.lucide) {
        window.lucide.createIcons();
    }
}

// Start app
document.addEventListener('DOMContentLoaded', init);
