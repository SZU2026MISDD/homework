-- Taobao-like marketplace schema (MySQL 8.x / SQLyog)
-- Charset: utf8mb4

SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS `taobao_demo` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `taobao_demo`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `tb_review_media`;
DROP TABLE IF EXISTS `tb_review`;
DROP TABLE IF EXISTS `tb_shipment_trace`;
DROP TABLE IF EXISTS `tb_order_shipment`;
DROP TABLE IF EXISTS `tb_order_payment`;
DROP TABLE IF EXISTS `tb_order_item`;
DROP TABLE IF EXISTS `tb_order`;
DROP TABLE IF EXISTS `tb_cart_item`;
DROP TABLE IF EXISTS `tb_cart`;
DROP TABLE IF EXISTS `tb_product_media`;
DROP TABLE IF EXISTS `tb_product_sku`;
DROP TABLE IF EXISTS `tb_product`;
DROP TABLE IF EXISTS `tb_shop_follow`;
DROP TABLE IF EXISTS `tb_favorite_product`;
DROP TABLE IF EXISTS `tb_shop`;
DROP TABLE IF EXISTS `tb_category`;
DROP TABLE IF EXISTS `tb_user_address`;
DROP TABLE IF EXISTS `tb_user`;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `tb_user` (
  `user_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(64) NOT NULL,
  `nickname` VARCHAR(64) NOT NULL,
  `email` VARCHAR(128) DEFAULT NULL,
  `mobile` VARCHAR(20) DEFAULT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `avatar_url` VARCHAR(500) DEFAULT NULL,
  `gender` ENUM('unknown','male','female') NOT NULL DEFAULT 'unknown',
  `birthday` DATE DEFAULT NULL,
  `status` ENUM('active','frozen','deleted') NOT NULL DEFAULT 'active',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_user_username` (`username`),
  UNIQUE KEY `uk_user_email` (`email`),
  UNIQUE KEY `uk_user_mobile` (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_user_address` (
  `address_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `consignee_name` VARCHAR(64) NOT NULL,
  `consignee_mobile` VARCHAR(20) NOT NULL,
  `country` VARCHAR(64) NOT NULL DEFAULT '中国',
  `province` VARCHAR(64) NOT NULL,
  `city` VARCHAR(64) NOT NULL,
  `district` VARCHAR(64) NOT NULL,
  `street` VARCHAR(255) NOT NULL,
  `postal_code` VARCHAR(20) DEFAULT NULL,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_address_user` (`user_id`),
  CONSTRAINT `fk_address_user`
    FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_category` (
  `category_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `parent_id` BIGINT UNSIGNED DEFAULT NULL,
  `category_name` VARCHAR(128) NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_category_parent_name` (`parent_id`,`category_name`),
  KEY `idx_category_parent` (`parent_id`),
  CONSTRAINT `fk_category_parent`
    FOREIGN KEY (`parent_id`) REFERENCES `tb_category` (`category_id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_shop` (
  `shop_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner_user_id` BIGINT UNSIGNED NOT NULL,
  `shop_name` VARCHAR(128) NOT NULL,
  `shop_type` ENUM('taobao','tmall','enterprise') NOT NULL DEFAULT 'taobao',
  `service_score` DECIMAL(3,2) NOT NULL DEFAULT 5.00,
  `logistics_score` DECIMAL(3,2) NOT NULL DEFAULT 5.00,
  `description_score` DECIMAL(3,2) NOT NULL DEFAULT 5.00,
  `status` ENUM('open','closed','suspended') NOT NULL DEFAULT 'open',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`shop_id`),
  UNIQUE KEY `uk_shop_name` (`shop_name`),
  KEY `idx_shop_owner` (`owner_user_id`),
  CONSTRAINT `fk_shop_owner_user`
    FOREIGN KEY (`owner_user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_shop_follow` (
  `follow_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `shop_id` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follow_id`),
  UNIQUE KEY `uk_shop_follow_user_shop` (`user_id`,`shop_id`),
  KEY `idx_shop_follow_shop` (`shop_id`),
  CONSTRAINT `fk_shop_follow_user`
    FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_shop_follow_shop`
    FOREIGN KEY (`shop_id`) REFERENCES `tb_shop` (`shop_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_favorite_product` (
  `favorite_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`favorite_id`),
  UNIQUE KEY `uk_favorite_user_product` (`user_id`,`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_product` (
  `product_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shop_id` BIGINT UNSIGNED NOT NULL,
  `category_id` BIGINT UNSIGNED NOT NULL,
  `product_title` VARCHAR(255) NOT NULL,
  `subtitle` VARCHAR(500) DEFAULT NULL,
  `main_image_url` VARCHAR(500) DEFAULT NULL,
  `detail_html` MEDIUMTEXT,
  `price_min` DECIMAL(10,2) NOT NULL,
  `price_max` DECIMAL(10,2) NOT NULL,
  `sales_count` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `status` ENUM('draft','on_sale','off_shelf') NOT NULL DEFAULT 'draft',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  KEY `idx_product_shop` (`shop_id`),
  KEY `idx_product_category` (`category_id`),
  KEY `idx_product_status` (`status`),
  CONSTRAINT `fk_product_shop`
    FOREIGN KEY (`shop_id`) REFERENCES `tb_shop` (`shop_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_product_category`
    FOREIGN KEY (`category_id`) REFERENCES `tb_category` (`category_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `tb_favorite_product`
  ADD KEY `idx_favorite_product` (`product_id`),
  ADD CONSTRAINT `fk_favorite_user`
    FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_favorite_product`
    FOREIGN KEY (`product_id`) REFERENCES `tb_product` (`product_id`)
    ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE `tb_product_sku` (
  `sku_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `sku_code` VARCHAR(64) NOT NULL,
  `spec_json` JSON DEFAULT NULL,
  `sale_price` DECIMAL(10,2) NOT NULL,
  `stock_qty` INT NOT NULL DEFAULT 0,
  `locked_qty` INT NOT NULL DEFAULT 0,
  `status` ENUM('enabled','disabled') NOT NULL DEFAULT 'enabled',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`sku_id`),
  UNIQUE KEY `uk_sku_product_code` (`product_id`,`sku_code`),
  KEY `idx_sku_status` (`status`),
  CONSTRAINT `fk_sku_product`
    FOREIGN KEY (`product_id`) REFERENCES `tb_product` (`product_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_product_media` (
  `media_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `media_type` ENUM('image','video') NOT NULL DEFAULT 'image',
  `media_url` VARCHAR(500) NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`media_id`),
  KEY `idx_media_product` (`product_id`),
  CONSTRAINT `fk_media_product`
    FOREIGN KEY (`product_id`) REFERENCES `tb_product` (`product_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_cart` (
  `cart_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_id`),
  UNIQUE KEY `uk_cart_user` (`user_id`),
  CONSTRAINT `fk_cart_user`
    FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_cart_item` (
  `cart_item_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cart_id` BIGINT UNSIGNED NOT NULL,
  `shop_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `sku_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `is_selected` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_item_id`),
  UNIQUE KEY `uk_cart_item_cart_sku` (`cart_id`,`sku_id`),
  KEY `idx_cart_item_shop` (`shop_id`),
  KEY `idx_cart_item_product` (`product_id`),
  CONSTRAINT `fk_cart_item_cart`
    FOREIGN KEY (`cart_id`) REFERENCES `tb_cart` (`cart_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_item_shop`
    FOREIGN KEY (`shop_id`) REFERENCES `tb_shop` (`shop_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_item_product`
    FOREIGN KEY (`product_id`) REFERENCES `tb_product` (`product_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_item_sku`
    FOREIGN KEY (`sku_id`) REFERENCES `tb_product_sku` (`sku_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_order` (
  `order_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_no` VARCHAR(40) NOT NULL,
  `buyer_user_id` BIGINT UNSIGNED NOT NULL,
  `shop_id` BIGINT UNSIGNED NOT NULL,
  `address_id` BIGINT UNSIGNED DEFAULT NULL,
  `order_status` ENUM(
    'WAIT_BUYER_PAY',
    'WAIT_SELLER_SEND_GOODS',
    'WAIT_BUYER_CONFIRM_GOODS',
    'TRADE_FINISHED',
    'TRADE_CLOSED'
  ) NOT NULL DEFAULT 'WAIT_BUYER_PAY',
  `goods_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `freight_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `pay_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `buyer_message` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid_at` DATETIME DEFAULT NULL,
  `shipped_at` DATETIME DEFAULT NULL,
  `confirmed_at` DATETIME DEFAULT NULL,
  `closed_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_order_buyer` (`buyer_user_id`),
  KEY `idx_order_shop` (`shop_id`),
  KEY `idx_order_status` (`order_status`),
  CONSTRAINT `fk_order_buyer`
    FOREIGN KEY (`buyer_user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_shop`
    FOREIGN KEY (`shop_id`) REFERENCES `tb_shop` (`shop_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_address`
    FOREIGN KEY (`address_id`) REFERENCES `tb_user_address` (`address_id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_order_item` (
  `order_item_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `sku_id` BIGINT UNSIGNED NOT NULL,
  `item_title_snapshot` VARCHAR(255) NOT NULL,
  `sku_spec_snapshot` VARCHAR(500) DEFAULT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `quantity` INT NOT NULL,
  `item_amount` DECIMAL(12,2) NOT NULL,
  `refund_status` ENUM('none','applying','success','closed') NOT NULL DEFAULT 'none',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_item_id`),
  KEY `idx_order_item_order` (`order_id`),
  KEY `idx_order_item_product` (`product_id`),
  KEY `idx_order_item_sku` (`sku_id`),
  CONSTRAINT `fk_order_item_order`
    FOREIGN KEY (`order_id`) REFERENCES `tb_order` (`order_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_item_product`
    FOREIGN KEY (`product_id`) REFERENCES `tb_product` (`product_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_order_item_sku`
    FOREIGN KEY (`sku_id`) REFERENCES `tb_product_sku` (`sku_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_order_payment` (
  `payment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `payment_method` ENUM('alipay','wechat','bank_card','balance') NOT NULL DEFAULT 'alipay',
  `payment_status` ENUM('unpaid','paid','refunded','failed') NOT NULL DEFAULT 'unpaid',
  `transaction_no` VARCHAR(64) DEFAULT NULL,
  `paid_amount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `paid_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uk_payment_order` (`order_id`),
  UNIQUE KEY `uk_payment_transaction_no` (`transaction_no`),
  CONSTRAINT `fk_payment_order`
    FOREIGN KEY (`order_id`) REFERENCES `tb_order` (`order_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_order_shipment` (
  `shipment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `logistics_company` VARCHAR(64) NOT NULL,
  `tracking_no` VARCHAR(64) NOT NULL,
  `shipment_status` ENUM('pending','shipped','in_transit','signed','exception') NOT NULL DEFAULT 'pending',
  `shipped_at` DATETIME DEFAULT NULL,
  `signed_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`shipment_id`),
  UNIQUE KEY `uk_shipment_order` (`order_id`),
  UNIQUE KEY `uk_shipment_tracking_no` (`tracking_no`),
  KEY `idx_shipment_status` (`shipment_status`),
  CONSTRAINT `fk_shipment_order`
    FOREIGN KEY (`order_id`) REFERENCES `tb_order` (`order_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_shipment_trace` (
  `trace_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shipment_id` BIGINT UNSIGNED NOT NULL,
  `trace_status` VARCHAR(64) NOT NULL,
  `trace_desc` VARCHAR(500) NOT NULL,
  `trace_time` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`trace_id`),
  KEY `idx_trace_shipment` (`shipment_id`),
  KEY `idx_trace_time` (`trace_time`),
  CONSTRAINT `fk_trace_shipment`
    FOREIGN KEY (`shipment_id`) REFERENCES `tb_order_shipment` (`shipment_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_review` (
  `review_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_item_id` BIGINT UNSIGNED NOT NULL,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `shop_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `rating` TINYINT UNSIGNED NOT NULL DEFAULT 5,
  `content` VARCHAR(2000) DEFAULT NULL,
  `is_anonymous` TINYINT(1) NOT NULL DEFAULT 0,
  `has_append_review` TINYINT(1) NOT NULL DEFAULT 0,
  `append_content` VARCHAR(2000) DEFAULT NULL,
  `append_created_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uk_review_order_item` (`order_item_id`),
  KEY `idx_review_product` (`product_id`),
  KEY `idx_review_shop` (`shop_id`),
  KEY `idx_review_user` (`user_id`),
  CONSTRAINT `fk_review_order_item`
    FOREIGN KEY (`order_item_id`) REFERENCES `tb_order_item` (`order_item_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_review_order`
    FOREIGN KEY (`order_id`) REFERENCES `tb_order` (`order_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_review_product`
    FOREIGN KEY (`product_id`) REFERENCES `tb_product` (`product_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_review_shop`
    FOREIGN KEY (`shop_id`) REFERENCES `tb_shop` (`shop_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_review_user`
    FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tb_review_media` (
  `review_media_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `review_id` BIGINT UNSIGNED NOT NULL,
  `media_type` ENUM('image','video') NOT NULL DEFAULT 'image',
  `media_url` VARCHAR(500) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_media_id`),
  KEY `idx_review_media_review` (`review_id`),
  CONSTRAINT `fk_review_media_review`
    FOREIGN KEY (`review_id`) REFERENCES `tb_review` (`review_id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

