import 'package:flutter/material.dart';

import '../editor_api.dart';
import '../models.dart';
import 'base.dart';

/// Allows to enter and edit links
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class LinkButton extends StatefulWidget {
  LinkButton({Key? key}) : super(key: key);

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  final _urlController = TextEditingController();
  final _textController = TextEditingController();
  bool _isInLink = false;

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    final buttonColor = _isInLink ? Theme.of(context).accentColor : null;
    api.onLinkSettingsChanged = _onLinkSettingsChanged;
    return IconButton(
      icon: Icon(Icons.link),
      onPressed: () => _editLink(api),
      color: buttonColor,
    );
  }

  void _onLinkSettingsChanged(LinkSettings? linkSettings) {
    if (linkSettings != null) {
      _urlController.text = linkSettings.url;
      _textController.text = linkSettings.text;
    }
    setState(() {
      _isInLink = (linkSettings != null);
    });
  }

  Future _editLink(HtmlEditorApi api) async {
    var restoreSelectionRange = false;
    if (!_isInLink) {
      final selectedText = await api.storeSelectionRange() ?? '';
      restoreSelectionRange = selectedText.isNotEmpty;
      _textController.text = selectedText;
      final urlText = selectedText.contains('://') ? selectedText : '';
      _urlController.text = urlText;
    }
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: LinkEditor(
            urlController: _urlController,
            textController: _textController,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (result == true && _urlController.text.trim().isNotEmpty) {
      // check link validity?
      var url = _urlController.text.trim();
      if (!url.contains(':')) {
        url = 'https://' + url;
      }
      var text = _textController.text.trim();
      if (text.isEmpty) {
        text = url;
      }
      if (_isInLink) {
        api.editCurrentLink(url, text);
      } else {
        if (restoreSelectionRange) {
          await api.restoreSelectionRange();
        }
        api.insertLink(url, text: text);
      }
    }
  }
}

class LinkEditor extends StatefulWidget {
  final TextEditingController urlController;
  final TextEditingController textController;
  LinkEditor(
      {Key? key, required this.urlController, required this.textController})
      : super(key: key);

  @override
  _LinkEditorState createState() => _LinkEditorState();
}

class _LinkEditorState extends State<LinkEditor> {
  late String _previewText;

  @override
  void initState() {
    super.initState();
    _previewText = widget.textController.text.isEmpty
        ? widget.urlController.text
        : widget.textController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.urlController,
          decoration: InputDecoration(
            icon: Icon(Icons.link),
            suffix: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => widget.urlController.text = '',
            ),
          ),
          autofocus: true,
          keyboardType: TextInputType.url,
          onChanged: (text) => _updatePreview(),
        ),
        TextField(
          controller: widget.textController,
          decoration: InputDecoration(
            icon: Icon(Icons.text_fields),
            suffix: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => widget.textController.text = '',
            ),
          ),
          autofocus: true,
          keyboardType: TextInputType.text,
          onChanged: (text) => _updatePreview(),
        ),
        Divider(),
        TextButton(
          child: Text(_previewText),
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(url)));
          },
        ),
      ],
    );
  }

  String get url {
    var text = widget.urlController.text;
    if (!text.contains(':')) {
      text = 'https://' + text;
    }
    return text;
  }

  void _updatePreview() {
    setState(() {
      _previewText = widget.textController.text.isNotEmpty
          ? widget.textController.text
          : widget.urlController.text;
    });
  }
}
