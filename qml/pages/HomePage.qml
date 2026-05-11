/**
 * HomePage.qml
 * The main landing page of the Kolhapuri Pure Veg app.
 *
 * Features:
 *  - Restaurant header with name and tagline
 *  - Category filter buttons (All, Starters, Main Course, Chinese, Beverages)
 *  - Search bar to filter items by name
 *  - Scrollable list of MenuItemCard components
 *  - Cart badge showing number of items in cart
 *
 * Navigation:
 *  - Tapping cart icon → CartPage
 *  - Tapping Order History → OrderHistoryPage
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import "../js/Database.js"  as DB
import "../js/CartLogic.js" as Cart
import "../components"

Page {
    id: homePage

    // ── Signals to parent (MainView) for navigation ────────────────────
    signal goToCart()
    signal goToOrderHistory()

    // ── Page Header ───────────────────────────────────────────────────────
    header: PageHeader {
        id: pageHeader
        title: "Kolhapuri Pure Veg"

        // Cart button in the header
        trailingActionBar.actions: [
            Action {
                iconName: "non-starred"  // Cart-like icon
                text:     "Cart (" + cartBadgeCount + ")"
                onTriggered: homePage.goToCart()
            },
            Action {
                iconName: "history"
                text:     "Order History"
                onTriggered: homePage.goToOrderHistory()
            }
        ]
    }

    // ── State ─────────────────────────────────────────────────────────────
    property int    cartBadgeCount:      0    // Updates when item added
    property string selectedCategory:    "All"
    property string searchText:          ""
    property var    allMenuItems:        []   // Full menu from DB
    property var    filteredItems:       []   // After filter/search applied

    // ── Load menu from DB when page is ready ──────────────────────────────
    Component.onCompleted: {
        allMenuItems = DB.getMenuItems()
        applyFilter()
    }

    // ── Called when returning from CartPage to update badge ───────────────
    function refreshCartBadge() {
        cartBadgeCount = Cart.getCount()
    }

    // ── Filter & Search Logic (JavaScript) ───────────────────────────────
    /**
     * applyFilter - Filters allMenuItems by category and search text,
     * then updates filteredItems which drives the ListView.
     */
    function applyFilter() {
        var result = []
        var query  = searchText.toLowerCase().trim()

        for (var i = 0; i < allMenuItems.length; i++) {
            var item = allMenuItems[i]

            // Category filter
            var categoryMatch = (selectedCategory === "All") ||
                                (item.category === selectedCategory)

            // Search filter (case-insensitive name match)
            var searchMatch = (query === "") ||
                              (item.name.toLowerCase().indexOf(query) !== -1)

            if (categoryMatch && searchMatch) {
                result.push(item)
            }
        }

        filteredItems = result
        menuModel.clear()
        for (var j = 0; j < result.length; j++) {
            menuModel.append(result[j])
        }
    }

    // ── Main Content ──────────────────────────────────────────────────────
    Column {
        anchors {
            top:    pageHeader.bottom
            left:   parent.left
            right:  parent.right
            bottom: parent.bottom
        }

        // ── Restaurant Banner ──────────────────────────────────────────────
        Rectangle {
            width:  parent.width
            height: units.gu(10)
            color:  "#FF6F00"  // Orange brand color

            Column {
                anchors.centerIn: parent
                spacing: units.gu(0.4)

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  "🌿 Kolhapuri Pure Veg"
                    fontSize: "large"
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:  "Authentic Flavors | Pure Vegetarian"
                    fontSize: "small"
                    color: "#FFE0B2"
                }
            }
        }

        // ── Search Bar ─────────────────────────────────────────────────────
        Rectangle {
            width:  parent.width
            height: units.gu(6)
            color:  "#FFF8F0"

            TextField {
                id: searchField
                anchors {
                    left:           parent.left
                    right:          parent.right
                    verticalCenter: parent.verticalCenter
                    margins:        units.gu(1.5)
                }
                placeholderText: "🔍  Search food items..."
                onTextChanged: {
                    searchText = text
                    applyFilter()
                }
                // Simple style overrides
                style: TextFieldStyle { background: Item {} }
            }

            // Bottom border line
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: "#FFE0B2"
            }
        }

        // ── Category Filter Buttons ────────────────────────────────────────
        Rectangle {
            width:  parent.width
            height: units.gu(6.5)
            color:  "#FFFFFF"

            // Horizontal scrollable row of category buttons
            ScrollView {
                anchors.fill: parent
                // Hide scroll bars (they appear on scroll)
                Row {
                    anchors {
                        left:           parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin:     units.gu(1)
                    }
                    spacing: units.gu(1)

                    // Create one button per category
                    Repeater {
                        model: ["All", "Starters", "Main Course", "Chinese", "Beverages"]

                        Rectangle {
                            width:  catLabel.implicitWidth + units.gu(3)
                            height: units.gu(4)
                            radius: units.gu(2)
                            // Active category is orange, inactive is outlined
                            color: selectedCategory === modelData ? "#FF6F00" : "#FFFFFF"
                            border.color: selectedCategory === modelData ? "#FF6F00" : "#BDBDBD"
                            border.width: 1

                            Label {
                                id: catLabel
                                anchors.centerIn: parent
                                text:  modelData
                                fontSize: "small"
                                color: selectedCategory === modelData ? "#FFFFFF" : "#616161"
                                font.weight: selectedCategory === modelData ? Font.Bold : Font.Normal
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    selectedCategory = modelData
                                    applyFilter()
                                }
                            }
                        }
                    }

                    // Extra right padding
                    Item { width: units.gu(1); height: 1 }
                }
            }

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: "#EEEEEE"
            }
        }

        // ── Menu Items List ────────────────────────────────────────────────
        // The list takes remaining vertical space
        ListView {
            id: menuListView
            width:  parent.width
            height: parent.height - units.gu(10) - units.gu(6) - units.gu(6.5)
            clip:   true  // Clip content to bounds

            // Model populated by applyFilter()
            model: ListModel { id: menuModel }

            // Delegate uses our MenuItemCard component
            delegate: MenuItemCard {
                itemId:          model.id
                itemName:        model.name
                itemDescription: model.description
                itemPrice:       model.price
                itemCategory:    model.category

                // Handle add-to-cart signal from card
                onAddToCart: function(id, name, price) {
                    Cart.addItem(id, name, price)
                    cartBadgeCount = Cart.getCount()
                    // Show brief toast notification
                    addedToast.itemAddedName = name
                    addedToast.visible = true
                    toastTimer.restart()
                }
            }

            // Empty state message
            Label {
                anchors.centerIn: parent
                text: "No items found.\nTry a different search or category."
                horizontalAlignment: Text.AlignHCenter
                color: "#BDBDBD"
                visible: menuModel.count === 0
            }
        }
    }

    // ── Toast Notification (brief "Added to Cart" message) ───────────────
    Rectangle {
        id: addedToast
        property string itemAddedName: ""
        visible: false
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: units.gu(3)
        }
        width:  toastLabel.implicitWidth + units.gu(4)
        height: units.gu(4.5)
        radius: units.gu(2)
        color:  "#323232"
        opacity: 0.9
        z: 100  // Above everything

        Label {
            id: toastLabel
            anchors.centerIn: parent
            text: "✓  " + addedToast.itemAddedName + " added to cart"
            fontSize: "small"
            color: "#FFFFFF"
        }

        Timer {
            id: toastTimer
            interval: 2000  // Show for 2 seconds
            onTriggered: addedToast.visible = false
        }
    }
}
