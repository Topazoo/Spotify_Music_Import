import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'spotify_manager.dart';

class Spotify_Widget extends StatefulWidget {
  /* Homepage widget that attaches to root */

  Spotify_Widget({Key key}) : super(key: key);

  final Spotify_Manager sm = new Spotify_Manager();  

  @override
  _Spotify_Widget createState() => _Spotify_Widget();
}

class _Spotify_Widget extends State<Spotify_Widget> {
  
  int _isAuthenticated = 0;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new WebviewScaffold(
          url: widget.sm.authUrl,
      )
    );
  }
}