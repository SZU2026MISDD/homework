-- Taobao-like database schema (MySQL 8.0+)
-- File: DDL.sql

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS user_coupons;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS shop_follows;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS user_addresses;
DROP TABLE IF EXISTS product_skus;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS shops;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    gender ENUM('M', 'F', 'U') DEFAULT 'U',
    birthday DATE,
    user_status ENUM('ACTIVE', 'DISABLED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shops (
    shop_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    owner_user_id BIGINT NOT NULL,
    shop_name VARCHAR(100) NOT NULL UNIQUE,
    shop_level TINYINT NOT NULL DEFAULT 1,
    shop_status ENUM('OPEN', 'CLOSED', 'SUSPENDED') NOT NULL DEFAULT 'OPEN',
    rating DECIMAL(3,2) NOT NULL DEFAULT 5.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categories (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    parent_category_id BIGINT NULL,
    category_name VARCHAR(100) NOT NULL,
    sort_no INT NOT NULL DEFAULT 0,
    is_enabled TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uk_parent_name (parent_category_id, category_name),
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    shop_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    product_title VARCHAR(200) NOT NULL,
    product_subtitle VARCHAR(300),
    detail_text TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    product_status ENUM('ON_SALE', 'OFF_SHELF', 'DELETED') NOT NULL DEFAULT 'ON_SALE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_skus (
    sku_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    sku_code VARCHAR(64) NOT NULL UNIQUE,
    attrs_json JSON,
    sale_price DECIMAL(10,2) NOT NULL,
    stock_qty INT NOT NULL DEFAULT 0,
    locked_stock INT NOT NULL DEFAULT 0,
    sku_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_addresses (
    address_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    receiver_name VARCHAR(50) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    province VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    district VARCHAR(50),
    detail_address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE carts (
    cart_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cart_items (
    cart_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cart_id BIGINT NOT NULL,
    sku_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    checked TINYINT(1) NOT NULL DEFAULT 1,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_cart_sku (cart_id, sku_id),
    CHECK (quantity > 0),
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    FOREIGN KEY (sku_id) REFERENCES product_skus(sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_no VARCHAR(40) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    shop_id BIGINT NOT NULL,
    address_id BIGINT NOT NULL,
    order_status ENUM('PENDING_PAYMENT', 'PAID', 'SHIPPED', 'COMPLETED', 'CANCELLED') NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    freight_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    payable_amount DECIMAL(12,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id),
    FOREIGN KEY (address_id) REFERENCES user_addresses(address_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    sku_id BIGINT NOT NULL,
    product_title_snapshot VARCHAR(200) NOT NULL,
    sku_attrs_snapshot VARCHAR(200),
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    line_amount DECIMAL(12,2) NOT NULL,
    CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (sku_id) REFERENCES product_skus(sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payments (
    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL UNIQUE,
    pay_method ENUM('ALIPAY', 'WECHAT', 'BANK_CARD') NOT NULL,
    pay_status ENUM('INIT', 'SUCCESS', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'INIT',
    transaction_no VARCHAR(64) UNIQUE,
    paid_amount DECIMAL(12,2) NOT NULL,
    paid_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shipments (
    shipment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL UNIQUE,
    carrier_name VARCHAR(50) NOT NULL,
    tracking_no VARCHAR(64) UNIQUE,
    shipment_status ENUM('WAITING', 'IN_TRANSIT', 'SIGNED') NOT NULL DEFAULT 'WAITING',
    shipped_at DATETIME,
    signed_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reviews (
    review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_item_id BIGINT NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    shop_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    rating TINYINT NOT NULL,
    content VARCHAR(500),
    has_image TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shop_follows (
    user_id BIGINT NOT NULL,
    shop_id BIGINT NOT NULL,
    followed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, shop_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE coupons (
    coupon_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    shop_id BIGINT NULL,
    coupon_code VARCHAR(40) NOT NULL UNIQUE,
    coupon_name VARCHAR(100) NOT NULL,
    threshold_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10,2) NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NOT NULL,
    total_count INT NOT NULL DEFAULT 0,
    issued_count INT NOT NULL DEFAULT 0,
    CHECK (valid_to > valid_from),
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_coupons (
    user_coupon_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    coupon_id BIGINT NOT NULL,
    order_id BIGINT NULL,
    coupon_status ENUM('UNUSED', 'USED', 'EXPIRED') NOT NULL DEFAULT 'UNUSED',
    claimed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    used_at DATETIME NULL,
    UNIQUE KEY uk_user_coupon (user_id, coupon_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Test data (5 insert statements)
INSERT INTO users (user_id, username, phone, email, password_hash, gender)
VALUES
    (1, 'buyer_zhang', '13800000001', 'buyer1@example.com', 'hash_a', 'M'),
    (2, 'seller_li', '13800000002', 'seller1@example.com', 'hash_b', 'F');

INSERT INTO shops (shop_id, owner_user_id, shop_name, shop_level, shop_status, rating)
VALUES
    (1, 2, '李家数码旗舰店', 3, 'OPEN', 4.90);

INSERT INTO categories (category_id, parent_category_id, category_name, sort_no, is_enabled)
VALUES
    (1, NULL, '数码家电', 1, 1),
    (2, 1, '手机', 1, 1);

INSERT INTO products (product_id, shop_id, category_id, product_title, product_subtitle, detail_text, base_price, product_status)
VALUES
    (1, 1, 2, '国产智能手机 X1', '8+256G，快速充电', '课堂作业测试商品', 2999.00, 'ON_SALE');

INSERT INTO product_skus (sku_id, product_id, sku_code, attrs_json, sale_price, stock_qty, locked_stock, sku_status)
VALUES
    (1, 1, 'X1-BLACK-8-256', JSON_OBJECT('color', 'black', 'ram', '8G', 'rom', '256G'), 2899.00, 100, 0, 'ACTIVE');
