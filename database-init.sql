-- =============================================
-- 个人技术博客项目 - MySQL数据库初始化脚本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `blog` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `blog`;

-- =============================================
-- 1. 用户相关表
-- =============================================

-- 用户基础信息表
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `gender` TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
  `birthday` DATE DEFAULT NULL COMMENT '生日',
  `bio` VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
  `website` VARCHAR(200) DEFAULT NULL COMMENT '个人网站',
  `location` VARCHAR(100) DEFAULT NULL COMMENT '所在地',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常，2-待激活',
  `email_verified` TINYINT DEFAULT 0 COMMENT '邮箱是否验证：0-未验证，1-已验证',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(45) DEFAULT NULL COMMENT '最后登录IP',
  `login_count` INT DEFAULT 0 COMMENT '登录次数',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` INT DEFAULT 1 COMMENT '乐观锁版本号',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_last_login` (`last_login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户基础信息表';

-- 用户角色表
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码：ADMIN-管理员，AUTHOR-作者，USER-普通用户',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `granted_by` BIGINT DEFAULT NULL COMMENT '授权人ID',
  `granted_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  `expire_time` DATETIME DEFAULT NULL COMMENT '过期时间，NULL表示永不过期',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_code`),
  KEY `idx_role_code` (`role_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色表';

-- =============================================
-- 2. 文章相关表
-- =============================================

-- 文章分类表
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `slug` VARCHAR(50) NOT NULL COMMENT '分类别名（URL友好）',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '分类描述',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '分类封面图',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父分类ID，0表示顶级分类',
  `level` TINYINT DEFAULT 1 COMMENT '分类层级',
  `sort_order` INT DEFAULT 0 COMMENT '排序权重',
  `article_count` INT DEFAULT 0 COMMENT '文章数量',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章分类表';

-- 标签表
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `name` VARCHAR(50) NOT NULL COMMENT '标签名称',
  `slug` VARCHAR(50) NOT NULL COMMENT '标签别名（URL友好）',
  `color` VARCHAR(7) DEFAULT '#007bff' COMMENT '标签颜色（十六进制）',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '标签描述',
  `article_count` INT DEFAULT 0 COMMENT '关联文章数量',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_status` (`status`),
  KEY `idx_article_count` (`article_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签表';

-- 文章基础信息表
DROP TABLE IF EXISTS `articles`;
CREATE TABLE `articles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `title` VARCHAR(200) NOT NULL COMMENT '文章标题',
  `summary` VARCHAR(500) DEFAULT NULL COMMENT '文章摘要',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图片URL',
  `author_id` BIGINT NOT NULL COMMENT '作者ID',
  `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-草稿，1-已发布，2-已下线，3-待审核',
  `is_top` TINYINT DEFAULT 0 COMMENT '是否置顶：0-否，1-是',
  `is_featured` TINYINT DEFAULT 0 COMMENT '是否精选：0-否，1-是',
  `allow_comment` TINYINT DEFAULT 1 COMMENT '是否允许评论：0-否，1-是',
  `view_count` INT DEFAULT 0 COMMENT '浏览量',
  `like_count` INT DEFAULT 0 COMMENT '点赞数',
  `comment_count` INT DEFAULT 0 COMMENT '评论数',
  `share_count` INT DEFAULT 0 COMMENT '分享数',
  `word_count` INT DEFAULT 0 COMMENT '字数统计',
  `reading_time` INT DEFAULT 0 COMMENT '预计阅读时间（分钟）',
  `publish_time` DATETIME DEFAULT NULL COMMENT '发布时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` INT DEFAULT 1 COMMENT '乐观锁版本号',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_publish_time` (`publish_time`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_is_top_featured` (`is_top`, `is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章基础信息表';

-- 文章标签关联表
DROP TABLE IF EXISTS `article_tags`;
CREATE TABLE `article_tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` BIGINT NOT NULL COMMENT '文章ID',
  `tag_id` BIGINT NOT NULL COMMENT '标签ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_tag` (`article_id`, `tag_id`),
  KEY `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章标签关联表';

-- =============================================
-- 3. 互动相关表
-- =============================================

-- 文章点赞表
DROP TABLE IF EXISTS `article_likes`;
CREATE TABLE `article_likes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` BIGINT NOT NULL COMMENT '文章ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `ip_address` VARCHAR(45) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '用户代理',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_user` (`article_id`, `user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章点赞表';

-- 用户关注表
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `follower_id` BIGINT NOT NULL COMMENT '关注者ID',
  `following_id` BIGINT NOT NULL COMMENT '被关注者ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_follower_following` (`follower_id`, `following_id`),
  KEY `idx_following_id` (`following_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户关注表';

-- =============================================
-- 4. 统计相关表
-- =============================================

-- 文章访问统计表
DROP TABLE IF EXISTS `article_view_stats`;
CREATE TABLE `article_view_stats` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` BIGINT NOT NULL COMMENT '文章ID',
  `view_date` DATE NOT NULL COMMENT '访问日期',
  `view_count` INT DEFAULT 0 COMMENT '访问次数',
  `unique_view_count` INT DEFAULT 0 COMMENT '独立访客数',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_date` (`article_id`, `view_date`),
  KEY `idx_view_date` (`view_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章访问统计表';

-- 用户活跃统计表
DROP TABLE IF EXISTS `user_activity_stats`;
CREATE TABLE `user_activity_stats` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `stat_date` DATE NOT NULL COMMENT '统计日期',
  `login_count` INT DEFAULT 0 COMMENT '登录次数',
  `article_count` INT DEFAULT 0 COMMENT '发布文章数',
  `comment_count` INT DEFAULT 0 COMMENT '评论数',
  `like_count` INT DEFAULT 0 COMMENT '点赞数',
  `view_count` INT DEFAULT 0 COMMENT '浏览数',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `stat_date`),
  KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户活跃统计表';

-- =============================================
-- 5. 系统配置表
-- =============================================

-- 系统配置表
DROP TABLE IF EXISTS `system_configs`;
CREATE TABLE `system_configs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` VARCHAR(100) NOT NULL COMMENT '配置键',
  `config_value` TEXT COMMENT '配置值',
  `config_type` VARCHAR(20) DEFAULT 'STRING' COMMENT '配置类型：STRING,NUMBER,BOOLEAN,JSON',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '配置描述',
  `category` VARCHAR(50) DEFAULT 'GENERAL' COMMENT '配置分类',
  `is_public` TINYINT DEFAULT 0 COMMENT '是否公开：0-否，1-是',
  `sort_order` INT DEFAULT 0 COMMENT '排序权重',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`),
  KEY `idx_category` (`category`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 操作日志表
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` BIGINT DEFAULT NULL COMMENT '操作用户ID',
  `username` VARCHAR(50) DEFAULT NULL COMMENT '操作用户名',
  `operation` VARCHAR(100) NOT NULL COMMENT '操作类型',
  `method` VARCHAR(10) DEFAULT NULL COMMENT '请求方法',
  `url` VARCHAR(500) DEFAULT NULL COMMENT '请求URL',
  `ip_address` VARCHAR(45) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '用户代理',
  `request_params` TEXT COMMENT '请求参数',
  `response_result` TEXT COMMENT '响应结果',
  `execution_time` INT DEFAULT NULL COMMENT '执行时间（毫秒）',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-失败，1-成功',
  `error_message` TEXT COMMENT '错误信息',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_operation` (`operation`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- =============================================
-- 6. 初始化数据
-- =============================================

-- 插入默认分类
INSERT INTO `categories` (`name`, `slug`, `description`, `sort_order`) VALUES
('技术分享', 'tech', '技术相关文章分类', 1),
('生活随笔', 'life', '生活感悟和随笔', 2),
('学习笔记', 'study', '学习过程中的笔记和总结', 3),
('项目实战', 'project', '实际项目开发经验分享', 4);

-- 插入默认标签
INSERT INTO `tags` (`name`, `slug`, `color`, `description`) VALUES
('Java', 'java', '#f89820', 'Java编程语言相关'),
('Spring Boot', 'spring-boot', '#6db33f', 'Spring Boot框架相关'),
('MySQL', 'mysql', '#4479a1', 'MySQL数据库相关'),
('Redis', 'redis', '#dc382d', 'Redis缓存相关'),
('MongoDB', 'mongodb', '#47a248', 'MongoDB数据库相关'),
('前端', 'frontend', '#61dafb', '前端开发相关'),
('后端', 'backend', '#68217a', '后端开发相关'),
('架构设计', 'architecture', '#ff6b6b', '系统架构设计相关');

-- 插入系统配置
INSERT INTO `system_configs` (`config_key`, `config_value`, `config_type`, `description`, `category`, `is_public`) VALUES
('site.name', '个人技术博客', 'STRING', '网站名称', 'SITE', 1),
('site.description', '专注于技术分享和学习交流', 'STRING', '网站描述', 'SITE', 1),
('site.keywords', 'Java,Spring Boot,技术博客,编程', 'STRING', '网站关键词', 'SITE', 1),
('site.author', 'Blog Author', 'STRING', '网站作者', 'SITE', 1),
('site.icp', '', 'STRING', 'ICP备案号', 'SITE', 1),
('comment.enable', 'true', 'BOOLEAN', '是否开启评论功能', 'FEATURE', 0),
('register.enable', 'true', 'BOOLEAN', '是否开启用户注册', 'FEATURE', 0),
('upload.max_size', '10485760', 'NUMBER', '文件上传最大大小（字节）', 'UPLOAD', 0),
('email.smtp.host', '', 'STRING', 'SMTP服务器地址', 'EMAIL', 0),
('email.smtp.port', '587', 'NUMBER', 'SMTP服务器端口', 'EMAIL', 0);

-- 创建管理员用户（密码：admin123，需要在应用中加密）
INSERT INTO `users` (`username`, `email`, `password`, `nickname`, `status`, `email_verified`) VALUES
('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', '管理员', 1, 1);

-- 为管理员分配角色
INSERT INTO `user_roles` (`user_id`, `role_code`, `role_name`) VALUES
(1, 'ADMIN', '管理员'),
(1, 'AUTHOR', '作者');

-- =============================================
-- 7. 创建视图（可选）
-- =============================================

-- 文章详情视图
CREATE OR REPLACE VIEW `v_article_details` AS
SELECT 
    a.id,
    a.title,
    a.summary,
    a.cover_image,
    a.author_id,
    u.username AS author_name,
    u.nickname AS author_nickname,
    a.category_id,
    c.name AS category_name,
    c.slug AS category_slug,
    a.status,
    a.is_top,
    a.is_featured,
    a.allow_comment,
    a.view_count,
    a.like_count,
    a.comment_count,
    a.share_count,
    a.word_count,
    a.reading_time,
    a.publish_time,
    a.create_time,
    a.update_time
FROM articles a
LEFT JOIN users u ON a.author_id = u.id
LEFT JOIN categories c ON a.category_id = c.id
WHERE a.is_deleted = 0;

-- =============================================
-- 8. 创建存储过程（可选）
-- =============================================

DELIMITER //

-- 更新文章统计数据的存储过程
CREATE PROCEDURE `UpdateArticleStats`(
    IN article_id BIGINT,
    IN stat_type VARCHAR(20),
    IN increment_value INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    CASE stat_type
        WHEN 'view' THEN
            UPDATE articles SET view_count = view_count + increment_value WHERE id = article_id;
        WHEN 'like' THEN
            UPDATE articles SET like_count = like_count + increment_value WHERE id = article_id;
        WHEN 'comment' THEN
            UPDATE articles SET comment_count = comment_count + increment_value WHERE id = article_id;
        WHEN 'share' THEN
            UPDATE articles SET share_count = share_count + increment_value WHERE id = article_id;
    END CASE;
    
    COMMIT;
END //

DELIMITER ;

-- =============================================
-- 初始化完成
-- =============================================
SELECT 'Database initialization completed successfully!' AS message;