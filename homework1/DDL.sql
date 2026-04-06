-- MySQL DDL for Taobao Database (Student ID: 0067)

-- 1. 用户表 (User)
CREATE TABLE `User` (
    `user_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码',
    `phone` VARCHAR(20) UNIQUE COMMENT '手机号',
    `email` VARCHAR(100) UNIQUE COMMENT '邮箱',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) COMMENT='用户表';

-- 2. 店铺表 (Shop)
CREATE TABLE `Shop` (
    `shop_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '店铺ID',
    `user_id` BIGINT NOT NULL UNIQUE COMMENT '卖家ID (关联User表)',
    `shop_name` VARCHAR(100) NOT NULL COMMENT '店铺名称',
    `description` TEXT COMMENT '店铺描述',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`)
) COMMENT='店铺表';

-- 3. 商品分类表 (Category)
CREATE TABLE `Category` (
    `category_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    `parent_id` INT DEFAULT NULL COMMENT '父分类ID (自关联)',
    `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '分类名称',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    FOREIGN KEY (`parent_id`) REFERENCES `Category`(`category_id`)
) COMMENT='商品分类表';

-- 4. 商品表 (Product)
CREATE TABLE `Product` (
    `product_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID',
    `shop_id` BIGINT NOT NULL COMMENT '所属店铺 (关联Shop表)',
    `category_id` INT NOT NULL COMMENT '所属分类 (关联Category表)',
    `title` VARCHAR(255) NOT NULL COMMENT '商品标题',
    `sub_title` VARCHAR(255) COMMENT '副标题',
    `status` TINYINT DEFAULT 1 COMMENT '状态 (0:下架, 1:上架)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (`shop_id`) REFERENCES `Shop`(`shop_id`),
    FOREIGN KEY (`category_id`) REFERENCES `Category`(`category_id`)
) COMMENT='商品表';

-- 5. 商品规格表 (SKU)
CREATE TABLE `SKU` (
    `sku_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'SKU_ID',
    `product_id` BIGINT NOT NULL COMMENT '所属商品 (关联Product表)',
    `spec_name` VARCHAR(100) NOT NULL COMMENT '规格名称 (如: 红色, L码)',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '价格',
    `stock` INT NOT NULL DEFAULT 0 COMMENT '库存',
    FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
) COMMENT='商品规格表';

-- 6. 收货地址表 (Address)
CREATE TABLE `Address` (
    `address_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '地址ID',
    `user_id` BIGINT NOT NULL COMMENT '所属用户 (关联User表)',
    `receiver_name` VARCHAR(50) NOT NULL COMMENT '收货人',
    `receiver_phone` VARCHAR(20) NOT NULL COMMENT '手机号',
    `province` VARCHAR(50) NOT NULL COMMENT '省',
    `city` VARCHAR(50) NOT NULL COMMENT '市',
    `district` VARCHAR(50) NOT NULL COMMENT '区',
    `detail_address` VARCHAR(255) NOT NULL COMMENT '详细地址',
    `is_default` BOOLEAN DEFAULT FALSE COMMENT '是否默认地址',
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`)
) COMMENT='收货地址表';

-- 7. 购物车表 (Cart)
CREATE TABLE `Cart` (
    `cart_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '购物车ID',
    `user_id` BIGINT NOT NULL COMMENT '所属用户 (关联User表)',
    `sku_id` BIGINT NOT NULL COMMENT '商品SKU (关联SKU表)',
    `quantity` INT NOT NULL DEFAULT 1 COMMENT '购买数量',
    `added_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    UNIQUE (`user_id`, `sku_id`) COMMENT '同一用户同一SKU只能有一条记录',
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`),
    FOREIGN KEY (`sku_id`) REFERENCES `SKU`(`sku_id`)
) COMMENT='购物车表';

-- 8. 订单表 (Order)
CREATE TABLE `Order` (
    `order_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    `user_id` BIGINT NOT NULL COMMENT '买家ID (关联User表)',
    `total_amount` DECIMAL(10, 2) NOT NULL COMMENT '总金额',
    `pay_status` TINYINT DEFAULT 0 COMMENT '支付状态 (0:未付, 1:已付)',
    `order_status` TINYINT DEFAULT 0 COMMENT '订单状态 (0:待发货, 1:已发货, 2:已收货, 3:已完成, 4:已取消)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`)
) COMMENT='订单表';

