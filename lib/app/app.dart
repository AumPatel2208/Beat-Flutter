import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../document/fountain_document.dart';
import 'editor_screen.dart';

/// Main application widget
class BeatApp extends StatelessWidget {
  const BeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Courier Prime',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Courier Prime',
      ),
      themeMode: ThemeMode.light,
      home: const MainWindow(),
    );
  }
}

/// Main application window
class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  FountainDocument? _document;
  
  @override
  void initState() {
    super.initState();
    _newDocument();
  }

  void _newDocument() {
    setState(() {
      _document = FountainDocument.withTemplate();
    });
  }

  Future<void> _openDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['fountain', 'txt'],
        dialogTitle: 'Open Screenplay',
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          final doc = FountainDocument();
          await doc.loadFromFile(path);
          setState(() {
            _document = doc;
          });
        }
      }
    } catch (e) {
      _showError('Failed to open file: $e');
    }
  }

  Future<void> _saveDocument() async {
    if (_document == null) return;

    if (_document!.filePath == null) {
      await _saveDocumentAs();
    } else {
      try {
        await _document!.save();
        setState(() {});
      } catch (e) {
        _showError('Failed to save file: $e');
      }
    }
  }

  Future<void> _saveDocumentAs() async {
    if (_document == null) return;

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Screenplay',
        fileName: '${_document!.name}.fountain',
        type: FileType.custom,
        allowedExtensions: ['fountain'],
      );

      if (result != null) {
        await _document!.saveAs(result);
        setState(() {});
      }
    } catch (e) {
      _showError('Failed to save file: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onDocumentChanged() {
    setState(() {});
  }

  String get _windowTitle {
    if (_document == null) return 'Beat';
    final dirty = _document!.isDirty ? '*' : '';
    return '$dirty${_document!.name} - Beat';
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            const _NewDocumentIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
            const _OpenDocumentIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveDocumentIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
                LogicalKeyboardKey.keyS):
            const _SaveAsDocumentIntent(),
      },
      child: Actions(
        actions: {
          _NewDocumentIntent: CallbackAction<_NewDocumentIntent>(
            onInvoke: (_) => _newDocument(),
          ),
          _OpenDocumentIntent: CallbackAction<_OpenDocumentIntent>(
            onInvoke: (_) => _openDocument(),
          ),
          _SaveDocumentIntent: CallbackAction<_SaveDocumentIntent>(
            onInvoke: (_) => _saveDocument(),
          ),
          _SaveAsDocumentIntent: CallbackAction<_SaveAsDocumentIntent>(
            onInvoke: (_) => _saveDocumentAs(),
          ),
        },
        child: Scaffold(
          body: Column(
            children: [
              // Menu bar
              _buildMenuBar(),
              
              // Editor
              Expanded(
                child: _document == null
                    ? const Center(child: CircularProgressIndicator())
                    : EditorScreen(
                        fountainDocument: _document!,
                        onDocumentChanged: _onDocumentChanged,
                      ),
              ),
              
              // Status bar
              if (_document != null)
                EditorStatusBar(document: _document!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // File menu
          _MenuButton(
            label: 'File',
            items: [
              _MenuItem(
                label: 'New',
                shortcut: 'Ctrl+N',
                onTap: _newDocument,
              ),
              _MenuItem(
                label: 'Open...',
                shortcut: 'Ctrl+O',
                onTap: _openDocument,
              ),
              const _MenuDivider(),
              _MenuItem(
                label: 'Save',
                shortcut: 'Ctrl+S',
                onTap: _saveDocument,
                enabled: _document != null,
              ),
              _MenuItem(
                label: 'Save As...',
                shortcut: 'Ctrl+Shift+S',
                onTap: _saveDocumentAs,
                enabled: _document != null,
              ),
              const _MenuDivider(),
              _MenuItem(
                label: 'Exit',
                onTap: () => SystemNavigator.pop(),
              ),
            ],
          ),
          
          // Edit menu
          _MenuButton(
            label: 'Edit',
            items: [
              _MenuItem(
                label: 'Undo',
                shortcut: 'Ctrl+Z',
                onTap: () {
                  // TODO: Implement undo
                },
              ),
              _MenuItem(
                label: 'Redo',
                shortcut: 'Ctrl+Y',
                onTap: () {
                  // TODO: Implement redo
                },
              ),
              const _MenuDivider(),
              _MenuItem(
                label: 'Cut',
                shortcut: 'Ctrl+X',
                onTap: () {
                  // TODO: Implement cut
                },
              ),
              _MenuItem(
                label: 'Copy',
                shortcut: 'Ctrl+C',
                onTap: () {
                  // TODO: Implement copy
                },
              ),
              _MenuItem(
                label: 'Paste',
                shortcut: 'Ctrl+V',
                onTap: () {
                  // TODO: Implement paste
                },
              ),
            ],
          ),
          
          // Help menu
          _MenuButton(
            label: 'Help',
            items: [
              _MenuItem(
                label: 'About Beat',
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _windowTitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Beat'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beat for Desktop',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('A cross-platform screenwriting application'),
            Text('using the Fountain format.'),
            SizedBox(height: 16),
            Text('Built with Flutter'),
            SizedBox(height: 8),
            Text(
              'Original Beat app by Lauri-Matti Parppei',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Intent classes for keyboard shortcuts
class _NewDocumentIntent extends Intent {
  const _NewDocumentIntent();
}

class _OpenDocumentIntent extends Intent {
  const _OpenDocumentIntent();
}

class _SaveDocumentIntent extends Intent {
  const _SaveDocumentIntent();
}

class _SaveAsDocumentIntent extends Intent {
  const _SaveAsDocumentIntent();
}

// Menu widgets
class _MenuButton extends StatefulWidget {
  final String label;
  final List<Widget> items;

  const _MenuButton({
    required this.label,
    required this.items,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  void _showMenu() {
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideMenu,
        child: Stack(
          children: [
            Positioned(
              left: _getMenuPosition(),
              top: 32,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.items.map((item) {
                      if (item is _MenuItem) {
                        return InkWell(
                          onTap: item.enabled
                              ? () {
                                  final callback = item.onTap;
                                  _hideMenu();
                                  if (callback != null) {
                                    Future.microtask(callback);
                                  }
                                }
                              : null,
                          child: item,
                        );
                      }
                      return item;
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  double _getMenuPosition() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final position = box.localToGlobal(Offset.zero);
      return position.dx;
    }
    return 0;
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideMenu();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: _focusNode,
      onTap: _showMenu,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          widget.label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool enabled;

  const _MenuItem({
    required this.label,
    this.shortcut,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
          ),
          if (shortcut != null)
            Text(
              shortcut!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey.shade300,
    );
  }
}
