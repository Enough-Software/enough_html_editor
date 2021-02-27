import 'editor.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EditorApi {
  WebViewController _webViewController;
  final HtmlEditorState _htmlEditorState;

  set webViewController(WebViewController value) => _webViewController = value;

  void Function() onReady;
  void Function(FormatSettings) onFormatSettingsChanged;
  void Function(ElementAlign) onAlignSettingsChanged;

  EditorApi(this._htmlEditorState);

  Future formatBold() {
    return _execCommand('"bold"');
  }

  Future formatItalic() {
    return _execCommand('"italic"');
  }

  Future formatUnderline() {
    return _execCommand('"underline"');
  }

  Future insertOrderedList() {
    return _execCommand('"insertOrderedList"');
  }

  Future insertUnorderedList() {
    return _execCommand('"insertUnorderedList"');
  }

  Future formatAlignLeft() {
    return _execCommand('"justifyLeft"');
  }

  Future formatAlignRight() {
    return _execCommand('"justifyRight"');
  }

  Future formatAlignCenter() {
    return _execCommand('"justifyCenter"');
  }

  Future formatAlignJustify() {
    return _execCommand('"justifyFull"');
  }

  Future insertHtml(String html) {
    html = html.replaceAll('"', r'\"');
    return _execCommand('"insertHTML", false, "$html"');
  }

  Future _execCommand(String command) async {
    await _webViewController
        .evaluateJavascript('document.execCommand($command);');
    // document.getElementById("editor").focus();
// FocusScope.of(context).unfocus();
// Timer(const Duration(milliseconds: 1), () {
    // FocusScope.of(context).requestFocus();
// });
  }

  /// Retrieves the edited text as HTML
  Future<String> getText() async {
    var rawHtml = await _webViewController
        .evaluateJavascript('document.getElementById("editor").innerHTML;');
    if (rawHtml.startsWith('"')) {
      rawHtml = rawHtml.substring(1, rawHtml.length - 1).trim();
    }
    rawHtml = rawHtml.replaceAll(r'\n', '\n');
    rawHtml = rawHtml.replaceAll(r'\"', '"');
    rawHtml = rawHtml.replaceAll(r'\\', r'\');
    rawHtml = rawHtml.replaceAll(r'\u003C', '<');
    return rawHtml;
  }
}
