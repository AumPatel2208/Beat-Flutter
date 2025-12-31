import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import '../nodes/screenplay_nodes.dart';

/// Component builders for screenplay document nodes.
/// 
/// These builders create visual representations of the custom
/// screenplay nodes in the editor.

// ============================================================================
// Main Screenplay Component Builder
// ============================================================================

/// Builds components for all screenplay node types.
class ScreenplayComponentBuilder implements ComponentBuilder {
  const ScreenplayComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    // Scene Heading
    if (node is SceneHeadingNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'sceneHeading',
      );
    }

    // Action
    if (node is ActionNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'action',
      );
    }

    // Character
    if (node is CharacterNode) {
      return _createTextViewModel(
        node: node,
        blockType: node.isDualDialogue ? 'dualDialogueCharacter' : 'character',
      );
    }

    // Dialogue
    if (node is DialogueNode) {
      return _createTextViewModel(
        node: node,
        blockType: node.isDualDialogue ? 'dualDialogue' : 'dialogue',
      );
    }

    // Parenthetical
    if (node is ParentheticalNode) {
      return _createTextViewModel(
        node: node,
        blockType: node.isDualDialogue ? 'dualDialogueParenthetical' : 'parenthetical',
      );
    }

    // Transition
    if (node is TransitionNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'transition',
      );
    }

    // Centered
    if (node is CenteredNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'centered',
      );
    }

    // Lyrics
    if (node is LyricsNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'lyrics',
      );
    }

    // Shot
    if (node is ShotNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'shot',
      );
    }

    // Section
    if (node is SectionNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'section',
      );
    }

    // Synopsis
    if (node is SynopsisNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'synopsis',
      );
    }

    // Title Page
    if (node is TitlePageNode) {
      return _createTextViewModel(
        node: node,
        blockType: 'titlePage',
      );
    }

    // Page Break
    if (node is PageBreakNode) {
      return PageBreakComponentViewModel(nodeId: node.id);
    }

    return null;
  }

  ParagraphComponentViewModel _createTextViewModel({
    required TextNode node,
    required String blockType,
  }) {
    final textDirection = _getTextDirection(node.text.toPlainText());

    return ParagraphComponentViewModel(
      nodeId: node.id,
      blockType: NamedAttribution(blockType),
      text: node.text,
      textDirection: textDirection,
      textAlignment: _getTextAlignment(blockType, textDirection),
      textStyleBuilder: noStyleBuilder,
      selectionColor: const Color(0x00000000),
    );
  }

  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    
    // Simple RTL detection - check first non-whitespace character
    for (final char in text.runes) {
      // Arabic, Hebrew, and other RTL ranges
      if ((char >= 0x0590 && char <= 0x05FF) || // Hebrew
          (char >= 0x0600 && char <= 0x06FF) || // Arabic
          (char >= 0x0700 && char <= 0x074F)) { // Syriac
        return TextDirection.rtl;
      }
      if (char > 0x40) {
        return TextDirection.ltr;
      }
    }
    return TextDirection.ltr;
  }

  TextAlign _getTextAlignment(String blockType, TextDirection direction) {
    switch (blockType) {
      case 'centered':
      case 'titlePage':
        return TextAlign.center;
      case 'transition':
        return TextAlign.right;
      default:
        return direction == TextDirection.rtl ? TextAlign.right : TextAlign.left;
    }
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is PageBreakComponentViewModel) {
      return PageBreakComponent(
        key: componentContext.componentKey,
        nodeId: componentViewModel.nodeId,
      );
    }

    // For text-based nodes, defer to the default paragraph component
    if (componentViewModel is ParagraphComponentViewModel) {
      return TextComponent(
        key: componentContext.componentKey,
        text: componentViewModel.text,
        textStyleBuilder: componentViewModel.textStyleBuilder,
        textSelection: componentViewModel.selection,
        selectionColor: componentViewModel.selectionColor,
        highlightWhenEmpty: componentViewModel.highlightWhenEmpty,
        textDirection: componentViewModel.textDirection,
        textAlign: componentViewModel.textAlignment,
      );
    }

    return null;
  }
}

// ============================================================================
// Page Break Component
// ============================================================================

/// View model for page break component
class PageBreakComponentViewModel extends SingleColumnLayoutComponentViewModel {
  PageBreakComponentViewModel({
    required String nodeId,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16),
    double? maxWidth,
  }) : super(nodeId: nodeId, padding: padding, maxWidth: maxWidth, createdAt: null);

  @override
  PageBreakComponentViewModel copy() {
    return PageBreakComponentViewModel(
      nodeId: nodeId,
      padding: padding is EdgeInsets ? padding as EdgeInsets : const EdgeInsets.symmetric(vertical: 16),
      maxWidth: maxWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is PageBreakComponentViewModel &&
          nodeId == other.nodeId;

  @override
  int get hashCode => super.hashCode ^ nodeId.hashCode;
}

/// Widget that renders a page break as a horizontal line
class PageBreakComponent extends StatelessWidget {
  const PageBreakComponent({
    super.key,
    required this.nodeId,
  });

  final String nodeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'PAGE BREAK',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Scene Number Component (for scene heading decoration)
// ============================================================================

/// Widget that displays scene number alongside scene heading
class SceneNumberDecoration extends StatelessWidget {
  const SceneNumberDecoration({
    super.key,
    required this.sceneNumber,
    required this.child,
  });

  final String sceneNumber;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            sceneNumber,
            style: const TextStyle(
              fontFamily: 'Courier Prime',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: child),
        SizedBox(
          width: 48,
          child: Text(
            sceneNumber,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Courier Prime',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Default Component Builders for Screenplay
// ============================================================================

/// Returns the list of component builders for a screenplay editor.
List<ComponentBuilder> get screenplayComponentBuilders => [
  const ScreenplayComponentBuilder(),
  // Fall back to default builders for any unhandled nodes
  ...defaultComponentBuilders,
];
