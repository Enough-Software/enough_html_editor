import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformSnackApp(
      title: 'enough_html_editor Demo',
      materialTheme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      cupertinoTheme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeGreen,
        brightness: Brightness.light,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
      ],
      home: EditorPage(),
    );
  }
}

/// Example how to use the simplified [PackagedHtmlEditor] that combines the default controls and the editor.
class EditorPage extends StatefulWidget {
  EditorPage({Key? key}) : super(key: key);

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  HtmlEditorApi? _editorApi;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('PackagedHtmlEditor'),
        trailingActions: [
          DensePlatformIconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              final text = await _editorApi!.getText();
              print('got text: [$text]');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResultScreen(htmlText: text),
                ),
              );
            },
          ),
          DensePlatformIconButton(
            icon: Icon(Icons.looks_two),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CustomScrollEditorPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: PackagedHtmlEditor(
            onCreated: (api) {
              _editorApi = api;
            },
            initialContent:
                '''<p>Here is some text</p> with a <a href="https://github.com/Enough-Software/enough_html_editor">link</a>.
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
      ),
    );
  }
}

/// Example how to use editor within a a CustomScrollView
class CustomScrollEditorPage extends StatefulWidget {
  CustomScrollEditorPage({Key? key}) : super(key: key);

  @override
  _CustomScrollEditorPageState createState() => _CustomScrollEditorPageState();
}

class _CustomScrollEditorPageState extends State<CustomScrollEditorPage> {
  HtmlEditorApi? _editorApi;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          PlatformSliverAppBar(
            title: Text('Sticky controls'),
            floating: false,
            pinned: true,
            stretch: true,
            actions: [
              DensePlatformIconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final text = await _editorApi!.getText();
                  print('got text: [$text]');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(htmlText: text),
                    ),
                  );
                },
              ),
              DensePlatformIconButton(
                icon: Icon(Icons.looks_one),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditorPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DecoratedPlatformTextField(
                  decoration: InputDecoration(hintText: 'Subject')),
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
}

class ResultScreen extends StatelessWidget {
  final String htmlText;
  const ResultScreen({Key? key, required this.htmlText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Result'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(child: SelectableText(htmlText)),
      ),
    );
  }
}
