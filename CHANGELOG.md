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
