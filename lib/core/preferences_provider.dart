import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

/// `main()`에서 `SharedPreferences.getInstance()`를 미리 로드한 뒤 override해서 쓴다.
/// favorites/정렬 기준처럼 로컬 저장이 필요한 provider가 동기 `build()`를 유지하면서도
/// (화면들이 `AsyncValue`로 바뀌지 않도록) 값을 읽고 쓸 수 있게 하는 배선용 provider.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('main()에서 ProviderScope(overrides: [...])로 주입해야 함');
}
