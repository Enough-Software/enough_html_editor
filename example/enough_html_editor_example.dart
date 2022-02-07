import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'enough_html_editor Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const EditorPage(),
      );
}

/// Example how to use the simplified [PackagedHtmlEditor]
/// that combines the default controls and the editor.
class EditorPage extends StatefulWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  HtmlEditorApi? _editorApi;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('PackagedHtmlEditor Demo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final text = await _editorApi!.getText();
                print('got text: [$text]');
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(htmlText: text),
                  ),
                );
              },
            ),
          ],
        ),
        body: PackagedHtmlEditor(
          onCreated: (api) {
            _editorApi = api;
          },
          initialContent: '''<p>Here is some text</p>
        <p>Here is <b>bold</b> text with a <a href="https://github.com/Enough-Software/enough_html_editor">link</a>.</p>
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
      );
}

/// Example how to use editor within a a CustomScrollView
class CustomScrollEditorPage extends StatefulWidget {
  const CustomScrollEditorPage({Key? key}) : super(key: key);

  @override
  _CustomScrollEditorPageState createState() => _CustomScrollEditorPageState();
}

class _CustomScrollEditorPageState extends State<CustomScrollEditorPage> {
  HtmlEditorApi? _editorApi;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Editor Demo'),
              floating: false,
              pinned: true,
              stretch: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = await _editorApi!.getText();
                    print('got text: [$text]');
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(htmlText: text),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    TextField(decoration: InputDecoration(hintText: 'Subject')),
              ),
            ),
            if (_editorApi != null) ...{
              SliverHeaderHtmlEditorControls(editorApi: _editorApi),
            },
            SliverToBoxAdapter(
              child: HtmlEditor(
                onCreated: (api) {
                  setState(() {
                    _editorApi = api;
                  });
                },
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

/// Displays the resulting HTML code
class ResultScreen extends StatelessWidget {
  /// Creates a new result page
  const ResultScreen({Key? key, required this.htmlText}) : super(key: key);

  /// The HTML code
  final String htmlText;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: SingleChildScrollView(
          child: SelectableText(htmlText),
        ),
      );
}
