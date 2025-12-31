import 'line.dart';
import 'line_type.dart';

/// Continuous Fountain Parser
/// 
/// This parser is based on Beat's ContinuousFountainParser, which parses
/// Fountain screenplay format. It supports both continuous (live editing)
/// and static (one-time) parsing modes.
/// 
/// The parser does NOT use regex for line type detection, but instead
/// parses character-by-character for speed and accuracy.
class ContinuousFountainParser {
  /// All lines in the document
  List<Line> lines = [];

  /// Title page elements as key-value pairs
  Map<String, List<Line>> titlePage = {};

  /// Whether this parser is in static (non-continuous) mode
  final bool staticParser;

  /// Scene heading prefixes
  static const List<String> sceneHeadingPrefixes = [
    'INT.',
    'EXT.',
    'INT/EXT.',
    'EXT/INT.',
    'I/E.',
    'E/I.',
    'INT ',
    'EXT ',
    'INT/EXT ',
    'EXT/INT ',
  ];

  /// Transition suffixes
  static const List<String> transitionSuffixes = [
    'TO:',
    'TO BLACK.',
    'TO WHITE.',
  ];

  ContinuousFountainParser({this.staticParser = false});

  /// Parse the full text of a screenplay
  void parseText(String text) {
    lines.clear();
    titlePage.clear();

    if (text.isEmpty) {
      lines.add(Line(string: '', type: LineType.empty, position: 0));
      return;
    }

    // Split into lines preserving positions
    final rawLines = text.split('\n');
    int position = 0;

    for (int i = 0; i < rawLines.length; i++) {
      final rawLine = rawLines[i];
      final line = Line(
        string: rawLine,
        position: position,
      );
      lines.add(line);
      position += rawLine.length + 1; // +1 for newline
    }

    // Parse title page first
    _parseTitlePage();

    // Then parse each line's type
    for (int i = 0; i < lines.length; i++) {
      _parseLineType(i);
    }

    // Parse formatting for all lines
    for (final line in lines) {
      _parseFormatting(line);
    }
  }

  /// Parse a change in the document (for continuous/live parsing)
  void parseChangeInRange(int start, int length, String replacement) {
    // For MVP, we'll do a full reparse
    // TODO: Implement incremental parsing for performance
    final text = rawText;
    final newText = text.replaceRange(
      start,
      start + length,
      replacement,
    );
    parseText(newText);
  }

  /// Returns the full document as a single string
  String get rawText {
    return lines.map((l) => l.string).join('\n');
  }

