import '../core/constants.dart';

/// 票号对象——取号后产生，绑定到某个窗口。
class Ticket {
  const Ticket({
    required this.ticketNo,
    required this.windowId,
    required this.aheadCount,
    required this.issuedAt,
  });

  final String ticketNo;
  final String windowId;
  final int aheadCount;
  final String issuedAt;

  factory Ticket.fromJsonSafe(Map<String, dynamic> json) {
    return Ticket(
      ticketNo: json[ApiFields.ticketNo] as String? ?? '--',
      windowId: json[ApiFields.windowId] as String? ?? '',
      aheadCount: (json[ApiFields.aheadCount] as num?)?.toInt() ?? 0,
      issuedAt: json[ApiFields.issuedAt] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        ApiFields.ticketNo: ticketNo,
        ApiFields.windowId: windowId,
        ApiFields.aheadCount: aheadCount,
        ApiFields.issuedAt: issuedAt,
      };
}
