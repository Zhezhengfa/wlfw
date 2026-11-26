/// 三种"状态视图"集中实现，页面层直接拿来用。
///
/// 课堂必考点：
/// - LoadingView 只显示转圈 + "加载中..."，不额外画图标
/// - ErrorView 有可点击的重试按钮；区分错误类型文案
/// - EmptyView 不红色、不叫报错；图标主色；无按钮（空了就是空了，刷新也没用）
import 'package:flutter/material.dart';

import '../core/app_exception.dart';

/// 加载中——小转圈 + 一行字
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = '加载中...'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// 出错——大图标 + 红色标题 + 副标题 + 重试按钮
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.exception,
    required this.onRetry,
  });
  final AppException exception;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(_iconFor(exception), color: color.error, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              exception.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color.error,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              exception.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AppException e) {
    return switch (e) {
      NetworkException() => Icons.wifi_off,
      TimeoutExceptionApp() => Icons.timer_off,
      HttpException() => Icons.error_outline,
      ParseException() => Icons.broken_image,
    };
  }
}

/// 空数据——非报错色；不显示"错误"字样；无重试按钮
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title = '当前没有开放的窗口',
    this.subtitle = '等下再来看看？或者联系工作人员',
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_off, color: color.primary, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
