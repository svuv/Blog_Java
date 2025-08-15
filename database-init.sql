-- =============================================
-- 个人技术博客项目 - MySQL数据库初始化脚本
-- 优化版：更符合个人博客需求，简化复杂设计
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `blog` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `blog`;

-- =============================================
-- 1. 用户相关表（简化版）
-- =============================================

-- 用户表（简化版，适合个人博客）
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
  `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `bio` VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
  `website` VARCHAR(200) DEFAULT NULL COMMENT '个人网站',
  `github_url` VARCHAR(200) DEFAULT NULL COMMENT 'GitHub地址',
  `location` VARCHAR(100) DEFAULT NULL COMMENT '所在地',
  `role` VARCHAR(20) DEFAULT 'USER' COMMENT '角色：ADMIN-管理员，USER-普通用户',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(45) DEFAULT NULL COMMENT '最后登录IP',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` INT DEFAULT 1 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- =============================================
-- 2. 内容管理相关表
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

-- 文章系列表（新增）
DROP TABLE IF EXISTS `article_series`;
CREATE TABLE `article_series` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '系列ID',
  `name` VARCHAR(100) NOT NULL COMMENT '系列名称',
  `slug` VARCHAR(100) NOT NULL COMMENT '系列别名（URL友好）',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '系列描述',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '系列封面',
  `article_count` INT DEFAULT 0 COMMENT '文章数量',
  `sort_order` INT DEFAULT 0 COMMENT '排序权重',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章系列表';

-- 文章表（增强版）
DROP TABLE IF EXISTS `articles`;
CREATE TABLE `articles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `title` VARCHAR(200) NOT NULL COMMENT '文章标题',
  `slug` VARCHAR(200) NOT NULL COMMENT '文章别名（URL友好）',
  `summary` VARCHAR(500) DEFAULT NULL COMMENT '文章摘要',
  `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图片URL',
  `author_id` BIGINT NOT NULL COMMENT '作者ID',
  `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
  `series_id` BIGINT DEFAULT NULL COMMENT '系列ID',
  `series_order` INT DEFAULT 0 COMMENT '系列中的顺序',
  `status` TINYINT DEFAULT 0 COMMENT '状态：0-草稿，1-已发布，2-已下线',
  `is_top` TINYINT DEFAULT 0 COMMENT '是否置顶：0-否，1-是',
  `is_featured` TINYINT DEFAULT 0 COMMENT '是否精选：0-否，1-是',
  `is_original` TINYINT DEFAULT 1 COMMENT '是否原创：0-转载，1-原创',
  `source_url` VARCHAR(500) DEFAULT NULL COMMENT '转载来源URL',
  `allow_comment` TINYINT DEFAULT 1 COMMENT '是否允许评论：0-否，1-是',
  `password` VARCHAR(100) DEFAULT NULL COMMENT '访问密码（私密文章）',
  `view_count` INT DEFAULT 0 COMMENT '浏览量',
  `like_count` INT DEFAULT 0 COMMENT '点赞数',
  `comment_count` INT DEFAULT 0 COMMENT '评论数',
  `word_count` INT DEFAULT 0 COMMENT '字数统计',
  `reading_time` INT DEFAULT 0 COMMENT '预计阅读时间（分钟）',
  `meta_keywords` VARCHAR(200) DEFAULT NULL COMMENT 'SEO关键词',
  `meta_description` VARCHAR(500) DEFAULT NULL COMMENT 'SEO描述',
  `publish_time` DATETIME DEFAULT NULL COMMENT '发布时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` INT DEFAULT 1 COMMENT '乐观锁版本号',
  `is_deleted` TINYINT DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_series_id` (`series_id`),
  KEY `idx_status_publish` (`status`, `publish_time`),
  KEY `idx_is_top_featured` (`is_top`, `is_featured`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章表';

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

-- 页面管理表（新增）
DROP TABLE IF EXISTS `pages`;
CREATE TABLE `pages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '页面ID',
  `title` VARCHAR(200) NOT NULL COMMENT '页面标题',
  `slug` VARCHAR(100) NOT NULL COMMENT '页面别名（URL友好）',
  `content` LONGTEXT COMMENT '页面内容',
  `template` VARCHAR(50) DEFAULT 'default' COMMENT '页面模板',
  `meta_keywords` VARCHAR(200) DEFAULT NULL COMMENT 'SEO关键词',
  `meta_description` VARCHAR(500) DEFAULT NULL COMMENT 'SEO描述',
  `sort_order` INT DEFAULT 0 COMMENT '排序权重',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='页面管理表';

