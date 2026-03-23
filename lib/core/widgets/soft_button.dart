import 'package:flutter/material.dart';

/// 硅胶感按钮包装器
/// 提供 CSS 拟态风格的软阴影效果
///
/// 阴影规则:
/// - 外阴影: 左上取背景色减淡版(白色), 右下取背景色加深版
/// - 内阴影: 左上取背景色加深版, 右下取背景色减淡版
class SoftButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isTabSelected; // 用于 TabBar 样式

  const SoftButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.width,
    this.height,
    this.padding,
    this.isTabSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    // 使用渐变背景色
    final gradientColors = [
      const Color(0xFFB6B9BA), // #b6b9ba
      const Color(0xFFF4F6F8), // #f4f6f8
    ];

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: const FractionalOffset(0.5, 1.0), // 对应 145deg
          end: const FractionalOffset(0.5, 0.0),
          stops: const [0.0, 1.0],
        ),
        borderRadius: radius,
        // 外阴影: 左上浅色, 右下深色 - 使用新的阴影参数
        boxShadow: [
          // 左上: 浅色阴影 (#fafafd)
          BoxShadow(
            color: const Color(0xFFFAFAFD),
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          // 右下: 深色阴影 (#b6b9ba)
          BoxShadow(
            color: const Color(0xFFB6B9BA),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          // 内阴影效果 - 使用 gradient 模拟
          splashColor: Colors.black.withValues(alpha: 0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              // 内阴影模拟: 左上加深, 右下减淡
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB6B9BA),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0xFFFAFAFD),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: -4,
                ),
              ],
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 用于 TabBar 的硅胶感标签包装器
class SoftTabBar extends StatelessWidget {
  final TabController controller;
  final List<Tab> tabs;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;

  const SoftTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.backgroundColor,
    this.selectedBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFFF5F7F9);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = index == controller.index;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFB6B9BA),
                            Color(0xFFF4F6F8),
                          ],
                          begin: FractionalOffset(0.5, 1.0),
                          end: FractionalOffset(0.5, 0.0),
                          stops: [0.0, 1.0],
                        )
                      : null,
                  color: isSelected ? null : bgColor,
                  borderRadius: BorderRadius.circular(12),
                  // 只在选中时显示阴影 - 使用新的阴影参数
                  boxShadow: isSelected
                      ? [
                          // 左上: 浅色阴影
                          BoxShadow(
                            color: const Color(0xFFFAFAFD),
                            offset: const Offset(-4, -4),
                            blurRadius: 8,
                          ),
                          // 右下: 深色阴影
                          BoxShadow(
                            color: const Color(0xFFB6B9BA),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Tab(
                  child: entry.value.child,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
