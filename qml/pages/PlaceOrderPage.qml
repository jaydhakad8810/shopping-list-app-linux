/**
 * PlaceOrderPage.qml
 * Checkout page where customer enters their details to confirm order.
 *
 * Features:
 *  - Order summary (items + total)
 *  - Customer Name text field
 *  - Table Number text field
 *  - Confirm Order button → saves to SQLite, shows success Dialog
 *  - Cancel button → back to CartPage
 *  - Input validation (checks empty fields)
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../js/CartLogic.js" as Cart
import "../js/Database.js"  as DB

Page {
    id: placeOrderPage

    // ── Signals ───────────────────────────────────────────────────────────
    signal goBack()       // Back to CartPage
    signal orderSuccess() // Navigate to home after success

    // ── Page Header ───────────────────────────────────────────────────────
    header: PageHeader {
        title: "Place Order"
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: placeOrderPage.goBack()
            }
        ]
    }

    // ── Scrollable Content ────────────────────────────────────────────────
    Flickable {
        anchors {
            top:    pageHeader.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        contentHeight: mainColumn.implicitHeight + units.gu(4)
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: units.gu(0)

            // ── Order Summary Card ─────────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: summaryColumn.implicitHeight + units.gu(4)
                color:  "#FFF8F0"

                Column {
                    id: summaryColumn
                    anchors {
                        left:    parent.left
                        right:   parent.right
                        top:     parent.top
                        margins: units.gu(2)
                    }
                    spacing: units.gu(1)

                    Label {
                        text: "📋  Order Summary"
                        fontSize: "medium"
                        font.weight: Font.Bold
                        color: "#E65100"
                    }

                    // Divider
                    Rectangle { width: parent.width; height: 1; color: "#FFE0B2" }

                    // List each cart item
                    Repeater {
                        model: Cart.cartItems

                        Row {
                            width: parent.width
                            spacing: units.gu(1)

                            Label {
                                text:  modelData.name + " × " + modelData.quantity
                                fontSize: "small"
                                color: "#424242"
                                width: parent.width * 0.7
                                wrapMode: Text.WordWrap
                            }

                            Label {
                                text: "₹" + (modelData.price * modelData.quantity).toFixed(0)
                                fontSize: "small"
                                color: "#D84315"
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignRight
                                width: parent.width * 0.3
                            }
                        }
                    }

                    // Divider
                    Rectangle { width: parent.width; height: 1; color: "#FFE0B2" }

                    // Total row
                    Row {
                        width: parent.width

                        Label {
                            text: "Total"
                            fontSize: "medium"
                            font.weight: Font.Bold
                            color: "#212121"
                            width: parent.width / 2
                        }

                        Label {
                            text: "₹" + Cart.getTotal().toFixed(0)
                            fontSize: "large"
                            font.weight: Font.Bold
                            color: "#D84315"
                            horizontalAlignment: Text.AlignRight
                            width: parent.width / 2
                        }
                    }
                }
            }

            // ── Customer Details Form ──────────────────────────────────────
            Rectangle {
                width:  parent.width
                height: formColumn.implicitHeight + units.gu(4)
                color:  "#FFFFFF"

                Column {
                    id: formColumn
                    anchors {
                        left:    parent.left
                        right:   parent.right
                        top:     parent.top
                        margins: units.gu(2)
                    }
                    spacing: units.gu(2)

                    Label {
                        text: "👤  Customer Details"
                        fontSize: "medium"
                        font.weight: Font.Bold
                        color: "#212121"
                    }

                    // ── Customer Name Field ───────────────────────────────
                    Column {
                        width: parent.width
                        spacing: units.gu(0.5)

                        Label {
                            text: "Customer Name *"
                            fontSize: "small"
                            color: "#616161"
                        }

                        TextField {
                            id: customerNameField
                            width: parent.width
                            placeholderText: "Enter your name"
                            // Highlight red border if validation fails
                            style: TextFieldStyle { background: Item {} }
                        }

                        // Validation error text
                        Label {
                            id: nameError
                            text: "⚠ Please enter your name"
                            fontSize: "x-small"
                            color: "#E53935"
                            visible: false
                        }
                    }

                    // ── Table Number Field ────────────────────────────────
                    Column {
                        width: parent.width
                        spacing: units.gu(0.5)

                        Label {
                            text: "Table Number *"
                            fontSize: "small"
                            color: "#616161"
                        }

                        TextField {
                            id: tableNumberField
                            width: parent.width
                            placeholderText: "e.g. 5 or A2"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            style: TextFieldStyle { background: Item {} }
                        }

                        Label {
                            id: tableError
                            text: "⚠ Please enter your table number"
                            fontSize: "x-small"
                            color: "#E53935"
                            visible: false
                        }
                    }

                    // ── Buttons Row ────────────────────────────────────────
                    Row {
                        width: parent.width
                        spacing: units.gu(1.5)

                        // Cancel button
                        Button {
                            width:  parent.width * 0.35
                            height: units.gu(5.5)
                            text:   "Cancel"
                            color:  "#9E9E9E"
                            onClicked: placeOrderPage.goBack()
                        }

                        // Confirm Order button
                        Button {
                            id: confirmBtn
                            width:  parent.width * 0.60
                            height: units.gu(5.5)
                            text:   "✓  Confirm Order"
                            color:  "#FF6F00"

                            onClicked: {
                                // ── Input Validation ────────────────────
                                var valid = true

                                if (customerNameField.text.trim() === "") {
                                    nameError.visible = true
                                    valid = false
                                } else {
                                    nameError.visible = false
                                }

                                if (tableNumberField.text.trim() === "") {
                                    tableError.visible = true
                                    valid = false
                                } else {
                                    tableError.visible = false
                                }

                                if (!valid) return  // Stop if any field empty

                                // ── Save Order to SQLite ─────────────────
                                var name   = customerNameField.text.trim()
                                var table  = tableNumberField.text.trim()
                                var items  = Cart.getItemsString()
                                var total  = Cart.getTotal()

                                var saved = DB.saveOrder(name, table, items, total)

                                if (saved) {
                                    // Clear the cart after successful order
                                    Cart.clearCart()
                                    // Show success popup
                                    PopupUtils.open(successDialog)
                                } else {
                                    // Show error (very unlikely)
                                    PopupUtils.open(errorDialog)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Success Dialog ────────────────────────────────────────────────────
    Component {
        id: successDialog

        Dialog {
            id: successPopup
            title: "Order Placed! 🎉"

            Column {
                spacing: units.gu(2)
                width: parent.width

                Label {
                    width: parent.width
                    text: "Your order has been placed successfully!\n\nThank you, " +
                          customerNameField.text.trim() + ".\n" +
                          "Table " + tableNumberField.text.trim() + " will be served shortly."
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    color: "#212121"
                }

                Button {
                    width: parent.width
                    text:  "Back to Menu"
                    color: "#FF6F00"
                    onClicked: {
                        PopupUtils.close(successPopup)
                        placeOrderPage.orderSuccess()  // Navigate to home
                    }
                }
            }
        }
    }

    // ── Error Dialog ──────────────────────────────────────────────────────
    Component {
        id: errorDialog

        Dialog {
            id: errorPopup
            title: "Error"

            Label {
                text: "Failed to place order. Please try again."
                wrapMode: Text.WordWrap
                color: "#E53935"
            }

            Button {
                text:  "OK"
                color: "#9E9E9E"
                onClicked: PopupUtils.close(errorPopup)
            }
        }
    }
}
