/// 看板数据仓库——HTTP 快照 + WebSocket 推送的"汇合点"。
///
/// 关键设计：
/// - [FutureBuilder] 走 [fetchWindows] → 决定页面骨架（loading / error / empty / list）
/// - 推送只 patch [windowsNotifier] 里的某一行 → 不整页 setState
/// - 缓存"先旧后新"三步走在这里实现：先读缓存 set 一次，再发 HTTP 覆盖
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../core/constants.dart';
import '../models/window.dart';
import '../services/cache_service.dart';
import '../services/ws_service.dart';

class BoardRepository {
  BoardRepository._();
  static final BoardRepository instance = BoardRepository._();

  late final ApiClient _api = ApiClient(http.Client());
  CacheService? _cache;
  StreamSubscription<WsEvent>? _wsSub;

  /// 窗口列表——页面层监听这个，只 patch 单行变化
  final ValueNotifier<List<Window>> windowsNotifier =
      ValueNotifier(const <Window>[]);

  /// 初始化——绑定缓存 + WebSocket 监听
  Future<void> init() async {
    _cache = await CacheService.instance;
    _wsSub?.cancel();
    _wsSub = WsService.instance.events.listen(_onWsEvent);
  }

  /// Step 1: 读缓存（立刻渲染）+ 后台刷新 HTTP
  Future<List<Window>> fetchWindows() async {
    // 先返回缓存，让 UI 先有东西显示（缓存旧也比白屏好）
    final cached = _cache?.readWindows();
    if (cached != null && cached.isNotEmpty) {
      windowsNotifier.value = cached;
    }

    // 后台发请求——无论成功与否，缓存已经在顶 UI 了
    final fetched = await _tryFetchFromHttp();
    if (fetched != null) {
      windowsNotifier.value = fetched;
      await _cache?.writeWindows(fetched);
    }

    return windowsNotifier.value;
  }

  /// 主动刷新（下拉刷新触发）——跳过缓存直连 HTTP
  Future<List<Window>> refresh() async {
    final fetched = await _tryFetchFromHttp();
    if (fetched == null) {
      // 网络不通就把当前缓存抛出去让 UI 展示 + 离线 banner
      final cached = _cache?.readWindows();
      if (cached != null) windowsNotifier.value = cached;
      return windowsNotifier.value;
    }
    windowsNotifier.value = fetched;
    await _cache?.writeWindows(fetched);
    return fetched;
  }

  /// 清除本地缓存（Mine 页"清除缓存"按钮）
  Future<void> clearCache() async => await _cache?.clear();

  Future<List<Window>?> _tryFetchFromHttp() async {
    try {
      final list = await _api.getList<Window>(
        url: ApiConstants.listWindows,
        fromJson: Window.fromJsonSafe,
      );
      // 过滤掉 id 为空的脏数据（fromJsonSafe 给了空串，业务层丢弃）
      return list.where((w) => w.id.isNotEmpty).toList();
    } on AppException catch (_) {
      // 出错时返回 null，让调用方决定展示什么
      return null;
    }
  }

  /// WebSocket 推送 → 只 patch 单行
  void _onWsEvent(WsEvent event) {
    if (event.type != 'window.update') return;
    final updated = Window.fromJsonSafe(event.payload);
    if (updated.id.isEmpty) return; // 脏消息忽略

    final list = List<Window>.of(windowsNotifier.value);
    final idx = list.indexWhere((w) => w.id == updated.id);
    if (idx >= 0) {
      list[idx] = updated;
    } else {
      list.add(updated);
    }
    windowsNotifier.value = list;
  }

  void dispose() {
    _wsSub?.cancel();
    _api is http.Client ? (_api as dynamic).close() : null;
  }
}
