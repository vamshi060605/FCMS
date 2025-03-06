-- Creating the database
CREATE DATABASE FoodOnCampus;
USE FoodOnCampus;

-- Table: Shop_Category
CREATE TABLE Shop_Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL UNIQUE
);

-- Table: Shop
CREATE TABLE Shop (
    shop_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    contact_number VARCHAR(15) UNIQUE NOT NULL,
    opening_hours TIME NOT NULL,
    closing_hours TIME NOT NULL,
    category_id INT,
    overall_rating DECIMAL(3,2) DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Shop_Category(category_id) ON DELETE SET NULL
);

-- Table: Menu
CREATE TABLE Menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE
);

-- Table: MenuItem
CREATE TABLE MenuItem (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_id INT,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE
);

-- Table: Review
CREATE TABLE Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    hygiene_rating INT CHECK (hygiene_rating BETWEEN 1 AND 5),
    price_rating INT CHECK (price_rating BETWEEN 1 AND 5),
    overall_rating INT CHECK (overall_rating BETWEEN 1 AND 5),
    comments TEXT,
    shop_id INT,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE
);

-- View: Shops with Average Ratings
CREATE VIEW Shop_Average_Ratings AS
SELECT s.shop_id, s.name, s.location, s.contact_number, s.category_id, 
       COALESCE(AVG(r.overall_rating), 0) AS avg_rating
FROM Shop s
LEFT JOIN Review r ON s.shop_id = r.shop_id
GROUP BY s.shop_id;

-- View: Top Rated Shops by Category
CREATE VIEW Top_Rated_Shops AS
SELECT s.shop_id, s.name, c.category_name, 
       COALESCE(AVG(r.overall_rating), 0) AS avg_rating
FROM Shop s
JOIN Shop_Category c ON s.category_id = c.category_id
LEFT JOIN Review r ON s.shop_id = r.shop_id
GROUP BY s.shop_id, c.category_name
ORDER BY avg_rating DESC;

-- Trigger: Update Overall Rating on Review Insert
DELIMITER //
CREATE TRIGGER Update_Shop_Rating
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    UPDATE Shop
    SET overall_rating = (SELECT AVG(overall_rating) FROM Review WHERE shop_id = NEW.shop_id)
    WHERE shop_id = NEW.shop_id;
END;//
DELIMITER ;

-- Stored Procedure: Get Shops by Rating
DELIMITER //
CREATE PROCEDURE Get_Shops_By_Rating(IN min_rating DECIMAL(3,2))
BEGIN
    SELECT * FROM Shop WHERE overall_rating >= min_rating;
END;//
DELIMITER ;

-- Stored Procedure: Add Review with Validation
DELIMITER //
CREATE PROCEDURE Add_Review(IN shop_id INT, IN hygiene INT, IN price INT, IN overall INT, IN comment TEXT)
BEGIN
    IF hygiene BETWEEN 1 AND 5 AND price BETWEEN 1 AND 5 AND overall BETWEEN 1 AND 5 THEN
        INSERT INTO Review (hygiene_rating, price_rating, overall_rating, comments, shop_id)
        VALUES (hygiene, price, overall, comment, shop_id);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ratings must be between 1 and 5';
    END IF;
END;//
DELIMITER ;

-- Sample Data
INSERT INTO Shop_Category (category_name) VALUES ('Cafeteria'), ('Fast Food'), ('Bakery');

INSERT INTO Shop (name, location, contact_number, opening_hours, closing_hours, category_id)
VALUES ('Campus Café', 'Building A', '1234567890', '08:00:00', '20:00:00', 1),
       ('Quick Bites', 'Building B', '0987654321', '10:00:00', '22:00:00', 2);

INSERT INTO Menu (shop_id) VALUES (1), (2);

INSERT INTO MenuItem (menu_id, item_name, description, price)
VALUES (1, 'Coffee', 'Hot brewed coffee', 2.50),
       (1, 'Sandwich', 'Cheese & Veggies', 4.00),
       (2, 'Burger', 'Chicken Burger', 5.50);

INSERT INTO Review (hygiene_rating, price_rating, overall_rating, comments, shop_id)
VALUES (5, 4, 5, 'Great coffee!', 1),
       (4, 3, 4, 'Tasty but a bit pricey.', 2);