-- 9. 订单详情表 (OrderItem)
CREATE TABLE `OrderItem` (
    `item_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单项ID',
    `order_id` BIGINT NOT NULL COMMENT '所属订单 (关联Order表)',
    `sku_id` BIGINT NOT NULL COMMENT '商品SKU (关联SKU表)',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '下单单价',
    `quantity` INT NOT NULL COMMENT '购买数量',
    FOREIGN KEY (`order_id`) REFERENCES `Order`(`order_id`),
    FOREIGN KEY (`sku_id`) REFERENCES `SKU`(`sku_id`)
) COMMENT='订单详情表';

-- 10. 评论表 (Review)
CREATE TABLE `Review` (
    `review_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID (关联User表)',
    `product_id` BIGINT NOT NULL COMMENT '商品ID (关联Product表)',
    `rating` TINYINT NOT NULL COMMENT '评分 (1-5星)',
    `content` TEXT COMMENT '评论内容',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`),
    FOREIGN KEY (`product_id`) REFERENCES `Product`(`product_id`)
) COMMENT='评论表';

-- 11. 收藏夹表 (Favorite)
CREATE TABLE `Favorite` (
    `favorite_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID (关联User表)',
    `target_id` BIGINT NOT NULL COMMENT '目标ID (商品或店铺ID)',
    `type` TINYINT NOT NULL COMMENT '类型 (1:商品, 2:店铺)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    UNIQUE (`user_id`, `target_id`, `type`) COMMENT '同一用户不能重复收藏同一目标',
    FOREIGN KEY (`user_id`) REFERENCES `User`(`user_id`)
) COMMENT='收藏夹表';


-- 插入测试数据

-- User
INSERT INTO `User` (`username`, `password`, `phone`, `email`) VALUES
('zhangsan', 'e10adc3949ba59abbe56e057f20f883e', '13800138000', 'zhangsan@example.com'),
('lisi', 'e10adc3949ba59abbe56e057f20f883e', '13912345678', 'lisi@example.com');

-- Shop
INSERT INTO `Shop` (`user_id`, `shop_name`, `description`) VALUES
(1, '张三的小店', '欢迎光临张三的小店，品质保证！'),
(2, '李四数码', '专注数码产品，正品行货。');

-- Category
INSERT INTO `Category` (`name`, `parent_id`) VALUES
('电子产品', NULL),
('手机', 1),
('电脑', 1),
('服装', NULL),
('男装', 4),
('女装', 4);

-- Product
INSERT INTO `Product` (`shop_id`, `category_id`, `title`, `sub_title`, `status`) VALUES
(1, 2, '小米手机', '高性能智能手机', 1),
(1, 5, '男士T恤', '纯棉舒适，夏季必备', 1),
(2, 3, '联想笔记本', '轻薄便携，办公学习', 1);

-- SKU
INSERT INTO `SKU` (`product_id`, `spec_name`, `price`, `stock`) VALUES
(1, '黑色 128GB', 1999.00, 100),
(1, '白色 256GB', 2299.00, 50),
(2, 'M码 黑色', 89.00, 200),
(2, 'L码 白色', 89.00, 150),
(3, 'i5 8GB 256GB', 4999.00, 30);

-- Address
INSERT INTO `Address` (`user_id`, `receiver_name`, `receiver_phone`, `province`, `city`, `district`, `detail_address`, `is_default`) VALUES
(1, '张三', '13800138000', '广东省', '深圳市', '南山区', '科技园深南大道1000号', TRUE),
(1, '张三', '13800138001', '广东省', '广州市', '天河区', '珠江新城华夏路1号', FALSE),
(2, '李四', '13912345678', '北京市', '北京市', '海淀区', '中关村大街1号', TRUE);

-- Cart
INSERT INTO `Cart` (`user_id`, `sku_id`, `quantity`) VALUES
(1, 1, 1),
(1, 3, 2),
(2, 5, 1);

-- Order
INSERT INTO `Order` (`user_id`, `total_amount`, `pay_status`, `order_status`) VALUES
(1, 1999.00, 1, 0),
(1, 178.00, 1, 1),
(2, 4999.00, 0, 0);

-- OrderItem
INSERT INTO `OrderItem` (`order_id`, `sku_id`, `price`, `quantity`) VALUES
(1, 1, 1999.00, 1),
(2, 3, 89.00, 2),
(3, 5, 4999.00, 1);

-- Review
INSERT INTO `Review` (`user_id`, `product_id`, `rating`, `content`) VALUES
(1, 1, 5, '手机很棒，运行流畅！'),
(1, 2, 4, 'T恤质量不错，就是有点薄。'),
(2, 3, 5, '笔记本电脑很轻，办公很方便。');

-- Favorite
INSERT INTO `Favorite` (`user_id`, `target_id`, `type`) VALUES
(1, 3, 1), -- 用户1收藏商品3
(1, 2, 2), -- 用户1收藏店铺2
(2, 1, 1); -- 用户2收藏商品1
