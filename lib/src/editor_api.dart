import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image/image.dart' as img;
import 'editor.dart';
import 'models.dart';

/// API to control the `HtmlEditor`.
///
/// Get access to this API either by waiting for the `HtmlEditor.onCreated()`
/// callback or by accessing the `HtmlEditorState` with a
/// `GlobalKey<HtmlEditorState>`.
class HtmlEditorApi {
  /// Creates a new HTLML editor api
  HtmlEditorApi(HtmlEditorState htmlEditorState)
      : _htmlEditorState = htmlEditorState;

  late InAppWebViewController _webViewController;
  final HtmlEditorState _htmlEditorState;

  /// The document's background color, defaults to `null`
  String? _documentBackgroundColor;

  /// The document's foreground color, defaults to `null`
  String? _documentForegroundColor;

  /// The web view controller allows direct interactions
  // ignore: unnecessary_getters_setters
  InAppWebViewController get webViewController => _webViewController;
  set webViewController(InAppWebViewController value) {
    _webViewController = value;
    //TODO wait for InAppWebView project to approve this
    //value.onImeCommitContent = _onImeCommitContent;
  }

  // void _onImeCommitContent(String mimeType, Uint8List data) {
  //   // print('HtmlEditor: onImeCommitContent: received $mimeType');
  //   insertImageData(data, mimeType);
  // }

  /// Define any custom CSS styles, replacing the existing styles.
  ///
  /// Also compare [customStyles].
  String get styles => _htmlEditorState.styles;
  set styles(String value) => _htmlEditorState.styles = value;

  /// Define any custom CSS styles, ammending the default styles
  ///
  /// Also compare [styles].
  String get customStyles => _htmlEditorState.styles;
  //TODO if called several times, this will change the custom styles each time
  set customStyles(String value) => _htmlEditorState.styles += value;

  /// Callback to be informed when the API can be used fully.
  void Function()? onReady;

  /// Callback to be informed when the format settings have been changed
  void Function(FormatSettings)? onFormatSettingsChanged;

  /// Callback to be informed when the align settings have been changed
  void Function(ElementAlign)? onAlignSettingsChanged;

  /// Callback to be informed when the font size has been changed
  void Function(FontSize)? onFontSizeChanged;

  /// Callback to be informed when the font family has been changed
  void Function(SafeFont?)? onFontFamilyChanged;

  final List<void Function(ColorSetting)> _colorChangedSettings = [];

  /// Callback to be informed when the color settings have been changed
  set onColorChanged(void Function(ColorSetting)? value) {
    if (value != null && !_colorChangedSettings.contains(value)) {
      _colorChangedSettings.add(value);
    }
  }

  /// Getter for color changes callback
  void Function(ColorSetting)? get onColorChanged {
    if (_colorChangedSettings.isEmpty) {
      return null;
    }
    return _callOnColorChanged;
  }

  /// Callback to be informed when the link settings have been changed.
  ///
  /// Getting a `null` value as the current link settings means that
  /// no link is currently selected
  void Function(LinkSettings?)? onLinkSettingsChanged;

  void _callOnColorChanged(ColorSetting colorSetting) {
    for (final callback in _colorChangedSettings) {
      callback(colorSetting);
    }
  }

  /// Removes the focus from the editor
  Future unfocus(BuildContext context) async {
    //TODO consider to re-implement or check if focus node works with
    // webview 3.0
    //await _webViewController.clearFocus();
    // _htmlEditorState.unfocus();
    FocusScope.of(context).unfocus();
  }

  /// Formats the current text to be bold
  Future formatBold() => _execCommand('"bold"');

  /// Formats the current text to be italic
  Future formatItalic() => _execCommand('"italic"');

  /// Formats the current text to be underlined
  Future formatUnderline() => _execCommand('"underline"');

  /// Formats the current text to be striked through
  Future formatStrikeThrough() => _execCommand('"strikeThrough"');

  /// Inserts an ordered list at the current position
  Future insertOrderedList() => _execCommand('"insertOrderedList"');

  /// Inserts an unordered list at the current position
  Future insertUnorderedList() => _execCommand('"insertUnorderedList"');

  /// Formats the current paragraph to align left
  Future formatAlignLeft() => _execCommand('"justifyLeft"');

  /// Formats the current paragraph to align right
  Future formatAlignRight() => _execCommand('"justifyRight"');

  /// Formats the current paragraph to center
  Future formatAlignCenter() => _execCommand('"justifyCenter"');

  /// Formats the current paragraph to justify
  Future formatAlignJustify() => _execCommand('"justifyFull"');

