-- 创建数据库
CREATE DATABASE IF NOT EXISTS taobao_db CHARACTER SET utf8mb4;
USE taobao_db;

-- 1. 用户表
CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 店铺表
CREATE TABLE Shop (
    shop_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    shop_name VARCHAR(100) NOT NULL,
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- 3. 商品分类表
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

-- 4. 商品表
CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    shop_id INT NOT NULL,
    category_id INT,
    title VARCHAR(200) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (shop_id) REFERENCES Shop(shop_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- 5. 收货地址表
CREATE TABLE Address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    receiver_name VARCHAR(50) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    detail_address TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- 6. 购物车表
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 7. 订单表
CREATE TABLE `Order` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled') DEFAULT 'pending',
    address_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- 8. 订单详情表
CREATE TABLE OrderItem (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 9. 评价表
CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 10. 支付记录表
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100) UNIQUE,
    pay_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
);

-- 测试数据插入
INSERT INTO Category (category_name) VALUES ('宠物用品'), ('电子产品');
INSERT INTO User (username, password, phone) VALUES ('TechDog', 'pwd123', '13800000000');
INSERT INTO Shop (user_id, shop_name) VALUES (1, 'Tuanty Pet Tech');
INSERT INTO Product (shop_id, category_id, title, base_price, stock_quantity) 
VALUES (1, 1, '智能鲜食机', 1999.00, 100);