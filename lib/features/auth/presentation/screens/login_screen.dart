import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 常量定义
  static const double _horizontalPadding = 32.0;
  static const double _logoSize = 80.0;
  static const double _spacingLarge = 48.0;
  static const double _spacingMedium = 32.0;
  static const double _spacingSmall = 16.0;
  static const double _spacingTiny = 12.0;
  static const double _spacingExtraSmall = 8.0;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(String role) {
    if (role == 'guest') {
      _showVisitorNotice();
      return;
    }

    // 验证表单
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      // 根据凭据决定角色
      final userRole = (username == 'admin' && password == 'admin') ? 'admin' : 'user';
      if (context.mounted) {
        context.go('/home', extra: userRole);
      }
    }
  }

  void _showVisitorNotice() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Visitor Access'),
        content: const Text(
          'As a visitor, you will have read-only access to the bulletin and giving information.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // 检查原上下文是否仍然有效
              if (context.mounted) {
                context.go('/home', extra: 'guest');
              }
            },
            child: const Text('I UNDERSTAND'),
          ),
        ],
      ),
    );
  }

  // 构建登录表单字段
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline_rounded),
        labelText: 'Username',
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.shield_outlined),
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  // 构建主要按钮（Member Login）
  Widget _buildMemberLoginButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _login('member'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
        ),
        child: const Text('MEMBER LOGIN'),
      ),
    );
  }

  // 构建访客按钮（Continue as Guest）
  Widget _buildGuestButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _login('guest'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
        ),
        child: const Text('CONTINUE AS GUEST'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo & Title ---
                Icon(Icons.church_rounded, size: _logoSize, color: theme.primaryColor),
                const SizedBox(height: _spacingSmall),
                Text(
                  'APIU BULLETIN',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.primaryColor,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: _spacingExtraSmall),
                Text(
                  'Your digital church companion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: _spacingLarge),

                // --- Login Form ---
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildUsernameField(),
                      const SizedBox(height: _spacingSmall),
                      _buildPasswordField(),
                    ],
                  ),
                ),
                const SizedBox(height: _spacingMedium),

                // --- Buttons ---
                _buildMemberLoginButton(theme),
                const SizedBox(height: _spacingTiny),
                _buildGuestButton(theme),

                const SizedBox(height: _spacingLarge),
                Text(
                  'DEMO CREDENTIALS\nadmin / admin',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ), 
        ),
      ),
    );
  }
}