  /// Formats the current paragraph to indent
  Future formatIndent() => _execCommand('"indent"');

  /// Formats the current paragraph to outdent
  Future formatOutent() => _execCommand('"outdent"');

  /// Sets the [size] of the selected text
  Future setFontSize(FontSize size) =>
      _execCommand('"fontSize", false, ${size.index + 1}');

  /// Sets the [font] of the selected text
  Future setFont(SafeFont font) => setFontFamily(font.name);

  /// Sets the [fontFamilyName] of the selected text
  Future setFontFamily(String fontFamilyName) =>
      _execCommand('"fontName", false, "$fontFamilyName"');

  /// Formats the current text to be header style select
  Future formatHeader(String headerStyle) async {
    await _execCommand('"formatBlock", false, "$headerStyle"');
  }

  /// Inserts the  [html] code at the insertion point (replaces selection).
  Future insertHtml(String html) async {
    final insertHtml = html.replaceAll('"', r'\"');
    await _execCommand('"insertHTML", false, "$insertHtml"');
    return _htmlEditorState.onDocumentChanged();
  }

  /// Inserts the given plain [text] at the insertion point
  /// (replaces selection).
  Future insertText(String text) async {
    await _execCommand('"insertText", false, "$text"');
    return _htmlEditorState.onDocumentChanged();
  }

  /// Inserts a link to [href] at the current position (replaces selection).
  ///
  /// Optionally specify the user-visible [text], by default the [href]
  /// will be user visible.
  ///
  /// You can define a link [target] such as `'_blank'`,
  /// by default no target will be defined.
  Future insertLink(String href, {String? text, String? target}) {
    final buffer = StringBuffer()
      ..write('<a href="')
      ..write(href)
      ..write('"');
    if (target != null) {
      buffer
        ..write(' target="')
        ..write(target)
        ..write('"');
    }
    buffer
      ..write('>')
      ..write(text ?? href)
      ..write('</a>');
    final html = buffer.toString();
    return insertHtml(html);
  }

  /// Converts the given [file] with the specifid [mimeType] into
  /// image data and inserts it into the editor.
  ///
  /// Optionally set the given [maxWidth] for the decoded image.
  Future insertImageFile(File file, String mimeType, {int? maxWidth}) async {
    final data = await file.readAsBytes();
    return insertImageData(data, mimeType, maxWidth: maxWidth);
  }

  /// Inserts the given image [data] with the specifid [mimeType]
  /// into the editor.
  ///
  /// Optionally set the given [maxWidth] for the decoded image.
  Future insertImageData(Uint8List data, String mimeType,
      {int? maxWidth}) async {
    if (maxWidth != null) {
      final image = img.decodeImage(data);
      if (image == null) {
        return;
      }
      if (image.width > maxWidth) {
        final copy = img.copyResize(image, width: maxWidth);
        // ignore: parameter_assignments
        data = img.encodePng(copy) as Uint8List;
        // ignore: parameter_assignments
        mimeType = 'image/png';
      }
    }
    final base64Data = base64Encode(data);
    return insertHtml(
        '<img src="data:$mimeType;base64,$base64Data" style="max-width: 100%" />');
  }

  /// Covert a link to [src] at the current position (replaces selection) into
  /// image data and inserts it into the editor.
  ///
  /// You can define a link [alt] such as `'_blank'`,
  /// by default no target will be defined.
  Future insertImageLink(String src, {String alt = 'image body'}) =>
      insertHtml('<img src="$src" alt="$alt" style="max-width: 100%" />');

  String _toHex(Color color) {
    final buffer = StringBuffer();
    _appendHex(color.red, buffer);
    _appendHex(color.green, buffer);
    _appendHex(color.blue, buffer);
    return buffer.toString();
  }

  void _appendHex(int value, StringBuffer buffer) {
    final text = value.toRadixString(16);
    if (text.length < 2) {
      buffer.write('0');
    }
    buffer.write(text);
  }

  String _getColor(Color color, double opacity) {
    if (opacity < 1.0) {
      return 'rgba(${color.red},${color.green},${color.blue},$opacity)';
    }
    return '#${_toHex(color)}';
  }

  /// Sets the given [color] as the current foreground / text color.
  ///
  /// Optionally specify the [opacity] being between `1.0` (fully opaque)
  /// and `0.0` (fully transparent).
  Future setColorTextForeground(Color color, {double opacity = 1.0}) async {
    final colorText = _getColor(color, opacity);
    return _execCommand('"foreColor", false, "$colorText"');
  }

