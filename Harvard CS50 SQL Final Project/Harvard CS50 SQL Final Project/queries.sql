--Find the top 5 product names, and the corresponding store name that has the most quantity sold from January 2018 to January 2019.
SELECT products.name AS product_name,
       stores.name AS store_name,
       SUM(sales.quantity) AS total_quantity_sold
FROM sales
JOIN products ON sales.product_id = products.id
JOIN stores ON sales.store_id = stores.id
WHERE sales.date BETWEEN DATE('2018-01-01') AND DATE('2019-01-01')
GROUP BY products.name, stores.name
ORDER BY total_quantity_sold DESC
LIMIT 5;


--Return all the sales performance made by a store at a given month
SELECT sales.*, stores.name AS store_name
FROM sales
JOIN stores ON sales.store_id = stores.id
WHERE sales.store_id = 22749
AND substr(sales.date, 1, 7) = '2019-12'
ORDER BY sales.date ASC;

--Find the supplier/s of a product given a product name
SELECT s.id, s.name
FROM suppliers s
JOIN products p ON p.supplier_id = s.id
WHERE p.name = 'Allspice - Jamaican';

--Find all product name that are low on quantity on a given store (Note that the quantity_available column might not be set as an integer)
SELECT products.name AS product_name, CAST(inventory.quantity_available AS INTEGER) AS quantity_available
FROM inventory
JOIN products ON inventory.product_id = products.id
WHERE inventory.store_id = 37444
AND CAST(inventory.quantity_available AS INTEGER) < 5
ORDER BY products.name ASC;

-- Insert into the products table (new product)
INSERT INTO products (name, supplier_id, cost)
VALUES ('fried chicken - whole', 35, 3.25);

-- Insert into the stores table (new store)
INSERT INTO stores (name, address, neighborhood)
VALUES ('centraltea', '5954 Crownhardt Place', 'Seton Business Park');

-- Insert into the inventory table (product on store)
INSERT INTO inventory (product_id, store_id, quantity_available)
VALUES (2, 10002, 100);

-- Insert into the sales table
INSERT INTO sales (store_id, product_id, date, unit_price, quantity, total)
VALUES (10002, 101, '2023-01-01', 7, 5, 35);

-- Insert into the supplier table (new supplier)
INSERT INTO suppliers (name, contact_info)
VALUES ('Fresh Bounty', '****');
