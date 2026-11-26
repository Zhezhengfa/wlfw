/// 我的号码——窗口详情页。
///
/// 大字展示：当前号码 + 窗口名；LinearProgressIndicator 显示排队进度。
/// 空态兜底：未取号 → 显示"去看板取号"按钮跳转。
import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../models/window.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key, this.ticket, this.window});
  final Ticket? ticket;
  final Window? window;

  int get _ahead => ticket?.aheadCount ?? 0;
  int get _progress {
    // 估算：总等待 = ahead + 1（自己），进度 = 叫号到自己还有多远
    if (_ahead == 0) return 100;
    return ((_ahead > 0 ? 1 : 0) / (_ahead + 1) * 100).round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final hasTicket = ticket != null && window != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('我的号码'),
      ),
      body: hasTicket ? _buildDetail(context) : _buildEmpty(context),
    );
  }

  Widget _buildDetail(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 大字号码卡
        Card.filled(
          color: color.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Text(
                  '我的号码',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  ticket!.ticketNo,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w400,
                    color: color.primary,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  window!.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '前面还有 $_ahead 位',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$_progress%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _progress / 100,
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 详细信息列表（surfaceContainer 背景，Divider 分隔）
        Container(
          decoration: BoxDecoration(
            color: color.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _infoRow(context, label: '当前叫号', value: window!.currentNumber),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _infoRow(context, label: '前面等待', value: '$_ahead 人'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _infoRow(context, label: '预计等待', value: '约 ${window!.estimatedMin} 分钟'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _infoRow(context, label: '取号时间', value: ticket!.issuedAt),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 放弃排队按钮
        OutlinedButton.icon(
          onPressed: () {
            // TODO: 调用 cancelTicket 接口
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('放弃排队'),
        ),
        const SizedBox(height: 16),

        // 底部提示（合规：票号只保存在本机）
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '号码只保存在本机；App 打开时自动刷新叫号状态；后台排队不中断。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
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
              child: Icon(Icons.confirmation_num_outlined, color: color.primary, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              '还没有取号',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '去叫号看板选一个窗口取号吧',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
