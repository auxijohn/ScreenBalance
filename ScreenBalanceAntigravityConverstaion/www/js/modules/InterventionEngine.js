import { eventBus, EVENTS } from '../core/EventBus.js';
import { userIdentity } from './UserIdentity.js';

/**
 * Modules 4 & 5: Behavioral Tracking & Intervention Engine
 * Listens to simulated or real OS events, checks against user settings and profiles,
 * and detects behavioral anomalies to trigger somatic resets.
 */
export class InterventionEngine {
    constructor() {
        this.appHistory = [];
        this.unlockHistory = [];
        this.lockHistory = [];
        this.scrollEvents = [];
        
        // Allows overriding current time for testing nighttime/work-hour behaviors
        this.simulatedHour = null;
        this.simulatedMinute = null;

        this.scenarios = {
            "DopamineLoop": {
                name: "Dopamine Loop",
                theme: "Focus",
                message: "You're moving fast between apps. This rapid switching can fragment your focus. Ready for a quick reset?",
                intervention: "The Sky Reset: Step outside (or near a window), tilt your face toward the sky, and close your eyes for 60 seconds."
            },
            "MidnightDrift": {
                name: "Midnight Drift",
                theme: "Rest",
                message: "It's past your quiet hour. Late-night light can trick your brain into staying 'alert' when it needs rest.",
                intervention: "Tactile Grounding: Put your phone down and touch 3 different textures (e.g., a cold table, a soft pillow, your own palms)."
            },
            "WorkLifeBlur": {
                name: "Work-Life Blur",
                theme: "Rest",
                message: "Checking work apps now can prevent your brain from fully decompressing. Is this urgent, or can it wait for 'Future You'?",
                intervention: "The Physical Boundary: Walk to a different room or stand up and do a full-body stretch to mark the end of 'work mode.'"
            },
            "LastScrollLoop": {
                name: "Last Scroll Loop",
                theme: "Rest",
                message: "You're trying to put the phone away, but the pull is strong. This 'last scroll' loop delays deep rest.",
                intervention: "The Darkroom Reset: Put the phone in a drawer, turn off the lights, and sit in silence for 60 seconds."
            },
            "TheVoid": {
                name: "The Void",
                theme: "Focus",
                message: "You've been scrolling for a while. This can create a 'mental fog.' Let's pull your awareness back to the room.",
                intervention: "The 5-Object Scan: Look away from the screen and find 5 objects in the room that are the same color."
            },
            "PhantomCheck": {
                name: "Phantom Check",
                theme: "Novelty",
                message: "You've checked in frequently with no alerts. This 'phantom checking' keeps your mind on high-alert.",
                intervention: "Physical Release: Roll your shoulders back 5 times and take one slow, deep breath with your eyes closed."
            }
        };
    }

