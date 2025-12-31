import 'dart:convert';

/// Document settings that are stored at the end of Fountain files
/// 
/// Beat stores additional metadata in a JSON block at the end of files:
/// ```
/// /* If you're seeing this, you can remove the following stuff - BEAT:
/// { json data }
/// END_BEAT*/
/// ```
class DocumentSettings {
  /// The settings dictionary
  final Map<String, dynamic> _settings = {};

  /// Known setting keys
  static const String keyCaretPosition = 'Caret Position';
  static const String keyPageSize = 'Page Size';
  static const String keyCharacterGenders = 'CharacterGenders';
  static const String keyCharacterData = 'CharacterData';
  static const String keyRevisions = 'Revision';
  static const String keySceneNumberStart = 'Scene Numbering Starts From';
  static const String keyPrintSceneNumbers = 'Print scene numbers';
  static const String keyHeader = 'Header';
  static const String keyHeaderAlignment = 'Header Alignment';
  static const String keyStylesheet = 'Stylesheet';
  static const String keyWindowWidth = 'Window Width';
  static const String keyWindowHeight = 'Window Height';
  static const String keyLocked = 'Locked';
  static const String keySidebarVisible = 'Sidebar Visible';
  static const String keySidebarWidth = 'Sidebar Width';

  /// Marker strings for the settings block
  static const String settingsBlockStart = '/* If you\'re seeing this, you can remove the following stuff - BEAT:';
  static const String settingsBlockEnd = 'END_BEAT*/';

  /// Alternative markers (some older files use this)
  static const String altSettingsBlockStart = '/* BEAT:';

  DocumentSettings();

  /// Create from existing settings map
  DocumentSettings.fromMap(Map<String, dynamic> settings) {
    _settings.addAll(settings);
  }

  /// Get a boolean setting
  bool getBool(String key, {bool defaultValue = false}) {
    final value = _settings[key];
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  /// Set a boolean setting
  void setBool(String key, bool value) {
    _settings[key] = value;
  }

  /// Get an integer setting
  int getInt(String key, {int defaultValue = 0}) {
    final value = _settings[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Set an integer setting
  void setInt(String key, int value) {
    _settings[key] = value;
  }

  /// Get a string setting
  String getString(String key, {String defaultValue = ''}) {
    final value = _settings[key];
    if (value is String) return value;
    if (value != null) return value.toString();
    return defaultValue;
  }

  /// Set a string setting
  void setString(String key, String value) {
    _settings[key] = value;
  }

  /// Get any setting value
  dynamic get(String key) => _settings[key];

  /// Set any setting value
  void set(String key, dynamic value) {
    _settings[key] = value;
  }

  /// Check if a setting exists
  bool has(String key) => _settings.containsKey(key);

  /// Remove a setting
  void remove(String key) => _settings.remove(key);

  /// Get the caret position
  int get caretPosition => getInt(keyCaretPosition);
  set caretPosition(int value) => setInt(keyCaretPosition, value);

  /// Get the page size (A4 or US Letter)
  String get pageSize => getString(keyPageSize, defaultValue: 'A4');
  set pageSize(String value) => setString(keyPageSize, value);

  /// Whether to print scene numbers
  bool get printSceneNumbers => getBool(keyPrintSceneNumbers, defaultValue: true);
  set printSceneNumbers(bool value) => setBool(keyPrintSceneNumbers, value);

  /// Whether the document is locked
  bool get locked => getBool(keyLocked);
  set locked(bool value) => setBool(keyLocked, value);

  /// Parse settings from the end of a Fountain file
  /// Returns the range of the actual screenplay content (excluding settings)
  static ParseResult parseFromString(String content) {
    final settings = DocumentSettings();
    
    // Try to find settings block
    int settingsStart = content.lastIndexOf(settingsBlockStart);
    if (settingsStart == -1) {
      settingsStart = content.lastIndexOf(altSettingsBlockStart);
    }
    
    if (settingsStart == -1) {
      // No settings block found, entire content is screenplay
      return ParseResult(
        settings: settings,
        contentRange: ContentRange(0, content.length),
      );
    }

    // Find end of settings block
    final settingsEnd = content.indexOf(settingsBlockEnd, settingsStart);
    if (settingsEnd == -1) {
      // Malformed settings block, ignore it
      return ParseResult(
        settings: settings,
        contentRange: ContentRange(0, settingsStart),
      );
    }

    // Extract JSON content
    String jsonStart;
    if (content.substring(settingsStart).startsWith(settingsBlockStart)) {
      jsonStart = content.substring(
        settingsStart + settingsBlockStart.length,
        settingsEnd,
      ).trim();
    } else {
      jsonStart = content.substring(
        settingsStart + altSettingsBlockStart.length,
        settingsEnd,
      ).trim();
    }

    // Parse JSON
    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonStart);
      settings._settings.addAll(parsed);
    } catch (e) {
      // JSON parsing failed, ignore settings
      print('Failed to parse document settings: $e');
    }

    return ParseResult(
      settings: settings,
      contentRange: ContentRange(0, settingsStart),
    );
  }

  /// Generate the settings string to append to a file
  String toSettingsString() {
    if (_settings.isEmpty) return '';

    final json = jsonEncode(_settings);
    return '\n$settingsBlockStart\n$json\n$settingsBlockEnd';
  }

  /// Get all settings as a map
  Map<String, dynamic> toMap() => Map.from(_settings);

  @override
  String toString() => 'DocumentSettings($_settings)';
}

/// Result of parsing settings from a file
class ParseResult {
  final DocumentSettings settings;
  final ContentRange contentRange;

  const ParseResult({
    required this.settings,
    required this.contentRange,
  });
}

/// Range of content in the file
class ContentRange {
  final int start;
  final int end;

  const ContentRange(this.start, this.end);

  int get length => end - start;
}
