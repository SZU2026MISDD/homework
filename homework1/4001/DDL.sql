-- =====================================================
-- 淘宝网站数据库设计 - SQL DDL 语句
-- 用途：完整演练从业务需求梳理到数据库物理实现的全流程
-- =====================================================

-- =====================================================
-- 1. 用户表 (Users)
-- =====================================================
CREATE TABLE 用户 (
    用户ID INT PRIMARY KEY AUTO_INCREMENT,
    用户名 VARCHAR(50) NOT NULL UNIQUE,
    密码 VARCHAR(255) NOT NULL,
    真实姓名 VARCHAR(100) NOT NULL,
    邮箱 VARCHAR(100) NOT NULL UNIQUE,
    手机号 VARCHAR(20) NOT NULL UNIQUE,
    账户余额 DECIMAL(15,2) DEFAULT 0,
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    最后登录时间 DATETIME,
    账户状态 ENUM('正常','冻结','注销') DEFAULT '正常',
    身份证号 VARCHAR(18) UNIQUE,
    备注 TEXT
);

-- =====================================================
-- 2. 商品分类表 (Categories)
-- =====================================================
CREATE TABLE 商品分类 (
    分类ID INT PRIMARY KEY AUTO_INCREMENT,
    分类名称 VARCHAR(100) NOT NULL UNIQUE,
    父分类ID INT,
    分类描述 TEXT,
    是否启用 BOOLEAN DEFAULT TRUE,
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (父分类ID) REFERENCES 商品分类(分类ID) ON DELETE SET NULL
);

-- =====================================================
-- 3. 店铺表 (Shops)
-- =====================================================
CREATE TABLE 店铺 (
    店铺ID INT PRIMARY KEY AUTO_INCREMENT,
    店主用户ID INT NOT NULL,
    店铺名称 VARCHAR(100) NOT NULL UNIQUE,
    店铺描述 TEXT,
    店铺LOGO VARCHAR(255),
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    店铺等级 ENUM('普通','中等','优质','旗舰') DEFAULT '普通',
    月销量 INT DEFAULT 0,
    店铺评分 DECIMAL(3,1) DEFAULT 5.0,
    是否启用 BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (店主用户ID) REFERENCES 用户(用户ID) ON DELETE CASCADE
);

-- =====================================================
-- 4. 商品表 (Products)
-- =====================================================
CREATE TABLE 商品 (
    商品ID INT PRIMARY KEY AUTO_INCREMENT,
    店铺ID INT NOT NULL,
    分类ID INT NOT NULL,
    商品名称 VARCHAR(200) NOT NULL,
    商品描述 TEXT,
    商品价格 DECIMAL(10,2) NOT NULL,
    原价 DECIMAL(10,2),
    库存数量 INT NOT NULL DEFAULT 0,
    销量 INT DEFAULT 0,
    商品评分 DECIMAL(3,1) DEFAULT 5.0,
    图片URL VARCHAR(255),
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    最后修改时间 DATETIME ON UPDATE CURRENT_TIMESTAMP,
    是否下架 BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (店铺ID) REFERENCES 店铺(店铺ID) ON DELETE CASCADE,
    FOREIGN KEY (分类ID) REFERENCES 商品分类(分类ID) ON DELETE RESTRICT
);

-- =====================================================
-- 5. 用户地址表 (UserAddresses)
-- =====================================================
CREATE TABLE 用户地址 (
    地址ID INT PRIMARY KEY AUTO_INCREMENT,
    用户ID INT NOT NULL,
    收货人名字 VARCHAR(50) NOT NULL,
    收货人电话 VARCHAR(20) NOT NULL,
    省份 VARCHAR(50) NOT NULL,
    城市 VARCHAR(50) NOT NULL,
    区县 VARCHAR(50) NOT NULL,
    详细地址 VARCHAR(255) NOT NULL,
    邮编 VARCHAR(10),
    是否默认 BOOLEAN DEFAULT FALSE,
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (用户ID) REFERENCES 用户(用户ID) ON DELETE CASCADE
);

-- =====================================================
-- 6. 购物车表 (ShoppingCart)
-- =====================================================
CREATE TABLE 购物车 (
    购物车ID INT PRIMARY KEY AUTO_INCREMENT,
    用户ID INT NOT NULL UNIQUE,
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    最后修改时间 DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (用户ID) REFERENCES 用户(用户ID) ON DELETE CASCADE
);

-- =====================================================
-- 7. 购物车项目表 (CartItems)
-- =====================================================
CREATE TABLE 购物车项 (
    购物车项ID INT PRIMARY KEY AUTO_INCREMENT,
    购物车ID INT NOT NULL,
    商品ID INT NOT NULL,
    数量 INT NOT NULL DEFAULT 1,
    添加时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (购物车ID) REFERENCES 购物车(购物车ID) ON DELETE CASCADE,
    FOREIGN KEY (商品ID) REFERENCES 商品(商品ID) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_product (购物车ID, 商品ID)
);

