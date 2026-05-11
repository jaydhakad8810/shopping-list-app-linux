/**
 * Database.js
 * Handles all SQLite database operations using QtQuick.LocalStorage.
 *
 * Tables:
 *   menu   - Stores all food menu items
 *   cart   - Stores current cart (not used heavily; cart is in-memory)
 *   orders - Stores placed orders with customer info
 *
 * Usage: import this file into QML pages that need database access.
 */

.pragma library  // Shared singleton across all QML components

// Qt's built-in LocalStorage module for SQLite access
.import QtQuick.LocalStorage 2.0 as LS

// ─── Get/Open Database ────────────────────────────────────────────────────
/**
 * getDatabase - Opens (or creates) the SQLite database.
 * @returns {object} The database connection object
 */
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync(
        "KolhapuriDB",    // Database name (used as filename internally)
        "1.0",            // Version
        "Restaurant DB",  // Description
        1000000           // Max size in bytes (~1MB)
    )
}

// ─── Initialize Database ──────────────────────────────────────────────────
/**
 * initDatabase - Creates all required tables if they don't exist.
 * Also seeds the menu with default food items on first run.
 * Call this once when the app starts (in Main.qml Component.onCompleted).
 */
function initDatabase() {
    var db = getDatabase()

    db.transaction(function(tx) {
        // Create MENU table
        tx.executeSql(`
            CREATE TABLE IF NOT EXISTS menu (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                name        TEXT    NOT NULL,
                description TEXT,
                price       REAL    NOT NULL,
                category    TEXT    NOT NULL
            )
        `)

        // Create CART table (optional, cart is mostly in-memory via CartLogic.js)
        tx.executeSql(`
            CREATE TABLE IF NOT EXISTS cart (
                id        INTEGER PRIMARY KEY AUTOINCREMENT,
                item_name TEXT    NOT NULL,
                quantity  INTEGER NOT NULL DEFAULT 1,
                price     REAL    NOT NULL
            )
        `)

        // Create ORDERS table
        tx.executeSql(`
            CREATE TABLE IF NOT EXISTS orders (
                id            INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_name TEXT    NOT NULL,
                table_number  TEXT    NOT NULL,
                items         TEXT    NOT NULL,
                total         REAL    NOT NULL,
                order_date    TEXT    NOT NULL
            )
        `)

        // ── Seed Menu Data (only if empty) ────────────────────────────────
        var result = tx.executeSql("SELECT COUNT(*) AS cnt FROM menu")
        if (result.rows.item(0).cnt === 0) {
            // Starters
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Paneer Tikka",     "Grilled cottage cheese with spices",    220, "Starters"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Veg Seekh Kebab",  "Minced vegetable kebab on skewer",      180, "Starters"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Crispy Corn",      "Stir fried crispy corn with seasoning", 150, "Starters"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Veg Spring Roll",  "Crunchy rolls filled with vegetables",  130, "Starters"])

            // Main Course
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Dal Makhani",      "Slow cooked black lentils in cream",    200, "Main Course"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Paneer Butter Masala", "Cottage cheese in rich tomato gravy", 260, "Main Course"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Kolhapuri Misal",  "Spicy sprout curry, Kolhapuri style",   180, "Main Course"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Jeera Rice",       "Basmati rice tempered with cumin",       120, "Main Course"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Garlic Naan",      "Tandoor baked bread with garlic butter",  60, "Main Course"])

            // Chinese
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Veg Fried Rice",   "Wok tossed rice with vegetables",       160, "Chinese"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Veg Noodles",      "Stir fried noodles Indo-Chinese style", 150, "Chinese"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Manchurian",       "Crispy veg balls in Manchurian sauce",  170, "Chinese"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Chilli Paneer",    "Cottage cheese in spicy chilli sauce",  210, "Chinese"])

            // Beverages
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Masala Chai",      "Classic Indian spiced tea",              40, "Beverages"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Mango Lassi",      "Creamy yogurt mango drink",              90, "Beverages"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Fresh Lime Soda",  "Chilled lime soda, sweet or salty",      60, "Beverages"])
            tx.executeSql("INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
                ["Buttermilk",       "Chilled spiced buttermilk (Chaas)",      50, "Beverages"])
        }
    })
}

// ─── Fetch All Menu Items ─────────────────────────────────────────────────
/**
 * getMenuItems - Retrieves all menu items from the database.
 * @returns {Array} Array of menu item objects {id, name, description, price, category}
 */
function getMenuItems() {
    var db = getDatabase()
    var items = []
    db.readTransaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM menu ORDER BY category, name")
        for (var i = 0; i < result.rows.length; i++) {
            items.push(result.rows.item(i))
        }
    })
    return items
}

// ─── Save Order ───────────────────────────────────────────────────────────
/**
 * saveOrder - Saves a placed order into the orders table.
 * @param {string} customerName - Customer's name
 * @param {string} tableNumber  - Table number (as string)
 * @param {string} items        - Summary string of ordered items
 * @param {real}   total        - Total bill amount
 * @returns {bool} true if saved successfully
 */
function saveOrder(customerName, tableNumber, items, total) {
    var db = getDatabase()
    var success = false
    db.transaction(function(tx) {
        var now = new Date().toLocaleString()
        tx.executeSql(
            "INSERT INTO orders (customer_name, table_number, items, total, order_date) VALUES (?, ?, ?, ?, ?)",
            [customerName, tableNumber, items, total, now]
        )
        success = true
    })
    return success
}

// ─── Fetch All Orders ─────────────────────────────────────────────────────
/**
 * getOrders - Retrieves all past orders from the database.
 * @returns {Array} Array of order objects
 */
function getOrders() {
    var db = getDatabase()
    var orders = []
    db.readTransaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM orders ORDER BY id DESC")
        for (var i = 0; i < result.rows.length; i++) {
            orders.push(result.rows.item(i))
        }
    })
    return orders
}

// ─── Clear All Orders (optional utility) ─────────────────────────────────
/**
 * clearOrders - Deletes all records from the orders table.
 * Useful for testing / reset.
 */
function clearOrders() {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("DELETE FROM orders")
    })
}
