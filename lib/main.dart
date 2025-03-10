import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart'; // Import for status bar handling

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, // Apply light theme
        primaryColor: Colors.white, 
        scaffoldBackgroundColor: Colors.white, // White background
      ),
      home: WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  @override
  _WebViewAppState createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController _controller;
  bool isLoading = true; // Track loading state
  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();

    // Ensure the app starts below the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Set status bar to light theme with dark icons
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFCFDFFB), // White background for status bar
        statusBarIconBrightness: Brightness.dark, // Dark icons for light theme
      ),
    );

    final WebViewController controller = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams()
    );

    _controller = controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => isLoading = true),
          onPageFinished: (url) => setState(() => isLoading = false),
          onWebResourceError: (error) {
            setState(() => isLoading = false);
            Fluttertoast.showToast(
              msg: "Failed to load page. Check your internet connection.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse("https://mobile.himerchind.com/"));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else {
      DateTime now = DateTime.now();
      if (lastPressed == null || now.difference(lastPressed!) > Duration(seconds: 2)) {
        lastPressed = now;
        Fluttertoast.showToast(
          msg: "Press again to exit",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return false;
      }
      return true;
    }
  }

  @override
  void dispose() {
    _controller.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea( // Ensures app starts below the status bar
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),

              // Semi-transparent overlay when loading
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
