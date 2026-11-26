/// 本地缓存服务——"先旧后新三步走"的实现。
///
/// ```
/// Step 1 冷启动读缓存 → 立刻渲染（哪怕是旧的）
/// Step 2 后台发 HTTP 请求
/// Step 3 请求成功 → 覆盖缓存 + 刷新 UI
///         请求失败 → 缓存继续顶住 + 离线 banner 标注
/// ```
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/window.dart';

class CacheService {
  CacheService._();
  static CacheService? _instance;
  static Future<CacheService> get instance async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = CacheService._().._prefs = prefs;
    return _instance!;
  }

  late final SharedPreferences _prefs;

  static const String _keyWindows = 'cache_windows';
  static const String _keyWindowsTs = 'cache_windows_ts';

  /// 读缓存，返回 null 表示还没缓存过
  List<Window>? readWindows() {
    final raw = _prefs.getString(_keyWindows);
    if (raw == null) return null;
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Window.fromJsonSafe(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      // 缓存损坏当没缓存过处理，不让 UI 崩
      return null;
    }
  }

  /// 写缓存 + 更新时间戳
  Future<void> writeWindows(List<Window> windows) async {
    final json = jsonEncode(windows.map((w) => w.toJson()).toList());
    await _prefs.setString(_keyWindows, json);
    await _prefs.setInt(_keyWindowsTs, _nowSeconds());
  }

  /// 缓存是否过期（超过 [AppFlags.cacheTtlSeconds]）
  bool get isExpired {
    final ts = _prefs.getInt(_keyWindowsTs) ?? 0;
    return _nowSeconds() - ts > AppFlags.cacheTtlSeconds;
  }

  int _nowSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> clear() async {
    await _prefs.remove(_keyWindows);
    await _prefs.remove(_keyWindowsTs);
  }
}
