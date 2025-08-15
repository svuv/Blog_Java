# Token状态验证设计方案

## 🎯 设计目标

1. **简洁高效**: 最少的配置，最大的灵活性
2. **状态可控**: 支持主动失效Token（登出、踢人等）
3. **性能优化**: Redis缓存减少数据库查询
4. **安全可靠**: JWT防篡改 + Redis状态验证

## 🏗️ 核心架构

### 1. Token生成流程
```
用户登录 → 验证用户名密码 → 生成JWT → 存储到Redis → 返回给客户端
```

### 2. Token验证流程
```
请求到达 → 提取Token → 解析JWT → 检查Redis状态 → 验证用户信息 → 放行/拒绝
```

### 3. Token失效流程
```
用户登出/管理员踢人 → 删除Redis中的Token → Token立即失效
```

## 📋 核心组件设计

### 1. JWT工具类 (JwtUtil)

```java
@Component
@Slf4j
public class JwtUtil {
    
    @Value("${jwt.secret:blog-secret-key-2024}")
    private String secret;
    
    @Value("${jwt.expiration:86400}") // 24小时
    private Long expiration;
    
    private Key getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(
            Base64.getEncoder().encodeToString(secret.getBytes())
        );
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    /**
     * 生成Token
     */
    public String generateToken(Long userId, String username) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration * 1000);
        
        return Jwts.builder()
                .setSubject(userId.toString())
                .claim("username", username)
                .claim("tokenId", UUID.randomUUID().toString()) // 唯一标识
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }
    
    /**
     * 解析Token
     */
    public Claims parseToken(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            log.error("Token解析失败: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * 获取用户ID
     */
    public Long getUserId(String token) {
        Claims claims = parseToken(token);
        return claims != null ? Long.valueOf(claims.getSubject()) : null;
    }
    
    /**
     * 获取Token唯一标识
     */
    public String getTokenId(String token) {
        Claims claims = parseToken(token);
        return claims != null ? claims.get("tokenId", String.class) : null;
    }
    
    /**
     * 检查Token是否过期
     */
    public boolean isTokenExpired(String token) {
        Claims claims = parseToken(token);
        return claims == null || claims.getExpiration().before(new Date());
    }
}
```

### 2. Token管理服务 (TokenService)

