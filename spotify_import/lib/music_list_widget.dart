import 'package:flutter/material.dart';
import 'audio_fs.dart' as Audio_FS;

class Music_List_Widget_Known extends StatefulWidget {
  /* Homepage widget that attaches to root */

  Music_List_Widget_Known({Key key, this.aud}) : super(key: key);

  final Audio_FS.Audio_Filesystem aud;

  @override
  _Music_List_Widget_Known createState() => _Music_List_Widget_Known();
}

class _Music_List_Widget_Known extends State<Music_List_Widget_Known> {
  
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Column(
        children: [
          new Expanded(child: new ListView.builder(
            //Set the count
            itemCount: widget.aud.files.length,

            shrinkWrap: true,

            //Set function used to build the list
            itemBuilder: (BuildContext context, int index) 
            {
              return new Column(
                //Create list item widgets with a checkbox
                children: <Widget>[
                  new CheckboxListTile(
                    //Add audio file title and artist to list item
                    title: new Text('${widget.aud.files[index].title}'),

                    subtitle: new Text('${widget.aud.files[index].artist}'),

                    //Determine if the item is currently selected (in the audio filesystem selected list)
                    value: widget.aud.selected.contains(widget.aud.files[index]),

                    //Set the function for when an item is selected
                    onChanged: (bool value) 
                    {
                      setState(() 
                      { 
                        //Remove from selected list if item is currently selected
                        if(widget.aud.selected.contains(widget.aud.files[index]))
                          widget.aud.selected.remove(widget.aud.files[index]);

                        else
                          //Otherwise add it to the selected list
                          widget.aud.selected.add(widget.aud.files[index]);
                      });
                    },
                  ),

                  new Divider(height: 2.0,),

                ],
              );
            },
          )),
        ]
      )
    );
  }
}

class Music_List_Widget_Unknown extends StatefulWidget {
  /* Homepage widget that attaches to root */

  Music_List_Widget_Unknown({Key key, this.aud}) : super(key: key);

  final Audio_FS.Audio_Filesystem aud;

  @override
  _Music_List_Widget_Unknown createState() => _Music_List_Widget_Unknown();
}

class _Music_List_Widget_Unknown extends State<Music_List_Widget_Unknown> {
  
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Column(
        children: [          
          new Expanded(child: new ListView.builder(
            //Set the count
            itemCount: widget.aud.unknownFiles.length,

            shrinkWrap: true,

            //Set function used to build the list
            itemBuilder: (BuildContext context, int index) 
            {
              return new Column(
                //Create list item widgets with a checkbox
                children: <Widget>[
                  new CheckboxListTile(
                    //Add audio file title and artist to list item
                    title: new Text('${widget.aud.unknownFiles[index].title}'),

                    subtitle: new Text('${widget.aud.unknownFiles[index].artist}'),

                    //Determine if the item is currently selected (in the audio filesystem selected list)
                    value: widget.aud.selected.contains(widget.aud.unknownFiles[index]),

                    //Set the function for when an item is selected
                    onChanged: (bool value) 
                    {
                      setState(() 
                      { 
                        //Remove from selected list if item is currently selected
                        if(widget.aud.selected.contains(widget.aud.unknownFiles[index]))
                          widget.aud.selected.remove(widget.aud.unknownFiles[index]);

                        else
                          //Otherwise add it to the selected list
                          widget.aud.selected.add(widget.aud.unknownFiles[index]);
                      });
                    },
                  ),

                  new Divider(height: 2.0,),

                ],
              );
            },
          ))
        ]
      )
    );
  }
}
