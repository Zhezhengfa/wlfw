/// 单张窗口卡片——叫号看板列表里的每一行。
///
/// **设计约束**（严格对标 Material 3 默认值）：
/// - Card 圆角 12dp / 16dp 左右边距 / 16dp 内边距
/// - 当前叫号大字 32sp / w500 / primary 色（原型用 56px 但 Flutter 默认字号体系里 32 更贴近 titleLarge 级别）
/// - 等待人数 + 预计时间：bodySmall onSurfaceVariant
import 'package:flutter/material.dart';

import '../models/window.dart';

class WindowTile extends StatelessWidget {
  const WindowTile({super.key, required this.window, this.onTap});
  final Window window;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card.filled(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      window.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '等待 ${window.waitingCount} 人 · 约 ${window.estimatedMin} 分钟',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    window.currentNumber,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: color.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '当前叫号',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
