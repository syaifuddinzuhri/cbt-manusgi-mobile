import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF00a65a),
            elevation: 0,
            title: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('MA NU SUNAN GIRI PRIGEN'),
                )
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  },
                  icon: Icon(Icons.arrow_back)),
              IconButton(
                  onPressed: () async {
                    _controller.reload();
                  },
                  icon: Icon(Icons.sync))
            ],
          ),
          body: Stack(
            children: <Widget>[
              WebView(
                initialUrl: 'https://ujian.manusunangiri.sch.id/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                },
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                },
                onPageStarted: (String url) {
                  setState(() {
                    isLoading = true;
                  });
                },
                onPageFinished: (String url) {
                  setState(() {
                    isLoading = false;
                  });
                },
                gestureNavigationEnabled: true,
                backgroundColor: const Color(0x00000000),
              ),
              isLoading
                  ? Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Stack(),
            ],
          )),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
