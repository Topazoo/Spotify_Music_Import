import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'spotify_manager.dart';

class Spotify_Widget extends StatefulWidget {
  /* Homepage widget that attaches to root */

  Spotify_Widget({Key key}) : super(key: key);

  final Spotify_Manager sm = new Spotify_Manager();  

  @override
  _Spotify_Widget createState()
  {
   _Spotify_Widget wid = _Spotify_Widget();
   sm.wid = wid;
    
    return wid;
  }
}

class _Spotify_Widget extends State<Spotify_Widget> {

  @override
  Widget build(BuildContext context) {
    if (widget.sm.retCode == -1)
      return new Center(
        child: new WebviewScaffold(
            url: widget.sm.authUrl,
        )
      );
    else if (widget.sm.retCode == 0)
      return new Center(child: new Text("Error connecting to Spotify services"));
    else
      return new Center(child: new Text("Connected to Spotify services!"));
  }
  
}