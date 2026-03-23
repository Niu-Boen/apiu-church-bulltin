import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/visitor_storage_service.dart';
import '../providers/user_provider.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  // 常量定义，提升可维护性
  static const double _padding = 16.0;
  static const double _spacing = 24.0;

  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 输入验证：去除首尾空格后检查是否为空
  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your name.');
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // 保持原有红色提示
      ),
    );
  }

  void _submit() async {
    if (!_validateInputs()) return;

    final name = _nameController.text.trim();

    // 记录访客访问
    final visitor = await VisitorStorageService.recordVisitor(name);

    if (visitor != null && context.mounted) {
      // 设置访客信息到 Provider
      context.read<UserProvider>().loginAsGuest(name);

      // 显示欢迎信息
      final message = visitor.visitCount > 1
          ? 'Welcome back, $name! This is visit #${visitor.visitCount}'
          : 'Welcome, $name!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // 导航到首页
      if (context.mounted) {
        context.go('/home');
      }
    } else if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNameTextField(),
            const SizedBox(height: _spacing),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // 提取文本输入字段构建方法（保持与之前一致）
  Widget _buildNameTextField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Enter your name',
        border: OutlineInputBorder(),
      ),
    );
  }
}