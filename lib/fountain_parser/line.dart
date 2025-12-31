import 'package:uuid/uuid.dart';
import 'line_type.dart';

/// Represents a single line in a Fountain screenplay.
/// 
/// Each parsed line is represented by a Line object, which holds the string,
/// formatting ranges, and other metadata. This matches Beat's Line object.
class Line {
  /// Unique identifier for this line
  final String uuid;

  /// The raw string content of this line
  String string;

  /// The type of this line (heading, dialogue, action, etc.)
  LineType type;

  /// Position (character index) of this line in the full document
  int position;

  /// Ranges of bold text (stored as list of [start, end] pairs relative to line)
  List<Range> boldRanges;

  /// Ranges of italic text
  List<Range> italicRanges;

  /// Ranges of underlined text
  List<Range> underlineRanges;

  /// Ranges of note text ([[notes]])
  List<Range> noteRanges;

  /// Ranges of omitted text (/* omitted */)
  List<Range> omitRanges;

  /// Ranges of strikeout text
  List<Range> strikeoutRanges;

  /// Ranges that contain escape characters
  List<Range> escapeRanges;

  /// The original string before any modifications
  String? originalString;

  /// Scene number if this is a heading
  String? sceneNumber;

  /// Color associated with this line (for scene coloring)
  String? color;

  /// Whether this line has changed since last parse
  bool changed = false;

  Line({
    String? uuid,
    required this.string,
    this.type = LineType.empty,
    this.position = 0,
    List<Range>? boldRanges,
    List<Range>? italicRanges,
    List<Range>? underlineRanges,
    List<Range>? noteRanges,
    List<Range>? omitRanges,
    List<Range>? strikeoutRanges,
    List<Range>? escapeRanges,
    this.originalString,
    this.sceneNumber,
    this.color,
  })  : uuid = uuid ?? const Uuid().v4(),
        boldRanges = boldRanges ?? [],
        italicRanges = italicRanges ?? [],
        underlineRanges = underlineRanges ?? [],
        noteRanges = noteRanges ?? [],
        omitRanges = omitRanges ?? [],
        strikeoutRanges = strikeoutRanges ?? [],
        escapeRanges = escapeRanges ?? [];

  /// Create a copy of this line
  Line copy() {
    return Line(
      uuid: uuid,
      string: string,
      type: type,
      position: position,
      boldRanges: List.from(boldRanges),
      italicRanges: List.from(italicRanges),
      underlineRanges: List.from(underlineRanges),
      noteRanges: List.from(noteRanges),
      omitRanges: List.from(omitRanges),
      strikeoutRanges: List.from(strikeoutRanges),
      escapeRanges: List.from(escapeRanges),
      originalString: originalString,
      sceneNumber: sceneNumber,
      color: color,
    );
  }

  /// Returns the length of this line's string
  int get length => string.length;

  /// Returns true if this line is empty or contains only whitespace
  bool get isEmpty => string.trim().isEmpty;

  /// Returns true if this line has actual content
  bool get isNotEmpty => !isEmpty;

  /// Returns the text range of this line in the document
  Range get textRange => Range(position, position + length);

  /// Returns the character name if this is a character cue, stripping extensions
  String? get characterName {
    if (!type.isAnyCharacter) return null;

    String name = string.trim();

    // Remove forced character marker
    if (name.startsWith('@')) {
      name = name.substring(1);
    }

    // Remove dual dialogue marker
    if (name.endsWith('^')) {
      name = name.substring(0, name.length - 1).trim();
    }

    // Remove parenthetical extensions like (V.O.), (O.S.), (CONT'D)
    final parenIndex = name.indexOf('(');
    if (parenIndex > 0) {
      name = name.substring(0, parenIndex).trim();
    }

    return name.toUpperCase();
  }

  /// Returns the string with Fountain formatting markup removed
  String get stripFormatting {
    String result = string;

    // Remove bold markers
    result = result.replaceAll('**', '');
    // Remove italic markers (but not bold which uses **)
    result = result.replaceAllMapped(
      RegExp(r'(?<!\*)\*(?!\*)'),
      (m) => '',
    );
    // Remove underline markers
    result = result.replaceAll('_', '');
    // Remove note markers
    result = result.replaceAll('[[', '').replaceAll(']]', '');

    return result;
  }

  /// Clears all formatting ranges
  void resetFormatting() {
    boldRanges.clear();
    italicRanges.clear();
    underlineRanges.clear();
    noteRanges.clear();
    omitRanges.clear();
    strikeoutRanges.clear();
    escapeRanges.clear();
  }

  @override
  String toString() => 'Line(type: ${type.displayName}, string: "$string")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Line && uuid == other.uuid);

  @override
  int get hashCode => uuid.hashCode;
}

/// A range within a line, represented by start and end indices
class Range {
  final int start;
  final int end;

  const Range(this.start, this.end);

  int get length => end - start;

  bool get isEmpty => length <= 0;
  bool get isNotEmpty => length > 0;

  /// Check if this range contains the given index
  bool contains(int index) => index >= start && index < end;

  /// Check if this range overlaps with another range
  bool overlaps(Range other) => start < other.end && end > other.start;

  /// Get the intersection of this range with another
  Range? intersection(Range other) {
    final newStart = start > other.start ? start : other.start;
    final newEnd = end < other.end ? end : other.end;
    if (newStart < newEnd) {
      return Range(newStart, newEnd);
    }
    return null;
  }

  @override
  String toString() => 'Range($start, $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Range && start == other.start && end == other.end);

  @override
  int get hashCode => Object.hash(start, end);
}
