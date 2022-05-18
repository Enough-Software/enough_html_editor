## [0.0.5] - 2022-05-18
- New feature: edit / add links
- New feature: color document foreground and background
- New feature: replace text (parts) using the `HtmlEditorApi`.
- Use cupertino look and feel on iOS
- Improve code style and documentation
- Ensure compatibility with Flutter 3.0

## [0.0.4] - 2021-04-28
- Support dark theme
- Simpler usage with `PackagedHtmlEditor` #2
- Select text foreground and background colors #12, $14
- New strike through option
- Bold, italic, underline text is now detected from inline CSS styles, too #5
- Optionally specify your own context menu items using the `textSelectionMenuItems` parameter
- Optionally specify your own widgets for the predefined `HtmlEditorControls` widget using the `prefix` and/or `suffix` parameters


## [0.0.3] - 2021-03-13
- `enough_html_editor` is now [null safe](https://dart.dev/null-safety/tour) #6
- You can now configure if a `blockquote` should be split when the user adds a newline #1


## [0.0.2] - 2021-02-27

* Improve documentation.
* Retrieve the full HTML document's text with `await editorApi.getFullHtml()`
* Add any custom CSS styles with `editorApi.customStyles` setter, for example 
  ```dart
  editorApi.customStyles = 
    '''
    blockquote {
        font: normal helvetica, sans-serif;
        margin-top: 10px;
        margin-bottom: 10px;
        margin-left: 20px;
        padding-left: 15px;
        border-left: 3px solid #ccc;
    }
    ''';
  ```
* Replace all CSS styles with the `editorApi.styles` setter. 
* Use the minimum height specified in `HtmlEditor.minHeight`. 

## [0.0.1] - 2021-02-27

* Basic HTML editor with Flutter-native control widgets.
