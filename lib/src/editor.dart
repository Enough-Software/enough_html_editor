import 'dart:io';
import 'dart:convert';
import 'editor_api.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Standard format settings
class FormatSettings {
  final isBold;
  final isItalic;
  final isUnderline;
  FormatSettings(this.isBold, this.isItalic, this.isUnderline);
}

/// Standard align settings
enum ElementAlign { left, center, right, justify }

/// Slim HTML Editor with API
class HtmlEditor extends StatefulWidget {
  /// Set the [initialContent] to populate the editor with some existing text
  final String initialContent;

  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  final bool adjustHeight;

  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  final int minHeight;

  /// Define the `onCreated(EditorApi)` callback to get notified when the API is ready.
  final void Function(EditorApi) onCreated;

  /// Creates a new HTML editor
  ///
  /// Set the [initialContent] to populate the editor with some existing text
  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  /// Define the `onCreated(EditorApi)` callback to get notified when the API is ready.
  HtmlEditor(
      {Key key,
      this.initialContent = '',
      this.adjustHeight = true,
      this.minHeight = 100,
      this.onCreated})
      : super(key: key);

  @override
  HtmlEditorState createState() => HtmlEditorState();
}

/// You can access the API by accessing the HtmlEditor's state.
/// The editor state can be accessed directly when using a GlobalKey<HtmlEditorState>.
class HtmlEditorState extends State<HtmlEditor> {
  static const String _template = '''
<!DOCTYPE html>
<html>
<head>
<style>==styles==
</style>
<script>
  var isSelectionBold = false;
  var isSelectionItalic = false;
  var isSelectionUnderline = false;
  var selectionTextAlign = undefined;
  var documentHeight;

  function onSelectionChange() {
    //console.log|("onSelectionChange");
    let {anchorNode, anchorOffset, focusNode, focusOffset} = document.getSelection();
    // traverse all parents to find <b>, <i> or <u> elements:
    var isBold = false;
    var isItalic = false;
    var isUnderline = false;
    var node = anchorNode;
    var textAlign = undefined;
    while (node.parentNode != null && node.id != 'editor') {
        if (node.nodeName == 'B') {
            isBold = true;
        } else if (node.nodeName == 'I') {
            isItalic = true;
        } else if (node.nodeName == 'U') {
            isUnderline = true;
        }
        if (textAlign == undefined && node.style?.textAlign != undefined && node.style.textAlign != '') {
          textAlign = node.style.textAlign;
        }
        node = node.parentNode;
    }
    if (isBold != isSelectionBold || isItalic != isSelectionItalic || isUnderline != isSelectionUnderline) {
        isSelectionBold = isBold;
        isSelectionItalic = isItalic;
        isSelectionUnderline = isUnderline;
        //console.log('bold=', isBold, ', italic=', isItalic, ', underline=', isUnderline);
        var message = 0;
        if (isBold) {
            message += 1;
        }
        if (isItalic) {
            message += 2;
        }
        if (isUnderline) {
            message += 4;
        }
        FormatSettings.postMessage(message);
    }
    if (textAlign != selectionTextAlign) {
        selectionTextAlign = textAlign;
        AlignSettings.postMessage(textAlign);
    }
  }

  function onInput() {
    var height = document.body.scrollHeight;
    if (height != documentHeight) {
        documentHeight = height;
        InternalUpdate.postMessage('h' + height);
    }
  }

  function onFocus() {
    InternalUpdate.postMessage('onfocus');
  }

  function onLoaded() {
      documentHeight = document.body.scrollHeight;
  }

  document.onselectionchange = onSelectionChange;
</script>
</head>
<body onload="onLoaded();">
<div id="editor" contenteditable="true" oninput="onInput();" onfocus="onFocus();">
==content==
</div>
</body>
</html>
''';
  String _initialPageContent;
  WebViewController _webViewController;
  double _documentHeight;
  EditorApi _api;

  /// Allows to replace the existing styles.
  String styles = '''
blockquote {
  font: normal helvetica, sans-serif;
  margin-top: 10px;
  margin-bottom: 10px;
  margin-left: 20px;
  padding-left: 15px;
  border-left: 3px solid #ccc;
}
#editor {
  min-height: ==minHeight==px;
}
  ''';

