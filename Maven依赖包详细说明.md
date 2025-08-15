# Maven 依赖包详细说明文档

## 项目基础信息

- **项目名称**: blog
- **Spring Boot 版本**: 3.5.4
- **Java 版本**: 17
- **构建工具**: Maven

## 依赖分类详解

### 🌐 Web 层相关依赖

#### spring-boot-starter-web

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

**作用**: Spring Boot Web 应用的核心启动器
**包含组件**:

- Spring MVC 框架
- 嵌入式 Tomcat 服务器
- Jackson JSON 处理器
- Spring Boot 自动配置

**学习重点**: RESTful API 开发、控制器编写、HTTP 请求处理

---

### 🗄️ MySQL 数据库相关依赖

#### mybatis-spring-boot-starter

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>3.0.5</version>
</dependency>
```

**作用**: MyBatis 与 Spring Boot 集成的官方启动器
**核心功能**:

- 自动配置 SqlSessionFactory
- 自动扫描 Mapper 接口
- 事务管理集成
- 配置属性绑定

**学习重点**: SQL 映射文件编写、动态 SQL、结果映射、手动编写 Mapper 接口

**为什么选择纯 MyBatis**:
- 更好地理解 SQL 映射原理
- 掌握手动编写 Mapper 的技能
- 学习原生 MyBatis 的核心概念
- 为后续学习 MyBatis-Plus 等增强工具打基础

#### mysql-connector-j

```xml
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <scope>runtime</scope>
</dependency>
```

**作用**: MySQL 数据库的 JDBC 驱动
**特点**:

- 支持 MySQL 8.0+
- 高性能连接
- SSL 加密支持
- 时区处理优化

#### druid-spring-boot-starter

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.2.20</version>
</dependency>
```

**作用**: 阿里巴巴开源的数据库连接池
**核心功能**:

- 高性能连接池管理
- SQL 监控和统计
- 防 SQL 注入
- 连接泄露监测
- Web 监控界面

**学习重点**: 连接池参数调优、SQL 监控、性能分析

#### pagehelper-spring-boot-starter

```xml
<dependency>
    <groupId>com.github.pagehelper</groupId>
    <artifactId>pagehelper-spring-boot-starter</artifactId>
    <version>2.1.0</version>
</dependency>
```

**作用**: MyBatis 分页插件
**核心功能**:

- 物理分页（真实的 limit 查询）
- 多数据库支持
- 分页参数自动解析
- 分页信息封装

**学习重点**: 分页查询实现、分页参数传递、分页结果处理

---

### 📄 MongoDB 数据库相关依赖

#### spring-boot-starter-data-mongodb

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

**作用**: Spring Data MongoDB 集成启动器
**核心功能**:

- MongoTemplate 操作模板
- Repository 接口自动实现
- 文档映射和转换
- 聚合查询支持
- 事务支持

**学习重点**: 文档操作、聚合查询、索引管理、事务处理

---

### 🚀 Redis 缓存相关依赖

#### spring-boot-starter-data-redis

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

**作用**: Spring Data Redis 集成启动器
**核心功能**:

- RedisTemplate 操作模板
- 缓存注解支持
- 序列化配置
- 连接池管理

**学习重点**: 缓存策略、数据序列化、过期时间管理

#### commons-pool2

```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>
```

**作用**: Apache 通用对象池，Redis 连接池的底层实现
**核心功能**:

- 连接池管理
- 对象生命周期管理
- 池化参数配置

#### redisson-spring-boot-starter

```xml
<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson-spring-boot-starter</artifactId>
    <version>3.24.3</version>
</dependency>
```

**作用**: Redis 的 Java 客户端，提供分布式功能
**核心功能**:

- 分布式锁
- 分布式集合
- 分布式对象
- 发布订阅
- 分布式服务

**学习重点**: 分布式锁实现、集群模式配置、分布式数据结构

---

