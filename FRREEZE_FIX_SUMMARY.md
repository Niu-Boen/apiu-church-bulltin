# 卡死问题修复说明

## 问题原因

应用在启动时卡死的原因是在 `main.dart` 的 `main()` 函数中，使用了 `await initializeBulletins()` 等待异步操作完成。这个操作会从 `SharedPreferences` 加载数据，在 Windows 平台上，`SharedPreferences` 的初始化可能会遇到问题或耗时较长，导致主线程被阻塞。

## 修复方案

### 1. 修改 `main.dart` (第 63 行)

**修改前：**
```dart
// 初始化 bulletin 数据
try {
  await initializeBulletins();
} catch (e) {
  debugPrint('Failed to initialize bulletins: $e');
  // 不阻止应用启动
}
```

**修改后：**
```dart
// 初始化 bulletin 数据（不阻塞主线程）
initializeBulletins().catchError((e) {
  debugPrint('Failed to initialize bulletins: $e');
});
```

**说明：** 移除了 `await` 关键字，让 `initializeBulletins()` 在后台异步执行，不阻塞应用启动。

### 2. 修改 `bulletin_data.dart` 的 `initializeBulletins()` 函数

**修改前：**
```dart
Future<void> initializeBulletins() async {
  try {
    final loadedBulletins = await BulletinStorageService.loadBulletins();

    if (loadedBulletins.isEmpty) {
      // 首次使用,加载默认数据
      bulletinItems = List.from(_defaultBulletins);
      await BulletinStorageService.saveBulletins(bulletinItems);
    } else {
      bulletinItems = loadedBulletins;
    }
  } catch (e) {
    // 加载失败,使用默认数据
    bulletinItems = List.from(_defaultBulletins);
  }
}
```

**修改后：**
```dart
Future<void> initializeBulletins() async {
  try {
    // 先使用默认数据，确保应用可以立即启动
    bulletinItems = List.from(_defaultBulletins);

    // 异步加载数据，不阻塞主线程
    final loadedBulletins = await BulletinStorageService.loadBulletins();

    if (loadedBulletins.isNotEmpty) {
      // 成功加载数据，使用加载的数据
      bulletinItems = loadedBulletins;
    }
  } catch (e) {
    debugPrint('Failed to load bulletins from storage: $e');
    // 加载失败，继续使用默认数据
  }
}
```

**说明：** 在开始时就设置默认数据，确保应用可以立即显示内容。然后异步加载存储的数据，成功后替换默认数据。

### 3. 优化 `bulletin_storage_service.dart`

**新增内容：**
- 添加了 `_isInitialized` 和 `_prefs` 静态变量，用于缓存 `SharedPreferences` 实例
- 添加了 `_initPrefs()` 私有方法，用于安全的初始化 `SharedPreferences`
- 在所有使用 `SharedPreferences` 的方法中，先调用 `_initPrefs()` 确保初始化
- 添加了更好的错误处理，防止 `SharedPreferences` 为 `null` 时崩溃

**说明：** 这样可以避免重复初始化 `SharedPreferences`，并提供更好的错误处理机制。

## 预期效果

1. **快速启动**：应用启动时不会等待数据加载，可以立即显示界面
2. **无卡死**：不会因为 `SharedPreferences` 初始化问题导致应用卡死
3. **优雅降级**：如果存储加载失败，应用仍然可以使用默认数据正常工作
4. **更好的用户体验**：用户点击鼠标和滚动滚轮时能够得到即时响应

## 测试建议

1. 在 Windows 平台上重新运行应用
2. 检查应用启动是否流畅，没有卡顿
3. 测试鼠标点击和滚轮滚动是否响应及时
4. 检查公告数据是否正常显示（默认数据或存储的数据）
