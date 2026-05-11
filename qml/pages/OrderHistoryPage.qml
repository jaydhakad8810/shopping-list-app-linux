/**
 * OrderHistoryPage.qml
 * Displays the complete history of all past orders from SQLite.
 *
 * Features:
 *  - Fetches all orders from the 'orders' table using Database.js
 *  - Each order displayed in a card showing:
 *      • Customer name
 *      • Table number
 *      • Items ordered
 *      • Total amount
 *      • Date/time of order
 *  - Empty state if no orders exist yet
 *  - Back button to return to HomePage
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import "../js/Database.js" as DB

Page {
    id: orderHistoryPage

    // ── Signal ────────────────────────────────────────────────────────────
    signal goBack()  // Navigate back to HomePage

    // ── Page Header ───────────────────────────────────────────────────────
    header: PageHeader {
        title: "Order History"
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: orderHistoryPage.goBack()
            }
        ]
    }

    // ── Load orders from DB when page is shown ────────────────────────────
    // Called by Main.qml when navigating to this page
    function refreshOrders() {
        ordersModel.clear()
        var orders = DB.getOrders()
        for (var i = 0; i < orders.length; i++) {
            ordersModel.append(orders[i])
        }
    }

    Component.onCompleted: refreshOrders()

    // ── Orders List ───────────────────────────────────────────────────────
    ListView {
        id: ordersListView
        anchors {
            top:    pageHeader.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }
        clip: true
        spacing: 0

        // Model populated by refreshOrders()
        model: ListModel { id: ordersModel }

        // ── Order Card Delegate ───────────────────────────────────────────
        delegate: Rectangle {
            width:  parent ? parent.width : units.gu(40)
            height: orderCardColumn.implicitHeight + units.gu(3)
            color:  "#FFFFFF"

            // Bottom border between cards
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: "#EEEEEE"
            }

            // Left color accent bar
            Rectangle {
                width:  units.gu(0.5)
                height: parent.height
                color:  "#FF6F00"
            }

            Column {
                id: orderCardColumn
                anchors {
                    left:    parent.left
                    right:   parent.right
                    top:     parent.top
                    margins: units.gu(1.5)
                    leftMargin: units.gu(2)
                }
                spacing: units.gu(0.6)

                // ── Header Row: Order # + Date ────────────────────────────
                Row {
                    width: parent.width
                    spacing: units.gu(1)

                    // Order number badge
                    Rectangle {
                        width:  orderNumLabel.implicitWidth + units.gu(1.5)
                        height: units.gu(2.5)
                        radius: units.gu(0.5)
                        color:  "#FF6F00"

                        Label {
                            id: orderNumLabel
                            anchors.centerIn: parent
                            text:  "Order #" + model.id
                            fontSize: "x-small"
                            color: "#FFFFFF"
                            font.weight: Font.Bold
                        }
                    }

                    Label {
                        text:  model.order_date
                        fontSize: "x-small"
                        color: "#9E9E9E"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ── Customer + Table Row ──────────────────────────────────
                Row {
                    width: parent.width
                    spacing: units.gu(2)

                    Label {
                        text: "👤 " + model.customer_name
                        fontSize: "small"
                        font.weight: Font.Bold
                        color: "#212121"
                    }

                    Label {
                        text: "🪑 Table " + model.table_number
                        fontSize: "small"
                        color: "#616161"
                    }
                }

                // ── Items Ordered ─────────────────────────────────────────
                Label {
                    width: parent.width
                    text:  "🍽  " + model.items
                    fontSize: "small"
                    color: "#424242"
                    wrapMode: Text.WordWrap
                }

                // ── Total Amount ──────────────────────────────────────────
                Row {
                    width: parent.width

                    // Label
                    Label {
                        text: "Bill Total: "
                        fontSize: "small"
                        color: "#757575"
                    }

                    Label {
                        text: "₹" + parseFloat(model.total).toFixed(0)
                        fontSize: "medium"
                        font.weight: Font.Bold
                        color: "#D84315"
                    }
                }

                // Bottom spacing inside card
                Item { width: 1; height: units.gu(0.5) }
            }
        }

        // ── Empty State ───────────────────────────────────────────────────
        Column {
            anchors.centerIn: parent
            spacing: units.gu(2)
            visible: ordersModel.count === 0

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📄"
                fontSize: "x-large"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No orders yet"
                fontSize: "large"
                color: "#9E9E9E"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Place your first order from the menu!"
                fontSize: "small"
                color: "#BDBDBD"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
