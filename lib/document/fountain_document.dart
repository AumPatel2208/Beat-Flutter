import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:super_editor/super_editor.dart';
import 'package:path/path.dart' as p;

import '../fountain_parser/fountain_parser.dart';
import '../editor/nodes/screenplay_nodes.dart';
import 'document_settings.dart';

// Re-export attributions for convenience
const italicAttribution = NamedAttribution('italics');

/// Represents a Fountain screenplay document.
/// 
/// This class bridges the Fountain parser with super_editor's document model,
/// handling file I/O and maintaining document state.
class FountainDocument extends ChangeNotifier {
  FountainDocument() {
    _parser = ContinuousFountainParser();
    _settings = DocumentSettings();
    _document = MutableDocument(nodes: [
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(''),
      ),
    ]);
  }

  /// Create a new document with a starter template
  factory FountainDocument.withTemplate() {
    final doc = FountainDocument();
    doc._initializeWithTemplate();
    return doc;
  }

  late ContinuousFountainParser _parser;
  late DocumentSettings _settings;
  late MutableDocument _document;
  
  String? _filePath;
  String _name = 'Untitled';
  bool _isDirty = false;

  /// The super_editor document
  MutableDocument get document => _document;

  /// The Fountain parser
  ContinuousFountainParser get parser => _parser;

  /// Document settings (Beat JSON block)
  DocumentSettings get settings => _settings;

  /// File path if document has been saved
  String? get filePath => _filePath;

  /// Document name (filename without extension)
  String get name => _name;

  /// Whether document has unsaved changes
  bool get isDirty => _isDirty;

  /// All parsed lines
  List<Line> get lines => _parser.lines;

  /// Get the raw Fountain text
  String get rawText => _parser.rawText;

  /// Initialize with a basic template
  void _initializeWithTemplate() {
    const template = '''Title: Untitled Screenplay
Author: 

===

FADE IN:

''';
    _parseAndBuildDocument(template);
    _name = 'Untitled';
    _isDirty = false;
  }

  /// Load document from a file
  Future<void> loadFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File not found', path);
    }

    final content = await file.readAsString();
    
    // Extract settings from the end of the file
    final settingsResult = DocumentSettings.extractFromContent(content);
    _settings = settingsResult.settings;
    
    // Parse the screenplay content (without settings block)
    _parseAndBuildDocument(settingsResult.content);
    
    _filePath = path;
    _name = p.basenameWithoutExtension(path);
    _isDirty = false;
    
    notifyListeners();
  }

  /// Save document to current file path
  Future<void> save() async {
    if (_filePath == null) {
      throw StateError('No file path set. Use saveAs() instead.');
    }
    await _saveToPath(_filePath!);
  }

  /// Save document to a new file path
  Future<void> saveAs(String path) async {
    await _saveToPath(path);
    _filePath = path;
    _name = p.basenameWithoutExtension(path);
    notifyListeners();
  }

  Future<void> _saveToPath(String path) async {
    final file = File(path);
    
    // Build content from document nodes
    final screenplayContent = _buildFountainContent();
    
    // Append settings block
    final settingsBlock = _settings.generateSettingsString();
    final fullContent = settingsBlock.isNotEmpty 
        ? '$screenplayContent\n\n$settingsBlock'
        : screenplayContent;
    
    await file.writeAsString(fullContent);
    
    _isDirty = false;
    notifyListeners();
  }

  /// Parse Fountain text and build super_editor document
  void _parseAndBuildDocument(String content) {
    _parser.parseText(content);
    _rebuildDocument();
  }

  /// Rebuild the super_editor document from parsed lines
  void _rebuildDocument() {
    final nodes = <DocumentNode>[];
    
    for (final line in _parser.lines) {
      final node = _createNodeFromLine(line);
      if (node != null) {
        nodes.add(node);
      }
    }
    
    // Ensure at least one node
    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(''),
      ));
    }
    
    _document = MutableDocument(nodes: nodes);
  }

  /// Create a DocumentNode from a parsed Line
  DocumentNode? _createNodeFromLine(Line line) {
    final id = Editor.createNodeId();
    final text = _createAttributedText(line);
    
    switch (line.type) {
      case LineType.empty:
        return ActionNode(
          id: id,
          text: AttributedText(''),
        );
        
      case LineType.heading:
        return SceneHeadingNode(
          id: id,
          text: text,
          sceneNumber: line.sceneNumber,
        );
        
      case LineType.action:
        return ActionNode(
          id: id,
          text: text,
        );
        
      case LineType.character:
        return CharacterNode(
          id: id,
          text: text,
          isDualDialogue: false,
        );
        
      case LineType.dialogue:
        return DialogueNode(
          id: id,
          text: text,
          isDualDialogue: false,
        );
        
      case LineType.parenthetical:
        return ParentheticalNode(
          id: id,
          text: text,
          isDualDialogue: false,
        );
        
      case LineType.dualDialogueCharacter:
        return CharacterNode(
          id: id,
          text: text,
          isDualDialogue: true,
        );
        
      case LineType.dualDialogue:
        return DialogueNode(
          id: id,
          text: text,
          isDualDialogue: true,
        );
        
      case LineType.dualDialogueParenthetical:
        return ParentheticalNode(
          id: id,
          text: text,
          isDualDialogue: true,
        );
        
      case LineType.transitionLine:
        return TransitionNode(
          id: id,
          text: text,
        );
        
      case LineType.centered:
        return CenteredNode(
          id: id,
          text: text,
        );
        
      case LineType.lyrics:
        return LyricsNode(
          id: id,
          text: text,
        );
        
      case LineType.shot:
        return ShotNode(
          id: id,
          text: text,
        );
        
      case LineType.section:
        return SectionNode(
          id: id,
          text: text,
          depth: line.sectionDepth ?? 1,
        );
        
      case LineType.synopsis:
        return SynopsisNode(
          id: id,
          text: text,
        );
        
      case LineType.pageBreak:
        // Page breaks are ActionNode with === text (editable)
        return ActionNode(
          id: id,
          text: AttributedText('==='),
        );
        
      case LineType.titlePageTitle:
      case LineType.titlePageAuthor:
      case LineType.titlePageCredit:
      case LineType.titlePageSource:
      case LineType.titlePageContact:
      case LineType.titlePageDraftDate:
      case LineType.titlePageUnknown:
        return TitlePageNode(
          id: id,
          text: text,
          key: _titlePageKeyFromType(line.type),
        );
        
      case LineType.more:
      case LineType.dualDialogueMore:
        // These are export-only types, skip them
        return null;
    }
  }

  String _titlePageKeyFromType(LineType type) {
    switch (type) {
      case LineType.titlePageTitle:
        return 'title';
      case LineType.titlePageAuthor:
        return 'author';
      case LineType.titlePageCredit:
        return 'credit';
      case LineType.titlePageSource:
        return 'source';
      case LineType.titlePageContact:
        return 'contact';
      case LineType.titlePageDraftDate:
        return 'draft date';
      default:
        return 'unknown';
    }
  }

  /// Create AttributedText from a Line, applying formatting ranges
  AttributedText _createAttributedText(Line line) {
    final text = line.string;
    final spans = AttributedSpans();
    
    // Apply bold ranges
    for (final range in line.boldRanges) {
      spans.addAttribution(
        newAttribution: boldAttribution,
        start: range.start,
        end: range.end - 1,
      );
    }
    
    // Apply italic ranges
    for (final range in line.italicRanges) {
      spans.addAttribution(
        newAttribution: italicAttribution,
        start: range.start,
        end: range.end - 1,
      );
    }
    
    // Apply underline ranges
    for (final range in line.underlineRanges) {
      spans.addAttribution(
        newAttribution: underlineAttribution,
        start: range.start,
        end: range.end - 1,
      );
    }
    
    // Apply note ranges (custom attribution)
    for (final range in line.noteRanges) {
      spans.addAttribution(
        newAttribution: const NamedAttribution('note'),
        start: range.start,
        end: range.end - 1,
      );
    }
    
    // Apply omitted ranges (custom attribution)
    for (final range in line.omittedRanges) {
      spans.addAttribution(
        newAttribution: const NamedAttribution('omitted'),
        start: range.start,
        end: range.end - 1,
      );
    }
    
    return AttributedText(text, spans);
  }

  /// Build Fountain content from document nodes
  String _buildFountainContent() {
    final buffer = StringBuffer();
    
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i);
      if (node != null) {
        final line = _nodeToFountainLine(node);
        buffer.write(line);
        if (i < _document.nodeCount - 1) {
          buffer.write('\n');
        }
      }
    }
    
    return buffer.toString();
  }

  /// Convert a DocumentNode back to Fountain text
  String _nodeToFountainLine(DocumentNode node) {
    if (node is TextNode) {
      final text = node.text.toPlainText();
      
      if (node is SceneHeadingNode) {
        // Scene headings that don't start with standard prefixes need a dot
        final upper = text.toUpperCase();
        final needsForce = !ContinuousFountainParser.sceneHeadingPrefixes
            .any((p) => upper.startsWith(p));
        return needsForce ? '.$text' : text;
      } else if (node is CharacterNode) {
        if (node.isDualDialogue) {
          return '$text ^';
        }
        return text;
      } else if (node is TransitionNode) {
        // Transitions that don't end with TO: need a >
        if (!text.toUpperCase().endsWith('TO:')) {
          return '>$text';
        }
        return text;
      } else if (node is CenteredNode) {
        return '>$text<';
      } else if (node is LyricsNode) {
        return '~$text';
      } else if (node is SectionNode) {
        final hashes = '#' * node.depth;
        return '$hashes $text';
      } else if (node is SynopsisNode) {
        return '= $text';
      } else if (node is TitlePageNode) {
        return '${node.key}: $text';
      } else {
        // Action, Dialogue, Parenthetical - output as-is
        return text;
      }
    }
    
    return '';
  }

  /// Mark document as dirty (has unsaved changes)
  void markDirty() {
    if (!_isDirty) {
      _isDirty = true;
      notifyListeners();
    }
  }

  /// Update content from editor changes
  void updateFromEditor() {
    // Rebuild parser from current document state
    final content = _buildFountainContent();
    _parser.parseText(content);
    markDirty();
  }

  /// Get word count
  int get wordCount {
    int count = 0;
    for (final line in _parser.lines) {
      if (!line.type.isInvisible) {
        count += line.string.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      }
    }
    return count;
  }

  /// Get approximate page count (assuming ~55 lines per page)
  int get pageCount {
    int lineCount = 0;
    for (final line in _parser.lines) {
      if (!line.type.isInvisible && line.type != LineType.empty) {
        lineCount++;
      }
    }
    return (lineCount / 55).ceil().clamp(1, 999);
  }

  /// Get all unique character names
  Set<String> get characterNames => _parser.characterNames;

  /// Get all scene headings
  List<Line> get sceneHeadings => _parser.sceneHeadings;

  @override
  void dispose() {
    super.dispose();
  }
}
