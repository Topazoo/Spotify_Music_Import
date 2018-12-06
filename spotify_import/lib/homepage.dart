import 'package:flutter/material.dart';
import 'audio_fs.dart' as Audio_FS;

class MyHomePage extends StatefulWidget {
  /* Homepage widget that attaches to root */

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  //Audio Filesystem containing audio files
  final Audio_FS.Audio_Filesystem aud = new Audio_FS.Audio_Filesystem();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    /* Build the contents of the homepage widget */
    
    //Get files stored in audio filesystem
    List<Audio_FS.Audio_File> files = widget.aud.files;

    return Scaffold(
      //Create appbar with title
      appBar: AppBar(

        title: Text(widget.title),

        centerTitle: true,
      ),

      //Create centered body with widget displaying stored audio files
      body: Center(
        child: music_list(context, files),
      ),

    );
  }

  Widget music_list(BuildContext context, List<Audio_FS.Audio_File> files) {
    /* Widget to display a list of audio files
      @context - The context of the parent widget
      @files - The files retrieved from the audio filesystem */

    return new ListView.builder(
      //Set the count
      itemCount: files.length,
      //Set function used to build the list
      itemBuilder: (BuildContext context, int index) 
      {
        return new Column(
          //Create list item widgets with a checkbox
          children: <Widget>[
            new CheckboxListTile(
              //Add audio file title and artist to list item
              title: new Text('${files[index].title}'),

              subtitle: new Text('${files[index].artist}'),

              //Determine if the item is currently selected (in the audio filesystem selected list)
              value: widget.aud.selected.contains(files[index]),

              //Set the function for when an item is selected
              onChanged: (bool value) 
              {
                setState(() 
                { 
                  //Remove from selected list if item is currently selected
                  if(widget.aud.selected.contains(files[index]))
                    widget.aud.selected.remove(files[index]);

                  else
                    //Otherwise add it to the selected list
                    widget.aud.selected.add(files[index]);
                });
              },
            ),

            new Divider(height: 2.0,),

          ],
        );
      },
    );
  }
} 


