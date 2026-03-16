import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GivingScreen extends StatelessWidget {
  const GivingScreen({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account number copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giving & Offerings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 顶部图标和激励语
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.volunteer_activism_rounded,
                    size: 64,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Support Our Mission',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your generosity enables our community to grow and serve. '
                    'Thank you for your faithful stewardship.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 二维码区域
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'SCAN TO GIVE',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 120,
                          color: theme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Supports all Thai banking apps',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 银行转账卡片
            _buildBankCard(
              context,
              title: 'Sabbath Offering / Tithe',
              bank: 'Kasikorn Bank (K-Bank)',
              account: '123-4-56789-0',
            ),
            const SizedBox(height: 12),
            _buildBankCard(
              context,
              title: 'Building Fund',
              bank: 'Siam Commercial Bank (SCB)',
              account: '098-7-65432-1',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCard(
    BuildContext context, {
    required String title,
    required String bank,
    required String account,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.account_balance,
            color: theme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(bank, style: theme.textTheme.bodyMedium),
            Text(
              account,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => _copyToClipboard(context, account),
        ),
      ),
    );
  }
}
