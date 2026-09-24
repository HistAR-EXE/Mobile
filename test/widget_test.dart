import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:histar_mobile/core/config/env.dart';

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: '''
API_BASE_URL=https://example.com
MEDIA_BASE_URL=https://media.example.com
WEB_APP_URL=https://web.example.com
''');
  });

  test('resolveMedia keeps absolute URLs', () {
    expect(
      AppEnv.resolveMedia('https://cdn.example/a.jpg'),
      'https://cdn.example/a.jpg',
    );
  });

  test('resolveMedia prefixes relative paths', () {
    expect(
      AppEnv.resolveMedia('/media/cu-chi/x.jpg'),
      'https://media.example.com/media/cu-chi/x.jpg',
    );
  });
}