### 🔐 安全认证相关依赖

#### jjwt-api + jjwt-impl + jjwt-jackson
```xml
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```
**作用**: JWT（JSON Web Token）处理库
**核心功能**:
- JWT Token生成和解析
- 数字签名验证
- Token过期时间管理
- 自定义Claims支持

**学习重点**: JWT原理、Token生成验证、安全签名

#### spring-boot-starter-security
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```
**作用**: Spring Security安全框架（可选）
**核心功能**:
- 密码加密和验证
- 认证和授权
- CSRF防护
- 会话管理

**学习重点**: 密码加密、安全配置、认证流程

---

### 🔄 多线程和异步处理依赖

#### spring-boot-starter-aop

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

**作用**: Spring AOP 面向切面编程支持
**核心功能**:

- 方法拦截
- 异步处理支持
- 事务管理
- 日志记录
- 性能监控

**学习重点**: 切面编程、异步注解使用、事务管理

#### spring-context

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
</dependency>
```

**作用**: Spring 核心上下文，包含线程池管理
**核心功能**:

- 应用上下文管理
- Bean 生命周期管理
- 任务调度
- 线程池配置

**学习重点**: 线程池配置、任务调度、Bean 管理

---

### 📊 JSON 和数据处理依赖

#### jackson-databind

```xml
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
</dependency>
```

**作用**: Jackson JSON 处理核心库
**核心功能**:

- JSON 序列化/反序列化
- 对象映射
- 数据绑定
- 注解支持

**学习重点**: JSON 处理、对象映射、自定义序列化

#### spring-boot-starter-validation

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

**作用**: 数据校验支持
**核心功能**:

- JSR-303/JSR-380 标准实现
- 注解式校验
- 自定义校验器
- 分组校验

**学习重点**: 参数校验、自定义校验规则、错误处理

---

### 🛠️ 工具类库依赖

#### lombok

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```

**作用**: Java 代码简化工具
**核心功能**:

- 自动生成 getter/setter
- 构造函数生成
- toString 方法生成
- 日志注解支持

**学习重点**: 注解使用、代码简化、编译时处理

#### hutool-all

```xml
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.22</version>
</dependency>
```

**作用**: Java 工具类库
**核心功能**:

- 日期时间处理
- 字符串工具
- 加密解密
- HTTP 客户端
- 文件操作
- 集合工具

**学习重点**: 常用工具类使用、加密解密、HTTP 请求

---

### 📚 API 文档和监控依赖

#### springdoc-openapi-starter-webmvc-ui

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

**作用**: OpenAPI 3.0 规范的 API 文档生成
**核心功能**:

- 自动生成 API 文档
- Swagger UI 界面
- 接口测试功能
- JSON/YAML 格式导出

**学习重点**: API 文档编写、接口注解使用、文档自动化

#### spring-boot-starter-actuator

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

**作用**: 应用监控和管理
**核心功能**:

- 健康检查
- 指标收集
- 应用信息
- 环境信息
- HTTP 跟踪

**学习重点**: 监控端点配置、健康检查、指标收集

#### micrometer-registry-prometheus

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

**作用**: Prometheus 指标收集
**核心功能**:

- 指标注册
- 时间序列数据
- 监控数据导出
- Grafana 集成

**学习重点**: 指标定义、监控数据收集、可视化展示

---

### 🔧 开发工具依赖

#### spring-boot-devtools

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```

**作用**: 开发时热重载工具
**核心功能**:

- 自动重启
- 实时重载
- 远程调试支持
- 属性默认值

**学习重点**: 热重载配置、开发效率提升

#### spring-boot-configuration-processor

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

**作用**: 配置属性处理器
**核心功能**:

- 配置属性元数据生成
- IDE 自动完成支持
- 配置验证

**学习重点**: 配置属性绑定、元数据生成

---

### 🧪 测试相关依赖

#### spring-boot-starter-test

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

