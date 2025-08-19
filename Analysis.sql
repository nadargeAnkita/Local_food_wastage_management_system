--  Q01: Providers per city
SELECT city, COUNT(*) AS providers_count
FROM providers
GROUP BY city;

--  Q02: Receivers per city
SELECT city, COUNT(*) AS receivers_count
FROM receivers
GROUP BY city;


--  Q03: Top food provider (by total quantity)
SELECT p.type AS provider_type, SUM(f.quantity) AS total_quantity
FROM providers p
JOIN food_listings f ON p.provider_id = f.provider_id
GROUP BY p.type
ORDER BY total_quantity DESC
LIMIT 1;


--  Q04: Contact information of food providers in a specific city
SELECT provider_id, name, contact, address
FROM providers;


-- Q05: Which receivers have claimed the most food
SELECT 
    r.receiver_id, 
    r.name, 
    COUNT(c.claim_id) AS claims_count, 
    COALESCE(SUM(f.quantity), 0) AS claimed_quantity_estimate
FROM receivers r
JOIN claims c 
    ON r.receiver_id = c.receiver_id
LEFT JOIN food_listings f 
    ON c.food_id = f.food_id
GROUP BY r.receiver_id, r.name
ORDER BY claims_count DESC
LIMIT 5;


-- Q06: Total quantity of food available from all providers
SELECT 
    SUM(quantity) AS total_available_quantity
FROM food_listings;


-- Q07: City with the highest number of food listings
SELECT 
    location AS city, 
    COUNT(*) AS listings_count
FROM food_listings
GROUP BY location
ORDER BY listings_count DESC
LIMIT 1;


-- Q08: Most commonly available food types and their total quantities and %
SELECT 
    food_type, 
    COUNT(*) AS count_listings, 
    SUM(quantity) AS total_quantity,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM food_listings), 2) AS '%_of_listings'
FROM food_listings
GROUP BY food_type
ORDER BY count_listings DESC;


-- Q09: Number of claims made for each food item
SELECT 
    f.food_id, 
    f.food_name, 
    COUNT(c.claim_id) AS claims_count
FROM food_listings f
LEFT JOIN claims c 
    ON f.food_id = c.food_id
GROUP BY f.food_id, f.food_name
ORDER BY claims_count DESC;


-- Q10: Provider with the highest number of successful (completed) claims
SELECT 
    p.provider_id, 
    p.name, 
    COUNT(c.claim_id) AS successful_claims
FROM providers p
JOIN food_listings f 
    ON p.provider_id = f.provider_id
JOIN claims c 
    ON f.food_id = c.food_id
WHERE c.status = 'Completed'
GROUP BY p.provider_id, p.name
ORDER BY successful_claims DESC
LIMIT 1;


-- Q11: Percentage distribution of claims by status
SELECT 
    status,
    COUNT(*) AS count,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM claims), 2) AS prcnt
FROM claims
GROUP BY status;


-- Q12: Average estimated quantity of food claimed per receiver
-- Note: Uses food_listings.quantity at time of claim, which may double-count if multiple claims share one listing
SELECT 
    r.receiver_id, 
    r.name,
    AVG(IFNULL(f.quantity, 0)) AS avg_quantity_per_claim,
    COUNT(c.claim_id) AS claims_count
FROM receivers r
JOIN claims c 
    ON r.receiver_id = c.receiver_id
LEFT JOIN food_listings f 
    ON c.food_id = f.food_id
GROUP BY r.receiver_id, r.name
ORDER BY avg_quantity_per_claim DESC;


-- Q13: Number of claims per meal type
SELECT 
    f.meal_type, 
    COUNT(c.claim_id) AS claims_count
FROM food_listings f
JOIN claims c 
    ON f.food_id = c.food_id
GROUP BY f.meal_type
ORDER BY claims_count DESC;


-- Q14: Total quantity of food donated by each provider
SELECT 
    p.provider_id, 
    p.name, 
    SUM(f.quantity) AS total_donated_quantity
FROM providers p
JOIN food_listings f 
    ON p.provider_id = f.provider_id
GROUP BY p.provider_id, p.name
ORDER BY total_donated_quantity DESC;


-- Q15: Number of claims per city
SELECT 
    f.location AS city, 
    COUNT(c.claim_id) AS claims_count 
FROM food_listings f
JOIN claims c 
    ON f.food_id = c.food_id
GROUP BY f.location
ORDER BY claims_count DESC;


-- Q16: Most commonly listed food items and their total quantities
SELECT 
    food_name, 
    COUNT(*) AS count_listings, 
    SUM(quantity) AS total_quantity
FROM food_listings
GROUP BY food_name
ORDER BY count_listings DESC;