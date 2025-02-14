-- Create the FCMS database if it doesn't exist
CREATE DATABASE IF NOT EXISTS FCMS;
USE FCMS;

-- Create the Shop_Category table
CREATE TABLE IF NOT EXISTS Shop_Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

-- Create the Shop table
CREATE TABLE IF NOT EXISTS Shop (
    shop_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    opening_hours TIME NOT NULL,
    closing_hours TIME NOT NULL,
    category_id INT,
    overall_rating FLOAT,
    FOREIGN KEY (category_id) REFERENCES Shop_Category(category_id)
);

-- Create the Review table
CREATE TABLE IF NOT EXISTS Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    hygiene_rating INT NOT NULL,
    price_rating INT NOT NULL,
    overall_rating FLOAT,
    comments TEXT,
    shop_id INT,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id)
);

-- Create the Menu table
CREATE TABLE IF NOT EXISTS Menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id)
);

-- Create the MenuItem table
CREATE TABLE IF NOT EXISTS MenuItem (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_id INT,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id)
);

-- Trigger to update overall_rating in Review table when a new review is added or an existing one is updated
DELIMITER $$
CREATE TRIGGER update_overall_rating
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    DECLARE total_reviews INT;
    DECLARE total_ratings FLOAT;

    -- Calculate total reviews and ratings for the shop
    SELECT COUNT(*), SUM(hygiene_rating + price_rating) INTO total_reviews, total_ratings
    FROM Review
    WHERE shop_id = NEW.shop_id;

    -- Update overall_rating in Shop table
    UPDATE Shop
    SET overall_rating = total_ratings / (total_reviews * 2)
    WHERE shop_id = NEW.shop_id;
END$$
DELIMITER ;

-- Trigger to update overall_rating in Shop table when a review is deleted
DELIMITER $$
CREATE TRIGGER update_overall_rating_on_delete
AFTER DELETE ON Review
FOR EACH ROW
BEGIN
    DECLARE total_reviews INT;
    DECLARE total_ratings FLOAT;

    -- Calculate total reviews and ratings for the shop
    SELECT COUNT(*), SUM(hygiene_rating + price_rating) INTO total_reviews, total_ratings
    FROM Review
    WHERE shop_id = OLD.shop_id;

    -- Update overall_rating in Shop table
    UPDATE Shop
    SET overall_rating = total_ratings / (total_reviews * 2)
    WHERE shop_id = OLD.shop_id;
END$$
DELIMITER ;

-- Stored Procedure to add a new shop 
DELIMITER $$
CREATE PROCEDURE AddShop(
    IN shop_name VARCHAR(255),
    IN location VARCHAR(255),
    IN contact_number VARCHAR(20),
    IN opening_hours TIME,
    IN closing_hours TIME,
    IN category_id INT
)
BEGIN
    INSERT INTO Shop (name, location, contact_number, opening_hours, closing_hours, category_id)
    VALUES (shop_name, location, contact_number, opening_hours, closing_hours, category_id);
END$$
DELIMITER ;

-- Stored Procedure to add a new review
DELIMITER $$
CREATE PROCEDURE AddReview(
    IN shop_id INT,
    IN hygiene_rating INT,
    IN price_rating INT,
    IN comments TEXT
)
BEGIN
    INSERT INTO Review (hygiene_rating, price_rating, overall_rating, comments, shop_id)
    VALUES (hygiene_rating, price_rating, (hygiene_rating + price_rating) / 2, comments, shop_id);
END$$
DELIMITER ;



-- View to display shops with their average ratings
CREATE VIEW ShopWithAverageRatings AS
SELECT s.*, AVG(r.overall_rating) AS average_rating
FROM Shop s
LEFT JOIN Review r ON s.shop_id = r.shop_id
GROUP BY s.shop_id;