**作用**: Spring Boot 测试支持
**包含组件**:

- JUnit 5
- Mockito
- AssertJ
- Hamcrest
- Spring Test

**学习重点**: 单元测试、集成测试、Mock 测试

#### mybatis-spring-boot-starter-test

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter-test</artifactId>
    <version>3.0.5</version>
    <scope>test</scope>
</dependency>
```

**作用**: MyBatis 测试支持
**核心功能**:

- @MybatisTest 注解
- 测试数据源配置
- SQL 测试支持

#### de.flapdoodle.embed.mongo

```xml
<dependency>
    <groupId>de.flapdoodle.embed</groupId>
    <artifactId>de.flapdoodle.embed.mongo</artifactId>
    <version>4.9.2</version>
    <scope>test</scope>
</dependency>
```

**作用**: 嵌入式 MongoDB 测试
**核心功能**:

- 内存 MongoDB 实例
- 测试隔离
- 快速启动

#### embedded-redis

```xml
<dependency>
    <groupId>it.ozimov</groupId>
    <artifactId>embedded-redis</artifactId>
    <version>0.7.3</version>
    <scope>test</scope>
</dependency>
```

**作用**: 嵌入式 Redis 测试
**核心功能**:

- 内存 Redis 实例
- 测试环境隔离
- 快速测试

#### h2

```xml
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

**作用**: 内存数据库，用于测试
**核心功能**:

- 内存数据库
- 快速测试
- SQL 兼容性

---

## 🔨 构建插件说明

### maven-compiler-plugin

**作用**: Maven 编译插件
**配置要点**:

- Java 17 编译支持
- Lombok 注解处理器配置
- 编译参数优化

### spring-boot-maven-plugin

**作用**: Spring Boot Maven 插件
**核心功能**:

- 可执行 JAR 打包
- 依赖管理
- 运行时支持

## 📋 依赖管理最佳实践

### 版本管理

1. **使用 Spring Boot BOM 管理版本**
2. **明确指定第三方库版本**
3. **定期更新依赖版本**

### 作用域管理

- **compile**: 编译和运行时都需要
- **runtime**: 只在运行时需要
- **test**: 只在测试时需要
- **optional**: 可选依赖

### 依赖冲突解决

1. **使用`mvn dependency:tree`查看依赖树**
2. **通过`<exclusions>`排除冲突依赖**
3. **明确指定版本解决冲突**

## 🎯 学习建议

### 学习顺序

1. **基础 Web 开发** → spring-boot-starter-web
2. **数据库操作** → 纯 MyBatis + MySQL（手动编写 Mapper）
3. **缓存应用** → Redis
4. **文档数据库** → MongoDB
5. **多线程处理** → AOP + 异步
6. **监控和测试** → Actuator + 测试框架

### 实践重点

1. **多数据源配置和使用**
2. **缓存策略设计和实现**
3. **异步处理和线程池管理**
4. **分布式锁的应用场景**
5. **API 文档自动化生成**
6. **应用监控和性能调优**

通过这些依赖包的学习和实践，你将掌握现代 Java Web 应用开发的核心技术栈。

## 💡 纯 MyBatis 学习优势

选择纯 MyBatis 而不使用 MyBatis-Plus 的学习优势：

1. **深入理解原理**: 手动编写 Mapper 接口和 XML 映射文件，更好地理解 MyBatis 的工作机制
2. **SQL 技能提升**: 需要手动编写 SQL 语句，提升 SQL 编写和优化能力
3. **灵活性更高**: 完全控制 SQL 的编写，可以进行复杂的查询优化
4. **基础更扎实**: 掌握了纯 MyBatis，学习其他 ORM 框架会更容易
5. **问题排查能力**: 遇到问题时能够从底层原理分析和解决

这种学习方式虽然初期会稍微复杂一些，但对于深入理解 MyBatis 和提升数据库操作能力非常有帮助。