    /**
     * Set a simulated time of day for testing
     * @param {number|null} hour (0-23)
     * @param {number|null} minute (0-59)
     */
    setSimulatedTime(hour, minute) {
        this.simulatedHour = hour;
        this.simulatedMinute = minute;
        console.log(`Intervention Engine: Simulated time set to ${hour !== null ? `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}` : 'System Real Time'}`);
    }

    /**
     * Get the current effective date/time (taking simulation into account)
     * @returns {Date}
     */
    getCurrentTime() {
        const now = new Date();
        if (this.simulatedHour !== null && this.simulatedMinute !== null) {
            now.setHours(this.simulatedHour, this.simulatedMinute, 0, 0);
        }
        return now;
    }

    /**
     * Trigger a mock app open event
     * @param {string} appName 
     */
    triggerAppOpen(appName) {
        const now = this.getCurrentTime();
        const profile = userIdentity.getProfile();
        const settings = profile ? profile.settings : null;
        const appCategories = settings ? settings.appCategories || {} : {};
        const appCategory = appCategories[appName] || 'social';

        console.log(`Tracking Engine: Opened ${appName} (${appCategory}) at ${now.toLocaleTimeString()}`);
        
        // Log event
        this.appHistory.push({ appName, category: appCategory, timestamp: now.getTime() });
        this._cleanHistory(now.getTime());

        // Check if app is blocked or exempt
        if (appCategory === 'utility') {
            console.log(`Tracking Engine: ${appName} is a Utility Exception. Exempt from checks.`);
            return;
        }

        // 1. Check Midnight Drift Rule
        if (settings && settings.targetBedtime) {
            if (this._isPastBedtime(now, settings.targetBedtime)) {
                // If it is an emotional, social, or entertainment app, trigger Midnight Drift
                if (appCategory === 'emotional' || appCategory === 'social' || appCategory === 'entertainment') {
                    this._triggerIntervention("MidnightDrift");
                    return;
                }
            }
        }

        // 2. Check Work-Life Blur Rule
        if (settings && appCategory === 'productivity') {
            if (this._isOutsideFocusHours(now, settings.focusStart || '09:00', settings.focusEnd || '17:00')) {
                this._triggerIntervention("WorkLifeBlur");
                return;
            }
        }

        // 3. Check Dopamine Loop Rule (3+ apps in <60 seconds)
        if (this._detectDopamineLoop(now.getTime())) {
            this._triggerIntervention("DopamineLoop");
            return;
        }
    }

    /**
     * Trigger a mock device unlock event
     */
    triggerDeviceUnlock() {
        const now = this.getCurrentTime();
        const profile = userIdentity.getProfile();
        const settings = profile ? profile.settings : null;
        
        console.log(`Tracking Engine: Device Unlocked at ${now.toLocaleTimeString()}`);
        
        this.unlockHistory.push(now.getTime());
        this._cleanHistory(now.getTime());

        // 1. Check Last Scroll Loop (3+ lock/unlock cycles in < 2 mins at night)
        if (settings && settings.targetBedtime && this._isPastBedtime(now, settings.targetBedtime)) {
            if (this._detectLastScrollLoop(now.getTime())) {
                this._triggerIntervention("LastScrollLoop");
                return;
            }
        }

        // 2. Check Phantom Check (10+ unlocks in 15 mins)
        if (this._detectPhantomCheck(now.getTime())) {
            this._triggerIntervention("PhantomCheck");
            return;
        }
    }

    /**
     * Trigger a mock device lock event
     */
    triggerDeviceLock() {
        const now = this.getCurrentTime();
        console.log(`Tracking Engine: Device Locked at ${now.toLocaleTimeString()}`);
        this.lockHistory.push(now.getTime());
        this._cleanHistory(now.getTime());
    }

    /**
     * Simulate continuous scrolling (triggers "The Void")
     */
    triggerContinuousScroll() {
        console.log("Tracking Engine: Simulating 20+ mins of continuous scrolling.");
        this._triggerIntervention("TheVoid");
    }

    /**
     * Clean historical arrays of events older than 30 minutes to manage memory
     */
    _cleanHistory(nowTime) {
        const thirtyMins = 30 * 60 * 1000;
        const cutoff = nowTime - thirtyMins;
        this.appHistory = this.appHistory.filter(h => h.timestamp > cutoff);
        this.unlockHistory = this.unlockHistory.filter(t => t > cutoff);
        this.lockHistory = this.lockHistory.filter(t => t > cutoff);
    }

    /**
     * Check if a given time is past the target bedtime
     */
    _isPastBedtime(time, bedtimeStr) {
        const [bedHour, bedMin] = bedtimeStr.split(':').map(Number);
        const currHour = time.getHours();
        const currMin = time.getMinutes();

        // Standard bedtime window: from bedtime hour until 5:00 AM the next morning
        if (bedHour > 5) {
            // E.g., Bedtime is 22:00. Past bedtime is 22:00 to 23:59 OR 00:00 to 05:00.
            if (currHour >= bedHour || currHour < 5) {
                if (currHour === bedHour) {
                    return currMin >= bedMin;
                }
                return true;
            }
        } else {
            // E.g., Bedtime is 01:00 AM. Past bedtime is 01:00 to 05:00.
            if (currHour >= bedHour && currHour < 5) {
                if (currHour === bedHour) {
                    return currMin >= bedMin;
                }
                return true;
            }
        }
        return false;
    }

    /**
     * Check if a given time is outside the user's focus hours
     */
    _isOutsideFocusHours(time, startStr, endStr) {
        const [startHour, startMin] = startStr.split(':').map(Number);
        const [endHour, endMin] = endStr.split(':').map(Number);
        
        const currHour = time.getHours();
        const currMin = time.getMinutes();

        const currentMinutes = currHour * 60 + currMin;
        const startMinutes = startHour * 60 + startMin;
        const endMinutes = endHour * 60 + endMin;

        if (startMinutes <= endMinutes) {
            // Standard daytime focus: e.g. 09:00 to 17:00
            return currentMinutes < startMinutes || currentMinutes > endMinutes;
        } else {
            // Overnight focus: e.g. 20:00 to 04:00
            return currentMinutes < startMinutes && currentMinutes > endMinutes;
        }
    }

    /**
     * Detect Dopamine Loop: 3+ unique app opens in < 60 seconds
     */
    _detectDopamineLoop(nowTime) {
        const sixtySecs = 60 * 1000;
        const recentAppOpens = this.appHistory.filter(h => h.timestamp >= nowTime - sixtySecs);
        
        // Find unique app names
        const uniqueApps = new Set(recentAppOpens.map(h => h.appName));
        return uniqueApps.size >= 3;
    }

    /**
     * Detect Last Scroll Loop: 3+ Lock/Unlock cycles in < 2 mins
     */
    _detectLastScrollLoop(nowTime) {
        const twoMins = 2 * 60 * 1000;
        const recentUnlocks = this.unlockHistory.filter(t => t >= nowTime - twoMins);
        const recentLocks = this.lockHistory.filter(t => t >= nowTime - twoMins);

        // A cycle is a lock followed by an unlock. We just need at least 3 unlocks in 2 minutes.
        return recentUnlocks.length >= 3 && recentLocks.length >= 2;
    }

    /**
     * Detect Phantom Check: 10+ unlocks in 15 mins (with low/no app engagement)
     */
    _detectPhantomCheck(nowTime) {
        const fifteenMins = 15 * 60 * 1000;
        const recentUnlocks = this.unlockHistory.filter(t => t >= nowTime - fifteenMins);
        return recentUnlocks.length >= 10;
    }

    /**
     * Dispatches the intervention command
     */
    _triggerIntervention(scenarioKey) {
        const scenario = this.scenarios[scenarioKey];
        if (!scenario) return;

        console.log(`INTERVENTION ROUTER: Pattern matched! Triggering [${scenario.name}] reset.`);
        eventBus.publish(EVENTS.INTERVENTION_TRIGGERED, scenario);
    }
}

// Export singleton
export const interventionEngine = new InterventionEngine();
