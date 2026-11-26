/// 叫号看板——首页列表页。
///
/// **双通道协同**（课程必考点）：
/// - HTTP 快照决定骨架视图 → [FutureBuilder] 三态
/// - WebSocket 推送只 patch 单行 → [ValueListenableBuilder] 监听 repository.windowsNotifier
/// - 两通道**同页协同、不冲突**：HTTP 负责首屏渲染，推送负责局部更新
///
/// **实时断开的处理**：
/// - 不清空列表 → 保留最后一次快照
/// - 整体降对比度 → 用 ColorFiltered 套一层 grayscale + opacity
/// - 顶部贴离线 banner
import 'package:flutter/material.dart';

import '../core/app_exception.dart';
import '../models/window.dart';
import '../repository/board_repository.dart';
import '../services/ws_service.dart';
import '../widgets/offline_banner.dart';
import '../widgets/state_views.dart';
import '../widgets/window_tile.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final BoardRepository _repo = BoardRepository.instance;
  late Future<List<Window>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchWindows();
    _repo.init(); // 绑定缓存 + WebSocket
    WsService.instance.connect();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = _repo.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = BoardRepository.instance;
    final ws = WsService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('叫号看板')),
      body: Stack(
        children: [
          // 主内容：FutureBuilder 决定骨架，ValueListenableBuilder 接收推送
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: FutureBuilder<List<Window>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const LoadingView();
                }
                if (snap.hasError && snap.error is AppException) {
                  return ErrorView(
                    exception: snap.error as AppException,
                    onRetry: _onRefresh,
                  );
                }
                final windows = repo.windowsNotifier.value;
                if (windows.isEmpty) {
                  return const EmptyView();
                }
                return _buildList(context, windows);
              },
            ),
          ),
          // 离线 banner（绝对定位顶部）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<WsConnectionState>(
              valueListenable: ws.state,
              builder: (_, state, __) => OfflineBanner(
                state: state,
                retryCount: ws.retryCount,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Window> windows) {
    // ValueListenableBuilder 监听 repository.windowsNotifier
    // → 推送到达时只重建这一段，不重走 FutureBuilder
    return ValueListenableBuilder<List<Window>>(
      valueListenable: BoardRepository.instance.windowsNotifier,
      builder: (ctx, liveList, __) {
        // 实时断开时整体降对比度
        final wsState = WsService.instance.state.value;
        final grayscale = wsState == WsConnectionState.disconnected;
        final list = liveList.isEmpty ? windows : liveList;

        Widget child = ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: list.length,
          itemBuilder: (_, i) => WindowTile(window: list[i]),
        );

        if (grayscale) {
          child = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.33, 0.33, 0.33, 0, 0,
              0.33, 0.33, 0.33, 0, 0,
              0.33, 0.33, 0.33, 0, 0,
              0,    0,    0,    0.55, 0,
            ]),
            child: child,
          );
        }
        return child;
      },
    );
  }
}
