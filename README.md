# enough_html_editor

Slim HTML editor for Flutter with full API control and optional Flutter-based widget controls.

## API Documentation
Check out the full API documentation at https://pub.dev/documentation/enough_html_editor/latest/

## Usage
The current `enough_html_editor` package the following widgets:
* `HtmlEditor` the HTML editor.
* `HtmlEditorControls` optional editor controls.
* `SliverHeaderHtmlEditorControls` wrapper to use the editor controls within a `CustomScrollView` as a sticky header. 
* `HtmlEditorApi` - not a widget - the API to control the editor, use the API to access the edited HTML text or to set the current text bold, add an unordered list, etc.

### Access API
You choose between two options to access the API:
1. Use the `onCreated(HtmlEditorApi)` callback:
    ```dart
    HtmlEditor(
        onCreated: (api) {
            setState(() {
            _editorApi = api;
            });
        },
        ...
    );
    ```
    You can then access the API afterwards directly, e.g.
    ```dart
    final text = await _editorApi.getText();
    ```

2. Define and assign a  `GlobalKey<HtmlEditorState>`:
    ```dart
    final _keyEditor = GlobalKey<HtmlEditorState>();
    Widget build(BuildContext context) {
        return HtmlEditor(
              key: _keyEditor,
              ...
        );
    }
    ```
    You can then access the `HtmlEditorState` via this `GlobalKey`:
    ```dart
    final text = await _keyEditor.currentState.api.getText();
    ```

Either the API or the global key is required for creating the `HtmlEditorControls`.

## Quick example
```dart
HtmlEditorApi _editorApi;

@override
Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
            if (_editorApi != null) ...{
              SliverHeaderHtmlEditorControls(editorApi: _editorApi),
            },
            SliverToBoxAdapter(
              child: FutureBuilder<String>(
                future: loadMailTextFuture,
                builder: (widget, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return Row(children: [CircularProgressIndicator()]);
                      break;
                    case ConnectionState.done:
                      return HtmlEditor(
                        onCreated: (api) {
                          setState(() {
                            _editorApi = api;
                          });
                        },
                        initialContent: snapshot.data,
                      );
                      break;
                  }
                  return Container();
                },
              ),
            ),
        ],
      ),
    );
}
```

## Installation
Add this dependency your pubspec.yaml file:

```
dependencies:
  enough_html_editor: ^0.0.2
```
The latest version or `enough_html_editor` is [![enough_html_editor version](https://img.shields.io/pub/v/enough_html_editor.svg)](https://pub.dartlang.org/packages/enough_html_editor).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/enough-software/enough_html_editor/issues

## License

Licensed under the commercial friendly [Mozilla Public License 2.0](LICENSE).