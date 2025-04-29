// **************************************************************************
// * WARNING: DO NOT MODIFY THIS FILE WITHOUT EXPLICIT APPROVAL                *
// * Changes to this file should be properly reviewed and authorized          *
// * Version: 1.1.0                                                          *
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebcamsScreen extends StatelessWidget {
  const WebcamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Webcams',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Front Camera',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: WebViewWidget(
                        controller: WebViewController()
                          ..loadRequest(
                            Uri.parse('https://video.nest.com/embedded/live/mvxc0rm2kW?autoplay=1'),
                          )
                          ..setJavaScriptMode(JavaScriptMode.unrestricted),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Backyard Camera',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: WebViewWidget(
                        controller: WebViewController()
                          ..loadRequest(
                            Uri.parse('https://video.nest.com/embedded/live/33OfUuZJ01?autoplay=1'),
                          )
                          ..setJavaScriptMode(JavaScriptMode.unrestricted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 