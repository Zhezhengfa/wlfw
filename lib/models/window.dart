import '../core/constants.dart';

/// 窗口对象——叫号看板每一行的数据来源。
///
/// [fromJsonSafe] 是核心：接口字段缺失时给默认值，
/// 一条脏消息不连累整页（课堂常考"字段兜底"考点）。
class Window {
  const Window({
    required this.id,
    required this.name,
    required this.currentNumber,
    required this.waitingCount,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String currentNumber;
  final int waitingCount;
  final int updatedAt;

  factory Window.fromJsonSafe(Map<String, dynamic> json) {
    final id = json[ApiFields.id] as String? ?? '';
    // id 空字符串 → list 层丢弃（业务约束：没 id 的窗口不显示）
    final name = json[ApiFields.name] as String? ?? '未命名窗口';
    final currentNumber =
        json[ApiFields.currentNumber] as String? ?? '未叫号';
    final waitingCount = (json[ApiFields.waitingCount] as num?)?.toInt() ?? 0;
    final updatedAt = (json[ApiFields.updatedAt] as num?)?.toInt() ?? 0;

    return Window(
      id: id,
      name: name,
      currentNumber: currentNumber,
      waitingCount: waitingCount,
      updatedAt: updatedAt,
    );
  }

  /// 预计等待分钟数 = 等待人数 × 2（每人约 2 分钟，纯估算）
  int get estimatedMin => waitingCount * 2;

  Map<String, dynamic> toJson() => {
        ApiFields.id: id,
        ApiFields.name: name,
        ApiFields.currentNumber: currentNumber,
        ApiFields.waitingCount: waitingCount,
        ApiFields.updatedAt: updatedAt,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Window &&
          id == other.id &&
          name == other.name &&
          currentNumber == other.currentNumber &&
          waitingCount == other.waitingCount &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, name, currentNumber, waitingCount, updatedAt);
}
