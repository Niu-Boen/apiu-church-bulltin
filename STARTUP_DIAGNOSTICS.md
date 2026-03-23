# 启动诊断指南

## 快速诊断步骤

### 1. 运行简化测试

首先运行 `test_simple.dart` 来确认Flutter环境是否正常：

```cmd
flutter run -t test_simple.dart
```

如果看到 "If you see this, Flutter works!"，说明Flutter环境正常。

### 2. 检查依赖安装

运行以下命令确认所有依赖已正确安装：

```cmd
flutter pub deps
```

应该能看到dio、provider、go_router等包都已安装。

### 3. 清理并重新运行

```cmd
flutter clean
flutter pub get
flutter run
```

### 4. 查看详细错误信息

运行时添加详细日志：

```cmd
flutter run -v
```

## 可能的原因和解决方案

### 原因1: 路径问题（最可能）

项目路径包含空格，可能导致某些Flutter命令失败。

**解决方案：**
- 将项目移动到没有空格的路径，例如：`C:\Study\apiu-bulletin`
- 或确保使用引号包裹路径

### 原因2: 依赖未正确安装

即使pubspec.lock存在，某些包可能没有正确下载。

**解决方案：**
```cmd
flutter clean
flutter pub cache repair
flutter pub get
```

### 原因3: 平台特定问题

某些功能在特定平台上可能不工作。

**解决方案：**
- 在Windows上运行: `flutter run -d windows`
- 在Chrome上运行: `flutter run -d chrome`
- 在Web上运行: `flutter run -d web`

### 原因4: API连接问题

应用尝试连接API服务器，如果网络有问题可能导致卡住。

**解决方案：**
- 检查网络连接
- 测试API是否可访问：https://bulletinapi.rindra.org/api/v1

### 原因5: 通知权限问题

应用尝试初始化本地通知，可能需要权限。

**解决方案：**
- 已添加错误处理，通知初始化失败不会阻止应用启动

## 如何获取详细错误信息

### Windows

1. 在命令提示符或PowerShell中运行
2. 查看控制台输出
3. 复制所有错误信息

### VS Code

1. 打开"输出"面板（Ctrl+Shift+U）
2. 选择"Flutter"或"Run"频道
3. 查看日志输出

### Android Studio

1. 打开"Run"面板（Alt+4）
2. 查看logcat输出

## 常见错误和解决方案

### Error: No pubspec.yaml found

**原因：** 在错误的目录运行命令

**解决：**
```cmd
cd "c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin"
flutter run
```

### Error: Could not resolve package 'dio'

**原因：** Dio包未安装

**解决：**
```cmd
flutter pub get
```

### Error: Unhandled Exception

**原因：** 运行时错误

**解决：**
- 查看完整错误堆栈
- 已添加全局错误处理，会显示错误详情
- 检查 `TROUBLESHOOTING.md` 获取更多帮助

## 下一步

如果以上步骤都无法解决问题，请提供：

1. Flutter版本：`flutter --version`
2. 运行平台：Windows/macOS/Linux/Android/iOS/Web
3. 完整的错误日志
4. 截图（如果可能）
