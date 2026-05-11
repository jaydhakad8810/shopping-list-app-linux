## Qt Project File for Kolhapuri Pure Veg Restaurant App
## This tells qmake how to build and install the QML app

TEMPLATE = app
TARGET = kolhapuri

# Use Qt Quick / QML modules
QT += qml quick

# Include all QML source files
SOURCES +=

# QML files to include in the project (for IDE support)
OTHER_FILES += \
    qml/Main.qml \
    qml/pages/HomePage.qml \
    qml/pages/CartPage.qml \
    qml/pages/PlaceOrderPage.qml \
    qml/pages/OrderHistoryPage.qml \
    qml/components/MenuItemCard.qml \
    qml/components/CartItemRow.qml \
    qml/js/CartLogic.js \
    qml/js/Database.js \
    manifest.json.in \
    kolhapuri.apparmor \
    kolhapuri.desktop

# Install rules
qml_files.files = qml
qml_files.path = /

assets_files.files = assets
assets_files.path = /

INSTALLS += qml_files assets_files

# Entry point
DISTFILES += \
    clickable.yaml
