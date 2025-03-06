-- Database Creation
CREATE DATABASE FoodOnCampus;
USE FoodOnCampus;

-- Shop Table
CREATE TABLE Shop (
    shop_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    overall_rating DECIMAL(3,2) DEFAULT 0.00
);

-- Menu Table
CREATE TABLE Menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE
);

-- MenuItem Table
CREATE TABLE MenuItem (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE
);

-- Review Table
CREATE TABLE Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    hygiene_rating INT CHECK (hygiene_rating BETWEEN 1 AND 5),
    price_rating INT CHECK (price_rating BETWEEN 1 AND 5),
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id) ON DELETE CASCADE
);

-- Trigger to update Shop overall rating
DELIMITER $$
CREATE TRIGGER update_overall_rating
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    UPDATE Shop s
    SET overall_rating = (
        SELECT AVG((hygiene_rating + price_rating) / 2.0)
        FROM Review
        WHERE shop_id = s.shop_id
    )
    WHERE s.shop_id = NEW.shop_id;
END$$
DELIMITER ;

-- Stored Procedure: Search Shops by Name or Location (Case-Insensitive)
DELIMITER $$
CREATE PROCEDURE SearchShops (IN search_term VARCHAR(255))
BEGIN
    SELECT * FROM Shop
    WHERE LOWER(name) LIKE CONCAT('%', LOWER(search_term), '%')
       OR LOWER(location) LIKE CONCAT('%', LOWER(search_term), '%');
END$$
DELIMITER ;

-- Stored Procedure: Add a Review with Validation
DELIMITER $$
CREATE PROCEDURE AddReview (
    IN p_shop_id INT,
    IN p_hygiene_rating INT,
    IN p_price_rating INT
)
BEGIN
    IF p_hygiene_rating BETWEEN 1 AND 5 AND p_price_rating BETWEEN 1 AND 5 THEN
        INSERT INTO Review (shop_id, hygiene_rating, price_rating)
        VALUES (p_shop_id, p_hygiene_rating, p_price_rating);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ratings must be between 1 and 5';
    END IF;
END$$
DELIMITER ;

-- View: List of Shops with Average Rating
CREATE VIEW ShopRatings AS
SELECT s.shop_id, s.name, s.location, COALESCE(AVG((r.hygiene_rating + r.price_rating) / 2.0), 0) AS avg_rating
FROM Shop s
LEFT JOIN Review r ON s.shop_id = r.shop_id
GROUP BY s.shop_id;

-- Sample Data Insertion
INSERT INTO Shop (name, location) VALUES ('Food Corner', 'Building A');
INSERT INTO Shop (name, location) VALUES ('Tasty Bites', 'Building B');

INSERT INTO Menu (shop_id, name) VALUES (1, 'Breakfast Menu');
INSERT INTO Menu (shop_id, name) VALUES (2, 'Lunch Menu');

INSERT INTO MenuItem (menu_id, name, price) VALUES (1, 'Pancakes', 50.00);
INSERT INTO MenuItem (menu_id, name, price) VALUES (2, 'Burger', 120.00);

INSERT INTO Review (shop_id, hygiene_rating, price_rating) VALUES (1, 5, 4);
INSERT INTO Review (shop_id, hygiene_rating, price_rating) VALUES (2, 3, 3);