```java
@Service
@Slf4j
public class TokenService {
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Autowired
    private UserMapper userMapper;
    
    private static final String TOKEN_PREFIX = "token:";
    private static final String USER_TOKEN_PREFIX = "user_token:";
    
    /**
     * 用户登录，生成Token
     */
    public LoginResponse login(String username, String password) {
        // 1. 验证用户名密码
        User user = userMapper.selectByUsername(username);
        if (user == null || !passwordEncoder.matches(password, user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 2. 生成JWT Token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        String tokenId = jwtUtil.getTokenId(token);
        
        // 3. 存储到Redis
        storeTokenToRedis(user.getId(), tokenId, token);
        
        // 4. 返回登录信息
        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .expiresIn(86400L)
                .build();
    }
    
    /**
     * 验证Token有效性
     */
    public TokenValidationResult validateToken(String token) {
        try {
            // 1. 解析JWT
            if (jwtUtil.isTokenExpired(token)) {
                return TokenValidationResult.expired();
            }
            
            Long userId = jwtUtil.getUserId(token);
            String tokenId = jwtUtil.getTokenId(token);
            
            if (userId == null || tokenId == null) {
                return TokenValidationResult.invalid();
            }
            
            // 2. 检查Redis中的状态
            String redisKey = TOKEN_PREFIX + tokenId;
            String storedToken = (String) redisTemplate.opsForValue().get(redisKey);
            
            if (storedToken == null || !storedToken.equals(token)) {
                return TokenValidationResult.invalid();
            }
            
            // 3. 获取用户信息（可选，根据需要）
            User user = userMapper.selectById(userId);
            if (user == null) {
                return TokenValidationResult.invalid();
            }
            
            return TokenValidationResult.success(userId, user.getUsername());
            
        } catch (Exception e) {
            log.error("Token验证异常: {}", e.getMessage());
            return TokenValidationResult.invalid();
        }
    }
    
    /**
     * 用户登出
     */
    public void logout(String token) {
        String tokenId = jwtUtil.getTokenId(token);
        Long userId = jwtUtil.getUserId(token);
        
        if (tokenId != null && userId != null) {
            // 删除Token记录
            redisTemplate.delete(TOKEN_PREFIX + tokenId);
            
            // 删除用户Token映射
            redisTemplate.opsForSet().remove(USER_TOKEN_PREFIX + userId, tokenId);
        }
    }
    
    /**
     * 踢出用户（删除用户所有Token）
     */
    public void kickOutUser(Long userId) {
        String userTokenKey = USER_TOKEN_PREFIX + userId;
        Set<Object> tokenIds = redisTemplate.opsForSet().members(userTokenKey);
        
        if (tokenIds != null && !tokenIds.isEmpty()) {
            // 删除所有Token
            List<String> tokenKeys = tokenIds.stream()
                    .map(tokenId -> TOKEN_PREFIX + tokenId)
                    .collect(Collectors.toList());
            
            redisTemplate.delete(tokenKeys);
            redisTemplate.delete(userTokenKey);
        }
    }
    
    /**
     * 刷新Token
     */
    public String refreshToken(String oldToken) {
        Long userId = jwtUtil.getUserId(oldToken);
        if (userId == null) {
            throw new BusinessException("无效的Token");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        // 删除旧Token
        logout(oldToken);
        
        // 生成新Token
        String newToken = jwtUtil.generateToken(user.getId(), user.getUsername());
        String tokenId = jwtUtil.getTokenId(newToken);
        storeTokenToRedis(user.getId(), tokenId, newToken);
        
        return newToken;
    }
    
    /**
     * 存储Token到Redis
     */
    private void storeTokenToRedis(Long userId, String tokenId, String token) {
        // 存储Token内容
        redisTemplate.opsForValue().set(
            TOKEN_PREFIX + tokenId, 
            token, 
            Duration.ofSeconds(86400)
        );
        
        // 存储用户Token映射（支持踢出功能）
        redisTemplate.opsForSet().add(USER_TOKEN_PREFIX + userId, tokenId);
        redisTemplate.expire(USER_TOKEN_PREFIX + userId, Duration.ofSeconds(86400));
    }
}
```

### 3. Token验证结果类

```java
@Data
@Builder
@AllArgsConstructor
public class TokenValidationResult {
    private boolean valid;
    private Long userId;
    private String username;
    private String message;
    
    public static TokenValidationResult success(Long userId, String username) {
        return TokenValidationResult.builder()
                .valid(true)
                .userId(userId)
                .username(username)
                .message("验证成功")
                .build();
    }
    
    public static TokenValidationResult invalid() {
        return TokenValidationResult.builder()
                .valid(false)
                .message("Token无效")
                .build();
    }
    
    public static TokenValidationResult expired() {
        return TokenValidationResult.builder()
                .valid(false)
                .message("Token已过期")
                .build();
    }
}
```

### 4. 拦截器实现

```java
@Component
@Slf4j
public class TokenInterceptor implements HandlerInterceptor {
    
    @Autowired
    private TokenService tokenService;
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, 
                           Object handler) throws Exception {
        
        // 跳过OPTIONS请求
        if ("OPTIONS".equals(request.getMethod())) {
            return true;
        }
        
        // 获取Token
        String token = extractToken(request);
        if (StringUtils.isEmpty(token)) {
            return handleUnauthorized(response, "缺少Token");
        }
        
        // 验证Token
        TokenValidationResult result = tokenService.validateToken(token);
        if (!result.isValid()) {
            return handleUnauthorized(response, result.getMessage());
        }
        
        // 设置用户信息到请求上下文
        request.setAttribute("userId", result.getUserId());
        request.setAttribute("username", result.getUsername());
        
        return true;
    }
    
    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
    
    private boolean handleUnauthorized(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType("application/json;charset=UTF-8");
        
        Map<String, Object> result = new HashMap<>();
        result.put("code", 401);
        result.put("message", message);
        result.put("timestamp", System.currentTimeMillis());
        
        response.getWriter().write(new ObjectMapper().writeValueAsString(result));
        return false;
    }
}
```

