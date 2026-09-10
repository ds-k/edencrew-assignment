import 'dart:convert';
import 'dart:io';

import 'package:edencrew_assignment_starter/data/dto/json_coerce.dart';
import 'package:edencrew_assignment_starter/data/dto/realtime_quote_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/search_suggestion_dto.dart';
import 'package:edencrew_assignment_starter/data/dto/stock_metadata_dto.dart';
import 'package:flutter_test/flutter_test.dart';

/// `assets/mock/` 의 실제 응답 샘플을 읽어 JSON 으로 파싱한다.
///
/// realtime 응답은 EUC-KR 이라 `nm` 필드 바이트가 UTF-8 로 유효하지 않다.
/// 테스트는 숫자 필드만 검증하므로 malformed 바이트는 치환 문자로 흘려보낸다.
Map<String, dynamic> _loadJson(String name) {
  final List<int> bytes = File('assets/mock/$name').readAsBytesSync();
  return jsonDecode(utf8.decode(bytes, allowMalformed: true))
      as Map<String, dynamic>;
}

void main() {
  group('json_coerce', () {
    test('asInt 는 쉼표 섞인 숫자문자열과 빈 값을 처리한다', () {
      expect(asInt(1234), 1234);
      expect(asInt('1,234'), 1234);
      expect(asInt('  5,846,278,608 '), 5846278608);
      expect(asInt(''), isNull);
      expect(asInt(null), isNull);
      expect(asInt('N/A'), isNull);
    });

    test('asDouble / asString / asBool', () {
      expect(asDouble('0.19'), closeTo(0.19, 1e-9));
      expect(asDouble('1,063.5'), closeTo(1063.5, 1e-9));
      expect(asString('  삼성전자  '), '삼성전자');
      expect(asString(''), isNull);
      expect(asString(null), isNull);
      expect(asBool('true'), isTrue);
      expect(asBool(false), isFalse);
      expect(asBool(1), isTrue);
    });
  });

  group('SearchAutocompleteDto', () {
    test('국내 종목 응답(q=삼성)을 파싱한다', () {
      final SearchAutocompleteDto dto =
          SearchAutocompleteDto.fromJson(_loadJson('search_autocomplete.json'));

      expect(dto.query, '삼성');
      expect(dto.items, isNotEmpty);

      final SearchSuggestionDto first = dto.items.first;
      expect(first.code, '005930');
      expect(first.name, '삼성전자');
      expect(first.typeCode, 'KOSPI');
      expect(first.typeName, '코스피');
      expect(first.nationCode, 'KOR');
      expect(first.category, 'stock');
    });

    test('해외 종목/비정형 코드도 원형 그대로 담는다(q=애플)', () {
      final SearchAutocompleteDto dto = SearchAutocompleteDto.fromJson(
        _loadJson('search_autocomplete_mixed.json'),
      );

      final SearchSuggestionDto apple =
          dto.items.firstWhere((SearchSuggestionDto i) => i.code == 'AAPL');
      expect(apple.nationCode, 'USA');
      expect(apple.category, 'stock');

      // 6자리 숫자가 아닌 코드도 DTO 단계에서는 걸러내지 않는다(필터는 repository).
      expect(
        dto.items.any((SearchSuggestionDto i) => i.code == '164A'),
        isTrue,
      );
      expect(
        dto.items.every((SearchSuggestionDto i) => i.nationCode != 'KOR'),
        isTrue,
      );
    });
  });

  group('RealtimeQuoteDto', () {
    test('한 응답의 여러 종목을 평탄화한다', () {
      final List<RealtimeQuoteDto> quotes =
          RealtimeQuoteDto.listFromResponse(_loadJson('realtime_quote.json'));

      expect(
        quotes.map((RealtimeQuoteDto q) => q.symbol),
        <String>['005930', '000660', '035720', '247540'],
      );

      final RealtimeQuoteDto samsung = quotes.first;
      expect(samsung.currentPrice, 269000);
      expect(samsung.previousClose, 269000);
      expect(samsung.open, 269000);
      expect(samsung.high, 270500);
      expect(samsung.low, 263500);
      expect(samsung.accumulatedVolume, 21010910);
      // 32비트를 넘는 상장 주식 수를 손실 없이 담는다.
      expect(samsung.listedShareCount, 5846278608);
      expect(samsung.listedShareCount! > 4294967295, isTrue);
    });

    test('구조가 어긋난 응답은 빈 리스트', () {
      expect(RealtimeQuoteDto.listFromResponse(<String, dynamic>{}), isEmpty);
      expect(
        RealtimeQuoteDto.listFromResponse(<String, dynamic>{'result': 42}),
        isEmpty,
      );
    });
  });

  group('StockMetadataDto', () {
    test('메타데이터 응답을 파싱한다', () {
      final StockMetadataDto dto =
          StockMetadataDto.fromJson(_loadJson('stock_metadata.json'));

      expect(dto.symbolCode, '005930');
      expect(dto.stockName, '삼성전자');
      expect(dto.exchangeName, 'KOSPI');
      expect(dto.exchangeNameKor, '코스피');
      expect(dto.nationType, 'KOR');
      expect(dto.isDelisting, isFalse);
    });
  });
}