-- =====================================================
-- 8. 订单表 (Orders)
-- =====================================================
CREATE TABLE 订单 (
    订单ID INT PRIMARY KEY AUTO_INCREMENT,
    买家用户ID INT NOT NULL,
    收货地址ID INT NOT NULL,
    订单总金额 DECIMAL(15,2) NOT NULL,
    实付金额 DECIMAL(15,2) NOT NULL,
    优惠金额 DECIMAL(15,2) DEFAULT 0,
    运费 DECIMAL(10,2) DEFAULT 0,
    订单状态 ENUM('待支付','已支付','已发货','已收货','已完成','已退款','已取消') DEFAULT '待支付',
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    支付时间 DATETIME,
    发货时间 DATETIME,
    收货时间 DATETIME,
    订单备注 TEXT,
    FOREIGN KEY (买家用户ID) REFERENCES 用户(用户ID) ON DELETE CASCADE,
    FOREIGN KEY (收货地址ID) REFERENCES 用户地址(地址ID) ON DELETE RESTRICT
);

-- =====================================================
-- 9. 订单项目表 (OrderItems)
-- =====================================================
CREATE TABLE 订单项 (
    订单项ID INT PRIMARY KEY AUTO_INCREMENT,
    订单ID INT NOT NULL,
    商品ID INT NOT NULL,
    店铺ID INT NOT NULL,
    商品数量 INT NOT NULL,
    商品单价 DECIMAL(10,2) NOT NULL,
    商品小计 DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (订单ID) REFERENCES 订单(订单ID) ON DELETE CASCADE,
    FOREIGN KEY (商品ID) REFERENCES 商品(商品ID) ON DELETE RESTRICT,
    FOREIGN KEY (店铺ID) REFERENCES 店铺(店铺ID) ON DELETE RESTRICT
);

-- =====================================================
-- 10. 评论表 (Reviews)
-- =====================================================
CREATE TABLE 评论 (
    评论ID INT PRIMARY KEY AUTO_INCREMENT,
    商品ID INT NOT NULL,
    用户ID INT NOT NULL,
    订单ID INT NOT NULL,
    评分 INT NOT NULL CHECK (评分 BETWEEN 1 AND 5),
    评论标题 VARCHAR(100) NOT NULL,
    评论内容 TEXT NOT NULL,
    有用数 INT DEFAULT 0,
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    修改时间 DATETIME ON UPDATE CURRENT_TIMESTAMP,
    审核状态 ENUM('待审核','已通过','已拒绝') DEFAULT '待审核',
    FOREIGN KEY (商品ID) REFERENCES 商品(商品ID) ON DELETE CASCADE,
    FOREIGN KEY (用户ID) REFERENCES 用户(用户ID) ON DELETE CASCADE,
    FOREIGN KEY (订单ID) REFERENCES 订单(订单ID) ON DELETE CASCADE
);

-- =====================================================
-- 11. 支付方式表 (PaymentMethods)
-- =====================================================
CREATE TABLE 支付方式 (
    支付方式ID INT PRIMARY KEY AUTO_INCREMENT,
    用户ID INT NOT NULL,
    支付类型 ENUM('支付宝','微信','银行卡','花呗','储值卡') NOT NULL,
    账户号 VARCHAR(100),
    账户名 VARCHAR(100),
    绑定时间 DATETIME DEFAULT CURRENT_TIMESTAMP,
    是否默认 BOOLEAN DEFAULT FALSE,
    是否启用 BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (用户ID) REFERENCES 用户(用户ID) ON DELETE CASCADE
);

-- =====================================================
-- 12. 物流信息表 (Shipments)
-- =====================================================
CREATE TABLE 物流信息 (
    物流ID INT PRIMARY KEY AUTO_INCREMENT,
    订单ID INT NOT NULL,
    物流公司 VARCHAR(50) NOT NULL,
    运单号 VARCHAR(50) NOT NULL UNIQUE,
    发货时间 DATETIME,
    预计送达时间 DATETIME,
    实际送达时间 DATETIME,
    当前位置 VARCHAR(100),
    物流状态 ENUM('已下单','已揽收','转运中','待派送','派送中','已签收','已退回') DEFAULT '已下单',
    运单备注 TEXT,
    FOREIGN KEY (订单ID) REFERENCES 订单(订单ID) ON DELETE CASCADE
);

-- =====================================================
-- 创建索引以提高查询性能
-- =====================================================

-- 用户表索引
CREATE INDEX idx_用户_用户名 ON 用户(用户名);
CREATE INDEX idx_用户_邮箱 ON 用户(邮箱);
CREATE INDEX idx_用户_创建时间 ON 用户(创建时间);

-- 店铺表索引
CREATE INDEX idx_店铺_店主 ON 店铺(店主用户ID);
CREATE INDEX idx_店铺_名称 ON 店铺(店铺名称);

-- 商品表索引
CREATE INDEX idx_商品_店铺 ON 商品(店铺ID);
CREATE INDEX idx_商品_分类 ON 商品(分类ID);
CREATE INDEX idx_商品_名称 ON 商品(商品名称);
CREATE INDEX idx_商品_创建时间 ON 商品(创建时间);

