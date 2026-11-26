/// 离线/重连提示条——绝对定位在内容顶部。
///
/// **实时断开时不清空列表**：界面保留最后一次快照 + 降对比度，
/// 顶部贴一条这个 banner，标注"实时更新中断，正在重连"。
import 'package:flutter/material.dart';

import '../services/ws_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.state, this.retryCount = 0});
  final WsConnectionState state;
  final int retryCount;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final (icon, text, bg) = switch (state) {
      WsConnectionState.disconnected => (
          Icons.cloud_off_rounded,
          '实时更新已断开，显示的是最后一次快照',
          color.errorContainer,
        ),
      WsConnectionState.connecting => (
          Icons.sync_rounded,
          '实时更新中断，正在重连${retryCount > 0 ? '（第 $retryCount 次尝试）' : '...'}',
          color.tertiaryContainer,
        ),
      WsConnectionState.connected => (
          null,
          '',
          color.tertiaryContainer,
        ),
    };

    if (state == WsConnectionState.connected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
