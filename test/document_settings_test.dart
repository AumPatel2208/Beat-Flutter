import 'package:flutter_test/flutter_test.dart';

import 'package:beat_app/document/document_settings.dart';

void main() {
  group('DocumentSettings', () {
    test('parses settings from file content', () {
      const content = '''Title: Test
Author: Test Author

FADE IN:

INT. HOUSE - DAY

/* If you're seeing this, you can remove the following stuff - BEAT:
{"Caret Position":42,"Page Size":"A4"}
END_BEAT*/''';

      final result = DocumentSettings.parseFromString(content);
      
      expect(result.settings.caretPosition, 42);
      expect(result.settings.pageSize, 'A4');
    });

    test('handles file without settings block', () {
      const content = '''Title: Test

FADE IN:

INT. HOUSE - DAY
''';

      final result = DocumentSettings.parseFromString(content);
      
      expect(result.settings.caretPosition, 0);
      expect(result.contentRange.start, 0);
      expect(result.contentRange.end, content.length);
    });

    test('generates settings string', () {
      final settings = DocumentSettings();
      settings.caretPosition = 100;
      settings.pageSize = 'US Letter';
      
      final string = settings.toSettingsString();
      
      expect(string.contains('BEAT:'), true);
      expect(string.contains('END_BEAT'), true);
      expect(string.contains('"Caret Position":100'), true);
    });

    test('boolean settings work correctly', () {
      final settings = DocumentSettings();
      
      settings.setBool('test', true);
      expect(settings.getBool('test'), true);
      
      settings.setBool('test', false);
      expect(settings.getBool('test'), false);
    });

    test('integer settings work correctly', () {
      final settings = DocumentSettings();
      
      settings.setInt('count', 42);
      expect(settings.getInt('count'), 42);
    });

    test('string settings work correctly', () {
      final settings = DocumentSettings();
      
      settings.setString('name', 'Test');
      expect(settings.getString('name'), 'Test');
    });
  });
}
