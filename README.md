# 🌿 Kolhapuri Pure Veg — Ubuntu Touch Restaurant Ordering App

A simple, clean, fully functional restaurant ordering application built for Ubuntu Touch using QML, QtQuick, Ubuntu.Components, and SQLite.

---

## 📱 Features

| Feature | Description |
|---|---|
| **Home Page** | Browse menu by category, search by name |
| **Menu Items** | Name, description, price, "Add to Cart" button |
| **Category Filter** | Starters · Main Course · Chinese · Beverages |
| **Search** | Real-time JavaScript-based name filtering |
| **Cart** | Add/remove items, adjust quantities, view total |
| **Place Order** | Enter name + table number, validates input, saves to SQLite |
| **Order History** | View all past orders from local SQLite database |

---

## 🗂️ Project Structure

```
restaurantordering/
│
├── qml/
│   ├── Main.qml                   ← App entry point, PageStack navigation
│   ├── pages/
│   │   ├── HomePage.qml           ← Menu browser + search + category filter
│   │   ├── CartPage.qml           ← Cart view with quantity controls
│   │   ├── PlaceOrderPage.qml     ← Checkout form + success dialog
│   │   └── OrderHistoryPage.qml   ← Past orders from SQLite
│   ├── components/
│   │   ├── MenuItemCard.qml       ← Reusable food item card
│   │   └── CartItemRow.qml        ← Reusable cart item row
│   └── js/
│       ├── CartLogic.js           ← Cart state (add/remove/qty/total)
│       └── Database.js            ← SQLite operations via LocalStorage
│
├── backend/
│   ├── app.py                     ← Flask REST API (optional)
│   ├── requirements.txt           ← Python dependencies
│   └── database.db                ← Created automatically on first run
│
├── assets/                        ← App icons and images
├── clickable.yaml                 ← Clickable build config
├── manifest.json.in               ← Ubuntu Touch app manifest
├── kolhapuri.apparmor             ← AppArmor security policy
├── kolhapuri.desktop              ← App launcher entry
├── restaurantordering.pro         ← Qt project file
└── README.md                      ← This file
```

---

## 🏗️ Architecture

### QML Frontend (Ubuntu Touch)

```
MainView
  └── PageStack
        ├── HomePage          ← Browse menu, search, filter
        │     └── MenuItemCard (component, repeated)
        ├── CartPage          ← View/edit cart
        │     └── CartItemRow (component, repeated)
        ├── PlaceOrderPage    ← Checkout + confirm
        └── OrderHistoryPage  ← Past orders
```

### JavaScript Modules

- **`CartLogic.js`** — Shared `.pragma library` singleton. Holds the cart array in memory. Methods: `addItem`, `removeItem`, `increaseQty`, `decreaseQty`, `getTotal`, `getCount`, `clearCart`, `getItemsString`.

- **`Database.js`** — Shared `.pragma library` singleton. Uses `QtQuick.LocalStorage` (SQLite). Methods: `initDatabase`, `getMenuItems`, `saveOrder`, `getOrders`.

### SQLite Tables (via QtQuick.LocalStorage)

```sql
-- MENU table
CREATE TABLE menu (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    description TEXT,
    price       REAL    NOT NULL,
    category    TEXT    NOT NULL
);

-- CART table (mostly in-memory, backed up here optionally)
CREATE TABLE cart (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    item_name TEXT    NOT NULL,
    quantity  INTEGER NOT NULL DEFAULT 1,
    price     REAL    NOT NULL
);

-- ORDERS table
CREATE TABLE orders (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT    NOT NULL,
    table_number  TEXT    NOT NULL,
    items         TEXT    NOT NULL,
    total         REAL    NOT NULL,
    order_date    TEXT    NOT NULL
);
```

---

## 🚀 How to Run

### Prerequisites

- [Clickable](https://clickable-ut.dev/en/latest/install.html) installed
- Docker (required by Clickable for building)

### Run on Desktop (for testing)

```bash
cd ordering_app
clickable desktop
```

This launches the app in a desktop window simulating Ubuntu Touch.

### Build for Ubuntu Touch Device

```bash
clickable
```

This builds a `.click` package and installs it on a connected Ubuntu Touch device via ADB.

### Run Flask Backend (optional)

```bash
cd backend
pip install flask
python app.py
```

Server starts at `http://localhost:5000`

**API Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/menu` | Get all menu items |
| GET | `/menu?category=Starters` | Filter by category |
| GET | `/menu?search=paneer` | Search by name |
| POST | `/placeorder` | Place a new order |
| GET | `/orders` | Get all past orders |
| GET | `/health` | Server health check |

**POST /placeorder — Request Body:**
```json
{
    "customer_name": "Rahul Sharma",
    "table_number": "5",
    "items": "Paneer Tikka x2, Dal Makhani x1",
    "total": 620.0
}
```

---

## 🍽️ Menu Categories

### Starters
| Item | Price |
|------|-------|
| Paneer Tikka | ₹220 |
| Veg Seekh Kebab | ₹180 |
| Crispy Corn | ₹150 |
| Veg Spring Roll | ₹130 |

### Main Course
| Item | Price |
|------|-------|
| Dal Makhani | ₹200 |
| Paneer Butter Masala | ₹260 |
| Kolhapuri Misal | ₹180 |
| Jeera Rice | ₹120 |
| Garlic Naan | ₹60 |

### Chinese
| Item | Price |
|------|-------|
| Veg Fried Rice | ₹160 |
| Veg Noodles | ₹150 |
| Manchurian | ₹170 |
| Chilli Paneer | ₹210 |

### Beverages
| Item | Price |
|------|-------|
| Masala Chai | ₹40 |
| Mango Lassi | ₹90 |
| Fresh Lime Soda | ₹60 |
| Buttermilk | ₹50 |

---

## 🧩 Key Concepts for Beginners

### 1. `.pragma library` in JavaScript
Makes the JS file a shared singleton — all QML components share the same instance. This is how `CartLogic.js` keeps cart state consistent across pages.

### 2. `QtQuick.LocalStorage`
Qt's built-in module that wraps SQLite. No external library needed. Works offline on the device. Perfect for Ubuntu Touch apps.

### 3. `PageStack`
Ubuntu Touch navigation pattern. Acts like a browser history — `push()` to go forward, `pop()` to go back.

### 4. `ListModel` + `Repeater`/`ListView`
QML's way to display dynamic lists. `ListModel` holds data, `ListView`/`Repeater` renders it.

### 5. Signals
QML pages communicate with parents via `signal`. For example, `CartPage` emits `goBack()` when Back is tapped, and `Main.qml` handles it with `onGoBack`.

---

## 🛠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| `clickable desktop` not found | Install Clickable: `pip3 install clickable-ut` |
| App shows blank screen | Check console for QML import errors. Verify `Ubuntu.Components 1.3` is installed. |
| Database not saving | LocalStorage path may need write permissions. Check AppArmor profile. |
| Flask server won't start | Run `pip install flask` first |

---

## 📝 License

MIT License — Free to use and modify.

---

*Built with ❤️ for Ubuntu Touch*
