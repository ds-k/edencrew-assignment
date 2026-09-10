# assets/mock

Naver 공개 endpoint의 실제 응답 샘플. 파싱 로직을 네트워크 없이 맞추고, `test/`의 픽스처로도 재사용한다.
수집일: 2026-09-11.

| 파일 | endpoint | 비고 |
| --- | --- | --- |
| `search_autocomplete.json` | `ac.stock.naver.com/ac?q=삼성` | 전부 국내 코스피 종목 (happy path) |
| `search_autocomplete_mixed.json` | `ac.stock.naver.com/ac?q=애플` | 필터 검증용 — 해외 종목(USA/JPN), 6자리 아닌 코드(`164A`, `2788`) 포함 |
| `realtime_quote.json` | `polling.finance.naver.com/api/realtime?query=SERVICE_ITEM:005930,000660,035720,247540` | 4종목 일괄 조회. **charset=EUC-KR** (`nm` 필드 한글이 깨져 있음 — 앱은 `nm` 미사용) |
| `stock_metadata.json` | `stock.naver.com/api/securityFe/api/fchart/domestic/stock/005930` | UTF-8. `symbolCode` / `stockName` / `stockExchangeNameKor` 사용 |
| `daily_price.html` | `finance.naver.com/item/sise_day.naver?code=005930&page=1` | **charset=EUC-KR**, HTML. 10거래일/페이지, 하단 네비에 `page=756`(lastPage) |

## 주의

- `realtime_quote.json`, `daily_price.html` 은 EUC-KR 로 저장되어 있다. UTF-8 로 그대로 디코딩하면 한글이 깨진다.
- 시세는 수집 시점 값이라 실행 시점과 다르다. 값이 아니라 **형식**을 맞추는 용도다.
