import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'spotify_manager.dart';
import 'theme.dart' as AppTheme;
import 'audio_fs.dart' as Audio_FS;

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

  @override
  Widget build(BuildContext context) {
    //Change display based on status
    int status = widget.sm.retCode;

    //If not connected to Spotify
    //TODO - Ping before opening webview
    if (status < 1)
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
    else if (status == 1)
    {
      //Close webview
      widget.webview.close();

      //Show import button
      return new Center(child: new RaisedButton(
                          color: AppTheme.MainThemeSwatch.swatch,
                          textColor: Colors.white,
                          child: new Text("Import Songs", textScaleFactor: 2.0,),
                          onPressed: widget.sm.import_songs,
                          padding: new EdgeInsets.fromLTRB(60.0, 25.0, 60.0, 25.0),)
                        );
    }

    //Else if songs imported
    else if (status == 2)
    {
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
                                                      ),
                                      ),
                          width: double.infinity,
                          color: Color.fromRGBO(30, 190, 54, 0.77),
                        );

        songs = widget.sm.files.selected;
      }

      else
      {
        int totalSongs = widget.aud.files.length + widget.aud.unknownFiles.length;
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
                                                      ),
                                      ),
                          width: double.infinity,
                          color: Color.fromRGBO(223, 52, 52, 0.77),
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
          ]
        )
      );
    }
  }
}