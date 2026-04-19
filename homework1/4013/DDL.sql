-- ==========================================
-- 淘宝电商系统数据库设计（严格按ER图）
-- ==========================================

-- 1. 用户表
CREATE TABLE user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    real_name VARCHAR(50),
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. 商品分类表
CREATE TABLE category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

-- 3. 店铺表
CREATE TABLE shop (
    shop_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    shop_name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url VARCHAR(255),
    established DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_shop_user FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- 4. 收货地址表
CREATE TABLE address (
    addr_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    recipient_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    province VARCHAR(50),
    city VARCHAR(50),
    district VARCHAR(50),
    address_detail VARCHAR(255),
    is_default BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES user(user_id),
    CONSTRAINT fk_address_shop FOREIGN KEY (shop_id) REFERENCES shop(shop_id)
);

-- 5. 商品表
CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    shop_id INT NOT NULL,
    category_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    sales_volume INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_shop FOREIGN KEY (shop_id) REFERENCES shop(shop_id),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- 6. 订单表
CREATE TABLE `order` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    address_id INT NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP NULL,
    delivery_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES user(user_id),
    CONSTRAINT fk_order_shop FOREIGN KEY (shop_id) REFERENCES shop(shop_id),
    CONSTRAINT fk_order_address FOREIGN KEY (address_id) REFERENCES address(addr_id)
);

-- 7. 订单项表
CREATE TABLE order_item (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES `order`(order_id),
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 8. 购物车表
CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- 9. 购物车项表
CREATE TABLE cart_item (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_cart_item_cart FOREIGN KEY (cart_id) REFERENCES cart(cart_id),
    CONSTRAINT fk_cart_item_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 10. 收藏表
CREATE TABLE favorite (
    favorite_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES user(user_id),
    CONSTRAINT fk_favorite_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 11. 评论表（
CREATE TABLE review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- ==========================================
-- 测试数据
-- ==========================================

INSERT INTO user (username, password, email, phone, real_name, avatar_url) VALUES
('user1', 'pass123', 'user1@example.com', '13800000001', '张三', 'http://avatar1.jpg'),
('user2', 'pass456', 'user2@example.com', '13800000002', '李四', 'http://avatar2.jpg'),
('user3', 'pass789', 'user3@example.com', '13800000003', '王五', 'http://avatar3.jpg');

INSERT INTO category (category_name) VALUES ('服装'), ('数码'), ('图书');

INSERT INTO shop (user_id, shop_name, description, logo_url, established) VALUES
(1, '店铺1', '服装店', 'http://logo1.jpg', '2020-01-01'),
(2, '店铺2', '数码店', 'http://logo2.jpg', '2019-06-15');

INSERT INTO address (user_id, shop_id, recipient_name, phone, province, city, district, address_detail, is_default) VALUES
(1, 1, '张三', '13800000001', '北京', '北京市', '朝阳区', '中关村大街1号', TRUE),
(2, 2, '李四', '13800000002', '上海', '上海市', '浦东新区', '世纪大道1号', FALSE);

INSERT INTO product (shop_id, category_id, product_name, description, price, stock, sales_volume) VALUES
(1, 1, 'T恤', '棉质T恤', 59.90, 100, 250),
(2, 2, '手机壳', '硅胶手机壳', 29.90, 200, 500);