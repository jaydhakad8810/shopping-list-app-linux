/**
 * CartLogic.js
 * Handles all cart operations: add, remove, update quantity, calculate total.
 * This is a shared JS library imported by QML pages.
 */

.pragma library  // Ensures this file is a shared singleton (not per-component)

// ─── Cart Storage ──────────────────────────────────────────────────────────
// cartItems is an array of objects:
// { id, name, price, quantity }
var cartItems = []

// ─── Add Item to Cart ──────────────────────────────────────────────────────
/**
 * addItem - Adds a menu item to the cart.
 * If item already exists, increases its quantity by 1.
 * @param {int}    id    - Unique item ID
 * @param {string} name  - Item name
 * @param {real}   price - Item price in rupees
 */
function addItem(id, name, price) {
    // Check if item already exists in cart
    for (var i = 0; i < cartItems.length; i++) {
        if (cartItems[i].id === id) {
            cartItems[i].quantity += 1
            return  // Item found and updated, no need to add again
        }
    }
    // Item not found → add new entry
    cartItems.push({ id: id, name: name, price: price, quantity: 1 })
}

// ─── Remove Item from Cart ────────────────────────────────────────────────
/**
 * removeItem - Removes an item completely from the cart.
 * @param {int} id - Unique item ID to remove
 */
function removeItem(id) {
    for (var i = 0; i < cartItems.length; i++) {
        if (cartItems[i].id === id) {
            cartItems.splice(i, 1)  // Remove item at index i
            return
        }
    }
}

// ─── Increase Quantity ────────────────────────────────────────────────────
/**
 * increaseQty - Increases an item's quantity by 1.
 * @param {int} id - Item ID
 */
function increaseQty(id) {
    for (var i = 0; i < cartItems.length; i++) {
        if (cartItems[i].id === id) {
            cartItems[i].quantity += 1
            return
        }
    }
}

// ─── Decrease Quantity ────────────────────────────────────────────────────
/**
 * decreaseQty - Decreases an item's quantity by 1.
 * If quantity becomes 0, the item is removed from cart.
 * @param {int} id - Item ID
 */
function decreaseQty(id) {
    for (var i = 0; i < cartItems.length; i++) {
        if (cartItems[i].id === id) {
            if (cartItems[i].quantity > 1) {
                cartItems[i].quantity -= 1
            } else {
                cartItems.splice(i, 1)  // Remove if qty reaches 0
            }
            return
        }
    }
}

// ─── Calculate Total ──────────────────────────────────────────────────────
/**
 * getTotal - Calculates the total price of all items in the cart.
 * @returns {real} Total amount in rupees
 */
function getTotal() {
    var total = 0
    for (var i = 0; i < cartItems.length; i++) {
        total += cartItems[i].price * cartItems[i].quantity
    }
    return total
}

// ─── Get Cart Count ───────────────────────────────────────────────────────
/**
 * getCount - Returns the total number of individual items in cart.
 * @returns {int} Number of items
 */
function getCount() {
    var count = 0
    for (var i = 0; i < cartItems.length; i++) {
        count += cartItems[i].quantity
    }
    return count
}

// ─── Clear Cart ───────────────────────────────────────────────────────────
/**
 * clearCart - Empties the entire cart after order is placed.
 */
function clearCart() {
    cartItems = []
}

// ─── Get Items as String ──────────────────────────────────────────────────
/**
 * getItemsString - Returns a summary string of all cart items.
 * Used when saving orders to the database.
 * @returns {string} e.g. "Paneer Tikka x2, Dal Makhani x1"
 */
function getItemsString() {
    var parts = []
    for (var i = 0; i < cartItems.length; i++) {
        parts.push(cartItems[i].name + " x" + cartItems[i].quantity)
    }
    return parts.join(", ")
}
