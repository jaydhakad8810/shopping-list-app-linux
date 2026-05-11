/**
 * CartPage.qml
 * Shows the current cart with all added items.
 *
 * Features:
 *  - List of cart items using CartItemRow component
 *  - Increase / decrease quantity controls
 *  - Remove item button
 *  - Live total bill calculation
 *  - "Place Order" button → navigates to PlaceOrderPage
 *  - "Continue Shopping" button → back to HomePage
 *  - Empty cart state
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import "../js/CartLogic.js" as Cart
import "../components"

Page {
    id: cartPage

    // ── Signals ───────────────────────────────────────────────────────────
    signal goBack()          // Back to HomePage
    signal goToPlaceOrder()  // Proceed to checkout

    // ── Page Header ───────────────────────────────────────────────────────
    header: PageHeader {
        title: "My Cart"
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: cartPage.goBack()
            }
        ]
    }

    // ── Refresh cart data every time page is shown ─────────────────────────
    // Called from Main.qml when navigating to this page
    function refreshCart() {
        cartModel.clear()
        var items = Cart.cartItems
        for (var i = 0; i < items.length; i++) {
            cartModel.append({
                itemId:       items[i].id,
                itemName:     items[i].name,
                itemPrice:    items[i].price,
                itemQuantity: items[i].quantity
            })
        }
        updateTotal()
    }

    // ── Calculate and update total ─────────────────────────────────────────
    function updateTotal() {
        totalAmount = Cart.getTotal()
    }

    property real totalAmount: 0.0

    // ── Main Layout ───────────────────────────────────────────────────────
    Column {
        anchors {
            top:    pageHeader.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }

        // ── Cart Items List ────────────────────────────────────────────────
        ListView {
            id: cartListView
            width:  parent.width
            // Leave room for the footer (total + button)
            height: parent.height - footerRect.height
            clip:   true

            model: ListModel { id: cartModel }

            delegate: CartItemRow {
                itemName:     model.itemName
                itemQuantity: model.itemQuantity
                itemPrice:    model.itemPrice

                // Increase quantity
                onIncrease: {
                    Cart.increaseQty(model.itemId)
                    refreshCart()
                }

                // Decrease quantity (removes if qty reaches 0)
                onDecrease: {
                    Cart.decreaseQty(model.itemId)
                    refreshCart()
                }

                // Remove item completely
                onRemove: {
                    Cart.removeItem(model.itemId)
                    refreshCart()
                }
            }

            // ── Empty Cart State ──────────────────────────────────────────
            Column {
                anchors.centerIn: parent
                spacing: units.gu(2)
                visible: cartModel.count === 0

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🛒"
                    fontSize: "x-large"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Your cart is empty"
                    fontSize: "large"
                    color: "#9E9E9E"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Go back and add some delicious items!"
                    fontSize: "small"
                    color: "#BDBDBD"
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  "Browse Menu"
                    color: "#FF6F00"
                    onClicked: cartPage.goBack()
                }
            }
        }

        // ── Footer: Total + Place Order Button ────────────────────────────
        Rectangle {
            id: footerRect
            width:  parent.width
            height: units.gu(16)
            color:  "#FFFFFF"

            // Top border
            Rectangle {
                anchors.top: parent.top
                width: parent.width; height: 1
                color: "#EEEEEE"
            }

            Column {
                anchors {
                    fill:    parent
                    margins: units.gu(2)
                }
                spacing: units.gu(1)

                // ── Bill Summary ──────────────────────────────────────────
                Row {
                    width: parent.width

                    Label {
                        text: "Items in Cart:"
                        fontSize: "small"
                        color: "#757575"
                        width: parent.width / 2
                    }

                    Label {
                        text: Cart.getCount() + " item(s)"
                        fontSize: "small"
                        color: "#212121"
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignRight
                        width: parent.width / 2
                    }
                }

                Row {
                    width: parent.width

                    Label {
                        text: "Total Amount:"
                        fontSize: "medium"
                        font.weight: Font.Bold
                        color: "#212121"
                        width: parent.width / 2
                    }

                    Label {
                        text: "₹" + totalAmount.toFixed(0)
                        fontSize: "large"
                        font.weight: Font.Bold
                        color: "#D84315"
                        horizontalAlignment: Text.AlignRight
                        width: parent.width / 2
                    }
                }

                // ── Place Order Button ────────────────────────────────────
                Button {
                    width:  parent.width
                    height: units.gu(5.5)
                    text:   cartModel.count > 0 ? "Proceed to Place Order  →" : "Cart is Empty"
                    color:  cartModel.count > 0 ? "#FF6F00" : "#BDBDBD"
                    enabled: cartModel.count > 0

                    onClicked: {
                        if (Cart.cartItems.length > 0) {
                            cartPage.goToPlaceOrder()
                        }
                    }
                }
            }
        }
    }
}
