/**
 * A wrapper around localStorage to ensure data is saved securely and consistently.
 */
export class Storage {
    static PREFIX = 'ScreenBalance_';

    /**
     * Save data to local storage
     * @param {string} key 
     * @param {any} value 
     */
    static set(key, value) {
        try {
            const serialized = JSON.stringify(value);
            localStorage.setItem(this.PREFIX + key, serialized);
            return true;
        } catch (error) {
            console.error(`Error saving ${key} to storage:`, error);
            return false;
        }
    }

    /**
     * Retrieve data from local storage
     * @param {string} key 
     * @returns {any|null}
     */
    static get(key) {
        try {
            const item = localStorage.getItem(this.PREFIX + key);
            return item ? JSON.parse(item) : null;
        } catch (error) {
            console.error(`Error retrieving ${key} from storage:`, error);
            return null;
        }
    }

    /**
     * Remove an item from storage
     * @param {string} key 
     */
    static remove(key) {
        localStorage.removeItem(this.PREFIX + key);
    }

    /**
     * Clear all ScreenBalance data
     */
    static clearAll() {
        const keysToRemove = [];
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            if (key.startsWith(this.PREFIX)) {
                keysToRemove.push(key);
            }
        }
        keysToRemove.forEach(key => localStorage.removeItem(key));
    }
}
