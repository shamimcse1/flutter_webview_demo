import 'package:flutter/material.dart';
import 'package:flutter_webview_demo/webview_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webview Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const WebviewPage(),
    );
  }
}
