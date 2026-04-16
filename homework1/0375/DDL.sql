CREATE TABLE user_info (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(30) NOT NULL,
    phone VARCHAR(11) NOT NULL UNIQUE
);

CREATE TABLE shop (
    shop_id INT IDENTITY(1,1) PRIMARY KEY,
    shop_name VARCHAR(50) NOT NULL UNIQUE,
    shop_score DECIMAL(2,1)
);

CREATE TABLE category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE address (
    address_id INT IDENTITY(1,1) PRIMARY KEY,
    receiver VARCHAR(20) NOT NULL,
    detail VARCHAR(200) NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_info(user_id)
);

CREATE TABLE cart (
    cart_id INT IDENTITY(1,1) PRIMARY KEY,
    create_time DATETIME NOT NULL,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES user_info(user_id)
);

CREATE TABLE product (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    shop_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (shop_id) REFERENCES shop(shop_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE comment (
    comment_id INT IDENTITY(1,1) PRIMARY KEY,
    content VARCHAR(500),
    score INT NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_info(user_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE order_info (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_time DATETIME NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    user_id INT NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_info(user_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE cart_item (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    quantity INT NOT NULL,
    add_time DATETIME NOT NULL,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE order_item (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    quantity INT NOT NULL,
    deal_price DECIMAL(10,2) NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES order_info(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO user_info (username, phone) VALUES ('张三', '13800138000');
INSERT INTO shop (shop_name, shop_score) VALUES ('数码专营店', 4.9);
INSERT INTO category (category_name) VALUES ('手机');
INSERT INTO address (receiver, detail, user_id) VALUES ('张三', '北京市海淀区', 1);
INSERT INTO product (product_name, price, shop_id, category_id) VALUES ('iPhone 15', 5999.00, 1, 1);