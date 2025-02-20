# Food On-Campus Management System

## 📌 Project Overview
The **Food On-Campus Management System** is a database management system designed to efficiently manage food vendors on a college campus. It allows users to store, retrieve, and analyze information related to food shops, menus, reviews, and more.

## ⚙️ Features
- **Shop Management**: Stores details of different food vendors on campus.
- **Menu Management**: Allows vendors to add and update their menu items.
- **Review System**: Users can rate and review different food vendors.
- **Data Queries & Reports**: Supports complex queries, aggregate functions, joins, and views.
- **Constraints & Triggers**: Implements database integrity with constraints and automated triggers.

## 🗃️ Database Schema
### Tables
1. **Shop**: Stores vendor details (shop_id, name, location, contact_number, opening_hours, closing_hours, category_id, overall_rating).
2. **Shop_Category**: Stores different categories of shops (category_id, category_name).
3. **Menu**: Links shops with menu items (menu_id, shop_id).
4. **MenuItem**: Stores individual menu items (item_id, menu_id, item_name, description, price).
5. **Review**: Stores user reviews (review_id, hygiene_rating, price_rating, overall_rating, comments, shop_id).

## 🔑 Database Queries & Operations
### 1️⃣ Constraints
- **NOT NULL**: Ensures critical fields cannot be left empty.
- **UNIQUE**: Guarantees no duplicate contact numbers for shops.
- **FOREIGN KEY**: Maintains relationships between tables.

### 2️⃣ Aggregate Functions
- Calculate total number of shops.
- Find the shop with the most reviews.
- Compute average ratings and number of reviews per shop.

### 3️⃣ Joins
- Retrieve shop details with their locations.
- Left Join to include shop menus.
- Self-Join to find shops with the same rating.

### 4️⃣ Views
- View of shops with the most reviews.
- View for shops with average ratings.
- View for top-rated shops by category.

### 5️⃣ Triggers
- Update the overall rating when a new review is added or deleted.

### 6️⃣ Cursors
- Iterate over all reviews for a specific shop using a stored procedure.

## 🛠️ Installation & Setup
1. Install **MySQL** or any SQL-based database management system.
2. Create the required tables using the provided `CREATE TABLE` queries.
3. Execute the SQL queries to manage shops, menus, and reviews.

## 📜 Contributors
- **Vamshi T** (RA2211003010211)
- **Harish Sridhar** (RA2211003010205)
- **Bindushree K** (RA2211003010228)

## 📌 Future Enhancements
- Web-based interface for easier shop management.
- Integration with mobile apps for real-time updates.
- AI-based recommendation system for food preferences.

---
**📌 Note**: This project is part of a **DBMS course** and focuses on database management concepts like constraints, views, joins, triggers, and stored procedures.
