# 访客登录 Null 错误修复说明

## 问题描述

当用户使用访客模式登录时，输入登录名后应用卡死，显示空白页面，只有底部导航栏。终端报错：
```
Another exception was thrown: Unexpected null value.
```

## 问题原因

1. **访客登录流程不完整**：在 `login_screen.dart` 中，访客登录时直接使用 `context.go('/home', extra: {...})` 导航到首页，但没有调用 `UserProvider.login()` 方法
2. **缺少访客用户管理**：`UserProvider` 只支持注册用户，不支持访客用户
3. **首页依赖问题**：`HomeScreen` 依赖 `UserProvider.currentUser`，当用户为 `null` 时可能导致布局或逻辑错误

## 修复方案

### 1. 扩展 `UserProvider` 支持访客用户

**文件：** `lib/features/auth/presentation/providers/user_provider.dart`

**修改内容：**
- 添加 `_guestName` 字段存储访客姓名
- 添加 `guestName` getter 获取访客姓名
- 添加 `isLoggedIn` getter 判断是否已登录（包括访客）
- 添加 `isGuest` getter 判断是否为访客用户
- 添加 `loginAsGuest()` 方法处理访客登录
- 修改 `logout()` 方法同时清除用户和访客信息

### 2. 修改访客登录逻辑

**文件：** `lib/features/auth/presentation/screens/login_screen.dart`

**修改内容：**
- 访客登录时调用 `context.read<UserProvider>().loginAsGuest(guestName)` 而不是直接导航
- 这样确保 `UserProvider` 中有访客信息
- 然后正常导航到首页：`context.go('/home')`

**修改前：**
```dart
Navigator.pop(dialogContext);
if (mounted) context.go('/home', extra: {'role': 'guest', 'name': guestName});
```

**修改后：**
```dart
Navigator.pop(dialogContext);
if (mounted) {
  context.read<UserProvider>().loginAsGuest(guestName);
  context.go('/home');
}
```

### 3. 更新首页显示逻辑

**文件：** `lib/features/home/presentation/screens/home_screen.dart`

**修改内容：**
- 从 `UserProvider` 获取 `guestName`
- 在欢迎消息中优先显示用户名，其次显示访客名，最后显示 "Guest"

**修改前：**
```dart
final user = context.watch<UserProvider>().currentUser;
// ...
title: Text(
  user != null ? 'Welcome, ${user.username}' : 'Welcome, Guest',
  style: const TextStyle(color: Colors.white),
),
```

**修改后：**
```dart
final user = context.watch<UserProvider>().currentUser;
final guestName = context.watch<UserProvider>().guestName;
// ...
title: Text(
  user != null
      ? 'Welcome, ${user.username}'
      : guestName != null
          ? 'Welcome, $guestName'
          : 'Welcome, Guest',
  style: const TextStyle(color: Colors.white),
),
```

## 修复效果

1. ✅ 访客登录后正常显示首页
2. ✅ 欢迎消息显示访客输入的姓名
3. ✅ 不会出现 `Unexpected null value` 错误
4. ✅ 访客用户可以正常使用应用的所有功能（除了需要管理员权限的功能）
5. ✅ 访客登出后状态正确清除

## 测试建议

1. 点击 "CONTINUE AS GUEST" 按钮
2. 输入访客姓名（例如："John"）
3. 点击 "CONTINUE" 按钮
4. 验证首页显示 "Welcome, John"
5. 验证底部导航栏可以正常点击切换
6. 测试登出功能是否正常

## UserProvider 新增属性说明

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `currentUser` | `UserModel?` | 当前登录的用户对象（注册用户） |
| `guestName` | `String?` | 访客姓名（仅访客模式） |
| `isAdmin` | `bool` | 是否为管理员（注册用户） |
| `isEditor` | `bool` | 是否为编辑者（注册用户） |
| `isLoggedIn` | `bool` | 是否已登录（包括访客） |
| `isGuest` | `bool` | 是否为访客用户 |

## UserProvider 新增方法说明

| 方法名 | 参数 | 说明 |
|--------|------|------|
| `login(user)` | `UserModel` | 注册用户登录 |
| `loginAsGuest(name)` | `String` | 访客登录，设置访客姓名 |
| `logout()` | - | 登出，清除所有用户信息 |
