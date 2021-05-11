import 'package:flutter/widgets.dart';

import 'editor_api.dart';

/// Standard format settings
class FormatSettings {
  final isBold;
  final isItalic;
  final isUnderline;
  final isStrikeThrough;
  FormatSettings(
      this.isBold, this.isItalic, this.isUnderline, this.isStrikeThrough);
}

/// Standard color settings
class ColorSetting {
  final Color? textForeground;
  final Color? textBackground;

  ColorSetting(this.textForeground, this.textBackground);
}

/// Link settings
class LinkSettings {
  final String url;
  final String text;

  LinkSettings(this.url, this.text);
}

/// Standard align settings
enum ElementAlign { left, center, right, justify }

/// Abstracts a text selection menu item.
class TextSelectionMenuItem {
  /// The text label of the item
  final String label;

  /// The callback
  final dynamic Function(HtmlEditorApi api) action;

  /// Creates a new selection menu item with the specified [label] and [action].
  TextSelectionMenuItem({required this.label, required this.action});
}

/// Font-sizes
enum FontSize { xSmall, small, medium, large, xLarge, xxLarge, xxxLarge }

/// Encapsulates the font size (for now)
class FontSetting {
  final FontSize fontSize;
  FontSetting(this.fontSize);
}

/// Contains safe font names that can be used across mobile, web and desktop
enum SafeFont {
  sansSerif,
  serif,
  monospace,
  cursive,
  courier,
  timesNewRoman,
}

extension SafeFontNamesExtension on SafeFont {
  String get name {
    switch (this) {
      case SafeFont.sansSerif:
        return 'sans-serif';
      case SafeFont.serif:
        return 'serif';
      case SafeFont.monospace:
        return 'monospace';
      case SafeFont.cursive:
        return 'cursive';
      case SafeFont.courier:
        return 'Courier';
      case SafeFont.timesNewRoman:
        return 'Times New Roman';
    }
  }
}
