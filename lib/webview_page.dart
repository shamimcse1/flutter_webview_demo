import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  InAppWebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller != null && await controller!.canGoBack()) {
          await controller!.goBack();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://ww3.tinyzone.org/'),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false, // ✅ Allows autoplay
                useOnLoadResource: true, // ✅ Monitor network requests

              ),
              android: AndroidInAppWebViewOptions(
                useWideViewPort: true,
                builtInZoomControls: false,
                displayZoomControls: false,
                hardwareAcceleration: true, // ✅ Improves video playback
                mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true, // ✅ iOS inline video fix
              ),
            ),
            onWebViewCreated: (InAppWebViewController webViewController) {
              controller = webViewController;
            },
            onLoadStart: (controller, url) async {
              print("🔹 Loading: $url");

              // Block known ad domains
              if (url.toString().contains("fuji9.com") ||
                  url.toString().contains("https://ak.stikroltiltoowi.net") ||
                  url.toString().contains("https://jeetbuzzbd-offer.com") ||
                  url.toString().contains("utm_source=ADCMP")) {
                print("🚫 Blocked Ad URL: $url");
                controller.goBack(); // ⛔ Stop navigation to ads
              }
            },
            onLoadStop: (controller, url) async {
              print("✅ Loaded: $url");

              // Force landscape if watching a video
              if (url.toString().contains("play") ||
                  url.toString().contains("watch")) {
                Orientation.landscape;
              } else {
                Orientation.portrait;
              }
              // Inject JavaScript to remove ads, popups, and unwanted redirects
              await controller.evaluateJavascript(source: """
              function findVideo() {
                  let video = document.querySelector("video");
                  if (video) {
                    console.log("🎬 Video Found! Playing...");
                    video.setAttribute("autoplay", "true");
                    video.play();
                  } else {
                    console.warn("⚠️ Video not found! Retrying...");
                    setTimeout(findVideo, 1000);
                  }
                }
                findVideo();
                (function() {
                  setTimeout(() => {
                    // Remove ads, popups, and modals
                    document.querySelectorAll('.modal, .popup, #ad-container, #ads, .popunder, iframe, .ad, .ads, .advertisement')
                      .forEach(el => el.remove());
              
                    // Ensure the video player is visible and on top
                    document.querySelectorAll('video, iframe').forEach(el => {
                      el.style.display = 'block';
                      el.style.zIndex = '9999';
                    });
              
                    // Block JavaScript-based redirects and popups
                    window.open = function() {};
                    history.pushState = function() {};
                    history.replaceState = function() {};
                  }, 1000);
              
                  // Function to wait for the video element
                  function waitForVideo() {
                    let video = document.querySelector('video');
                    if (video) {
                      console.log("🎬 Video Found! Playing...");
                      video.setAttribute('autoplay', 'true'); // Ensure autoplay
                      video.play();
                    } else {
                      console.warn("⚠️ Video not found. Retrying...");
                      setTimeout(waitForVideo, 1000);
                    }
                  }
                  waitForVideo();
              
                  // If the video is inside an iframe, check inside it
                  function waitForIframeVideo() {
                    let iframe = document.querySelector('iframe');
                    if (iframe) {
                      let iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
                      let video = iframeDoc ? iframeDoc.querySelector('video') : null;
                      if (video) {
                        console.log("🎬 Video inside iframe found! Playing...");
                        video.setAttribute('autoplay', 'true'); // Ensure autoplay
                        video.play();
                      } else {
                        console.warn("⚠️ Video inside iframe not found. Retrying...");
                        setTimeout(waitForIframeVideo, 1000);
                      }
                    } else {
                      console.warn("⚠️ No iframe found. Retrying...");
                      setTimeout(waitForIframeVideo, 1000);
                    }
                  }
                  waitForIframeVideo();
                })();
              """);
            },
            onConsoleMessage: (controller, consoleMessage) {
              // Handle JavaScript errors and warnings
              print("JS Console: ${consoleMessage.message}");
              if (consoleMessage.messageLevel == ConsoleMessageLevel.WARNING) {
                print("⚠️ Warning: ${consoleMessage.message}");
              }
              if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
                print("❌ Error: ${consoleMessage.message}");
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var url = navigationAction.request.url.toString();

              // Block navigation to known ad domains
              if (url.contains("fuji9.com") ||
                  url.contains("utm_source=ADCMP")) {
                print("🚫 Blocked Navigation: $url");
                return NavigationActionPolicy.CANCEL; // Block ad redirections
              }

              // Block intent URL (open in browser instead)
              if (url.startsWith("intent://")) {
                print("🚫 Blocked Intent URL: $url");
                return NavigationActionPolicy.CANCEL; // Block intent URL
              }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadError: (controller, url, code, message) {
              print("❌ Error: $message");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Webpage is not available. Please try again later."),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
