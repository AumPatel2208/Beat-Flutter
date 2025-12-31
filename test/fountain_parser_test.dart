import 'package:flutter_test/flutter_test.dart';

import 'package:beat_app/fountain_parser/fountain_parser.dart';

void main() {
  group('FountainParser', () {
    test('parses empty document', () {
      final parser = ContinuousFountainParser();
      parser.parseText('');
      
      expect(parser.lines.length, 1);
      expect(parser.lines[0].type, LineType.empty);
    });

    test('parses scene heading with INT.', () {
      final parser = ContinuousFountainParser();
      parser.parseText('INT. HOUSE - DAY');
      
      expect(parser.lines.length, 1);
      expect(parser.lines[0].type, LineType.heading);
      expect(parser.lines[0].string, 'INT. HOUSE - DAY');
    });

    test('parses scene heading with EXT.', () {
      final parser = ContinuousFountainParser();
      parser.parseText('EXT. PARK - NIGHT');
      
      expect(parser.lines.length, 1);
      expect(parser.lines[0].type, LineType.heading);
    });

    test('parses forced scene heading', () {
      final parser = ContinuousFountainParser();
      parser.parseText('.FLASHBACK');
      
      expect(parser.lines.length, 1);
      expect(parser.lines[0].type, LineType.heading);
    });

    test('parses action line', () {
      final parser = ContinuousFountainParser();
      parser.parseText('The door opens slowly.');
      
      expect(parser.lines.length, 1);
      expect(parser.lines[0].type, LineType.action);
    });

    test('parses character cue and dialogue', () {
      final parser = ContinuousFountainParser();
      parser.parseText('''
JOHN
Hello, world!
''');
      
      expect(parser.lines.length, 3);
      expect(parser.lines[0].type, LineType.empty);
      expect(parser.lines[1].type, LineType.character);
      expect(parser.lines[1].string, 'JOHN');
      expect(parser.lines[2].type, LineType.dialogue);
    });

    test('parses parenthetical', () {
      final parser = ContinuousFountainParser();
      parser.parseText('''
JOHN
(whispering)
Hello, world!
''');
      
      expect(parser.lines[2].type, LineType.parenthetical);
      expect(parser.lines[3].type, LineType.dialogue);
    });

    test('parses transition', () {
      final parser = ContinuousFountainParser();
      parser.parseText('CUT TO:');
      
      expect(parser.lines[0].type, LineType.transitionLine);
    });

    test('parses forced transition', () {
      final parser = ContinuousFountainParser();
      parser.parseText('>FADE TO BLACK');
      
      expect(parser.lines[0].type, LineType.transitionLine);
    });

    test('parses centered text', () {
      final parser = ContinuousFountainParser();
      parser.parseText('>THE END<');
      
      expect(parser.lines[0].type, LineType.centered);
    });

    test('parses lyrics', () {
      final parser = ContinuousFountainParser();
      parser.parseText('~Happy birthday to you');
      
      expect(parser.lines[0].type, LineType.lyrics);
    });

    test('parses page break', () {
      final parser = ContinuousFountainParser();
      parser.parseText('===');
      
      expect(parser.lines[0].type, LineType.pageBreak);
    });

    test('parses section', () {
      final parser = ContinuousFountainParser();
      parser.parseText('# Act One');
      
      expect(parser.lines[0].type, LineType.section);
    });

    test('parses synopsis', () {
      final parser = ContinuousFountainParser();
      parser.parseText('= This is a synopsis');
      
      expect(parser.lines[0].type, LineType.synopsis);
    });

    test('parses title page', () {
      final parser = ContinuousFountainParser();
      parser.parseText('''Title: My Screenplay
Author: John Doe

FADE IN:''');
      
      expect(parser.lines[0].type, LineType.titlePageTitle);
      expect(parser.lines[1].type, LineType.titlePageAuthor);
      expect(parser.titlePage.containsKey('title'), true);
      expect(parser.titlePage.containsKey('author'), true);
    });

    test('extracts character name correctly', () {
      final parser = ContinuousFountainParser();
      parser.parseText('''
JOHN (V.O.)
Hello!
''');
      
      final characterNames = parser.characterNames;
      expect(characterNames.contains('JOHN'), true);
    });

    test('parses bold formatting', () {
      final parser = ContinuousFountainParser();
      parser.parseText('This is **bold** text.');
      
      expect(parser.lines[0].boldRanges.length, 1);
    });

    test('parses italic formatting', () {
      final parser = ContinuousFountainParser();
      parser.parseText('This is *italic* text.');
      
      expect(parser.lines[0].italicRanges.length, 1);
    });

    test('parses underline formatting', () {
      final parser = ContinuousFountainParser();
      parser.parseText('This is _underlined_ text.');
      
      expect(parser.lines[0].underlineRanges.length, 1);
    });

    test('parses notes', () {
      final parser = ContinuousFountainParser();
      parser.parseText('Some text [[this is a note]] more text.');
      
      expect(parser.lines[0].noteRanges.length, 1);
    });

    test('parses dual dialogue marker', () {
      final parser = ContinuousFountainParser();
      parser.parseText('''
JOHN
Hello!

JANE ^
Hi there!
''');
      
      // Find the JANE line
      final janeLine = parser.lines.firstWhere(
        (l) => l.string.trim().startsWith('JANE'),
        orElse: () => Line(string: ''),
      );
      expect(janeLine.type, LineType.dualDialogueCharacter);
    });
  });

  group('Line', () {
    test('characterName extracts name without extension', () {
      final line = Line(string: 'JOHN (V.O.)', type: LineType.character);
      expect(line.characterName, 'JOHN');
    });

    test('characterName handles dual dialogue marker', () {
      final line = Line(string: 'JANE ^', type: LineType.character);
      expect(line.characterName, 'JANE');
    });

    test('characterName handles forced character', () {
      final line = Line(string: '@McCloud', type: LineType.character);
      expect(line.characterName, 'MCCLOUD');
    });

    test('stripFormatting removes bold markers', () {
      final line = Line(string: 'This is **bold** text.', type: LineType.action);
      expect(line.stripFormatting, 'This is bold text.');
    });
  });
}
