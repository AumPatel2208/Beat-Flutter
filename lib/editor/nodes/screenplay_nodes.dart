import 'package:flutter/foundation.dart';
import 'package:super_editor/super_editor.dart';

/// Custom document nodes for screenplay elements.
/// 
/// These nodes extend super_editor's TextNode to represent
/// the various Fountain screenplay element types.

// ============================================================================
// Scene Heading Node
// ============================================================================

/// A scene heading (slug line) like "INT. HOUSE - DAY"
@immutable
class SceneHeadingNode extends TextNode {
  SceneHeadingNode({
    required super.id,
    required super.text,
    super.metadata,
    this.sceneNumber,
    this.color,
  });

  /// Optional scene number (e.g., "1", "1A")
  final String? sceneNumber;

  /// Optional color tag for the scene
  final String? color;

  @override
  SceneHeadingNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return SceneHeadingNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      sceneNumber: sceneNumber,
      color: color,
    );
  }

  SceneHeadingNode copyWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
    String? sceneNumber,
    String? color,
  }) {
    return SceneHeadingNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      sceneNumber: sceneNumber ?? this.sceneNumber,
      color: color ?? this.color,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is SceneHeadingNode &&
        text == other.text &&
        sceneNumber == other.sceneNumber &&
        color == other.color;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SceneHeadingNode &&
          sceneNumber == other.sceneNumber &&
          color == other.color;

  @override
  int get hashCode => super.hashCode ^ sceneNumber.hashCode ^ color.hashCode;
}

// ============================================================================
// Action Node
// ============================================================================

/// Action/description text
@immutable
class ActionNode extends TextNode {
  ActionNode({
    required super.id,
    required super.text,
    super.metadata,
  });

  @override
  ActionNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return ActionNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is ActionNode && text == other.text;
  }
}

// ============================================================================
// Character Node
// ============================================================================

/// Character cue (name before dialogue)
@immutable
class CharacterNode extends TextNode {
  CharacterNode({
    required super.id,
    required super.text,
    super.metadata,
    this.isDualDialogue = false,
    this.extension,
  });

  /// Whether this is part of dual dialogue
  final bool isDualDialogue;

  /// Character extension like (V.O.) or (O.S.)
  final String? extension;

  /// Extract the character name without extension
  String get characterName {
    final fullText = text.toPlainText();
    final parenIndex = fullText.indexOf('(');
    if (parenIndex > 0) {
      return fullText.substring(0, parenIndex).trim();
    }
    // Remove ^ for dual dialogue
    return fullText.replaceAll('^', '').trim();
  }

  @override
  CharacterNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return CharacterNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      isDualDialogue: isDualDialogue,
      extension: extension,
    );
  }

  CharacterNode copyWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
    bool? isDualDialogue,
    String? extension,
  }) {
    return CharacterNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      isDualDialogue: isDualDialogue ?? this.isDualDialogue,
      extension: extension ?? this.extension,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is CharacterNode &&
        text == other.text &&
        isDualDialogue == other.isDualDialogue;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CharacterNode &&
          isDualDialogue == other.isDualDialogue &&
          extension == other.extension;

  @override
  int get hashCode =>
      super.hashCode ^ isDualDialogue.hashCode ^ extension.hashCode;
}

// ============================================================================
// Dialogue Node
// ============================================================================

/// Dialogue spoken by a character
@immutable
class DialogueNode extends TextNode {
  DialogueNode({
    required super.id,
    required super.text,
    super.metadata,
    this.isDualDialogue = false,
  });

  /// Whether this is part of dual dialogue
  final bool isDualDialogue;

  @override
  DialogueNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return DialogueNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      isDualDialogue: isDualDialogue,
    );
  }

  DialogueNode copyWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
    bool? isDualDialogue,
  }) {
    return DialogueNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      isDualDialogue: isDualDialogue ?? this.isDualDialogue,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is DialogueNode &&
        text == other.text &&
        isDualDialogue == other.isDualDialogue;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is DialogueNode &&
          isDualDialogue == other.isDualDialogue;

  @override
  int get hashCode => super.hashCode ^ isDualDialogue.hashCode;
}

// ============================================================================
// Parenthetical Node
// ============================================================================

/// Parenthetical direction within dialogue
@immutable
class ParentheticalNode extends TextNode {
  ParentheticalNode({
    required super.id,
    required super.text,
    super.metadata,
    this.isDualDialogue = false,
  });

  /// Whether this is part of dual dialogue
  final bool isDualDialogue;

  @override
  ParentheticalNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return ParentheticalNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      isDualDialogue: isDualDialogue,
    );
  }

  ParentheticalNode copyWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
    bool? isDualDialogue,
  }) {
    return ParentheticalNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      isDualDialogue: isDualDialogue ?? this.isDualDialogue,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is ParentheticalNode &&
        text == other.text &&
        isDualDialogue == other.isDualDialogue;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ParentheticalNode &&
          isDualDialogue == other.isDualDialogue;

  @override
  int get hashCode => super.hashCode ^ isDualDialogue.hashCode;
}

