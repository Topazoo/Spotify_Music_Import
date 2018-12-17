import 'package:flutter/material.dart';
import 'music_list_widget.dart';
import 'spotify_widget.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'theme.dart' as AppThemes;
import 'audio_fs.dart' as Audio_FS;

class MyHomePage extends StatefulWidget {
  /* Homepage widget that attaches to root */

  MyHomePage({Key key, this.title}) : super(key: key);

  //App title
  final String title;
  //Singleton webview reference (to close overlay when other pages are visited)
  final FlutterWebviewPlugin webview = new FlutterWebviewPlugin();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Selected page (based on bottom navbar)
  int _selectedIndex = 0;
  
  //Audio Filesystem containing audio files
  static final Audio_FS.Audio_Filesystem am = new Audio_FS.Audio_Filesystem();
  
  //Possible pages based on bottom navbar selection
  final List<Widget> _pages = [
    Music_List_Widget_Known(aud: am),
    Music_List_Widget_Unknown(aud: am),
    Spotify_Widget(aud: am)
  ];

  @override
  Widget build(BuildContext context) {
    /* Build the contents of the homepage widget */

    //Close webview if open
    widget.webview.close();

    return Scaffold(
      //Create appbar with title
      appBar: AppBar(

        title: Text(widget.title, style: TextStyle(color: Colors.white)),

        centerTitle: true,
      ),

      //Create centered body with widget displaying stored audio files
      body: _pages[_selectedIndex],

      //Create bottom navbar
      bottomNavigationBar: build_import_btn(context),

    );
  }

  Widget build_import_btn(BuildContext context)
  {
    /* Build the bottom navbar */
  
    return new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.library_music), title: Text('Songs')),

          BottomNavigationBarItem(icon: Icon(Icons.help_outline), title: Text('Unknown Songs')),

          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), title: Text('Import')),
        ],

        //Set page to selected index
        currentIndex: _selectedIndex,

        fixedColor: AppThemes.MainThemeSwatch.swatch,

        //Change page on tap        
        onTap: change_page,
      );
  }

  void change_page(int index) 
  {
    setState(() {
      _selectedIndex = index;
    });
  }
}
