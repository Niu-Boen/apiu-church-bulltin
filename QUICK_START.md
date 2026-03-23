# APIU Church Bulletin - 快速启动指南

## 一键启动

### Windows用户

**最简单的方法：**
```cmd
run.bat
```

这个脚本会自动：
1. 安装依赖
2. 清理之前的构建
3. 启动应用

### 手动启动

```cmd
cd "c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin"
flutter pub get
flutter run
```

## 应用功能

### 🏠 首页
- 安息日倒计时
- 每日经文
- 快速操作入口

### 📅 公告栏
- 周五晚间程序
- 安息日程序
- 协调员信息
- 公告通知

### 💰 奉献
- 奉献方式说明
- 支付二维码

### ⏰ 安息日
- 安息日详细信息
- 日落时间
- 安息日提醒

### 👥 志愿者
- 志愿者服务信息
- 报名方式

## 测试账号

| 角色 | 用户名 | 密码 | 权限 |
|------|--------|------|------|
| 管理员 | admin | admin123 | 完全权限 |
| 编辑员 | editor | editor123 | 编辑公告 |
| 访客 | - | - | 只读访问 |

**注意**: 访客模式可直接点击"CONTINUE AS GUEST"进入

## 常见问题

### Q: 应用启动后显示空白？
**A**: 请运行 `run.bat` 或执行：
```cmd
flutter clean
flutter pub get
flutter run
```

详细解决方案请查看 `BLANK_SCREEN_FIX.md`

### Q: 需要什么Flutter版本？
**A**: Flutter 3.13.0 或更高版本

检查Flutter版本：
```cmd
flutter --version
```

### Q: 如何在不同平台运行？
**A**:
- Windows桌面: `flutter run -d windows`
- Chrome浏览器: `flutter run -d chrome`
- Web: `flutter run -d web`

### Q: API连接失败怎么办？
**A**:
1. 检查网络连接
2. 确认API地址: https://bulletinapi.rindra.org/api/v1
3. 使用访客模式跳过登录

## 技术栈

- **Flutter**: 3.13.0+
- **Dart**: 3.1.0+
- **状态管理**: Provider
- **路由**: Go Router
- **HTTP客户端**: Dio
- **本地通知**: flutter_local_notifications
- **字体**: Google Fonts (PT Sans)

## 项目结构

```
lib/
├── core/
│   ├── models/           # 数据模型
│   └── services/         # API服务
├── features/
│   ├── auth/             # 认证功能
│   ├── home/             # 首页
│   ├── bulletin/         # 公告栏
│   ├── giving/           # 奉献
│   ├── sabbath/         # 安息日
│   ├── volunteer/        # 志愿者
│   └── about/            # 关于我们
└── main.dart            # 应用入口
```

## 文档

- **BLANK_SCREEN_FIX.md**: 空白屏幕问题修复
- **TROUBLESHOOTING.md**: 问题排查指南
- **STARTUP_DIAGNOSTICS.md**: 启动诊断步骤
- **API_INTEGRATION_SUMMARY.md**: API集成文档
- **INSTALLATION.md**: 安装说明

## 开发

### 安装依赖
```cmd
flutter pub get
```

### 运行应用
```cmd
flutter run
```

### 构建发布版本
```cmd
# Windows
flutter build windows

# Web
flutter build web

# Android APK
flutter build apk
```

### 检查代码质量
```cmd
flutter analyze
```

### 运行测试
```cmd
flutter test
```

## 贡献

欢迎贡献代码、报告问题或提出建议！

## 许可证

版权所有 © 2026 APIU Church

---

**需要帮助？** 查看 `BLANK_SCREEN_FIX.md` 获取详细的故障排除指南