  /// Sets the given [color] as the current text background color.
  ///
  /// Optionally specify the [opacity] being between `1.0` (fully opaque) and
  /// `0.0` (fully transparent).
  Future setColorTextBackground(Color color, {double opacity = 1.0}) async {
    final colorText = _getColor(color, opacity);
    return _execCommand('"backColor", false, "$colorText"');
  }

  /// Sets the document's background color
  Future setColorDocumentBackground(Color color) async {
    final colorText = _getColor(color, 1.0);
    _documentBackgroundColor = colorText;
    return _webViewController.evaluateJavascript(
        source: 'document.body.style.backgroundColor="$colorText";');
  }

  /// Sets the document's foreground color
  Future setColorDocumentForeground(Color color) async {
    final colorText = _getColor(color, 1.0);
    _documentForegroundColor = colorText;
    return _webViewController.evaluateJavascript(
        source: 'document.body.style.color="$colorText";');
  }

  Future _execCommand(String command) async {
    await _webViewController.evaluateJavascript(
        source: 'document.execCommand($command);');
  }

  /// Retrieves the edited text as HTML
  ///
  /// Compare [getFullHtml()] to the complete HTML document's text.
  Future<String> getText() async {
    final innerHtml = await _webViewController.evaluateJavascript(
        source: 'document.getElementById("editor").innerHTML;');
    return innerHtml;
  }

  /// Retrieves the edited text within a complete HTML document.
  ///
  /// Optionally specify the [content] if you have previously called [getText]
  /// for other reasons.
  ///
  /// Compare [getText] to retrieve only the edited HTML text.
  Future<String> getFullHtml({String? content}) async {
    content ??= await getText();
    final bodyStyle =
        (_documentBackgroundColor != null && _documentForegroundColor != null)
            ? ' style="color: $_documentForegroundColor;'
                'background-color: $_documentBackgroundColor;"'
            : _documentForegroundColor != null
                ? ' style="color: $_documentForegroundColor;"'
                : _documentBackgroundColor != null
                    ? ' style="background-color: $_documentBackgroundColor;"'
                    : '';
    final styles = _htmlEditorState.styles
        .replaceFirst('''#editor {
  min-height: ==minHeight==px;
}''', '');
    return '''<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="content-type" content="text/html;charset="utf-8">
<style>$styles</style>
</head>
<body$bodyStyle>$content</body>
</html>''';
  }

  /// Retrieves the currently selected text.
  Future<String?> getSelectedText() async {
    final text = await _webViewController.evaluateJavascript(
        source: '''document.getSelection().getRangeAt(0).toString();''');
    if (text.isEmpty || text == 'null') {
      return null;
    }
    return _removeQuotes(text);
  }

  String _removeQuotes(String text) {
    if (text.length > 1 && text.startsWith('"') && text.endsWith('"')) {
      return text.substring(1, text.length - 1);
    }
    return text;
  }

  /// Stores the current selection and retrieves the selected text.
  ///
  /// Compare [restoreSelectionRange]
  Future<String> storeSelectionRange() async {
    final text = await _webViewController.evaluateJavascript(
        source: 'storeSelectionRange();');
    return _removeQuotes(text);
  }

  /// Restores the previously stored selection range
  ///
  /// Compare [storeSelectionRange]
  Future restoreSelectionRange() =>
      _webViewController.evaluateJavascript(source: 'restoreSelectionRange();');

  /// Replaces all text parts [from] with the replacement [replace]
  /// and returns the updated text.
  Future<String> replaceAll(String from, String replace) async {
    final text = (await getText()).replaceAll(from, replace);
    await setText(text);
    return text;
  }

  /// Sets the given text, replacing the previous text completely
  Future<void> setText(String text) {
    final html = _htmlEditorState.generateHtmlDocument(text);
    return _webViewController.evaluateJavascript(source: html);
  }

  /// Selects the HTML DOM node at the current position fully.
  Future<void> selectCurrentNode() =>
      _webViewController.evaluateJavascript(source: 'selectNode();');

  /// Updates the currently selected link with the url [href] and [text].
  Future<void> editCurrentLink(String href, String text) => _webViewController
      .evaluateJavascript(source: "editLink('$href', '$text');");

  /// Insert signature
  Future<void> insertSignature(String signature) => _webViewController
      .evaluateJavascript(source: "insertSignature('$signature');");

  /// Remove signature
  Future<void> removeSignature() => _webViewController
      .evaluateJavascript(source: 'removeSignature();');
}
