import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'spotify_manager.dart';

class Spotify_Widget extends StatefulWidget {
  /* Homepage widget that attaches to root */

  Spotify_Widget({Key key}) : super(key: key);

  final Spotify_Manager sm = new Spotify_Manager();  
  final FlutterWebviewPlugin webview = new FlutterWebviewPlugin();

  @override
  _Spotify_Widget createState()
  {
    //Embed widget in Spotify Manager to allow it to update state
    _Spotify_Widget wid = _Spotify_Widget();
    sm.wid = wid;
    
    return wid;
  }
}

class _Spotify_Widget extends State<Spotify_Widget> {

  @override
  Widget build(BuildContext context) {
    //If not connected to Spotify
    if (widget.sm.retCode != 1)
    {
      //Embed webview in custom view
      Rect newRect = new Rect.fromLTWH(0.0, 80.0, 
                MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 135);

      //Launch webview
      widget.webview.launch(widget.sm.authUrl, rect: newRect);

      //Empty placeholder under webview
      return Center(heightFactor: 0, widthFactor: 0,);
    }

    //If connected to Spotify
    else
    {
      //Close webview
      widget.webview.close();
      //TODO - Replace with import button
      return new Center(child: new Text("Connected to Spotify services!\nCode: " + widget.sm.accessCode));
    }
  }
  
}