  /// Access to the API of the editor.
  ///
  /// Instead of accessing the API via the `HtmlEditorState` you can also directly get in in the `HtmlEditor.onCreated(...)` callback.
  EditorApi get api => _api;

  @override
  void initState() {
    super.initState();
    _api = EditorApi(this);

    // Enable hybrid composition for better editing support.
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    final stylesWithMinHeight =
        styles.replaceFirst('==minHeight==', '${widget.minHeight}');
    final html = _template
        .replaceFirst('==styles==', stylesWithMinHeight)
        .replaceFirst('==content==', widget.initialContent ?? '');
    _initialPageContent = 'data:text/html;base64,' +
        base64Encode(const Utf8Encoder().convert(html));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adjustHeight) {
      final screenHeight = MediaQuery.of(context).size.height;
      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) {
            constraints = constraints.copyWith(
                maxHeight: _documentHeight ?? screenHeight);
          }
          return ConstrainedBox(
            constraints: constraints,
            child: _buildEditor(),
          );
        },
      );
    } else {
      return _buildEditor();
    }
  }

  Widget _buildEditor() {
    return FocusScope(
      canRequestFocus: true,
      child: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return WebView(
      initialUrl: _initialPageContent,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: _onWebViewCreated,
      javascriptChannels: _buildJsChannels(),
      onPageFinished: (url) async {
        if (widget.adjustHeight) {
          final scrollHeightText = await _webViewController
              .evaluateJavascript('document.body.scrollHeight');
          double height = double.tryParse(scrollHeightText);
          if ((height != null) &&
              mounted &&
              (widget.minHeight == null || (height + 20 > widget.minHeight))) {
            setState(() {
              _documentHeight = height + 20;
            });
          }
        }
      },
    );
  }

  void _onWebViewCreated(WebViewController controller) {
    _webViewController = controller;
    _api.webViewController = controller;
    if (widget.onCreated != null) {
      widget.onCreated(_api);
    }
    if (_api.onReady != null) {
      _api.onReady();
    }
  }

  Set<JavascriptChannel> _buildJsChannels() {
    return [
      _formatSettingsJavascriptChannel(),
      _alignSettingsJavascriptChannel(),
      _internalUpdatesJavascriptChannel(),
    ].toSet();
  }

  JavascriptChannel _formatSettingsJavascriptChannel() {
    return JavascriptChannel(
      name: 'FormatSettings',
      onMessageReceived: (JavascriptMessage message) {
        // print('FormatSettings got update: ${message.message}');
        if (_api.onFormatSettingsChanged != null) {
          final numericMessage = int.tryParse(message.message);
          if (numericMessage != null) {
            final isBold = (numericMessage & 1) == 1;
            final isItalic = (numericMessage & 2) == 2;
            final isUnderline = (numericMessage & 4) == 4;
            _api.onFormatSettingsChanged(
                FormatSettings(isBold, isItalic, isUnderline));
          }
        }
      },
    );
  }

  JavascriptChannel _alignSettingsJavascriptChannel() {
    return JavascriptChannel(
      name: 'AlignSettings',
      onMessageReceived: (JavascriptMessage message) {
        // print('AlignSettings got update: ${message.message}');
        if (_api.onAlignSettingsChanged != null) {
          ElementAlign align;
          switch (message.message) {
            case 'left':
              align = ElementAlign.left;
              break;
            case 'center':
              align = ElementAlign.center;
              break;
            case 'right':
              align = ElementAlign.right;
              break;
            case 'justify':
              align = ElementAlign.justify;
              break;
          }
          _api.onAlignSettingsChanged(align);
        }
      },
    );
  }

  JavascriptChannel _internalUpdatesJavascriptChannel() {
    return JavascriptChannel(
      name: 'InternalUpdate',
      onMessageReceived: (JavascriptMessage message) {
        print('InternalUpdate got update: ${message.message}');
        if (message.message.startsWith('h')) {
          final height = double.tryParse(message.message.substring(1));
          if (height != null) {
            setState(() {
              _documentHeight = height + 5;
            });
          }
        } else if (message.message == 'onfocus') {
          FocusScope.of(context).unfocus();
          //_webViewController.
          //FocusScope.of(context).requestFocus();
        }
      },
    );
  }
}