// ============================================================================
// Transition Node
// ============================================================================

/// Transition like "CUT TO:" or "FADE OUT."
@immutable
class TransitionNode extends TextNode {
  TransitionNode({
    required super.id,
    required super.text,
    super.metadata,
  });

  @override
  TransitionNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return TransitionNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is TransitionNode && text == other.text;
  }
}

// ============================================================================
// Centered Node
// ============================================================================

/// Centered text (wrapped in > <)
@immutable
class CenteredNode extends TextNode {
  CenteredNode({
    required super.id,
    required super.text,
    super.metadata,
  });

  @override
  CenteredNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return CenteredNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is CenteredNode && text == other.text;
  }
}

// ============================================================================
// Lyrics Node
// ============================================================================

/// Lyrics (lines starting with ~)
@immutable
class LyricsNode extends TextNode {
  LyricsNode({
    required super.id,
    required super.text,
    super.metadata,
  });

  @override
  LyricsNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return LyricsNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is LyricsNode && text == other.text;
  }
}

// ============================================================================
// Shot Node
// ============================================================================

/// Shot description (like a mini scene heading)
@immutable
class ShotNode extends TextNode {
  ShotNode({
    required super.id,
    required super.text,
    super.metadata,
  });

  @override
  ShotNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return ShotNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is ShotNode && text == other.text;
  }
}

// ============================================================================
// Section Node
// ============================================================================

/// Section header (outline element, # ## ###)
@immutable
class SectionNode extends TextNode {
  SectionNode({
    required super.id,
    required super.text,
    super.metadata,
    required this.depth,
  });

  /// Section depth (1 = #, 2 = ##, 3 = ###, etc.)
  final int depth;

  @override
  SectionNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return SectionNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      depth: depth,
    );
  }

  SectionNode copyWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
    int? depth,
  }) {
    return SectionNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      depth: depth ?? this.depth,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is SectionNode && text == other.text && depth == other.depth;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is SectionNode && depth == other.depth;

  @override
  int get hashCode => super.hashCode ^ depth.hashCode;
}

// ============================================================================
// Synopsis Node
// ============================================================================

/// Synopsis (outline element, starts with =)
@immutable
class SynopsisNode extends TextNode {
  SynopsisNode({
    required super.id,
    required super.text,
    super.metadata,
  });

  @override
  SynopsisNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return SynopsisNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is SynopsisNode && text == other.text;
  }
}

// ============================================================================
// Page Break
// ============================================================================
// Page breaks are represented as ActionNode with text content "==="
// They are parsed and styled specially but remain editable text.

// ============================================================================
// Title Page Node
// ============================================================================

/// Title page element (Title:, Author:, etc.)
@immutable
class TitlePageNode extends TextNode {
  TitlePageNode({
    required super.id,
    required super.text,
    super.metadata,
    required this.key,
  });

  /// The title page key (title, author, credit, source, contact, draft date)
  final String key;

  @override
  TitlePageNode copyTextNodeWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
  }) {
    return TitlePageNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      key: key,
    );
  }

  TitlePageNode copyWith({
    String? id,
    AttributedText? text,
    Map<String, dynamic>? metadata,
    String? key,
  }) {
    return TitlePageNode(
      id: id ?? this.id,
      text: text ?? this.text,
      metadata: metadata ?? this.metadata,
      key: key ?? this.key,
    );
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is TitlePageNode && text == other.text && key == other.key;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is TitlePageNode && key == other.key;

  @override
  int get hashCode => super.hashCode ^ key.hashCode;
}

// ============================================================================
// Block Type Names (for stylesheet selectors)
// ============================================================================

/// Block type name mappings for stylesheet selectors
extension ScreenplayNodeBlockType on DocumentNode {
  String get blockTypeName {
    if (this is SceneHeadingNode) return 'sceneHeading';
    if (this is ActionNode) return 'action';
    if (this is CharacterNode) {
      return (this as CharacterNode).isDualDialogue
          ? 'dualDialogueCharacter'
          : 'character';
    }
    if (this is DialogueNode) {
      return (this as DialogueNode).isDualDialogue
          ? 'dualDialogue'
          : 'dialogue';
    }
    if (this is ParentheticalNode) {
      return (this as ParentheticalNode).isDualDialogue
          ? 'dualDialogueParenthetical'
          : 'parenthetical';
    }
    if (this is TransitionNode) return 'transition';
    if (this is CenteredNode) return 'centered';
    if (this is LyricsNode) return 'lyrics';
    if (this is ShotNode) return 'shot';
    if (this is SectionNode) return 'section';
    if (this is SynopsisNode) return 'synopsis';
    if (this is TitlePageNode) return 'titlePage';
    return 'action'; // default
  }
}
