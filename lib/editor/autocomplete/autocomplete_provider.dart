import 'package:flutter/material.dart';

import '../../fountain_parser/fountain_parser.dart';

/// Provides autocompletion suggestions for screenplay elements.
/// 
/// Supports:
/// - Character name completion (from existing character cues)
/// - Scene heading prefixes (INT., EXT., etc.)
class AutocompleteProvider {
  AutocompleteProvider({
    required this.parser,
  });

  final ContinuousFountainParser parser;

  /// Get character name suggestions based on input
  List<String> getCharacterSuggestions(String input) {
    if (input.isEmpty) {
      // Return all character names sorted by frequency
      return _getCharacterNamesByFrequency();
    }

    final upperInput = input.toUpperCase();
    final names = parser.characterNames;
    
    // Filter and sort by relevance
    final matches = names
        .where((name) => name.toUpperCase().startsWith(upperInput))
        .toList();
    
    // Sort by frequency (most used first)
    matches.sort((a, b) {
      final aCount = _getCharacterFrequency(a);
      final bCount = _getCharacterFrequency(b);
      return bCount.compareTo(aCount);
    });

    return matches;
  }

  /// Get scene heading suggestions based on input
  List<String> getSceneHeadingSuggestions(String input) {
    final suggestions = <String>[];
    final upperInput = input.toUpperCase();

    // Standard prefixes
    const prefixes = [
      'INT. ',
      'EXT. ',
      'INT./EXT. ',
      'EXT./INT. ',
      'I/E. ',
    ];

    // Add matching prefixes
    for (final prefix in prefixes) {
      if (prefix.startsWith(upperInput)) {
        suggestions.add(prefix);
      }
    }

    // If input has a prefix, suggest existing locations
    if (_hasScenePrefix(upperInput)) {
      final locations = _getUniqueLocations();
      final prefixEnd = _findPrefixEnd(upperInput);
      final locationPart = upperInput.substring(prefixEnd).trim();

      for (final location in locations) {
        if (location.toUpperCase().startsWith(locationPart.toUpperCase())) {
          // Reconstruct with the original prefix
          final prefix = upperInput.substring(0, prefixEnd);
          suggestions.add('$prefix$location');
        }
      }
    }

    return suggestions;
  }

  /// Get all character names sorted by frequency
  List<String> _getCharacterNamesByFrequency() {
    final names = parser.characterNames.toList();
    names.sort((a, b) {
      final aCount = _getCharacterFrequency(a);
      final bCount = _getCharacterFrequency(b);
      return bCount.compareTo(aCount);
    });
    return names;
  }

  /// Count how many times a character appears
  int _getCharacterFrequency(String characterName) {
    return parser.characterCues
        .where((line) => line.characterName?.toUpperCase() == characterName.toUpperCase())
        .length;
  }

  /// Check if input starts with a scene heading prefix
  bool _hasScenePrefix(String input) {
    const prefixes = ['INT.', 'EXT.', 'INT./EXT.', 'EXT./INT.', 'I/E.', 'E/I.'];
    final upper = input.toUpperCase();
    return prefixes.any((p) => upper.startsWith(p));
  }

  /// Find where the prefix ends in the input
  int _findPrefixEnd(String input) {
    const prefixes = ['INT./EXT. ', 'EXT./INT. ', 'I/E. ', 'E/I. ', 'INT. ', 'EXT. '];
    final upper = input.toUpperCase();
    
    for (final prefix in prefixes) {
      if (upper.startsWith(prefix)) {
        return prefix.length;
      }
    }
    return 0;
  }

  /// Extract unique location names from existing scene headings
  Set<String> _getUniqueLocations() {
    final locations = <String>{};
    
    for (final heading in parser.sceneHeadings) {
      final text = heading.string;
      final upper = text.toUpperCase();
      
      // Find where the prefix ends
      int start = 0;
      for (final prefix in ContinuousFountainParser.sceneHeadingPrefixes) {
        if (upper.startsWith(prefix)) {
          start = prefix.length;
          break;
        }
      }
      
      // Extract location (before time of day marker)
      var location = text.substring(start).trim();
      
      // Remove time of day (- DAY, - NIGHT, etc.)
      final dashIndex = location.lastIndexOf(' - ');
      if (dashIndex > 0) {
        location = location.substring(0, dashIndex).trim();
      }
      
      if (location.isNotEmpty) {
        locations.add(location);
      }
    }
    
    return locations;
  }

  /// Get time of day suggestions
  List<String> getTimeOfDaySuggestions() {
    return [
      'DAY',
      'NIGHT',
      'MORNING',
      'EVENING',
      'AFTERNOON',
      'DAWN',
      'DUSK',
      'LATER',
      'CONTINUOUS',
      'MOMENTS LATER',
    ];
  }
}

/// Overlay widget for showing autocomplete suggestions
class AutocompleteOverlay extends StatelessWidget {
  const AutocompleteOverlay({
    super.key,
    required this.suggestions,
    required this.onSelect,
    this.selectedIndex = 0,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelect;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200,
          maxWidth: 300,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final isSelected = index == selectedIndex;
            return InkWell(
              onTap: () => onSelect(suggestions[index]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: isSelected ? Colors.blue.shade50 : null,
                child: Text(
                  suggestions[index],
                  style: TextStyle(
                    fontFamily: 'Courier Prime',
                    fontSize: 14,
                    color: isSelected ? Colors.blue.shade700 : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