-- 订单表索引
CREATE INDEX idx_订单_买家 ON 订单(买家用户ID);
CREATE INDEX idx_订单_状态 ON 订单(订单状态);
CREATE INDEX idx_订单_创建时间 ON 订单(创建时间);

-- 评论表索引
CREATE INDEX idx_评论_商品 ON 评论(商品ID);
CREATE INDEX idx_评论_用户 ON 评论(用户ID);
CREATE INDEX idx_评论_审核状态 ON 评论(审核状态);

-- =====================================================
-- 测试数据 (INSERT 语句)
-- =====================================================

-- 插入用户数据
INSERT INTO 用户 (用户名, 密码, 真实姓名, 邮箱, 手机号, 账户余额, 身份证号) VALUES
('张三_买家', 'pass123456', '张三', 'zhangsan@taobao.com', '13800138000', 5000.00, '110101199001011234'),
('李四_卖家', 'pass123456', '李四', 'lisi@taobao.com', '13800138001', 10000.00, '110101199002021234'),
('王五_买家', 'pass123456', '王五', 'wangwu@taobao.com', '13800138002', 3000.00, '110101199003031234');

-- 插入商品分类数据
INSERT INTO 商品分类 (分类名称, 父分类ID, 分类描述) VALUES
('服装鞋包', NULL, '服装鞋包大类'),
('女装', 1, '女性服装'),
('男装', 1, '男性服装'),
('电子产品', NULL, '电子产品大类'),
('手机', 4, '智能手机');

-- 插入店铺数据
INSERT INTO 店铺 (店主用户ID, 店铺名称, 店铺描述, 店铺等级, 月销量, 店铺评分) VALUES
(2, '李四服装店', '专业服装销售', '优质', 1500, 4.8);

-- 插入商品数据
INSERT INTO 商品 (店铺ID, 分类ID, 商品名称, 商品描述, 商品价格, 原价, 库存数量, 销量, 商品评分) VALUES
(1, 2, '夏季棉质T恤', '高品质棉质T恤，舒适透气', 49.99, 79.99, 500, 1200, 4.7),
(1, 3, '男士牛仔裤', '潮流款式男士牛仔裤', 129.99, 199.99, 300, 800, 4.6),
(1, 5, '华为手机 P50', '最新款华为5G手机', 3999.00, 4499.00, 50, 200, 4.9);

-- 插入用户地址数据
INSERT INTO 用户地址 (用户ID, 收货人名字, 收货人电话, 省份, 城市, 区县, 详细地址, 邮编, 是否默认) VALUES
(1, '张三', '13800138000', '北京市', '朝阳区', '朝阳街道', '朝阳门大街1号', '100010', TRUE),
(3, '王五', '13800138002', '上海市', '浦东新区', '世纪大道', '世纪大道500号', '200126', TRUE);

-- 插入购物车数据
INSERT INTO 购物车 (用户ID) VALUES
(1),
(3);

-- 插入购物车项数据
INSERT INTO 购物车项 (购物车ID, 商品ID, 数量) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 3, 1);

-- 插入订单数据
INSERT INTO 订单 (买家用户ID, 收货地址ID, 订单总金额, 实付金额, 优惠金额, 运费, 订单状态, 支付时间) VALUES
(1, 1, 229.97, 219.97, 10.00, 5.00, '已发货', NOW()),
(3, 2, 3999.00, 3899.00, 100.00, 10.00, '已收货', NOW());

-- 插入订单项数据
INSERT INTO 订单项 (订单ID, 商品ID, 店铺ID, 商品数量, 商品单价, 商品小计) VALUES
(1, 1, 1, 2, 49.99, 99.98),
(1, 2, 1, 1, 129.99, 129.99),
(2, 3, 1, 1, 3999.00, 3999.00);

-- 插入评论数据
INSERT INTO 评论 (商品ID, 用户ID, 订单ID, 评分, 评论标题, 评论内容, 审核状态) VALUES
(1, 1, 1, 5, '非常满意', '质量很好，穿着舒服，物流快，强烈推荐！', '已通过'),
(3, 3, 2, 5, '旗舰级体验', '手机收到了，功能强大，运行流畅，配送快速，非常满意！', '已通过');

-- =====================================================
-- 验证数据完整性
-- =====================================================

-- 查看用户数据
SELECT '=== 用户数据 ===' AS '';
SELECT 用户ID, 用户名, 真实姓名, 邮箱 FROM 用户;

-- 查看店铺数据
SELECT '=== 店铺数据 ===' AS '';
SELECT 店铺ID, 店铺名称, 店主用户ID FROM 店铺;

-- 查看商品数据
SELECT '=== 商品数据 ===' AS '';
SELECT 商品ID, 商品名称, 商品价格, 库存数量, 销量 FROM 商品;

-- 查看订单数据
SELECT '=== 订单数据 ===' AS '';
SELECT 订单ID, 买家用户ID, 订单总金额, 订单状态 FROM 订单;

-- 查看评论数据
SELECT '=== 评论数据 ===' AS '';
SELECT 评论ID, 商品ID, 用户ID, 评分, 评论标题 FROM 评论;
