
CREATE DATABASE food_wastage_mgmt_db;
USE food_wastage_mgmt_db;


show tables;

-- Create tables for providers
CREATE TABLE IF NOT EXISTS providers (
  provider_id INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(100),
  address VARCHAR(500),
  city VARCHAR(100),
  contact VARCHAR(100)
);

select * from providers;

-- Create tables for receivers
CREATE TABLE IF NOT EXISTS receivers (
  receiver_id INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(100),
  city VARCHAR(100),
  contact VARCHAR(100)
);

-- Create tables for food_listings
CREATE TABLE IF NOT EXISTS food_listings (
  food_id INT PRIMARY KEY,
  food_name VARCHAR(255) NOT NULL,
  quantity INT DEFAULT 0,
  expiry_date DATE,
  provider_id INT,
  provider_type VARCHAR(100),
  location VARCHAR(100),
  food_type VARCHAR(50),     -- Vegetarian/Non-Veg/Vegan etc
  meal_type VARCHAR(50),     -- Breakfast/Lunch/Dinner/Snacks
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

-- Create tables for claims
CREATE TABLE IF NOT EXISTS claims (
  claim_id INT PRIMARY KEY,
  food_id INT,
  receiver_id INT,
  status VARCHAR(50),        -- Pending / Completed / Cancelled
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (food_id) REFERENCES food_listings(food_id),
  FOREIGN KEY (receiver_id) REFERENCES receivers(receiver_id)
);
-- --------------------------------------------------------------------------------------------------------------------------------

-- Load Data for Provider table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/providers_data.csv'
INTO TABLE providers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(provider_id, name, type, address, city, contact);


-- Load Data for Receivers table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/receivers_data.csv'
INTO TABLE receivers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(receiver_id, name, type, city, contact);

-- Load Data for Food Listings table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/food_listings_data.csv'
INTO TABLE food_listings
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(food_id, food_name, quantity, @expiry_date, provider_id, provider_type, location, food_type, meal_type)
SET expiry_date = STR_TO_DATE(@expiry_date, '%m/%d/%Y');

-- Load Data for Claims table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/claims_data.csv'
INTO TABLE claims
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(claim_id, food_id, receiver_id, status, @claim_timestamp)
SET timestamp = STR_TO_DATE(@claim_timestamp, '%m/%e/%Y %H:%i');
-- --------------------------------------------------------------------------------------------------------------------------------

-- Data cleaning & validation

-- Trim whitespace:
UPDATE providers SET name = TRIM(name), city = TRIM(city), contact = TRIM(contact);
UPDATE receivers SET name = TRIM(name), city = TRIM(city), contact = TRIM(contact);
UPDATE food_listings SET food_name = TRIM(food_name), location = TRIM(location);

-- Fix invalid quantities:
UPDATE food_listings SET quantity = 0 WHERE quantity IS NULL OR quantity < 0;

-- Standardize status values:
UPDATE claims SET status = CASE
  WHEN LOWER(status) IN ('done','complete','completed') THEN 'Completed'
  WHEN LOWER(status) IN ('pending','inprogress') THEN 'Pending'
  WHEN LOWER(status) IN ('cancel','canceled','cancelled') THEN 'Cancelled'
  ELSE CONCAT(UPPER(LEFT(status,1)), LOWER(SUBSTRING(status,2)))
END;


-- find orphan food_listings with missing provider
SELECT f.* FROM food_listings f
LEFT JOIN providers p ON f.provider_id = p.provider_id
WHERE p.provider_id IS NULL;

-- find claims with missing food or receiver
SELECT c.* FROM claims c
LEFT JOIN food_listings f ON c.food_id = f.food_id
WHERE f.food_id IS NULL;

-- Add indexes on fields used in WHERE / JOIN / GROUP BY:
CREATE INDEX idx_providers_city ON providers(city);
CREATE INDEX idx_food_location ON food_listings(location);
CREATE INDEX idx_food_provider ON food_listings(provider_id);
CREATE INDEX idx_claims_food ON claims(food_id);
CREATE INDEX idx_claims_receiver ON claims(receiver_id);
CREATE INDEX idx_claims_status ON claims(status);
-- --------------------------------------------------------------------------------------------------------------------------------

-- SHOW TABLE STRUCTURE & SAMPLE DATA 
SELECT * FROM providers LIMIT 10;
SELECT * FROM receivers LIMIT 10;
SELECT * FROM food_listings LIMIT 10;
SELECT * FROM claims LIMIT 10;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';




select * from providers;


