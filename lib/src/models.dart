import 'package:flutter/widgets.dart';

import 'editor_api.dart';

/// Standard format settings
class FormatSettings {
  /// Creates new format settings
  const FormatSettings({
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikeThrough = false,
  });

  /// is the current text bold?
  final bool isBold;

  /// is the current text italic?
  final bool isItalic;

  /// is the current text underlined?
  final bool isUnderline;

  /// is the current text striked through?
  final bool isStrikeThrough;
}

/// Standard color settings
class ColorSetting {
  /// Creates new color settings
  const ColorSetting(this.textForeground, this.textBackground);

  /// The foreground color
  final Color? textForeground;

  /// The background hightlight color
  final Color? textBackground;
}

/// Link settings
class LinkSettings {
  /// Creates new link settings
  const LinkSettings(this.url, this.text);

  /// The URL of the link
  final String url;

  /// The displayed text for the link
  final String text;
}

/// Standard align settings
enum ElementAlign {
  /// left aligned
  left,

  /// centered
  center,

  /// right aligned
  right,

  /// justified text
  justify,
}

/// Abstracts a text selection menu item.
class TextSelectionMenuItem {
  /// Creates a new selection menu item with the specified [label] and [action].
  const TextSelectionMenuItem({required this.label, required this.action});

  /// The text label of the item
  final String label;

  /// The callback
  final dynamic Function(HtmlEditorApi api) action;
}

/// Font-sizes
enum FontSize {
  /// XS very small
  xSmall,

  /// S small
  small,

  /// M medium
  medium,

  /// L large
  large,

  /// XL very large
  xLarge,

  /// XXL very very large
  xxLarge,

  /// XXXL very very very large
  xxxLarge,
}

/// Encapsulates the font size (for now)
class FontSetting {
  /// Creates new font settings
  const FontSetting(this.fontSize);

  /// The size of the current text
  final FontSize fontSize;
}

/// Contains safe font names that can be used across mobile, web and desktop
enum SafeFont {
  /// sans serif
  sansSerif,

  /// serif
  serif,

  /// monospace
  monospace,

  /// cursive
  cursive,

  /// courier
  courier,

  /// times new roman
  timesNewRoman,
}

/// Extends SafeFont
extension SafeFontNamesExtension on SafeFont {
  /// Retrieves the name of this font
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

/// The position relative to the element
enum PositionRelative {

  /// Before the element. Only valid if the element is in the DOM tree and has
  /// a parent element.
  beforeBegin('beforebegin'),

  /// Just inside the element, before its first child.
  afterBegin('afterbegin'),

  /// Just inside the element, after its last child.
  beforeEnd('beforeend'),

  /// After the element. Only valid if the element is in the DOM tree and has a
  /// parent element.
  afterEnd('afterend');

  /// Constructor
  const PositionRelative(this.value);

  /// Value
  final String value;
}