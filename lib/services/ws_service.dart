/// WebSocket 服务——连接 / 监听 / 心跳 / 重连。
///
/// 课堂必考点：
/// - 断开后**不清空 UI**——保留最后一次快照，整体降对比度 + 顶部离线 banner
/// - 指数退避重连：1s → 2s → 4s → 8s → 上限 30s
/// - 重连成功后**主动拉一次 HTTP 快照补齐**（避免推送期间漏消息）
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';

// 方便内部使用 AppConstants / AppFlags / WsConnectionState 等符号
export '../core/constants.dart';

enum WsConnectionState { connected, connecting, disconnected }

/// 推送事件类型——只关心 window update，其他忽略。
class WsEvent {
  final String type; // 'window.update'
  final Map<String, dynamic> payload;
  const WsEvent({required this.type, required this.payload});
}

class WsService {
  WsService._();
  static WsService? _instance;
  static WsService get instance => _instance ??= WsService._();

  WebSocket? _ws;
  Timer? _heartbeat;
  Timer? _reconnect;
  int _retryDelay = 1;
  bool _manualClose = false;

  /// 当前连接状态（UI 监听这个）
  final ValueNotifier<WsConnectionState> state =
      ValueNotifier(WsConnectionState.disconnected);

  /// 推送事件流——Repository 订阅，只 patch 单行，不整页重建
  final StreamController<WsEvent> _events = StreamController.broadcast();
  Stream<WsEvent> get events => _events.stream;

  int _retryCount = 0;
  int get retryCount => _retryCount;

  Future<void> connect() async {
    _manualClose = false;
    await _open();
  }

  void disconnect() {
    _manualClose = true;
    _reconnect?.cancel();
    _heartbeat?.cancel();
    _ws?.close();
    state.value = WsConnectionState.disconnected;
  }

  Future<void> _open() async {
    state.value = WsConnectionState.connecting;
    try {
      _ws = await WebSocket.connect(ApiConstants.wsUrl)
          .timeout(const Duration(seconds: 5));
      state.value = WsConnectionState.connected;
      _retryDelay = 1;
      _retryCount = 0;
      _startHeartbeat();
      _listen();
    } catch (_) {
      // 连不上（网络不通 / mock 模式）→ 标记 disconnected，让 Repository
      // 决定是否重连。mock 模式下这个状态会一直保持，UI 显示"已断开"。
      state.value = WsConnectionState.disconnected;
      if (!_manualClose) _scheduleReconnect();
    }
  }

  void _listen() {
    _ws!.listen(
      (raw) {
        try {
          final json = jsonDecode(raw as String) as Map<String, dynamic>;
          final event = WsEvent(
            type: json['type'] as String? ?? '',
            payload: json['payload'] as Map<String, dynamic>? ?? {},
          );
          _events.add(event);
        } catch (_) {
          // 一条脏消息直接丢弃，不影响其他消息
        }
      },
      onDone: () => _onClose(),
      onError: (_) => _onClose(),
    );
  }

  void _onClose() {
    _heartbeat?.cancel();
    state.value = WsConnectionState.disconnected;
    if (!_manualClose) _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_ws != null && state.value == WsConnectionState.connected) {
        try {
          _ws!.add('_ping');
        } catch (_) {
          _onClose();
        }
      }
    });
  }

  /// 指数退避重连
  void _scheduleReconnect() {
    _reconnect?.cancel();
    _retryCount++;
    state.value = WsConnectionState.connecting;
    _reconnect = Timer(Duration(seconds: _retryDelay), () {
      _retryDelay = (_retryDelay * 2).clamp(1, 30);
      _open();
    });
  }
}
