/**
 * MenuItemCard.qml
 * A reusable card component that displays a single food item.
 * Shows: Name, Category badge, Description, Price, and "Add to Cart" button.
 *
 * Usage:
 *   MenuItemCard {
 *       itemId:          model.id
 *       itemName:        model.name
 *       itemDescription: model.description
 *       itemPrice:       model.price
 *       itemCategory:    model.category
 *       onAddToCart: function(id, name, price) { ... }
 *   }
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

// ── Root Item ────────────────────────────────────────────────────────────
Item {
    id: root

    // ── Properties (set by parent ListView) ──────────────────────────────
    property int    itemId:          0
    property string itemName:        ""
    property string itemDescription: ""
    property real   itemPrice:       0.0
    property string itemCategory:    ""

    // ── Signal emitted when user taps "Add to Cart" ───────────────────────
    signal addToCart(int id, string name, real price)

    // ── Card size ─────────────────────────────────────────────────────────
    width:  parent ? parent.width : units.gu(40)  // Full width of list
    height: cardColumn.implicitHeight + units.gu(3)

    // ── Card Background ───────────────────────────────────────────────────
    Rectangle {
        id: cardRect
        anchors.fill: parent
        anchors.margins: units.gu(1)
        color:  "#FFFFFF"                   // White card background
        radius: units.gu(1.2)               // Rounded corners
        border.color: "#E8E8E8"             // Light grey border
        border.width: 1

        // Subtle shadow using a slightly darker rectangle behind
        layer.enabled: true
        layer.effect: null  // Simple approach without ShaderEffect

        // ── Card Content Layout ───────────────────────────────────────────
        Column {
            id: cardColumn
            anchors {
                left:   parent.left
                right:  parent.right
                top:    parent.top
                margins: units.gu(1.5)
            }
            spacing: units.gu(0.5)

            // ── Category Badge + Item Name Row ────────────────────────────
            Row {
                width: parent.width
                spacing: units.gu(1)

                // Category badge (small colored tag)
                Rectangle {
                    width:  categoryLabel.implicitWidth + units.gu(1.5)
                    height: units.gu(2.5)
                    radius: units.gu(1)
                    color: {
                        // Different color per category
                        if (itemCategory === "Starters")    return "#FFF3E0"
                        if (itemCategory === "Main Course") return "#E8F5E9"
                        if (itemCategory === "Chinese")     return "#E3F2FD"
                        if (itemCategory === "Beverages")   return "#F3E5F5"
                        return "#F5F5F5"
                    }

                    Label {
                        id: categoryLabel
                        anchors.centerIn: parent
                        text: itemCategory
                        fontSize: "x-small"
                        color: {
                            if (itemCategory === "Starters")    return "#E65100"
                            if (itemCategory === "Main Course") return "#2E7D32"
                            if (itemCategory === "Chinese")     return "#1565C0"
                            if (itemCategory === "Beverages")   return "#6A1B9A"
                            return "#616161"
                        }
                        font.weight: Font.Medium
                    }
                }
            }

            // ── Item Name ─────────────────────────────────────────────────
            Label {
                width: parent.width
                text:  itemName
                fontSize: "medium"
                font.weight: Font.Bold
                color: "#212121"
                wrapMode: Text.WordWrap
            }

            // ── Description ───────────────────────────────────────────────
            Label {
                width: parent.width
                text:  itemDescription
                fontSize: "small"
                color: "#757575"
                wrapMode: Text.WordWrap
            }

            // ── Price + Add Button Row ─────────────────────────────────────
            Item {
                width:  parent.width
                height: units.gu(5)

                // Price label on the left
                Label {
                    anchors {
                        left:           parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    text:  "₹" + itemPrice.toFixed(0)
                    fontSize: "large"
                    font.weight: Font.Bold
                    color: "#D84315"  // Deep orange - food brand color
                }

                // "Add to Cart" button on the right
                Button {
                    id: addBtn
                    anchors {
                        right:          parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width:  units.gu(14)
                    height: units.gu(4)
                    text:   "Add to Cart"
                    color:  "#FF6F00"  // Amber/orange button

                    onClicked: {
                        // Emit signal back to parent page
                        root.addToCart(itemId, itemName, itemPrice)
                        // Visual feedback - brief color flash
                        addBtn.color = "#E65100"
                        colorResetTimer.restart()
                    }

                    // Reset button color after feedback
                    Timer {
                        id: colorResetTimer
                        interval: 300
                        onTriggered: addBtn.color = "#FF6F00"
                    }
                }
            }

            // Bottom spacing inside card
            Item { width: 1; height: units.gu(0.5) }
        }
    }
}
