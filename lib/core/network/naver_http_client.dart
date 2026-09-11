import 'package:http/http.dart' as http;

/// Naver 응답이 아닐 때(차단/에러 페이지 등) 던지는 예외.
///
/// 상태코드를 확인하지 않으면 예를 들어 일별 시세가 429/5xx 에러 페이지를
/// `table.type2`가 없는 "정상적인 빈 1페이지"로 잘못 해석해 캐시에 영구히
/// 박아버릴 수 있다. 4개 datasource가 전부 이 지점을 거치게 해서 한 곳에서 막는다.
class NaverHttpException implements Exception {
  NaverHttpException(this.statusCode, this.uri);

  final int statusCode;
  final Uri uri;

  @override
  String toString() => 'NaverHttpException($statusCode, $uri)';
}

/// 4개 datasource가 공유하는 GET 실행 지점. `docs/NAVER_API.md`가 경고하는
/// "호출이 잦으면 응답이 느려지거나 차단될 수 있다" 상황에서, 상태코드가
/// 200이 아니면 파싱을 시도하지 않고 예외로 던진다.
Future<http.Response> naverGet(http.Client client, Uri uri) async {
  final response = await client.get(uri);
  if (response.statusCode != 200) {
    throw NaverHttpException(response.statusCode, uri);
  }
  return response;
}
