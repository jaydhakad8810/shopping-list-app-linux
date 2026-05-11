/**
 * Main.qml
 * Entry point of the Kolhapuri Pure Veg Restaurant Ordering App.
 *
 * This file:
 *  1. Initializes the SQLite database on startup
 *  2. Sets up the main window (MainView)
 *  3. Manages page navigation via a PageStack
 *  4. Contains all 4 pages: Home, Cart, PlaceOrder, OrderHistory
 *
 * Pages:
 *  - HomePage         → Browse menu, search, filter, add to cart
 *  - CartPage         → View cart, modify quantities, see total
 *  - PlaceOrderPage   → Enter customer details, confirm order
 *  - OrderHistoryPage → View all past orders from SQLite
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import Ubuntu.Components 1.3
import "pages"
import "js/Database.js" as DB

// ── MainView: The root Ubuntu Touch component ─────────────────────────────
MainView {
    id: app

    // App identifier (must match manifest.json.in)
    applicationName: "kolhapuri.pure.veg"

    // Window size (Ubuntu Touch adapts this to screen size automatically)
    width:  units.gu(45)   // ~360dp equivalent
    height: units.gu(80)   // ~640dp equivalent

    // ── App-wide color theme ──────────────────────────────────────────────
    theme.name: "Ubuntu.Components.Themes.Ambiance"

    // ── Initialize Database on App Start ──────────────────────────────────
    Component.onCompleted: {
        // Create tables and seed menu data if first run
        DB.initDatabase()
        console.log("Kolhapuri Pure Veg: Database initialized.")
    }

    // ── PageStack: Manages navigation between pages ───────────────────────
    // PageStack works like a navigation stack:
    //   push(page) → goes to new page
    //   pop()      → goes back to previous page
    PageStack {
        id: pageStack
        anchors.fill: parent

        // Start on the HomePage when app launches
        Component.onCompleted: {
            pageStack.push(homePage)
        }

        // ── Page 1: Home Page ─────────────────────────────────────────────
        HomePage {
            id: homePage

            // Navigate to CartPage
            onGoToCart: {
                pageStack.push(cartPage)
                cartPage.refreshCart()         // Load latest cart data
            }

            // Navigate to OrderHistoryPage
            onGoToOrderHistory: {
                pageStack.push(orderHistoryPage)
                orderHistoryPage.refreshOrders()  // Load latest orders from DB
            }
        }

        // ── Page 2: Cart Page ─────────────────────────────────────────────
        CartPage {
            id: cartPage
            visible: false  // Hidden until pushed onto stack

            // Go back to HomePage
            onGoBack: {
                pageStack.pop()
                homePage.refreshCartBadge()    // Update cart count badge
            }

            // Go to PlaceOrder page
            onGoToPlaceOrder: {
                pageStack.push(placeOrderPage)
            }
        }

        // ── Page 3: Place Order Page ──────────────────────────────────────
        PlaceOrderPage {
            id: placeOrderPage
            visible: false

            // Go back to CartPage (cancelled)
            onGoBack: {
                pageStack.pop()
            }

            // Order confirmed successfully → go all the way back to Home
            onOrderSuccess: {
                // Pop PlaceOrder and Cart pages, land on Home
                pageStack.pop()  // Pop PlaceOrderPage → CartPage
                pageStack.pop()  // Pop CartPage → HomePage
                homePage.refreshCartBadge()    // Badge should now be 0
            }
        }

        // ── Page 4: Order History Page ─────────────────────────────────────
        OrderHistoryPage {
            id: orderHistoryPage
            visible: false

            // Go back to HomePage
            onGoBack: {
                pageStack.pop()
            }
        }
    }
}
