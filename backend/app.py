# -*- coding: utf-8 -*-
"""
app.py - Flask Backend for Kolhapuri Pure Veg Restaurant App
============================================================
This is a simple REST API backend that provides menu data and
stores orders in a SQLite database.

Endpoints:
    GET  /menu         → Returns all menu items as JSON
    POST /placeorder   → Accepts order data and saves to DB
    GET  /orders       → Returns all past orders as JSON
    GET  /health       → Simple health check

How to run:
    pip install flask
    python app.py

The server will start at: http://localhost:5000

Note: The QML app uses QtQuick LocalStorage (device-local SQLite)
for offline use. This Flask backend is optional and can be used
for a web dashboard or multi-device sync.
"""

from flask import Flask, request, jsonify, send_from_directory
import sqlite3
import os
from datetime import datetime

# ── App Setup ──────────────────────────────────────────────────────────────
app = Flask(__name__)

# Web preview directory
PREVIEW_DIR = os.path.join(os.path.dirname(__file__), "..", "web_preview")

# Database file path (stored in backend/ directory)
DB_PATH = os.path.join(os.path.dirname(__file__), "database.db")


# ── Database Helpers ───────────────────────────────────────────────────────

def get_db():
    """Opens a connection to the SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row   # Allows dict-style access: row["name"]
    return conn


def init_db():
    """
    Creates all required tables if they don't exist.
    Seeds the menu with default food items.
    Called once when the Flask server starts.
    """
    conn = get_db()
    cursor = conn.cursor()

    # Create MENU table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS menu (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT    NOT NULL,
            description TEXT,
            price       REAL    NOT NULL,
            category    TEXT    NOT NULL
        )
    """)

    # Create ORDERS table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT    NOT NULL,
            table_number  TEXT    NOT NULL,
            items         TEXT    NOT NULL,
            total         REAL    NOT NULL,
            order_date    TEXT    NOT NULL
        )
    """)

    # Seed menu data only if table is empty
    count = cursor.execute("SELECT COUNT(*) FROM menu").fetchone()[0]
    if count == 0:
        menu_items = [
            # (name, description, price, category)
            # Starters
            ("Paneer Tikka",       "Grilled cottage cheese with spices",    220, "Starters"),
            ("Veg Seekh Kebab",    "Minced vegetable kebab on skewer",      180, "Starters"),
            ("Crispy Corn",        "Stir fried crispy corn with seasoning", 150, "Starters"),
            ("Veg Spring Roll",    "Crunchy rolls filled with vegetables",  130, "Starters"),
            # Main Course
            ("Dal Makhani",        "Slow cooked black lentils in cream",    200, "Main Course"),
            ("Paneer Butter Masala","Cottage cheese in rich tomato gravy",  260, "Main Course"),
            ("Kolhapuri Misal",    "Spicy sprout curry, Kolhapuri style",   180, "Main Course"),
            ("Jeera Rice",         "Basmati rice tempered with cumin",      120, "Main Course"),
            ("Garlic Naan",        "Tandoor baked bread with garlic butter",  60, "Main Course"),
            # Chinese
            ("Veg Fried Rice",     "Wok tossed rice with vegetables",       160, "Chinese"),
            ("Veg Noodles",        "Stir fried noodles Indo-Chinese style", 150, "Chinese"),
            ("Manchurian",         "Crispy veg balls in Manchurian sauce",  170, "Chinese"),
            ("Chilli Paneer",      "Cottage cheese in spicy chilli sauce",  210, "Chinese"),
            # Beverages
            ("Masala Chai",        "Classic Indian spiced tea",               40, "Beverages"),
            ("Mango Lassi",        "Creamy yogurt mango drink",               90, "Beverages"),
            ("Fresh Lime Soda",    "Chilled lime soda, sweet or salty",       60, "Beverages"),
            ("Buttermilk",         "Chilled spiced buttermilk (Chaas)",       50, "Beverages"),
        ]
        cursor.executemany(
            "INSERT INTO menu (name, description, price, category) VALUES (?, ?, ?, ?)",
            menu_items
        )
        print(f"  [OK] Seeded {len(menu_items)} menu items into database.")

    conn.commit()
    conn.close()
    print("  [OK] Database initialized successfully.")


# ── Routes ─────────────────────────────────────────────────────────────────

@app.route("/")
@app.route("/preview")
def serve_preview():
    """Serve the web preview UI."""
    return send_from_directory(os.path.abspath(PREVIEW_DIR), "index.html")


@app.route("/health", methods=["GET"])
def health_check():
    """Simple health check endpoint."""
    return jsonify({
        "status":  "ok",
        "message": "Kolhapuri Pure Veg API is running!",
        "time":    datetime.now().isoformat()
    })


@app.route("/menu", methods=["GET"])
def get_menu():
    """
    GET /menu
    Returns all menu items grouped by category.
    
    Query param (optional):
        category=Starters  → filter by category
        search=paneer      → filter by name (case-insensitive)
    
    Response:
        {
            "success": true,
            "count": 17,
            "items": [
                { "id":1, "name":"Paneer Tikka", "description":"...",
                  "price":220, "category":"Starters" },
                ...
            ]
        }
    """
    conn = conn = get_db()
    cursor = conn.cursor()

    # Build query with optional filters
    query  = "SELECT * FROM menu WHERE 1=1"
    params = []

    # Category filter
    category = request.args.get("category", "").strip()
    if category:
        query  += " AND category = ?"
        params.append(category)

    # Search filter
    search = request.args.get("search", "").strip()
    if search:
        query  += " AND LOWER(name) LIKE ?"
        params.append(f"%{search.lower()}%")

    query += " ORDER BY category, name"

    rows = cursor.execute(query, params).fetchall()
    conn.close()

    # Convert rows to list of dicts
    items = [dict(row) for row in rows]

    return jsonify({
        "success": True,
        "count":   len(items),
        "items":   items
    })


@app.route("/placeorder", methods=["POST"])
def place_order():
    """
    POST /placeorder
    Accepts a JSON body with order details and saves to database.

    Request body (JSON):
        {
            "customer_name": "Rahul Sharma",
            "table_number":  "5",
            "items":         "Paneer Tikka x2, Dal Makhani x1",
            "total":         620.0
        }

    Response:
        {
            "success": true,
            "message": "Order placed successfully!",
            "order_id": 7
        }
    """
    data = request.get_json()

    # Validate required fields
    required = ["customer_name", "table_number", "items", "total"]
    for field in required:
        if field not in data or not str(data[field]).strip():
            return jsonify({
                "success": False,
                "error":   f"Missing required field: {field}"
            }), 400

    # Insert into orders table
    conn = get_db()
    cursor = conn.cursor()

    order_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    cursor.execute(
        """INSERT INTO orders (customer_name, table_number, items, total, order_date)
           VALUES (?, ?, ?, ?, ?)""",
        [
            data["customer_name"].strip(),
            str(data["table_number"]).strip(),
            data["items"].strip(),
            float(data["total"]),
            order_date
        ]
    )
    order_id = cursor.lastrowid
    conn.commit()
    conn.close()

    print(f"  [OK] New order #{order_id} placed for {data['customer_name']}")

    return jsonify({
        "success":  True,
        "message":  "Order placed successfully!",
        "order_id": order_id
    }), 201


@app.route("/orders", methods=["GET"])
def get_orders():
    """
    GET /orders
    Returns all past orders from the database, newest first.

    Response:
        {
            "success": true,
            "count": 3,
            "orders": [
                { "id":3, "customer_name":"...", "table_number":"5",
                  "items":"...", "total":620.0, "order_date":"..." },
                ...
            ]
        }
    """
    conn = get_db()
    cursor = conn.cursor()
    rows = cursor.execute("SELECT * FROM orders ORDER BY id DESC").fetchall()
    conn.close()

    orders = [dict(row) for row in rows]

    return jsonify({
        "success": True,
        "count":   len(orders),
        "orders":  orders
    })


# ── Entry Point ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import sys, io
    # Force UTF-8 output on Windows to avoid codec errors
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

    print("\n[Kolhapuri Pure Veg] Backend Server")
    print("=" * 40)
    print(f"  Database: {DB_PATH}")

    # Initialize database tables and seed data
    init_db()

    print("\n  API Endpoints:")
    print("    GET  http://localhost:5001/menu")
    print("    POST http://localhost:5001/placeorder")
    print("    GET  http://localhost:5001/orders")
    print("    GET  http://localhost:5001/health")
    print("\n  Server starting on http://localhost:5001 ...\n")

    # Start the Flask development server
    # debug=True -> auto-reload on file changes
    app.run(host="0.0.0.0", port=5001, debug=True)
