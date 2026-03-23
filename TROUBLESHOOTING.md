# 空白屏幕问题排查指南

## 问题症状
应用启动后显示空白屏幕

## 解决步骤

### 1. 安装依赖包

由于项目路径包含空格，Flutter命令可能无法正常执行。请按以下步骤操作：

**Windows用户：**
```cmd
cd "c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin"
flutter pub get
```

或者直接运行：
```cmd
install_deps.bat
```

**macOS/Linux用户：**
```bash
cd "/c/Study/2026-1st/android app/apiu bulletin/https---github.com-Niu-Boen-apiu-church-bulltin"
flutter pub get
```

### 2. 清理并重建

如果依赖已安装但仍显示空白，执行以下命令：

```cmd
flutter clean
flutter pub get
flutter run
```

### 3. 检查错误日志

在终端运行时，查看是否有错误信息。常见错误包括：

- **Dio包未找到**：说明依赖未正确安装
- **网络连接错误**：API无法访问
- **认证失败**：登录token无效

### 4. 测试API连接

确认以下API是否可访问：
- 基础URL: https://bulletinapi.rindra.org/api/v1

### 5. 检查路由配置

应用初始路由为 `/login`，如果登录页面加载失败，会显示空白。

## 常见问题

### Q: 为什么需要安装dio包？
A: dio是用于HTTP请求的包，应用需要它来与API服务器通信。

### Q: 可以跳过登录吗？
A: 可以，点击"CONTINUE AS GUEST"按钮可以以访客身份访问。

### Q: API测试账号是什么？
A:
- 管理员: username=`admin`, password=`admin123`
- 编辑员: username=`editor`, password=`editor123`

### Q: 如何确认依赖已安装？
A: 检查项目目录下是否有 `pubspec.lock` 文件，或运行 `flutter doctor` 检查环境。

## 如果问题仍然存在

请提供以下信息：
1. Flutter版本: 运行 `flutter --version`
2. 错误日志: 运行应用时的完整错误信息
3. 操作系统: Windows/macOS/Linux
4. 运行平台: Android/iOS/Web/Desktop

## 联系支持

如果以上步骤都无法解决问题，请联系技术支持。
