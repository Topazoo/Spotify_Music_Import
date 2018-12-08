import 'package:flutter/material.dart';
import 'music_list_widget.dart';
import 'spotify_widget.dart';
import 'theme.dart' as AppThemes;
import 'audio_fs.dart' as Audio_FS;

class MyHomePage extends StatefulWidget {
  /* Homepage widget that attaches to root */

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  
  //Audio Filesystem containing audio files
  static final Audio_FS.Audio_Filesystem am = new Audio_FS.Audio_Filesystem();
  
  //Possible pages based on bottom navbar selection
  final List<Widget> _pages = [
    Music_List_Widget_Known(aud: am),
    Music_List_Widget_Unknown(aud: am),
    Spotify_Widget()
  ];

  @override
  Widget build(BuildContext context) {
    /* Build the contents of the homepage widget */

    return Scaffold(
      //Create appbar with title
      appBar: AppBar(

        title: Text(widget.title),

        centerTitle: true,
      ),

      //Create centered body with widget displaying stored audio files
      body: _pages[_selectedIndex],

      bottomNavigationBar: build_import_btn(context),

    );
  }

  Widget build_import_btn(BuildContext context)
  {
    return new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.library_music), title: Text('Songs')),

          BottomNavigationBarItem(icon: Icon(Icons.help_outline), title: Text('Unknown Songs')),

          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), title: Text('Import')),
        ],

        currentIndex: _selectedIndex,

        fixedColor: AppThemes.MainThemeSwatch.swatch,

        onTap: import,
      );
  }

  void import(int index) 
  {
    setState(() {
      _selectedIndex = index;
    });
  }
}
