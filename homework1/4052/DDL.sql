-- =====================================================
-- 淘宝网数据库设计 DDL 
-- 包含实体：用户、店铺、商品分类、商品、评论、购物车、
--          收货地址、订单、订单明细、支付记录
-- =====================================================

-- 启用外键约束检查（SQLite3 默认关闭）
PRAGMA foreign_keys = ON;

-- ----------------------------
-- 1. 用户表
-- ----------------------------
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    user_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username        TEXT NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    phone           TEXT,
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1))
);

-- ----------------------------
-- 2. 店铺表
-- ----------------------------
DROP TABLE IF EXISTS shop;
CREATE TABLE shop (
    shop_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_name       TEXT NOT NULL,
    owner_user_id   INTEGER NOT NULL,
    description     TEXT,
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    FOREIGN KEY (owner_user_id) REFERENCES user(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_shop_owner ON shop(owner_user_id);

-- ----------------------------
-- 3. 商品分类表（自关联）
-- ----------------------------
DROP TABLE IF EXISTS category;
CREATE TABLE category (
    category_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name      TEXT NOT NULL,
    parent_category_id INTEGER,
    FOREIGN KEY (parent_category_id) REFERENCES category(category_id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_category_parent ON category(parent_category_id);

-- ----------------------------
-- 4. 商品表
-- ----------------------------
DROP TABLE IF EXISTS product;
CREATE TABLE product (
    product_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name    TEXT NOT NULL,
    shop_id         INTEGER NOT NULL,
    category_id     INTEGER,
    price           NUMERIC NOT NULL CHECK (price >= 0),
    stock           INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    description     TEXT,
    listed_at       TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    FOREIGN KEY (shop_id) REFERENCES shop(shop_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX idx_product_shop ON product(shop_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_price ON product(price);

-- ----------------------------
-- 5. 评论表
-- ----------------------------
DROP TABLE IF EXISTS review;
CREATE TABLE review (
    review_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id      INTEGER NOT NULL,
    user_id         INTEGER NOT NULL,
    rating          INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    content         TEXT,
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE(user_id, product_id)  -- 同一用户对同一商品仅能评论一次
);
CREATE INDEX idx_review_product ON review(product_id);
CREATE INDEX idx_review_user ON review(user_id);

-- ----------------------------
-- 6. 购物车表
-- ----------------------------
DROP TABLE IF EXISTS cart;
CREATE TABLE cart (
    cart_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    product_id      INTEGER NOT NULL,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    added_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE(user_id, product_id)
);
CREATE INDEX idx_cart_product ON cart(product_id);

-- ----------------------------
-- 7. 收货地址表
-- ----------------------------
DROP TABLE IF EXISTS address;
CREATE TABLE address (
    address_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    recipient_name  TEXT NOT NULL,
    phone           TEXT NOT NULL,
    province        TEXT,
    city            TEXT,
    district        TEXT,
    detail_address  TEXT NOT NULL,
    is_default      INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1)),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_address_user ON address(user_id);

-- ----------------------------
-- 8. 订单表
-- ----------------------------
DROP TABLE IF EXISTS "order";
CREATE TABLE "order" (
    order_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    address_id      INTEGER NOT NULL,
    total_amount    NUMERIC NOT NULL CHECK (total_amount >= 0),
    status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','paid','shipped','completed','cancelled')),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at         TEXT,
    shipped_at      TEXT,
    completed_at    TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_order_user ON "order"(user_id);
CREATE INDEX idx_order_status ON "order"(status);
CREATE INDEX idx_order_created ON "order"(created_at);

-- ----------------------------
-- 9. 订单明细表
-- ----------------------------
DROP TABLE IF EXISTS order_item;
CREATE TABLE order_item (
    order_item_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        INTEGER NOT NULL,
    product_id      INTEGER NOT NULL,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_orderitem_order ON order_item(order_id);
CREATE INDEX idx_orderitem_product ON order_item(product_id);

-- ----------------------------
-- 10. 支付记录表
-- ----------------------------
DROP TABLE IF EXISTS payment;
CREATE TABLE payment (
    payment_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        INTEGER NOT NULL UNIQUE,  -- 一个订单一条支付记录
    payment_method  TEXT NOT NULL,
    amount          NUMERIC NOT NULL CHECK (amount >= 0),
    payment_status  TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending','success','failed')),
    transaction_id  TEXT,
    paid_at         TEXT,
    FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX idx_payment_status ON payment(payment_status);

-- =====================================================
-- 插入测试数据（验证表结构合理性）
-- =====================================================

-- 1. 插入一个用户
INSERT INTO user (username, password_hash, email, phone) VALUES
('buyer001', 'hashed_password_123', 'buyer@example.com', '13800138000');

-- 2. 插入一个店铺（店主为上述用户）
INSERT INTO shop (shop_name, owner_user_id, description) VALUES
('时尚数码店', 1, '主营手机、电脑及配件');

-- 3. 插入商品分类
INSERT INTO category (category_id, category_name, parent_category_id) VALUES
(1, '数码家电', NULL),
(2, '手机', 1),
(3, '电脑', 1);

-- 4. 插入一个商品
INSERT INTO product (product_name, shop_id, category_id, price, stock, description) VALUES
('超级智能手机 X1', 1, 2, 2999.00, 100, '6.7英寸屏幕，12GB+256GB');

-- 5. 插入收货地址
INSERT INTO address (user_id, recipient_name, phone, province, city, district, detail_address, is_default) VALUES
(1, '张三', '13800138000', '浙江省', '杭州市', '西湖区', '文三路100号', 1);

-- 6. 查询用户和其店铺
SELECT u.username, s.shop_name 
FROM user u 
JOIN shop s ON u.user_id = s.owner_user_id;

-- 7. 查询商品及其所属店铺与分类
SELECT p.product_name, s.shop_name, c.category_name 
FROM product p 
LEFT JOIN shop s ON p.shop_id = s.shop_id 
LEFT JOIN category c ON p.category_id = c.category_id;

-- 8. 尝试插入违反外键的数据（会被拒绝）
-- 下面语句会失败，因为 user_id = 999 不存在
INSERT INTO shop (shop_name, owner_user_id) VALUES ('测试店铺', 999);
-- 预期错误：FOREIGN KEY constraint failed

