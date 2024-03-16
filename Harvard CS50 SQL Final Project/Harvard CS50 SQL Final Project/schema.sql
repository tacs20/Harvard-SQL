--Create a database database.db
sqlite3 database.db

--import csv files into the database
.import --csv Products.csv products1
.import --csv supplier.csv suppliers1
.import --csv stores.csv stores1
.import --csv Inventory.csv inventory1
.import --csv Sales.csv sales1

-- The table "products": Represents each product and corresponding costs
CREATE TABLE products (
    id INT,
    name TEXT NOT NULL,
    supplier_id INT NOT NULL,
    cost NUMERIC NOT NULL CHECK(cost > 0),
    PRIMARY KEY(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- The table "supplier": Where the products are procured (contact infos are censored)
CREATE TABLE suppliers (
    id INT,
    name TEXT NOT NULL,
    contact_info TEXT NOT NULL,
    PRIMARY KEY(id)
);

-- The table "stores": Represents each branch of stores on specific locations
CREATE TABLE stores (
    id INT,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    neighborhood TEXT NOT NULL,
    PRIMARY KEY(id)
);

-- The table "inventory": Shows the current assets of all store branches in specified locations
CREATE TABLE inventory (
    id INT,
    product_id INT,
    store_id INT,
    quantity_available INT NOT NULL CHECK(quantity_available >= 0),
    PRIMARY KEY (id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY(store_id) REFERENCES stores(id)
);

-- The "sales" table: Represents all sales transaction made on all store branches
CREATE TABLE sales (
    id INT,
    store_id INT,
    product_id INT,
    date DATE DEFAULT (date('now')) NOT NULL,
    unit_price NUMERIC NOT NULL,
    quantity INT NOT NULL,
    total NUMERIC NOT NULL,
    PRIMARY KEY(id),
    FOREIGN KEY (store_id) REFERENCES stores(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert data into the "products" table
INSERT INTO products (id, name, supplier_id, cost)
SELECT id, name, supplier_id, cost
FROM products1;

-- Insert data into the "suppliers" table
INSERT INTO suppliers (id, name, contact_info)
SELECT id, name, contact_info
FROM suppliers1;

-- Insert data into the "stores" table
INSERT INTO stores (id, name, address, neighborhood)
SELECT id, store_name, address, neighborhood
FROM stores1;

-- Insert data into the "inventory" table
INSERT INTO inventory (id, product_id, store_id, quantity_available)
SELECT id, product_id, store_id, quantity_available
FROM inventory1;

-- Insert data into the "sales" table
INSERT INTO sales (id, store_id, product_id, date, unit_price, quantity, total)
SELECT id, store_id, product_id, date, unit_price, quantity, total
FROM sales1;

--Drop all temporary tables
DROP TABLE IF EXISTS products1;
DROP TABLE IF EXISTS suppliers1;
DROP TABLE IF EXISTS stores1;
DROP TABLE IF EXISTS inventory1;
DROP TABLE IF EXISTS sales1;


-- The after sales trigger: Automatically updates the inventory table whenever a sale is made
CREATE TRIGGER update_inventory_after_sale
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    -- Check if there is enough quantity available in inventory
    -- If available quantity is less than or equal to zero, rollback the transaction
    SELECT CASE
        WHEN (SELECT quantity_available FROM inventory WHERE product_id = NEW.product_id AND store_id = NEW.store_id) < NEW.quantity
        THEN RAISE(ABORT, 'Insufficient quantity available in inventory')
    END;

    -- Update inventory if there is sufficient quantity available
    UPDATE inventory
    SET quantity_available = quantity_available - NEW.quantity
    WHERE product_id = NEW.product_id
    AND store_id = NEW.store_id;
END;

-- Creating indexes to speed common searches
CREATE INDEX "product_search_index" ON products ("name", "cost");
CREATE INDEX "inventory_index" ON inventory ("product_id", "quantity_available");
CREATE INDEX "supplier_index" ON suppliers ("id", "name");
CREATE INDEX "store_index" ON stores ("id", "name");
CREATE INDEX "sales_index" ON sales ("id", "store_id", "product_id");

