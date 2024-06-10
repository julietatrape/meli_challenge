CREATE TABLE IF NOT EXISTS customers(
	customer_id SERIAL PRIMARY KEY,
    is_seller BOOLEAN NOT NULL,
	name VARCHAR(50) NOT NULL,
	surname VARCHAR(50) NOT NULL,
	email VARCHAR(50),
	gender VARCHAR(50),
	address VARCHAR(150),
    date_of_birth DATE,
    phone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS categories(
	category_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(150),
	path VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS items(
	item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    is_published BOOLEAN,
	price FLOAT NOT NULL CHECK (price > 0),
    created_at DATE,
    updated_at DATE,
	discontinuation_date DATE,
    category_id INT,
	FOREIGN KEY(category_id) REFERENCES categories(category_id)
);

CREATE TABLE IF NOT EXISTS orders(
	order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    item_id INT,
	FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(item_id) REFERENCES items(item_id)
);