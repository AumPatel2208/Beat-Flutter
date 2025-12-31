import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// Screenplay stylesheet configuration
/// 
/// Defines the visual styling for screenplay elements following
/// industry-standard screenplay formatting.
class ScreenplayStylesheet {
  /// Standard screenplay font (Courier Prime)
  static const String screenplayFontFamily = 'Courier Prime';

  /// Standard screenplay font size (12pt)
  static const double screenplayFontSize = 16.0; // 12pt at standard DPI

  /// Standard line height for screenplays
  static const double lineHeight = 1.0;

  /// Page margins (in logical pixels, approximating 1 inch = 96px)
  static const double leftMargin = 96.0; // 1 inch
  static const double rightMargin = 96.0; // 1 inch

  /// Element-specific margins (from left edge of text area)
  static const double characterLeftMargin = 192.0; // ~2 inches from left
  static const double dialogueLeftMargin = 96.0; // 1 inch from left
  static const double dialogueRightMargin = 144.0; // 1.5 inches from right
  static const double parentheticalLeftMargin = 144.0; // 1.5 inches from left
  static const double parentheticalRightMargin = 192.0; // 2 inches from right
  static const double transitionLeftMargin = 288.0; // 4 inches from left

  /// Create the default screenplay stylesheet
  static Stylesheet createStylesheet() {
    return defaultStylesheet.copyWith(
      addRulesAfter: [
        // Scene Heading
        StyleRule(
          const BlockSelector('sceneHeading'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              fontWeight: FontWeight.bold,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': const CascadingPadding.only(top: 24, bottom: 12),
          },
        ),

        // Action
        StyleRule(
          const BlockSelector('action'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': const CascadingPadding.only(top: 12, bottom: 12),
          },
        ),

        // Character
        StyleRule(
          const BlockSelector('character'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': CascadingPadding.only(
              top: 12,
              left: characterLeftMargin,
            ),
            'textAlign': TextAlign.left,
          },
        ),

        // Dialogue
        StyleRule(
          const BlockSelector('dialogue'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': CascadingPadding.only(
              left: dialogueLeftMargin,
              right: dialogueRightMargin,
            ),
          },
        ),

        // Parenthetical
        StyleRule(
          const BlockSelector('parenthetical'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': CascadingPadding.only(
              left: parentheticalLeftMargin,
              right: parentheticalRightMargin,
            ),
          },
        ),

        // Transition
        StyleRule(
          const BlockSelector('transition'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': CascadingPadding.only(
              top: 12,
              bottom: 12,
              left: transitionLeftMargin,
            ),
          },
        ),

        // Centered
        StyleRule(
          const BlockSelector('centered'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': const CascadingPadding.only(top: 12, bottom: 12),
            'textAlign': TextAlign.center,
          },
        ),

        // Lyrics
        StyleRule(
          const BlockSelector('lyrics'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              fontStyle: FontStyle.italic,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': const CascadingPadding.only(top: 12, bottom: 12),
          },
        ),

        // Section (outline element - styled differently)
        StyleRule(
          const BlockSelector('section'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize * 1.2,
              fontWeight: FontWeight.bold,
              height: lineHeight,
              color: Colors.grey,
            ),
            'padding': const CascadingPadding.only(top: 24, bottom: 12),
          },
        ),

        // Synopsis (outline element - styled differently)
        StyleRule(
          const BlockSelector('synopsis'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              fontStyle: FontStyle.italic,
              height: lineHeight,
              color: Colors.grey,
            ),
            'padding': const CascadingPadding.only(top: 6, bottom: 6),
          },
        ),

        // Page Break (displayed as centered === with visual styling)
        StyleRule(
          const BlockSelector('pageBreak'),
          (doc, node) => {
            'textStyle': TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.grey.shade500,
              letterSpacing: 4,
            ),
            'textAlign': TextAlign.center,
            'padding': const CascadingPadding.symmetric(vertical: 12),
          },
        ),

        // Title Page elements
        StyleRule(
          const BlockSelector('titlePage'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.black,
            ),
            'padding': const CascadingPadding.only(top: 6, bottom: 6),
            'textAlign': TextAlign.center,
          },
        ),

        // Note attribution (inline styling)
        StyleRule(
          BlockSelector.all,
          (doc, node) => {
            'inlineTextStyler': (attributions, style) {
              TextStyle newStyle = style;
              
              // Check for note attribution
              if (attributions.contains(const NamedAttribution('note'))) {
                newStyle = newStyle.copyWith(
                  color: Colors.orange.shade700,
                  backgroundColor: Colors.orange.shade50,
                );
              }
              
              return newStyle;
            },
          },
        ),
      ],
    );
  }

  /// Create a dark mode screenplay stylesheet
  static Stylesheet createDarkStylesheet() {
    return defaultStylesheet.copyWith(
      addRulesAfter: [
        // Scene Heading
        StyleRule(
          const BlockSelector('sceneHeading'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              fontWeight: FontWeight.bold,
              height: lineHeight,
              color: Colors.white,
            ),
            'padding': const CascadingPadding.only(top: 24, bottom: 12),
          },
        ),

        // Action
        StyleRule(
          const BlockSelector('action'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.white,
            ),
            'padding': const CascadingPadding.only(top: 12, bottom: 12),
          },
        ),

        // Character
        StyleRule(
          const BlockSelector('character'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.white,
            ),
            'padding': CascadingPadding.only(
              top: 12,
              left: characterLeftMargin,
            ),
          },
        ),

        // Dialogue
        StyleRule(
          const BlockSelector('dialogue'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.white,
            ),
            'padding': CascadingPadding.only(
              left: dialogueLeftMargin,
              right: dialogueRightMargin,
            ),
          },
        ),

        // Parenthetical
        StyleRule(
          const BlockSelector('parenthetical'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.white,
            ),
            'padding': CascadingPadding.only(
              left: parentheticalLeftMargin,
              right: parentheticalRightMargin,
            ),
          },
        ),

        // Transition
        StyleRule(
          const BlockSelector('transition'),
          (doc, node) => {
            'textStyle': const TextStyle(
              fontFamily: screenplayFontFamily,
              fontSize: screenplayFontSize,
              height: lineHeight,
              color: Colors.white,
            ),
            'padding': CascadingPadding.only(
              top: 12,
              bottom: 12,
              left: transitionLeftMargin,
            ),
          },
        ),

        // Other styles follow same pattern with Colors.white...
      ],
    );
  }
}