-- 友情链接表（新增）
DROP TABLE IF EXISTS `friend_links`;
CREATE TABLE `friend_links` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '链接ID',
  `name` VARCHAR(100) NOT NULL COMMENT '链接名称',
  `url` VARCHAR(500) NOT NULL COMMENT '链接地址',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '链接描述',
  `avatar` VARCHAR(500) DEFAULT NULL COMMENT '链接头像',
  `sort_order` INT DEFAULT 0 COMMENT '排序权重',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status_sort` (`status`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='友情链接表';

-- =============================================
-- 3. 互动相关表
-- =============================================

-- 文章点赞表
DROP TABLE IF EXISTS `article_likes`;
CREATE TABLE `article_likes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` BIGINT NOT NULL COMMENT '文章ID',
  `user_id` BIGINT DEFAULT NULL COMMENT '用户ID（游客为NULL）',
  `ip_address` VARCHAR(45) NOT NULL COMMENT 'IP地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '用户代理',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_user` (`article_id`, `user_id`),
  UNIQUE KEY `uk_article_ip` (`article_id`, `ip_address`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章点赞表';

-- =============================================
-- 4. 统计相关表
-- =============================================

-- 文章访问日志表（简化版）
DROP TABLE IF EXISTS `article_view_logs`;
CREATE TABLE `article_view_logs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` BIGINT NOT NULL COMMENT '文章ID',
  `ip_address` VARCHAR(45) NOT NULL COMMENT 'IP地址',
  `user_agent` VARCHAR(500) DEFAULT NULL COMMENT '用户代理',
  `referer` VARCHAR(500) DEFAULT NULL COMMENT '来源页面',
  `view_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
  PRIMARY KEY (`id`),
  KEY `idx_article_id` (`article_id`),
  KEY `idx_view_time` (`view_time`),
  KEY `idx_ip_article` (`ip_address`, `article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章访问日志表';

-- 网站统计表（新增）
DROP TABLE IF EXISTS `site_stats`;
CREATE TABLE `site_stats` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stat_date` DATE NOT NULL COMMENT '统计日期',
  `total_views` INT DEFAULT 0 COMMENT '总访问量',
  `unique_visitors` INT DEFAULT 0 COMMENT '独立访客数',
  `total_articles` INT DEFAULT 0 COMMENT '文章总数',
  `total_comments` INT DEFAULT 0 COMMENT '评论总数',
  `total_likes` INT DEFAULT 0 COMMENT '点赞总数',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='网站统计表';

-- =============================================
-- 5. 系统管理表
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
('学习笔记', 'study', '学习过程中的笔记和总结', 2),
('项目实战', 'project', '实际项目开发经验分享', 3),
('生活随笔', 'life', '生活感悟和随笔', 4);

-- 插入默认标签
INSERT INTO `tags` (`name`, `slug`, `color`, `description`) VALUES
('Java', 'java', '#f89820', 'Java编程语言相关'),
('Spring Boot', 'spring-boot', '#6db33f', 'Spring Boot框架相关'),
('MySQL', 'mysql', '#4479a1', 'MySQL数据库相关'),
('Redis', 'redis', '#dc382d', 'Redis缓存相关'),
('MongoDB', 'mongodb', '#47a248', 'MongoDB数据库相关'),
('MyBatis', 'mybatis', '#ec407a', 'MyBatis框架相关'),
('多线程', 'multithreading', '#9c27b0', '多线程编程相关'),
('架构设计', 'architecture', '#ff6b6b', '系统架构设计相关');

-- 插入默认文章系列
INSERT INTO `article_series` (`name`, `slug`, `description`, `sort_order`) VALUES
('Spring Boot实战', 'spring-boot-practice', 'Spring Boot框架实战教程系列', 1),
('多数据库整合', 'multi-database', 'MySQL、MongoDB、Redis多数据库整合实践', 2),
('多线程编程', 'multithreading-guide', 'Java多线程编程从入门到精通', 3);

-- 插入默认页面
INSERT INTO `pages` (`title`, `slug`, `content`, `meta_description`) VALUES
('关于我', 'about', '<h1>关于我</h1><p>这里是关于我的介绍...</p>', '个人介绍页面'),
('联系方式', 'contact', '<h1>联系方式</h1><p>Email: contact@example.com</p>', '联系方式页面'),
('友情链接', 'links', '<h1>友情链接</h1><p>欢迎交换友情链接...</p>', '友情链接页面');

-- 插入默认友情链接
INSERT INTO `friend_links` (`name`, `url`, `description`, `sort_order`) VALUES
('Spring官网', 'https://spring.io/', 'Spring框架官方网站', 1),
('MyBatis官网', 'https://mybatis.org/', 'MyBatis持久层框架官网', 2),
('GitHub', 'https://github.com/', '全球最大的代码托管平台', 3);

-- 插入系统配置
INSERT INTO `system_configs` (`config_key`, `config_value`, `config_type`, `description`, `category`, `is_public`) VALUES
('site.name', '个人技术博客', 'STRING', '网站名称', 'SITE', 1),
('site.description', '专注于Java技术分享和学习交流', 'STRING', '网站描述', 'SITE', 1),
('site.keywords', 'Java,Spring Boot,MyBatis,技术博客,多线程,多数据库', 'STRING', '网站关键词', 'SITE', 1),
('site.author', 'Blog Author', 'STRING', '网站作者', 'SITE', 1),
('site.logo', '', 'STRING', '网站Logo URL', 'SITE', 1),
('site.favicon', '', 'STRING', '网站Favicon URL', 'SITE', 1),
('site.icp', '', 'STRING', 'ICP备案号', 'SITE', 1),
('comment.enable', 'true', 'BOOLEAN', '是否开启评论功能', 'FEATURE', 0),
('register.enable', 'false', 'BOOLEAN', '是否开启用户注册', 'FEATURE', 0),
('article.auto_summary', 'true', 'BOOLEAN', '是否自动生成文章摘要', 'FEATURE', 0),
('upload.max_size', '10485760', 'NUMBER', '文件上传最大大小（字节）', 'UPLOAD', 0),
('upload.allowed_types', 'jpg,jpeg,png,gif,webp', 'STRING', '允许上传的文件类型', 'UPLOAD', 0);

-- 创建管理员用户（密码：admin123，需要在应用中加密）
INSERT INTO `users` (`username`, `email`, `password`, `nickname`, `bio`, `role`, `status`) VALUES
('admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', '博客管理员', '专注于Java技术分享，热爱编程和学习', 'ADMIN', 1);

-- =============================================
-- 7. 创建视图（可选）
-- =============================================

-- 文章详情视图
CREATE OR REPLACE VIEW `v_article_details` AS
SELECT 
    a.id,
    a.title,
    a.slug,
    a.summary,
    a.cover_image,
    a.author_id,
    u.username AS author_name,
    u.nickname AS author_nickname,
    a.category_id,
    c.name AS category_name,
    c.slug AS category_slug,
    a.series_id,
    s.name AS series_name,
    s.slug AS series_slug,
    a.series_order,
    a.status,
    a.is_top,
    a.is_featured,
    a.is_original,
    a.allow_comment,
    a.view_count,
    a.like_count,
    a.comment_count,
    a.word_count,
    a.reading_time,
    a.publish_time,
    a.create_time,
    a.update_time
FROM articles a
LEFT JOIN users u ON a.author_id = u.id
LEFT JOIN categories c ON a.category_id = c.id
LEFT JOIN article_series s ON a.series_id = s.id
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
    END CASE;
    
    COMMIT;
END //

-- 更新分类文章数量的存储过程
CREATE PROCEDURE `UpdateCategoryArticleCount`(
    IN category_id BIGINT
)
BEGIN
    UPDATE categories 
    SET article_count = (
        SELECT COUNT(*) 
        FROM articles 
        WHERE category_id = category_id 
        AND status = 1 
        AND is_deleted = 0
    )
    WHERE id = category_id;
END //

-- 更新标签文章数量的存储过程
CREATE PROCEDURE `UpdateTagArticleCount`(
    IN tag_id BIGINT
)
BEGIN
    UPDATE tags 
    SET article_count = (
        SELECT COUNT(*) 
        FROM article_tags at
        INNER JOIN articles a ON at.article_id = a.id
        WHERE at.tag_id = tag_id 
        AND a.status = 1 
        AND a.is_deleted = 0
    )
    WHERE id = tag_id;
END //

DELIMITER ;

-- =============================================
-- 初始化完成
-- =============================================
SELECT 'Database initialization completed successfully!' AS message;