
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  WebViewController? _controller;
  int progressValue = 0;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              progressValue = progress;
            });
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation requested to: ${request.url}');
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('Navigation prevented for: ${request.url}');
              return NavigationDecision.prevent;
            }
            print('Navigation allowed for: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller!.canGoBack()) {
          // Navigate back within WebView
          _controller?.goBack();
          return false; // Do not exit the app
        }
        return true; // Exit the app
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("WebView Demo"),
            actions: const [],
          ),
          body:progressValue > 100  ?  const Center(child: CircularProgressIndicator(color: Colors.pink,)) : WebViewWidget(controller: _controller!)),
    );
  }
}
