/// 接口地址集中管理，全局搜索 "http" 只出现在此文件。
/// 便于合规核查：只访问课堂发布端点，不硬编码分散在各处。
class ApiConstants {
  static const String baseUrl = 'http://class-api.example.com';
  static const String wsUrl = 'ws://class-api.example.com/ws';

  static const String listWindows = '$baseUrl/api/windows';
  static const String listTickets = '$baseUrl/api/tickets';
  static const String issueTicket = '$baseUrl/api/tickets/issue';
  static const String cancelTicket = '$baseUrl/api/tickets/cancel';
}

/// 是否使用本地 mock 数据。
/// 课堂原型阶段默认 true，换真实接口时改 false。
class AppFlags {
  static const bool useMock = true;

  /// mock 文件名（对应 assets/mock/ 下的文件）
  static const String mockWindowsAsset = 'assets/mock/windows.json';
  static const String mockEmptyAsset = 'assets/mock/windows_empty.json';

  /// 超时时间（秒）
  static const int timeoutSeconds = 8;

  /// 缓存过期时间（秒），超过此时间触发"先旧后新"里的后台刷新
  static const int cacheTtlSeconds = 60;
}

/// 接口字段名常量，集中管理防拼写错。
class ApiFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String currentNumber = 'currentNumber';
  static const String waitingCount = 'waitingCount';
  static const String updatedAt = 'updatedAt';

  static const String ticketNo = 'ticketNo';
  static const String windowId = 'windowId';
  static const String aheadCount = 'aheadCount';
  static const String issuedAt = 'issuedAt';
}
