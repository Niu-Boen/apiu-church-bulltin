# API Integration Summary

本文档说明了将Bulletin API集成到Flutter应用中所做的主要更改。

## 📋 更新内容

### 1. 依赖添加 (pubspec.yaml)
添加了HTTP客户端依赖：
- `http: ^1.2.0` - 标准HTTP客户端
- `dio: ^5.4.0` - 高级HTTP客户端，支持拦截器和自动token管理

### 2. API服务层

#### core/services/api_service.dart
- 配置基础API设置（baseUrl: https://bulletinapi.rindra.org/api/v1）
- 实现Dio客户端初始化
- 添加JWT token自动注入拦截器
- 实现token自动刷新机制
- 提供统一的HTTP方法（GET, POST, PUT, DELETE）

#### core/services/auth_api_service.dart
实现认证相关API调用：
- `login()` - 用户登录（返回access_token和refresh_token）
- `register()` - 用户注册
- `getCurrentUser()` - 获取当前用户信息
- `changePassword()` - 修改密码
- `logout()` - 用户登出
- `refreshToken()` - 刷新访问令牌
- 统一的错误处理机制

#### core/services/bulletin_api_service.dart
实现公告管理API调用：
- `getBulletins()` - 获取公告列表（支持分页、搜索、日期过滤）
- `getBulletinDetail()` - 获取单个公告详情
- `createBulletin()` - 创建新公告
- `updateBulletin()` - 更新公告
- `deleteBulletin()` - 删除公告
- `addProgramItem()` - 添加程序项目
- `addAnnouncement()` - 添加公告通知

### 3. 数据模型

#### core/models/user_model.dart
用户数据模型：
- 用户基本信息（id, username, email, fullName）
- 角色管理（role, isAdmin, isEditor）
- JSON序列化/反序列化

#### core/models/bulletin_model.dart
公告相关数据模型：
- `BulletinModel` - 主公告模型
- `ProgramItem` - 程序项目模型（title, time, servicePersonnel, block等）
- `Coordinator` - 协调员模型
- `Announcement` - 公告通知模型（支持置顶）
- 完整的JSON序列化支持

### 4. 认证集成

#### features/auth/presentation/screens/login_screen.dart
更改：
- 替换本地UserService为AuthApiService
- 添加登录加载状态
- 更新演示凭证（admin/admin123, editor/editor123）
- 集成API登录流程
- 获取并存储用户详细信息

#### features/auth/presentation/screens/register_screen.dart
更改：
- 添加email和fullName字段
- 集成API注册流程
- 注册后自动登录
- 添加加载状态显示

#### main.dart
更改：
- 在main函数中初始化ApiService
- 导入api_service

### 5. 公告显示

#### features/bulletin/presentation/screens/bulletin_screen.dart
更改：
- 集成BulletinApiService获取公告数据
- 实现加载状态和错误处理
- 支持下拉刷新
- 完全重新设计UI以适配API数据结构：
  - 按block分组显示程序项目
  - 显示协调员信息
  - 显示公告通知（支持置顶）
  - 显示完整的公告详情

## 🔐 认证机制

1. **登录流程**：
   - 用户输入凭证
   - 调用 `/auth/login` 获取token
   - 存储access_token和refresh_token
   - 获取用户详细信息
   - Token自动注入到后续请求

2. **Token刷新**：
   - 当收到401错误时，自动尝试刷新token
   - 使用refresh_token获取新的access_token
   - 刷新成功后重试原请求
   - 刷新失败则清除token

3. **登出**：
   - 调用API登出端点
   - 清除本地存储的token

## 📊 数据流

```
用户操作 → UI层 → Provider → API Service → Dio → API Server
                                    ↓
                                Token注入拦截器
                                    ↓
                                错误处理拦截器
```

## 🎯 API端点映射

| 功能 | 端点 | 方法 |
|------|------|------|
| 登录 | /auth/login | POST |
| 注册 | /auth/register | POST |
| 获取用户信息 | /auth/me | GET |
| 获取公告列表 | /bulletins | GET |
| 获取公告详情 | /bulletins/{id} | GET |
| 创建公告 | /bulletins | POST |
| 更新公告 | /bulletins/{id} | PUT |
| 删除公告 | /bulletins/{id} | DELETE |
| 添加程序项 | /bulletins/{id}/programs | POST |
| 添加通知 | /bulletins/{id}/announcements | POST |

## 🚀 使用说明

### 运行应用

1. 安装依赖：
```bash
flutter pub get
```

2. 运行应用：
```bash
flutter run
```

### 测试账号

- **管理员**: `admin` / `admin123`
- **编辑者**: `editor` / `editor123`
- **访客**: 点击"CONTINUE AS GUEST"进入（只读模式）

## 📝 注意事项

1. **网络权限**：确保设备有网络连接
2. **SSL证书**：API使用Let's Encrypt SSL证书
3. **错误处理**：所有API调用都包含错误处理，用户会收到友好提示
4. **加载状态**：网络请求期间显示加载指示器
5. **Token管理**：Token自动刷新，无需手动处理

## 🔮 未来改进

1. 添加离线缓存（Hive或SQLite）
2. 实现请求重试机制
3. 添加网络状态检测
4. 实现数据同步
5. 添加更多错误日志
6. 优化性能（如分页加载）

## 📚 参考文档

- API文档: https://bulletinapi.rindra.org/docs
- ReDoc: https://bulletinapi.rindra.org/redoc
- OpenAPI规范: https://bulletinapi.rindra.org/openapi.json
- Dio文档: https://pub.dev/packages/dio
