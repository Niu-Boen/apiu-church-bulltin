import 'package:flutter/material.dart';

class GivingScreen extends StatelessWidget {
  const GivingScreen({super.key});

  // 常量定义
  static const double _horizontalPadding = 24.0;
  static const double _verticalPadding = 32.0;
  static const double _iconSize = 48.0;
  static const double _qrCodeSize = 220.0;
  static const double _qrIconSize = 100.0;
  static const double _spacingLarge = 40.0;
  static const double _spacingMedium = 20.0;
  static const double _spacingSmall = 16.0;
  static const double _spacingTiny = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giving & Offerings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGuidanceSection(textTheme, theme),
            const SizedBox(height: _spacingLarge),
            _buildQRCodeSection(theme),
            const SizedBox(height: _spacingLarge),
            _buildBankDetailsSection(theme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceSection(TextTheme textTheme, ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.volunteer_activism_rounded,
          size: _iconSize,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(height: _spacingSmall),
        Text(
          'Support Our Mission',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: _spacingTiny),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your generosity enables our community to grow and serve. Thank you for your faithful stewardship.',
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'SCAN TO GIVE',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: _spacingMedium),
        // --- Placeholder QR Code Area ---
        // Note: Flutter Canvas needed for true dashed border; currently using solid border.
        Container(
          width: _qrCodeSize,
          height: _qrCodeSize,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.2),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              size: _qrIconSize,
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: _spacingSmall),
        Text(
          'Supports all Thai banking apps',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection(ThemeData theme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'BANK TRANSFER',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        _buildBankCard(
          theme,
          textTheme,
          'Sabbath Offering / Tithe',
          'Kasikorn Bank (K-Bank)',
          '123-4-56789-0',
        ),
        const SizedBox(height: _spacingTiny),
        _buildBankCard(
          theme,
          textTheme,
          'Building Fund',
          'Siam Commercial Bank (SCB)',
          '098-7-65432-1',
        ),
      ],
    );
  }

  Widget _buildBankCard(
    ThemeData theme,
    TextTheme textTheme,
    String title,
    String bank,
    String account,
  ) {
    return Card(
      elevation: 0,
      color: theme.primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(bank, style: textTheme.bodyMedium),
            Text(
              account,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () {
            // TODO: Implement copy to clipboard functionality
            // Example: Clipboard.setData(ClipboardData(text: account));
          },
        ),
      ),
    );
  }
}