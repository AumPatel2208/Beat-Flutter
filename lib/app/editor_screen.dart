import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import '../document/fountain_document.dart';
import '../editor/editor.dart';

/// The main editor screen that displays the screenplay editor.
class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.fountainDocument,
    this.onDocumentChanged,
  });

  final FountainDocument fountainDocument;
  final VoidCallback? onDocumentChanged;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late MutableDocumentComposer _composer;
  late Editor _editor;
  late FocusNode _editorFocusNode;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  @override
  void didUpdateWidget(EditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fountainDocument != oldWidget.fountainDocument) {
      _initializeEditor();
    }
  }

  void _initializeEditor() {
    _composer = MutableDocumentComposer();
    _editorFocusNode = FocusNode();
    
    _editor = createDefaultDocumentEditor(
      document: widget.fountainDocument.document,
      composer: _composer,
    );
    
    // Listen for document changes
    _editor.addListener(FunctionalEditListener(_onDocumentEdit));
  }

  void _onDocumentEdit(List<EditEvent> events) {
    // Mark document as dirty on any edit
    widget.fountainDocument.markDirty();
    widget.onDocumentChanged?.call();
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SuperEditor(
        focusNode: _editorFocusNode,
        editor: _editor,
        stylesheet: ScreenplayStylesheet.createStylesheet(),
        componentBuilders: screenplayComponentBuilders,
        gestureMode: DocumentGestureMode.mouse,
        inputSource: TextInputSource.ime,
        autofocus: true,
        documentLayoutKey: GlobalKey(),
      ),
    );
  }
}

/// Status bar showing document information
class EditorStatusBar extends StatelessWidget {
  const EditorStatusBar({
    super.key,
    required this.document,
  });

  final FountainDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Page count
          _StatusItem(
            icon: Icons.description_outlined,
            label: '${document.pageCount} pages',
          ),
          const SizedBox(width: 24),
          
          // Word count
          _StatusItem(
            icon: Icons.text_fields,
            label: '${document.wordCount} words',
          ),
          const SizedBox(width: 24),
          
          // Character count
          _StatusItem(
            icon: Icons.people_outline,
            label: '${document.characterNames.length} characters',
          ),
          
          const Spacer(),
          
          // Scene count
          _StatusItem(
            icon: Icons.movie_outlined,
            label: '${document.sceneHeadings.length} scenes',
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
