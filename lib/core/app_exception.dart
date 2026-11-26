/// 错误三分类——课程必考点：页面层文案统一归口，不写 try/catch。
///
/// | 来源              | 类型                  | 文案                     |
/// |-------------------|-----------------------|--------------------------|
/// | SocketException   | [NetworkException]    | 请检查网络连接           |
/// | TimeoutException  | [TimeoutExceptionApp] | 请求超时，请稍后再试     |
/// | HTTP 非 2xx       | [HttpException]       | 服务异常：HTTP xxx       |
/// | JSON 解析失败     | [ParseException]      | 数据格式异常             |
import 'constants.dart';

sealed class AppException implements Exception {
  final String title;
  final String subtitle;
  const AppException({required this.title, required this.subtitle});

  @override
  String toString() => '$title — $subtitle';
}

class NetworkException extends AppException {
  const NetworkException()
      : super(
          title: '请检查网络连接',
          subtitle: '移动数据/Wi-Fi 似乎没连上，或者网络被墙拦住了',
        );
}

class TimeoutExceptionApp extends AppException {
  const TimeoutExceptionApp()
      : super(
          title: '请求超时，请稍后再试',
          subtitle: '${AppFlags.timeoutSeconds} 秒内没收到响应，可能是对方慢了',
        );
}

class HttpException extends AppException {
  final int statusCode;
  HttpException(this.statusCode)
      : super(
          title: '服务异常：HTTP $statusCode',
          subtitle: switch (statusCode) {
            400 => '请求参数有问题',
            401 => '需要登录才能访问',
            404 => '接口不存在',
            500 => '服务端炸了，等会儿再试试',
            _ => '服务器返回了异常状态码',
          },
        );
}

class ParseException extends AppException {
  const ParseException()
      : super(title: '数据格式异常', subtitle: 'JSON 结构和预期对不上');
}
