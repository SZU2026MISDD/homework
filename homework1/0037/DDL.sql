-- 描述: 淘宝网数据库，包含 11 个实体、完整约束、测试数据及结果视图
-- 0. 创建数据库
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'TaobaoDB')
BEGIN
    CREATE DATABASE TaobaoDB;
END
GO

USE TaobaoDB;
GO

-- 1. 初始化

IF OBJECT_ID('REVIEWS', 'U') IS NOT NULL DROP TABLE REVIEWS;
IF OBJECT_ID('PAYMENTS', 'U') IS NOT NULL DROP TABLE PAYMENTS;
IF OBJECT_ID('ORDER_DETAILS', 'U') IS NOT NULL DROP TABLE ORDER_DETAILS;
IF OBJECT_ID('ORDERS', 'U') IS NOT NULL DROP TABLE ORDERS;
IF OBJECT_ID('CART_ITEMS', 'U') IS NOT NULL DROP TABLE CART_ITEMS;
IF OBJECT_ID('ADDRESSES', 'U') IS NOT NULL DROP TABLE ADDRESSES;
IF OBJECT_ID('PRODUCTS', 'U') IS NOT NULL DROP TABLE PRODUCTS;
IF OBJECT_ID('SHOPS', 'U') IS NOT NULL DROP TABLE SHOPS;
IF OBJECT_ID('COUPONS', 'U') IS NOT NULL DROP TABLE COUPONS;
IF OBJECT_ID('CATEGORIES', 'U') IS NOT NULL DROP TABLE CATEGORIES;
IF OBJECT_ID('USERS', 'U') IS NOT NULL DROP TABLE USERS;
GO

-- 2. 建表及约束定义

-- 用户表
CREATE TABLE USERS (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE, -- 唯一约束
    phone VARCHAR(20) NOT NULL,            -- 非空约束
    email VARCHAR(100)
);

-- 分类表
CREATE TABLE CATEGORIES (
    cat_id INT IDENTITY(1,1) PRIMARY KEY,
    cat_name NVARCHAR(50) NOT NULL
);

-- 优惠券表
CREATE TABLE COUPONS (
    coupon_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(100) NOT NULL,
    discount DECIMAL(10, 2) NOT NULL
);

-- 店铺表
CREATE TABLE SHOPS (
    shop_id INT IDENTITY(1,1) PRIMARY KEY,
    owner_id INT NOT NULL,
    shop_name NVARCHAR(100) NOT NULL,
    rating DECIMAL(3, 1) DEFAULT 5.0,
    FOREIGN KEY (owner_id) REFERENCES USERS(user_id)
);

-- 商品表
CREATE TABLE PRODUCTS (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    shop_id INT NOT NULL,
    cat_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    FOREIGN KEY (shop_id) REFERENCES SHOPS(shop_id),
    FOREIGN KEY (cat_id) REFERENCES CATEGORIES(cat_id)
);

-- 地址表
CREATE TABLE ADDRESSES (
    addr_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    detail NVARCHAR(MAX) NOT NULL,
    receiver NVARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 购物车表
CREATE TABLE CART_ITEMS (
    cart_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- 订单主表
CREATE TABLE ORDERS (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 订单明细表
CREATE TABLE ORDER_DETAILS (
    detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- 支付表
CREATE TABLE PAYMENTS (
    pay_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,          -- 唯一约束，确保1对1关系
    method NVARCHAR(30) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Success',
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
);

-- 评价表
CREATE TABLE REVIEWS (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    score INT CHECK (score BETWEEN 1 AND 5), -- 检查约束
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);
GO


-- 3. 插入测试数据 (验证约束与表结构)
-- 用户数据
INSERT INTO USERS (username, phone, email) VALUES 
(N'黄同学', '13800138037', 'huang@szu.edu.cn'),
(N'彭同学', '13900139001', 'peng@szu.edu.cn'),
(N'李同学', '13700137002', 'li@szu.edu.cn');

-- 地址数据
INSERT INTO ADDRESSES (user_id, detail, receiver) VALUES 
(1, N'深圳大学致理楼', N'黄同学'),
(2, N'深圳大学南区宿舍', N'彭同学'),
(3, N'深圳大学粤海校区', N'李同学');

-- 分类数据
INSERT INTO CATEGORIES (cat_name) VALUES 
(N'电子数码'), (N'学习教材');

-- 店铺数据
INSERT INTO SHOPS (owner_id, shop_name) VALUES 
(1, N'边缘计算硬件直营店'),
(2, N'期末复习资料共享铺');

-- 商品数据
INSERT INTO PRODUCTS (shop_id, cat_id, title, price, stock) VALUES 
(1, 1, N'开发板', 699.00, 20),
(1, 1, N'NVIDIA A100 80GB 算力租赁', 299.00, 50),
(2, 2, N'数据库系统原理', 9.90, 100),
(2, 2, N'管理信息系统开发技术', 15.50, 200);

-- 订单业务流转：李同学购买了开发板并完成评价
INSERT INTO ORDERS (user_id, total_amount, status) VALUES (3, 699.00, N'Completed');
INSERT INTO ORDER_DETAILS (order_id, product_id, quantity) VALUES (1, 1, 1);
INSERT INTO PAYMENTS (order_id, method, status) VALUES (1, N'WeChat', N'Success');
INSERT INTO REVIEWS (order_id, user_id, score) VALUES (1, 3, 5);

-- 订单业务流转：彭同学购买了算力租赁，已支付未评价
INSERT INTO ORDERS (user_id, total_amount, status) VALUES (2, 299.00, N'Paid');
INSERT INTO ORDER_DETAILS (order_id, product_id, quantity) VALUES (2, 2, 1);
INSERT INTO PAYMENTS (order_id, method, status) VALUES (2, N'Alipay', N'Success');

-- 订单业务流转：黄同学购买了两份学习资料，提交了订单但未支付
INSERT INTO ORDERS (user_id, total_amount, status) VALUES (1, 25.40, N'Pending');
INSERT INTO ORDER_DETAILS (order_id, product_id, quantity) VALUES (3, 3, 1);
INSERT INTO ORDER_DETAILS (order_id, product_id, quantity) VALUES (3, 4, 1);
GO

-- 4. 打印视图 


SELECT user_id AS N'用户ID', username AS N'用户名', phone AS N'手机号' 
FROM USERS;

SELECT p.product_id AS N'商品ID', s.shop_name AS N'所属店铺', c.cat_name AS N'分类', p.title AS N'商品名称', p.price AS N'单价'
FROM PRODUCTS p
JOIN SHOPS s ON p.shop_id = s.shop_id
JOIN CATEGORIES c ON p.cat_id = c.cat_id;

SELECT 
    o.order_id AS N'订单编号',
    u.username AS N'买家姓名',
    p.title AS N'包含商品',
    od.quantity AS N'数量',
    o.total_amount AS N'订单总价',
    o.status AS N'订单状态',
    ISNULL(pay.method, N'未支付') AS N'支付方式',
    ISNULL(CAST(r.score AS VARCHAR), N'暂无评价') AS N'买家评分'
FROM ORDERS o
JOIN USERS u ON o.user_id = u.user_id
JOIN ORDER_DETAILS od ON o.order_id = od.order_id
JOIN PRODUCTS p ON od.product_id = p.product_id
LEFT JOIN PAYMENTS pay ON o.order_id = pay.order_id
LEFT JOIN REVIEWS r ON o.order_id = r.order_id;
GO