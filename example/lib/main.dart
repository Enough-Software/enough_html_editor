import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'enough_html_editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EditorPage(), //MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class EditorPage extends StatefulWidget {
  EditorPage({Key? key}) : super(key: key);

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _keyEditor = GlobalKey<HtmlEditorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text('Editor Demo'),
            floating: false,
            pinned: true,
            stretch: true,
            actions: [
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final text = await _keyEditor.currentState!.api.getText();
                  print('got text: [$text]');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(htmlText: text),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  TextField(decoration: InputDecoration(hintText: 'Subject')),
            ),
          ),
          SliverHeaderHtmlEditorControls(editorKey: _keyEditor),
          SliverToBoxAdapter(
            child: HtmlEditor(
              key: _keyEditor,
              textSelectionMenuItems: [
                TextSelectionMenuItem(
                  label: 'Upper',
                  action: (api) async {
                    final selectedText = await api.getSelectedText();
                    print('selected text: $selectedText');
                    if (selectedText != null) {
                      final replacement = selectedText.toUpperCase();
                      api.insertText(replacement);
                    }
                  },
                ),
              ],
              initialContent: '''<p>Here is some text</p>
        <p>Here is <b>bold</b> text</p>
        <p>Here is <i>some italic sic</i> text</p>
        <p>Here is <i><b>bold and italic</b></i> text</p>
        <p style="text-align: center;">Here is <u><i><b>bold and italic and underline</b></i></u> text</p>
        <ul><li>one list element</li><li>another point</li></ul>
        <blockquote>Here is a quote<br/>
          that spans several lines<br/>
          <blockquote>
              Another second level blockqote 
          </blockquote>
      </blockquote>
''',
            ),
          ),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String htmlText;
  const ResultScreen({Key? key, required this.htmlText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: SingleChildScrollView(
        child: SelectableText(htmlText),
      ),
    );
  }
}
