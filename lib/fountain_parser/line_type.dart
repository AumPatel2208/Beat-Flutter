/// Fountain line type enum matching Beat's LineType
/// 
/// These represent the different types of elements in a Fountain screenplay.
/// Some types are only used in static parsing and/or exporting.
enum LineType {
  empty,
  section,
  synopsis,
  titlePageTitle,
  titlePageAuthor,
  titlePageCredit,
  titlePageSource,
  titlePageContact,
  titlePageDraftDate,
  titlePageUnknown,
  heading,
  action,
  character,
  parenthetical,
  dialogue,
  dualDialogueCharacter,
  dualDialogueParenthetical,
  dualDialogue,
  transitionLine,
  lyrics,
  pageBreak,
  centered,
  shot,
  more, // fake element for exporting
  dualDialogueMore, // fake element for exporting
}

extension LineTypeExtension on LineType {
  /// Returns true if this is any type of character cue
  bool get isAnyCharacter =>
      this == LineType.character || this == LineType.dualDialogueCharacter;

  /// Returns true if this is any type of dialogue
  bool get isAnyDialogue =>
      this == LineType.dialogue || this == LineType.dualDialogue;

  /// Returns true if this is any type of parenthetical
  bool get isAnyParenthetical =>
      this == LineType.parenthetical ||
      this == LineType.dualDialogueParenthetical;

  /// Returns true if this is a title page element
  bool get isTitlePage =>
      this == LineType.titlePageTitle ||
      this == LineType.titlePageAuthor ||
      this == LineType.titlePageCredit ||
      this == LineType.titlePageSource ||
      this == LineType.titlePageContact ||
      this == LineType.titlePageDraftDate ||
      this == LineType.titlePageUnknown;

  /// Returns true if this is an outline/structure element
  bool get isOutlineElement =>
      this == LineType.heading ||
      this == LineType.section ||
      this == LineType.synopsis;

  /// Returns true if this line type is invisible (non-printing)
  bool get isInvisible =>
      this == LineType.section ||
      this == LineType.synopsis ||
      this == LineType.empty;

  /// Human-readable name for this line type
  String get displayName {
    switch (this) {
      case LineType.empty:
        return 'Empty';
      case LineType.section:
        return 'Section';
      case LineType.synopsis:
        return 'Synopsis';
      case LineType.titlePageTitle:
        return 'Title';
      case LineType.titlePageAuthor:
        return 'Author';
      case LineType.titlePageCredit:
        return 'Credit';
      case LineType.titlePageSource:
        return 'Source';
      case LineType.titlePageContact:
        return 'Contact';
      case LineType.titlePageDraftDate:
        return 'Draft Date';
      case LineType.titlePageUnknown:
        return 'Title Page';
      case LineType.heading:
        return 'Scene Heading';
      case LineType.action:
        return 'Action';
      case LineType.character:
        return 'Character';
      case LineType.parenthetical:
        return 'Parenthetical';
      case LineType.dialogue:
        return 'Dialogue';
      case LineType.dualDialogueCharacter:
        return 'Character (Dual)';
      case LineType.dualDialogueParenthetical:
        return 'Parenthetical (Dual)';
      case LineType.dualDialogue:
        return 'Dialogue (Dual)';
      case LineType.transitionLine:
        return 'Transition';
      case LineType.lyrics:
        return 'Lyrics';
      case LineType.pageBreak:
        return 'Page Break';
      case LineType.centered:
        return 'Centered';
      case LineType.shot:
        return 'Shot';
      case LineType.more:
        return 'More';
      case LineType.dualDialogueMore:
        return 'More (Dual)';
    }
  }
}
