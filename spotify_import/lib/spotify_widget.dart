import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'connection_uitility.dart';
import 'spotify_manager.dart';
import 'theme.dart' as AppTheme;
import 'audio_fs.dart' as Audio_FS;
import 'webview_builder.dart';
import 'dart:io' as IO;

class Spotify_Widget extends StatefulWidget {
  /* Homepage widget that attaches to root */

  Spotify_Widget({Key key, this.aud}) : super(key: key);

  final Spotify_Manager sm = new Spotify_Manager();  
  final FlutterWebviewPlugin webview = new FlutterWebviewPlugin();
  final Audio_FS.Audio_Filesystem aud;

  @override
  _Spotify_Widget createState()
  {
    //Embed widget in Spotify Manager to allow it to update state
    _Spotify_Widget wid = _Spotify_Widget();
    sm.wid = wid;
    sm.files = aud;
    
    return wid;
  }
}

class _Spotify_Widget extends State<Spotify_Widget> {

  Connection_Manager mngr = new Connection_Manager();

  //Function to pass to connection manager
  void update()
  {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //Change display based on status
    int status = widget.sm.retCode;

    //If not connected to Spotify
    if (status < 1)
    {
      if(IO.Platform.isAndroid)
      {
        //If connected, open webview
        if(mngr.isCompleted && mngr.isConnected)
        {
          //Embed webview in custom view
          Rect newRect = get_device_rect(context);

          //Launch webview
          widget.webview.launch(widget.sm.authUrl, rect: newRect);

          //Empty placeholder under webview
          return Center(heightFactor: 0, widthFactor: 0,);
        }
        //Should never reach this
        else if(mngr.isCompleted && !mngr.isConnected)
        {
          return new Center(child: new Text("Not connected"),);
        }
        //Wait for connection
        else
        {
          if (!mngr.inProgress)
          {
            mngr.test_connect(update);
            mngr.inProgress = true;
          }

          return new Center(child: new Text("Attempting to connect to Spotify server...", 
                                    textScaleFactor: 1.2,));
        }
      }
      else
      {
        widget.sm.handle_auth_iOS();
        return new Center(child: new Text("iOS Connection manager"),);
      }
    }

    //If connected to Spotify
    else if (status == 1)
    {
      Widget playlistField;
      //Close webview
      widget.webview.close();

      if (widget.sm.options.toPlaylist)
        playlistField = new Column(children:
                        [
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(16, 16, 16, 20),
                            child: TextField(
                              controller: widget.sm.options.textController,
                              style: TextStyle(fontSize: 20, color: Colors.black),
                              decoration: InputDecoration(
                                            labelText: "Enter a playlist name:",
                                            labelStyle: TextStyle(fontSize: 20, height: -.5),
                                            hintText: widget.sm.options.playlistName,  
                                            ),
                              autofocus: true,
                                          ),
                          ),
                          new Divider(height: 2.0,),
                        ]
                      );
      else
        playlistField = new Center();

      //Show import button
      return new Column(children: 
                        [
                          new SwitchListTile(
                            //Add audio file title and artist to list item
                            title: new Text("Add songs to library", 
                                            style: new TextStyle(fontSize: 20),),

                            value: widget.sm.options.toLibrary, 

                            //Set the function for when an item is selected
                            onChanged: (bool value) 
                            {
                              setState(() 
                              { 
                                if (widget.sm.options.toLibrary)
                                  widget.sm.options.toLibrary = false;
                                else
                                  widget.sm.options.toLibrary = true;
                              });
                            },
                          ),

                          new Divider(height: 2.0,),

                          new SwitchListTile(
                            //Add audio file title and artist to list item
                            title: new Text("Add songs to playlist",
                                            style: new TextStyle(fontSize: 20),),

                            value: widget.sm.options.toPlaylist,

                            //Set the function for when an item is selected
                            onChanged: (bool value) 
                            {
                              setState(() 
                              { 
                                if (widget.sm.options.toPlaylist)
                                  widget.sm.options.toPlaylist = false;
                                else
                                  widget.sm.options.toPlaylist = true;
                              });
                            },
                          ),

                          new Divider(height: 2.0,),

                          playlistField,

                          new Expanded(child: 
                            new Align(child: 
                              new Row(children: 
                                [ 
                                  new Expanded(child: new RaisedButton(
                                    color: AppTheme.MainThemeSwatch.swatch,
                                    textColor: Colors.white,
                                    child: new Text("Import Songs", textScaleFactor: 2.0,),
                                    onPressed: widget.sm.import_songs,
                                    padding: new EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                                  )) 
                                ],
                              ),
                              alignment: Alignment.bottomCenter,
                            ),
                          )
                        ],
                      );
    }