### 5. Web配置

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Autowired
    private TokenInterceptor tokenInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(tokenInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/api/auth/login",
                    "/api/auth/register", 
                    "/swagger-ui/**",
                    "/v3/api-docs/**",
                    "/actuator/**"
                );
    }
}
```

### 6. 认证控制器

```java
@RestController
@RequestMapping("/api/auth")
@Slf4j
public class AuthController {
    
    @Autowired
    private TokenService tokenService;
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody @Valid LoginRequest request) {
        LoginResponse response = tokenService.login(request.getUsername(), request.getPassword());
        return ApiResponse.success(response);
    }
    
    /**
     * 用户登出
     */
    @PostMapping("/logout")
    public ApiResponse<Void> logout(HttpServletRequest request) {
        String token = extractToken(request);
        if (token != null) {
            tokenService.logout(token);
        }
        return ApiResponse.success();
    }
    
    /**
     * 刷新Token
     */
    @PostMapping("/refresh")
    public ApiResponse<String> refreshToken(HttpServletRequest request) {
        String token = extractToken(request);
        String newToken = tokenService.refreshToken(token);
        return ApiResponse.success(newToken);
    }
    
    /**
     * 获取当前用户信息
     */
    @GetMapping("/me")
    public ApiResponse<UserInfo> getCurrentUser(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String username = (String) request.getAttribute("username");
        
        UserInfo userInfo = UserInfo.builder()
                .userId(userId)
                .username(username)
                .build();
                
        return ApiResponse.success(userInfo);
    }
    
    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

## ⚙️ 配置文件

```yaml
# application.properties
jwt:
  secret: blog-jwt-secret-key-2024-very-long-secret
  expiration: 86400 # 24小时，单位：秒

spring:
  security:
    # 禁用Spring Security的默认配置
    basic:
      enabled: false
    # 或者自定义配置
```

## 🎯 使用方式

### 1. 前端登录
```javascript
// 登录请求
const response = await fetch('/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'admin',
    password: 'password'
  })
});

const data = await response.json();
const token = data.data.token;

// 存储Token
localStorage.setItem('token', token);
```

### 2. 前端请求携带Token
```javascript
// 后续请求携带Token
const response = await fetch('/api/articles', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  }
});
```

### 3. 后端获取用户信息
```java
@GetMapping("/articles")
public ApiResponse<List<Article>> getArticles(HttpServletRequest request) {
    Long userId = (Long) request.getAttribute("userId");
    String username = (String) request.getAttribute("username");
    
    // 使用用户信息进行业务处理
    List<Article> articles = articleService.getArticlesByUser(userId);
    return ApiResponse.success(articles);
}
```

## 🔧 优势特点

1. **简洁高效**: 最少的依赖和配置
2. **状态可控**: Redis存储支持主动失效
3. **性能优化**: JWT减少数据库查询
4. **安全可靠**: 双重验证机制
5. **易于扩展**: 支持多端登录、踢人等功能

## 🚀 扩展功能

1. **多端登录控制**: 限制同一用户的登录设备数量
2. **Token自动续期**: 接近过期时自动刷新
3. **登录日志**: 记录用户登录行为
4. **权限控制**: 结合角色权限系统
5. **单点登录**: 扩展为SSO系统

这个方案既保持了简洁性，又具备了企业级应用所需的功能和安全性。