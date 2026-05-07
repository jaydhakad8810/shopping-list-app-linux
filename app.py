from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

# Database configuration
basedir = os.path.abspath(os.path.dirname(__file__))
db_path = os.path.join(basedir, 'shopping.db')

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + db_path
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


# Database Model
class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)

    def __repr__(self):
        return f"<Item {self.name}>"


# Home Route
@app.route('/')
def index():
    items = Item.query.order_by(Item.id.desc()).all()
    return render_template('index.html', items=items)


# Add Item Route
@app.route('/add', methods=['POST'])
def add_item():
    name = request.form.get('item')

    if name:
        item = Item(name=name.strip())
        db.session.add(item)
        db.session.commit()

    return redirect(url_for('index'))


# Create Database Tables
with app.app_context():
    db.create_all()


# Run Application
if __name__ == '__main__':
    app.run(debug=True)