  /// Returns the screenplay content ready for saving
  String get screenplayForSaving {
    final buffer = StringBuffer();
    for (int i = 0; i < lines.length; i++) {
      buffer.write(lines[i].string);
      if (i < lines.length - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  /// Get all scene headings
  List<Line> get sceneHeadings {
    return lines.where((l) => l.type == LineType.heading).toList();
  }

  /// Get all character cues
  List<Line> get characterCues {
    return lines.where((l) => l.type.isAnyCharacter).toList();
  }

  /// Get unique character names
  Set<String> get characterNames {
    return characterCues
        .map((l) => l.characterName)
        .where((n) => n != null && n.isNotEmpty)
        .cast<String>()
        .toSet();
  }

  /// Parse title page from the beginning of the document
  void _parseTitlePage() {
    if (lines.isEmpty) return;

    int i = 0;
    bool inTitlePage = false;
    String? currentKey;

    // Title page must start at the very beginning
    final firstLine = lines[0].string;
    if (!_isTitlePageKey(firstLine)) return;

    inTitlePage = true;

    while (i < lines.length && inTitlePage) {
      final line = lines[i];
      final trimmed = line.string.trim();

      // Empty line ends title page if we've seen content
      if (trimmed.isEmpty && currentKey != null) {
        // Check if next non-empty line is still title page
        int nextNonEmpty = i + 1;
        while (nextNonEmpty < lines.length &&
            lines[nextNonEmpty].string.trim().isEmpty) {
          nextNonEmpty++;
        }
        if (nextNonEmpty >= lines.length ||
            !_isTitlePageKey(lines[nextNonEmpty].string) &&
                !lines[nextNonEmpty].string.startsWith('   ') &&
                !lines[nextNonEmpty].string.startsWith('\t')) {
          inTitlePage = false;
          break;
        }
      }

      if (_isTitlePageKey(line.string)) {
        // This is a title page key line
        final colonIndex = line.string.indexOf(':');
        currentKey = line.string.substring(0, colonIndex).trim().toLowerCase();
        final value = line.string.substring(colonIndex + 1).trim();

        line.type = _titlePageTypeForKey(currentKey);
        titlePage[currentKey] = [line];

        if (value.isNotEmpty) {
          // Value is on the same line
        }
      } else if (currentKey != null &&
          (line.string.startsWith('   ') || line.string.startsWith('\t'))) {
        // Continuation of previous title page entry
        line.type = _titlePageTypeForKey(currentKey);
        titlePage[currentKey]?.add(line);
      } else if (trimmed.isEmpty) {
        line.type = LineType.empty;
      } else {
        // Not a title page line, we've exited title page
        inTitlePage = false;
        break;
      }

      i++;
    }
  }

  /// Check if a line is a title page key (e.g., "Title:", "Author:")
  bool _isTitlePageKey(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;

    final colonIndex = trimmed.indexOf(':');
    if (colonIndex <= 0) return false;

    // Key must be at the start of the line (no leading whitespace for keys)
    if (line.startsWith(' ') || line.startsWith('\t')) return false;

    final key = trimmed.substring(0, colonIndex).toLowerCase();
    return [
      'title',
      'author',
      'authors',
      'credit',
      'source',
      'contact',
      'draft date',
      'date',
      'notes',
      'copyright',
    ].contains(key);
  }

  /// Get the LineType for a title page key
  LineType _titlePageTypeForKey(String key) {
    switch (key) {
      case 'title':
        return LineType.titlePageTitle;
      case 'author':
      case 'authors':
        return LineType.titlePageAuthor;
      case 'credit':
        return LineType.titlePageCredit;
      case 'source':
        return LineType.titlePageSource;
      case 'contact':
        return LineType.titlePageContact;
      case 'draft date':
      case 'date':
        return LineType.titlePageDraftDate;
      default:
        return LineType.titlePageUnknown;
    }
  }

  /// Parse the type of a single line
  void _parseLineType(int index) {
    if (index < 0 || index >= lines.length) return;

    final line = lines[index];
    final trimmed = line.string.trim();

    // Skip if already parsed as title page
    if (line.type.isTitlePage) return;

    // Empty line
    if (trimmed.isEmpty) {
      line.type = LineType.empty;
      return;
    }

    // Get previous and next non-empty lines for context
    final prevLine = _previousNonEmptyLine(index);
    final nextLine = _nextNonEmptyLine(index);

    // Section (starts with #)
    if (trimmed.startsWith('#')) {
      line.type = LineType.section;
      return;
    }

    // Synopsis (starts with =, but not ===)
    if (trimmed.startsWith('=') && !trimmed.startsWith('===')) {
      line.type = LineType.synopsis;
      return;
    }

    // Page break (=== or more)
    if (RegExp(r'^={3,}\s*$').hasMatch(trimmed)) {
      line.type = LineType.pageBreak;
      return;
    }

    // Centered text (wrapped in > <)
    if (trimmed.startsWith('>') && trimmed.endsWith('<')) {
      line.type = LineType.centered;
      return;
    }

    // Forced scene heading (starts with .)
    if (trimmed.startsWith('.') && trimmed.length > 1 && trimmed[1] != '.') {
      line.type = LineType.heading;
      return;
    }

    // Scene heading (INT., EXT., etc.)
    final upperTrimmed = trimmed.toUpperCase();
    for (final prefix in sceneHeadingPrefixes) {
      if (upperTrimmed.startsWith(prefix)) {
        line.type = LineType.heading;
        return;
      }
    }

    // Forced character (starts with @)
    if (trimmed.startsWith('@')) {
      line.type = LineType.character;
      return;
    }

    // Transition (ends with TO: or forced with >)
    if (trimmed.startsWith('>') && !trimmed.endsWith('<')) {
      line.type = LineType.transitionLine;
      return;
    }
    for (final suffix in transitionSuffixes) {
      if (upperTrimmed.endsWith(suffix) && _isAllCaps(trimmed)) {
        line.type = LineType.transitionLine;
        return;
      }
    }

    // Lyrics (starts with ~)
    if (trimmed.startsWith('~')) {
      line.type = LineType.lyrics;
      return;
    }

    // Character cue detection
    // Must be: ALL CAPS, preceded by empty line, followed by non-empty line
    if (_isCharacterCue(index)) {
      // Check for dual dialogue marker
      if (trimmed.endsWith('^')) {
        line.type = LineType.dualDialogueCharacter;
      } else {
        line.type = LineType.character;
      }
      return;
    }

    // Parenthetical (line wrapped in parentheses after character/dialogue)
    if (trimmed.startsWith('(') && trimmed.endsWith(')')) {
      if (prevLine != null &&
          (prevLine.type.isAnyCharacter ||
              prevLine.type.isAnyDialogue ||
              prevLine.type.isAnyParenthetical)) {
        if (prevLine.type == LineType.dualDialogueCharacter ||
            prevLine.type == LineType.dualDialogue ||
            prevLine.type == LineType.dualDialogueParenthetical) {
          line.type = LineType.dualDialogueParenthetical;
        } else {
          line.type = LineType.parenthetical;
        }
        return;
      }
    }

    // Dialogue (follows character cue or parenthetical)
    if (prevLine != null &&
        (prevLine.type.isAnyCharacter ||
            prevLine.type.isAnyDialogue ||
            prevLine.type.isAnyParenthetical)) {
      if (prevLine.type == LineType.dualDialogueCharacter ||
          prevLine.type == LineType.dualDialogue ||
          prevLine.type == LineType.dualDialogueParenthetical) {
        line.type = LineType.dualDialogue;
      } else {
        line.type = LineType.dialogue;
      }
      return;
    }

    // Default to action
    line.type = LineType.action;
  }

  /// Check if a line at the given index is a character cue
  bool _isCharacterCue(int index) {
    final line = lines[index];
    final trimmed = line.string.trim();

    if (trimmed.isEmpty) return false;

    // Must be preceded by an empty line (or be first line after title page)
    final prevLine = index > 0 ? lines[index - 1] : null;
    if (prevLine != null && prevLine.type != LineType.empty) {
      // Exception: could follow title page
      if (!prevLine.type.isTitlePage) return false;
    }

    // Must be followed by a non-empty line
    final nextLine = index < lines.length - 1 ? lines[index + 1] : null;
    if (nextLine == null || nextLine.string.trim().isEmpty) return false;

    // Remove dual dialogue marker for checking
    String checkString = trimmed;
    if (checkString.endsWith('^')) {
      checkString = checkString.substring(0, checkString.length - 1).trim();
    }

    // Must be ALL CAPS (letters only, allowing parentheticals)
    // Strip out parenthetical content for the check
    final parenIndex = checkString.indexOf('(');
    if (parenIndex > 0) {
      checkString = checkString.substring(0, parenIndex).trim();
    }

    return _isAllCaps(checkString) && _hasLetters(checkString);
  }

  /// Check if string is all caps (ignoring non-letter characters)
  bool _isAllCaps(String s) {
    for (final char in s.runes) {
      final c = String.fromCharCode(char);
      if (c.toUpperCase() != c.toLowerCase()) {
        // It's a letter
        if (c != c.toUpperCase()) return false;
      }
    }
    return true;
  }

  /// Check if string contains at least one letter
  bool _hasLetters(String s) {
    for (final char in s.runes) {
      final c = String.fromCharCode(char);
      if (c.toUpperCase() != c.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  /// Get the previous non-empty line
  Line? _previousNonEmptyLine(int index) {
    for (int i = index - 1; i >= 0; i--) {
      if (lines[i].type != LineType.empty) {
        return lines[i];
      }
    }
    return null;
  }

  /// Get the next non-empty line
  Line? _nextNonEmptyLine(int index) {
    for (int i = index + 1; i < lines.length; i++) {
      if (lines[i].string.trim().isNotEmpty) {
        return lines[i];
      }
    }
    return null;
  }

  /// Parse formatting (bold, italic, underline, notes) within a line
  void _parseFormatting(Line line) {
    line.resetFormatting();
    final text = line.string;
    if (text.isEmpty) return;

    // Parse bold (**text**)
    _parseFormattingPattern(text, '**', '**', line.boldRanges);

    // Parse italic (*text*) - but not bold
    _parseItalic(text, line.italicRanges, line.boldRanges);

    // Parse underline (_text_)
    _parseFormattingPattern(text, '_', '_', line.underlineRanges);

    // Parse notes ([[text]])
    _parseFormattingPattern(text, '[[', ']]', line.noteRanges);

    // Parse omitted (/*text*/)
    _parseFormattingPattern(text, '/*', '*/', line.omitRanges);
  }

  /// Parse a formatting pattern and add ranges
  void _parseFormattingPattern(
    String text,
    String openPattern,
    String closePattern,
    List<Range> ranges,
  ) {
    int searchStart = 0;

    while (searchStart < text.length) {
      final openIndex = text.indexOf(openPattern, searchStart);
      if (openIndex == -1) break;

      final closeIndex =
          text.indexOf(closePattern, openIndex + openPattern.length);
      if (closeIndex == -1) break;

      ranges.add(Range(openIndex, closeIndex + closePattern.length));
      searchStart = closeIndex + closePattern.length;
    }
  }

  /// Parse italic while avoiding bold ranges
  void _parseItalic(String text, List<Range> italicRanges, List<Range> boldRanges) {
    int searchStart = 0;

    while (searchStart < text.length) {
      final openIndex = text.indexOf('*', searchStart);
      if (openIndex == -1) break;

      // Skip if this is part of bold (**)
      if (openIndex + 1 < text.length && text[openIndex + 1] == '*') {
        searchStart = openIndex + 2;
        continue;
      }
      if (openIndex > 0 && text[openIndex - 1] == '*') {
        searchStart = openIndex + 1;
        continue;
      }

      // Find closing *
      final closeIndex = text.indexOf('*', openIndex + 1);
      if (closeIndex == -1) break;

      // Skip if closing is part of bold
      if (closeIndex + 1 < text.length && text[closeIndex + 1] == '*') {
        searchStart = closeIndex + 1;
        continue;
      }
      if (closeIndex > 0 && text[closeIndex - 1] == '*') {
        searchStart = closeIndex + 1;
        continue;
      }

      italicRanges.add(Range(openIndex, closeIndex + 1));
      searchStart = closeIndex + 1;
    }
  }
}