    //Else if songs imported
    else if (status == 2)
    {
      widget.webview.close();

      String resText = "";
      Widget failed, number;
      List<Audio_FS.Audio_File> songs;

      //If all songs imported successfully
      if (widget.sm.notFound.length == 0)
      {
        resText = "All songs imported successfully!";
        failed = new Center();
        number = new Container(child: 
                          new Padding(padding: new EdgeInsets.fromLTRB(0, 11, 0, 7),
                                      child: new Text(resText, 
                                                      textAlign: TextAlign.center,
                                                      textScaleFactor: 1.3,
                                                      style: new TextStyle(color:
                                                         AppTheme.MainThemeSwatch.swatch,
                                                         height: 2),
                                                      ),
                                      ),
                          width: double.infinity,
                        );

        songs = widget.sm.files.selected;
      }

      else
      {
        int totalSongs = widget.aud.selected.length;
        int totalSuccess = totalSongs - widget.sm.notFound.length;

        songs = widget.sm.notFound; 

        resText = "Imported " + totalSuccess.toString() + " of " + totalSongs.toString() +
                  " songs";

        failed = new Container(child: 
                          new Padding(padding: new EdgeInsets.fromLTRB(0, 8, 0, 6),
                                      child: new Text("Failed to import", 
                                                      textAlign: TextAlign.center,
                                                      textScaleFactor: 1.2,
                                                      ),
                                      ),
                          width: double.infinity,
                        );

        number = new Container(child: 
                          new Padding(padding: new EdgeInsets.fromLTRB(0, 11, 0, 7),
                                      child: new Text(resText, 
                                                      textAlign: TextAlign.center,
                                                      textScaleFactor: 1.3,
                                                      style: new TextStyle(color:
                                                         Colors.red,
                                                         height: 2),                                                      
                                                      ),
                                      ),
                          width: double.infinity,
                        );
      }

      return new Center(
        child: Column(children: [                        
            
            failed,

            new Divider(height: 2.0, color: Colors.black,),

            new Expanded(child: new Container(child: 
                                              new ListView.builder(
                                                //Set the count
                                                itemCount: songs.length,

                                                shrinkWrap: true,

                                                //Set function used to build the list
                                                itemBuilder: (BuildContext context, int index) 
                                                {
                                                  return new Column(
                                                    //Create list item widgets 
                                                    children: <Widget>[
                                                      new ListTile(
                                                        //Add audio file title and artist to list item
                                                        title: new Text('${songs[index].title}'),

                                                        subtitle: new Text('${songs[index].artist}'),
                                                      ),

                                                      new Divider(height: 2.0,),

                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                          ),
              number,

              new Row(children: 
                [ 
                  new Expanded(child: new RaisedButton(
                    color: AppTheme.MainThemeSwatch.swatch,
                    textColor: Colors.white,
                    child: new Text("Done", textScaleFactor: 2.0,),
                    onPressed: (){widget.sm.retCode = 1; update();},
                    padding: new EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                  )) 
                ],
              ),

          ]
        )
      );
    }
  }
}