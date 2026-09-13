import 'package:edencrew_assignment_starter/core/network/naver_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('naverGet', () {
    test('브라우저처럼 보이는 User-Agent를 붙여서 요청한다', () async {
      // http 패키지 기본 User-Agent(Dart/...)로 요청하면 finance.naver.com이
      // 실제 데이터 대신 "페이지를 찾을 수 없습니다" 안내 페이지를 200 OK로
      // 내려준다 — 상태코드 검사를 통과해버려 빈 결과로 조용히 실패한다.
      String? sentUserAgent;
      final client = MockClient((request) async {
        sentUserAgent = request.headers['user-agent'];
        return http.Response('ok', 200);
      });

      await naverGet(client, Uri.parse('https://example.com'));

      expect(sentUserAgent, isNotNull);
      expect(sentUserAgent, isNot(contains('Dart')));
    });

    test('200이 아니면 예외를 던진다', () async {
      final client = MockClient((request) async => http.Response('blocked', 503));

      await expectLater(
        () => naverGet(client, Uri.parse('https://example.com')),
        throwsA(isA<NaverHttpException>()),
      );
    });
  });
}
