/// 我的——个人中心页。
///
/// 区块顺序：当前号码卡 → 设置组（实时连接 + 缓存 + 清除）→ 历史记录 → 数据来源与合规 → 关于信息。
///
/// **合规必查项**：
/// - 无手机号/位置等个人信息字段
/// - "数据来源"区块写明数据来自课堂统一数据集
/// - "票号存储"区块注明"仅保存在本机"
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../repository/board_repository.dart';
import '../services/ws_service.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // 当前号码卡（占位：实际应读取本地票号）
          Card.filled(
            color: color.surfaceContainerHigh,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前号码', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('—', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: color.primary)),
                      const SizedBox(width: 8),
                      Text('暂无取号', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _groupTitle(context, '设置'),
          _buildSettingsGroup(context),

          const SizedBox(height: 24),
          _groupTitle(context, '历史记录'),
          _buildHistoryGroup(context),

          const SizedBox(height: 24),
          _groupTitle(context, '数据来源与合规'),
          _buildComplianceGroup(context),
          _complianceNote(context),

          const SizedBox(height: 24),
          _groupTitle(context, '关于'),
          _buildAboutGroup(context),
        ],
      ),
    );
  }

  Widget _groupTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  Widget _buildSettingsGroup(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 实时连接状态
          ValueListenableBuilder<WsConnectionState>(
            valueListenable: WsService.instance.state,
            builder: (_, state, __) => ListTile(
              leading: const Icon(Icons.signal_cellular_alt),
              title: const Text('实时连接'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: switch (state) {
                        WsConnectionState.connected => Colors.green,
                        WsConnectionState.connecting => Colors.orange,
                        WsConnectionState.disconnected => color.error,
                      },
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    switch (state) {
                      WsConnectionState.connected => '已连接',
                      WsConnectionState.connecting => '重连中',
                      WsConnectionState.disconnected => '已断开',
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('本地缓存'),
            trailing: Text('2.3 KB · 2 小时前更新',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('清除缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await BoardRepository.instance.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存已清除')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryGroup(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text('暂无历史记录', style: TextStyle(color: Color(0xFF49454F))),
      ),
    );
  }

  Widget _buildComplianceGroup(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('数据来源'),
            trailing: Text('课程统一数据集',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('票号存储'),
            trailing: Text('仅保存在本机',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('课堂接口'),
            trailing: Text(AppFlags.useMock ? '本地 mock' : '已接入',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _complianceNote(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 16, 8),
      child: Text(
        '本应用仅用于课程原型练习，不采集手机号、位置等个人信息；不申请通讯录、相册、定位权限。',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
      ),
    );
  }

  Widget _buildAboutGroup(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('版本信息'),
            trailing: Text('v0.1.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('课程'),
            trailing: Text('第 11 课 · 网络访问与异步交互',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
