/**
 * CartItemRow.qml
 * A reusable row component for the Cart Page.
 * Displays: Item name, quantity controls (- / +), per-item price, subtotal.
 * Provides buttons to increase, decrease, or remove the item.
 *
 * Usage:
 *   CartItemRow {
 *       itemName:     "Paneer Tikka"
 *       itemQuantity: 2
 *       itemPrice:    220
 *       onIncrease: function() { ... }
 *       onDecrease: function() { ... }
 *       onRemove:   function() { ... }
 *   }
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

Item {
    id: root

    // ── Properties ────────────────────────────────────────────────────────
    property string itemName:     ""
    property int    itemQuantity: 1
    property real   itemPrice:    0.0

    // ── Signals ───────────────────────────────────────────────────────────
    signal increase()
    signal decrease()
    signal remove()

    // ── Size ──────────────────────────────────────────────────────────────
    width:  parent ? parent.width : units.gu(40)
    height: units.gu(8)

    // ── Divider Line ──────────────────────────────────────────────────────
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#EEEEEE"
    }

    // ── Row Layout ────────────────────────────────────────────────────────
    Row {
        anchors {
            fill:    parent
            margins: units.gu(1)
        }
        spacing: units.gu(1)

        // ── Item Info (Name + Price per unit) ─────────────────────────────
        Column {
            width:   parent.width * 0.4
            anchors.verticalCenter: parent.verticalCenter
            spacing: units.gu(0.3)

            Label {
                width: parent.width
                text:  itemName
                fontSize: "small"
                font.weight: Font.Bold
                color: "#212121"
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            Label {
                text:  "₹" + itemPrice.toFixed(0) + " each"
                fontSize: "x-small"
                color: "#9E9E9E"
            }
        }

        // ── Quantity Controls: [ - ] qty [ + ] ────────────────────────────
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: units.gu(0.8)

            // Decrease / Remove button
            Rectangle {
                width:  units.gu(3.5)
                height: units.gu(3.5)
                radius: units.gu(0.5)
                color:  decreaseMouse.containsMouse ? "#FFCCBC" : "#FFF3E0"
                border.color: "#FF6F00"
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: "−"
                    fontSize: "medium"
                    color: "#FF6F00"
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: decreaseMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.decrease()
                }
            }

            // Quantity display
            Label {
                width: units.gu(4)
                text:  itemQuantity
                fontSize: "medium"
                font.weight: Font.Bold
                color: "#212121"
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            // Increase button
            Rectangle {
                width:  units.gu(3.5)
                height: units.gu(3.5)
                radius: units.gu(0.5)
                color:  increaseMouse.containsMouse ? "#FF8F00" : "#FF6F00"
                border.color: "#E65100"
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: "+"
                    fontSize: "medium"
                    color: "#FFFFFF"
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: increaseMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.increase()
                }
            }
        }

        // Spacer
        Item { width: units.gu(1); height: 1 }

        // ── Subtotal for this item ────────────────────────────────────────
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: units.gu(0.2)

            Label {
                text: "₹" + (itemPrice * itemQuantity).toFixed(0)
                fontSize: "medium"
                font.weight: Font.Bold
                color: "#D84315"
                horizontalAlignment: Text.AlignRight
            }

            Label {
                text: "subtotal"
                fontSize: "x-small"
                color: "#BDBDBD"
            }
        }

        // Spacer
        Item { width: units.gu(0.5); height: 1 }

        // ── Remove (×) Button ────────────────────────────────────────────
        Rectangle {
            width:  units.gu(3.5)
            height: units.gu(3.5)
            radius: units.gu(1.75)  // Circle
            color:  removeMouse.containsMouse ? "#FFCDD2" : "#FFFFFF"
            border.color: "#EF9A9A"
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Label {
                anchors.centerIn: parent
                text: "×"
                fontSize: "medium"
                color: "#E53935"
                font.weight: Font.Bold
            }

            MouseArea {
                id: removeMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.remove()
            }
        }
    }
}