-- Stored Procedure to iterate over reviews for a specific shop
DELIMITER $$
CREATE PROCEDURE IterateReviewsForShop(IN shopID INT)
BEGIN
    DECLARE done_reviews BOOLEAN DEFAULT FALSE;
    DECLARE review_id INT;
    DECLARE hygiene_rating INT;
    DECLARE price_rating INT;
    DECLARE overall_rating FLOAT;
    DECLARE comments TEXT;
    
    -- Declare cursor for iterating over reviews
    DECLARE cur_reviews CURSOR FOR
        SELECT review_id, hygiene_rating, price_rating, overall_rating, comments
        FROM Review
        WHERE shop_id = shopID;
    
    -- Declare continue handler to exit loop
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_reviews = TRUE;
    
    -- Open cursor
    OPEN cur_reviews;
    
    -- Start iterating over reviews
    read_reviews_loop: LOOP
        -- Fetch review data into variables
        FETCH cur_reviews INTO review_id, hygiene_rating, price_rating, overall_rating, comments;
        
        -- Exit loop if no more rows
        IF done_reviews THEN
            LEAVE read_reviews_loop;
        END IF;
        
        -- Print out information about the review
        SELECT CONCAT('Review ID: ', review_id, ', Hygiene Rating: ', hygiene_rating, ', Price Rating: ', price_rating, ', Overall Rating: ', overall_rating, ', Comments: ', comments) AS Review_Info;
    END LOOP;
    
    -- Close cursor
    CLOSE cur_reviews;
END$$
DELIMITER ;

-- Stored Procedure to generate dynamic SQL statements based on condition
DELIMITER $$

DELIMITER $$
CREATE PROCEDURE ShowReviewsForShop(IN shopID INT)
BEGIN
    SELECT review_id, hygiene_rating, price_rating, overall_rating, comments
    FROM Review
    WHERE shop_id = shopID;
END$$
DELIMITER ;


CREATE VIEW ShopsWithMostReviews AS
SELECT s.name AS shop_name, s.location, COUNT(r.review_id) AS review_count
FROM Shop s
LEFT JOIN Review r ON s.shop_id = r.shop_id
GROUP BY s.shop_id
ORDER BY review_count DESC;


CREATE VIEW TopRatedShopsByCategory AS
SELECT c.category_name, s.name AS shop_name, s.location, s.contact_number, s.overall_rating
FROM Shop s
JOIN Shop_Category c ON s.category_id = c.category_id
WHERE s.overall_rating = (
    SELECT MAX(overall_rating)
    FROM Shop
    WHERE category_id = s.category_id
);

-- Create the SearchShops stored procedure
DELIMITER $$
CREATE PROCEDURE SearchShops(
    IN search_query VARCHAR(255)
)
BEGIN
    SELECT s.shop_id, s.name, s.location, AVG(r.overall_rating) AS overall_rating
    FROM Shop s
    LEFT JOIN Review r ON s.shop_id = r.shop_id
    WHERE s.name LIKE CONCAT('%', search_query, '%') OR s.location LIKE CONCAT('%', search_query, '%')
    GROUP BY s.shop_id;
END$$
DELIMITER ;



















-- Sample data for Review table
-- Insert sample data for Shop_Category
INSERT INTO Shop_Category (category_id, category_name) VALUES
(1, 'Restaurant'),
(2, 'Cafe'),
(3, 'Bakery');

-- Insert sample data for Shop
INSERT INTO Shop (name, location, contact_number, opening_hours, closing_hours, category_id)
VALUES
('Tasty Treats', '123 Main Street', '123-456-7890', '08:00:00', '20:00:00', 1),
('Coffee Corner', '456 Oak Avenue', '987-654-3210', '07:00:00', '19:00:00', 2),
('Sweet Delights', '789 Elm Road', '555-123-4567', '09:00:00', '18:00:00', 3),
('Sizzling Grill', '321 Pine Lane', '333-444-5555', '10:00:00', '22:00:00', 1),
('Cozy Cafe', '555 Cedar Street', '777-888-9999', '08:30:00', '17:30:00', 2),
('Fresh Bakery', '777 Maple Avenue', '111-222-3333', '07:30:00', '18:30:00', 3),
('Spice Haven', '999 Walnut Boulevard', '444-555-6666', '11:00:00', '21:00:00', 1);

-- Insert sample data for Review
INSERT INTO Review (hygiene_rating, price_rating, overall_rating, comments, shop_id)
VALUES
(5, 4, 4.5, 'Excellent food and service!', 1),
(4, 3, 3.5, 'Good variety but a bit pricey.', 1),
(5, 5, 5.0, 'Absolutely amazing experience!', 1),
(3, 3, 3.0, 'Average quality, needs improvement.', 1),
(4, 5, 4.5, 'Great atmosphere and delicious food.', 1),

(4, 4, 4.0, 'Fantastic coffee and cozy ambiance.', 2),
(5, 3, 4.0, 'Good place to relax and enjoy coffee.', 2),
(3, 4, 3.5, 'Decent service but coffee could be better.', 2),
(5, 5, 5.0, 'Love the variety of coffee options!', 2),
(4, 3, 3.5, 'Average coffee, nothing special.', 2),

