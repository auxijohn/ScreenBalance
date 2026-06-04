/**
 * A lightweight Publish/Subscribe Event Bus to decouple modules.
 */
class EventBus {
    constructor() {
        this.events = {};
    }

    /**
     * Subscribe to an event
     * @param {string} eventName - The name of the event
     * @param {function} callback - The callback function to execute
     * @returns {function} An unsubscribe function
     */
    subscribe(eventName, callback) {
        if (!this.events[eventName]) {
            this.events[eventName] = [];
        }
        
        this.events[eventName].push(callback);
        
        // Return unsubscribe function
        return () => {
            this.events[eventName] = this.events[eventName].filter(cb => cb !== callback);
        };
    }

    /**
     * Publish an event with data
     * @param {string} eventName - The name of the event
     * @param {any} data - The data to pass to the callbacks
     */
    publish(eventName, data) {
        if (!this.events[eventName]) return;
        
        this.events[eventName].forEach(callback => {
            try {
                callback(data);
            } catch (error) {
                console.error(`Error in EventBus subscriber for [${eventName}]:`, error);
            }
        });
    }

    /**
     * Clear all subscribers for an event
     * @param {string} eventName 
     */
    clear(eventName) {
        if (this.events[eventName]) {
            delete this.events[eventName];
        }
    }
}

// Export a singleton instance
export const eventBus = new EventBus();

// Global Events Constants
export const EVENTS = {
    PROFILE_CREATED: 'PROFILE_CREATED',
    PROFILE_LOADED: 'PROFILE_LOADED',
    PROFILE_UPDATED: 'PROFILE_UPDATED',
    INTENTION_CARD_UPDATED: 'INTENTION_CARD_UPDATED',
    INTERVENTION_TRIGGERED: 'INTERVENTION_TRIGGERED',
    INTERVENTION_COMPLETED: 'INTERVENTION_COMPLETED'
};
