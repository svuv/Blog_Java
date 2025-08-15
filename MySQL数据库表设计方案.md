# MySQL数据库表设计方案

## 🎯 设计原则

### 核心设计思路
1. **职责分离**: MySQL存储结构化数据，MongoDB存储非结构化内容
2. **性能优化**: 合理的索引设计，避免冗余字段
3. **扩展性**: 预留扩展字段，支持业务发展
4. **一致性**: 统一的命名规范和数据类型
5. **安全性**: 敏感数据加密，软删除机制

### 数据分布策略
- **MySQL**: 用户信息、文章元数据、分类标签、统计数据、系统配置
- **MongoDB**: 文章内容、评论详情、搜索索引
- **Redis**: 缓存数据、会话信息、计数器

## 📊 数据库表结构设计

### 1. 用户相关表

#### 1.1 用户基础信息表 (users)
```sql
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
```

#### 1.2 用户角色表 (user_roles)
```sql
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
```

### 2. 文章相关表

#### 2.1 文章基础信息表 (articles)
```sql
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
```

#### 2.2 文章分类表 (categories)
```sql
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
```

#### 2.3 标签表 (tags)
```sql
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
```

#### 2.4 文章标签关联表 (article_tags)
```sql
CREATE TABLE `article_tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` BIGINT NOT NULL COMMENT '文章ID',
  `tag_id` BIGINT NOT NULL COMMENT '标签ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_tag` (`article_id`, `tag_id`),
  KEY `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章标签关联表';
```

### 3. 互动相关表

#### 3.1 文章点赞表 (article_likes)
```sql
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
```

#### 3.2 用户关注表 (user_follows)
```sql
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
```

### 4. 统计相关表

#### 4.1 文章访问统计表 (article_view_stats)
```sql
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
```

#### 4.2 用户活跃统计表 (user_activity_stats)
```sql
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
```

### 5. 系统配置表

#### 5.1 系统配置表 (system_configs)
```sql
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
```

#### 5.2 操作日志表 (operation_logs)
```sql
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
```

## 🔧 索引设计策略

### 1. 主键索引
- 所有表都使用`BIGINT AUTO_INCREMENT`作为主键
- 保证全局唯一性和高性能

### 2. 唯一索引
- 用户名、邮箱等业务唯一字段
- 防止数据重复，提高查询效率

### 3. 普通索引
- 经常用于WHERE条件的字段
- 外键字段
- 排序字段

### 4. 复合索引
- 多字段组合查询场景
- 遵循最左前缀原则

## 📈 性能优化建议

### 1. 分区策略
```sql
-- 按时间分区（日志表）
ALTER TABLE operation_logs 
PARTITION BY RANGE (YEAR(create_time)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);
```

### 2. 读写分离
- 主库：写操作
- 从库：读操作
- 统计查询使用从库

### 3. 缓存策略
- 热点数据Redis缓存
- 查询结果缓存
- 计数器Redis实现

## 🛡️ 安全设计

### 1. 数据加密
- 密码使用BCrypt加密
- 敏感信息AES加密存储

### 2. 软删除
- 重要数据使用`is_deleted`字段
- 避免物理删除造成的数据丢失

### 3. 乐观锁
- 使用`version`字段防止并发更新冲突

### 4. 审计日志
- 记录关键操作日志
- 便于问题追踪和安全审计

## 🚀 扩展性考虑

### 1. 预留字段
- 每个表预留扩展字段
- 支持业务快速迭代

### 2. 分库分表
- 用户表按用户ID分片
- 文章表按时间或作者分片

### 3. 多租户支持
- 预留租户ID字段
- 支持SaaS化部署

这个设计方案既保证了数据的完整性和一致性，又考虑了性能和扩展性，适合个人博客项目的长期发展需求。