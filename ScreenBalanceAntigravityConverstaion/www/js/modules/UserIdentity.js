import { Storage } from '../core/Storage.js';
import { eventBus, EVENTS } from '../core/EventBus.js';

/**
 * Module 1: User Identity & Profile Management
 * Handles local user login, profile creation, and stores user details securely on the device.
 */
export class UserIdentity {
    constructor() {
        this.profile = null;
        this.STORAGE_KEY = 'user_profile';
    }

    /**
     * Initialize the module and load any existing profile
     * @returns {Object|null} The loaded profile or null if none exists
     */
    init() {
        this.profile = Storage.get(this.STORAGE_KEY);
        if (this.profile) {
            // Safeguard & migration for older profiles
            if (!this.profile.settings) {
                this.profile.settings = {};
            }
            if (!this.profile.settings.appCategories || Object.values(this.profile.settings.appCategories).includes('disengage') || Object.values(this.profile.settings.appCategories).includes('block')) {
                this.profile.settings.appCategories = {
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
            if (!this.profile.settings.targetBedtime) this.profile.settings.targetBedtime = '22:00';
            if (!this.profile.settings.morningBufferMinutes) this.profile.settings.morningBufferMinutes = 30;
            if (!this.profile.settings.focusStart) this.profile.settings.focusStart = '09:00';
            if (!this.profile.settings.focusEnd) this.profile.settings.focusEnd = '17:00';
            if (!this.profile.settings.accountabilityContacts) this.profile.settings.accountabilityContacts = [];
            this._save();

            console.log('User Identity: Profile loaded.', this.profile.name);
            eventBus.publish(EVENTS.PROFILE_LOADED, this.profile);
        }
        return this.profile;
    }

    /**
     * Create a new user profile
     * @param {string} name - User's name or nickname
     * @returns {Object} The newly created profile
     */
    createProfile(name) {
        this.profile = {
            id: 'usr_' + Date.now().toString(36) + Math.random().toString(36).substr(2),
            name: name,
            createdAt: new Date().toISOString(),
            intentionCard: null,
            settings: {
                targetBedtime: '22:00',
                morningBufferMinutes: 30,
                focusStart: '09:00',
                focusEnd: '17:00',
                appCategories: {
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
                },
                accountabilityContacts: []
            }
        };

        this._save();
        console.log('User Identity: Profile created.', this.profile.name);
        eventBus.publish(EVENTS.PROFILE_CREATED, this.profile);
        return this.profile;
    }

    /**
     * Update the user's Intention Card (from Quiz or Adaptive Engine)
     * @param {Object} card - The intention card object
     */
    updateIntentionCard(card) {
        if (!this.profile) return;
        
        this.profile.intentionCard = card;
        this._save();
        console.log('User Identity: Intention Card updated.', card.title);
        eventBus.publish(EVENTS.INTENTION_CARD_UPDATED, this.profile);
    }

    /**
     * Update user settings
     * @param {Object} newSettings 
     */
    updateSettings(newSettings) {
        if (!this.profile) return;

        this.profile.settings = { ...this.profile.settings, ...newSettings };
        this._save();
        console.log('User Identity: Settings updated.');
        eventBus.publish(EVENTS.PROFILE_UPDATED, this.profile);
    }

    /**
     * Delete the current profile (reset the app)
     */
    deleteProfile() {
        this.profile = null;
        Storage.remove(this.STORAGE_KEY);
        console.log('User Identity: Profile deleted.');
    }

    /**
     * Get the current profile
     * @returns {Object|null}
     */
    getProfile() {
        return this.profile;
    }

    /**
     * Internal method to persist the profile
     */
    _save() {
        if (this.profile) {
            Storage.set(this.STORAGE_KEY, this.profile);
        }
    }
}

// Export singleton
export const userIdentity = new UserIdentity();