(5, 5, 5.0, 'Delicious pastries and friendly staff.', 3),
(4, 4, 4.0, 'Freshly baked goods, highly recommend.', 3),
(3, 4, 3.5, 'Good selection but a bit overpriced.', 3),
(5, 3, 4.0, 'Love the desserts, will come back!', 3),
(4, 5, 4.5, 'Great bakery with tasty treats.', 3),

(4, 4, 4.0, 'Awesome BBQ and friendly service.', 4),
(5, 5, 5.0, 'Best steakhouse in town, hands down!', 4),
(3, 3, 3.0, 'Average food quality, could improve.', 4),
(4, 3, 3.5, 'Decent menu but portions are small.', 4),
(5, 4, 4.5, 'Excellent flavors and presentation.', 4),

(5, 4, 4.5, 'Love the cozy ambiance and tasty sandwiches.', 5),
(4, 5, 4.5, 'Great place for brunch, friendly staff.', 5),
(3, 3, 3.0, 'Average food, nothing special.', 5),
(5, 4, 4.5, 'Enjoyable dining experience, will return.', 5),
(4, 4, 4.0, 'Good variety on the menu, reasonable prices.', 5),

(3, 4, 3.5, 'Decent selection of bread but service is slow.', 6),
(4, 3, 3.5, 'Freshly baked bread, could be warmer.', 6),
(5, 5, 5.0, 'Love the pastries and friendly atmosphere.', 6),
(4, 4, 4.0, 'Delicious cakes and pies!', 6),
(3, 3, 3.0, 'Average bakery, needs improvement.', 6),

(4, 5, 4.5, 'Amazing flavors, love the spicy dishes!', 7),
(5, 4, 4.5, 'Great service and variety of dishes.', 7),
(3, 3, 3.0, 'Average quality, could be better.', 7),
(4, 4, 4.0, 'Good portion sizes and reasonable prices.', 7),
(5, 5, 5.0, 'Best Indian food in town!', 7);

-- Insert sample data for Menu
INSERT INTO Menu (shop_id) VALUES (1), (2), (3), (4), (5), (6), (7);

-- Insert sample data for MenuItem
INSERT INTO MenuItem (menu_id, item_name, description, price)
VALUES
(1, 'Steak Dinner', 'Juicy steak served with mashed potatoes and vegetables', 20.99),
(1, 'Salmon Fillet', 'Grilled salmon served with rice pilaf and salad', 18.99),
(1, 'Vegetarian Pasta', 'Penne pasta with assorted vegetables in marinara sauce', 15.99),
(2, 'Espresso', 'Strong black coffee', 3.49),
(2, 'Cappuccino', 'Espresso mixed with steamed milk and topped with foam', 4.99),
(2, 'Latte', 'Espresso mixed with steamed milk', 4.49),
(3, 'Assorted Cupcakes', 'Variety of cupcakes with different frosting flavors', 2.99),
(3, 'Chocolate Croissant', 'Flaky pastry filled with chocolate', 2.49),
(3, 'Blueberry Muffin', 'Moist muffin filled with blueberries', 1.99),
(4, 'BBQ Ribs', 'Tender BBQ ribs served with coleslaw and fries', 16.99),
(4, 'Grilled Chicken', 'Marinated grilled chicken breast with roasted vegetables', 14.99),
(4, 'Pulled Pork Sandwich', 'Slow-cooked pulled pork served on a bun with BBQ sauce', 10.99),
(5, 'Club Sandwich', 'Triple-decker sandwich with turkey, bacon, lettuce, and tomato', 9.99),
(5, 'Avocado Toast', 'Toasted bread topped with mashed avocado and cherry tomatoes', 7.99),
(5, 'Caesar Salad', 'Romaine lettuce, croutons, and Parmesan cheese tossed in Caesar dressing', 8.99),
(6, 'Baguette', 'Freshly baked French baguette', 3.99),
(6, 'Chocolate Eclair', 'Light pastry filled with chocolate cream and topped with ganache', 4.49),
(6, 'Apple Pie', 'Classic apple pie with a flaky crust', 5.99),
(7, 'Chicken Tikka Masala', 'Tender chicken cooked in a creamy tomato sauce', 12.99),
(7, 'Vegetable Biryani', 'Fragrant basmati rice cooked with mixed vegetables and spices', 10.99),
(7, 'Garlic Naan', 'Soft and fluffy bread with garlic flavor', 2.49);