import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'editor.dart';

/// API to control the `HtmlEditor`.
///
/// Get access to this API either by waiting for the `HtmlEditor.onCreated()` callback or by accessing
/// the `HtmlEditorState` with a `GlobalKey<HtmlEditorState>`.
class EditorApi {
  InAppWebViewController _webViewController;
  final HtmlEditorState _htmlEditorState;

  set webViewController(InAppWebViewController value) =>
      _webViewController = value;

  /// Define any custom CSS styles, replacing the existing styles.
  ///
  /// Also compare [customStyles].
  set styles(String value) => _htmlEditorState.styles = value;

  /// Define any custom CSS styles, ammending the default styles
  ///
  /// Also compare [styles].
  set customStyles(String value) => _htmlEditorState.styles += value;

  /// Callback to be informed when the API can be used fully.
  void Function() onReady;

  /// Callback to be informed when the format settings have been changed
  void Function(FormatSettings) onFormatSettingsChanged;

  /// Callback to be informed when the align settings have been changed
  void Function(ElementAlign) onAlignSettingsChanged;

  EditorApi(this._htmlEditorState);

  /// Formats the current text to be bold
  Future formatBold() {
    return _execCommand('"bold"');
  }

  /// Formats the current text to be italic
  Future formatItalic() {
    return _execCommand('"italic"');
  }

  /// Formats the current text to be underlined
  Future formatUnderline() {
    return _execCommand('"underline"');
  }

  /// Inserts an ordered list at the current position
  Future insertOrderedList() {
    return _execCommand('"insertOrderedList"');
  }

  /// Inserts an unordered list at the current position
  Future insertUnorderedList() {
    return _execCommand('"insertUnorderedList"');
  }

  /// Formats the current paragraph to align left
  Future formatAlignLeft() {
    return _execCommand('"justifyLeft"');
  }

  /// Formats the current paragraph to align right
  Future formatAlignRight() {
    return _execCommand('"justifyRight"');
  }

  /// Formats the current paragraph to center
  Future formatAlignCenter() {
    return _execCommand('"justifyCenter"');
  }

  /// Formats the current paragraph to justify
  Future formatAlignJustify() {
    return _execCommand('"justifyFull"');
  }

  /// Inserts the specified HTML code
  Future insertHtml(String html) {
    html = html.replaceAll('"', r'\"');
    return _execCommand('"insertHTML", false, "$html"');
  }

  Future _execCommand(String command) async {
    await _webViewController.evaluateJavascript(
        source: 'document.execCommand($command);');
    // document.getElementById("editor").focus();
// FocusScope.of(context).unfocus();
// Timer(const Duration(milliseconds: 1), () {
    // FocusScope.of(context).requestFocus();
// });
  }

  /// Retrieves the edited text as HTML
  ///
  /// Compare [getFullHtml()] to the complete HTML document's text.
  Future<String> getText() async {
    final innerHtml = await _webViewController.evaluateJavascript(
        source: 'document.getElementById("editor").innerHTML;') as String;
    return innerHtml;
  }

  /// Retrieves the edited text within a complete HTML document.
  ///
  /// Optionally specify the [content] if you have previously called [getText()] for other reasons.
  /// Compare [getText()] to retrieve only the edited HTML text.
  Future<String> getFullHtml({String content}) async {
    content ??= await getText();
    final styles = _htmlEditorState.styles;
    return '''<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="content-type" content="text/html;charset="utf-8">
<style>$styles</style>
</head>
<body>$content</body>
</html>''';
  }
}
