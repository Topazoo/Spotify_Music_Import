import 'package:flutter/material.dart';
import 'audio_fs.dart' as Audio_FS;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final Audio_FS.Audio_Filesystem audio_fs = new Audio_FS.Audio_Filesystem();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
    // Class to access and retrieve audio files

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder<List<Audio_FS.Audio_File>>(
          future: widget.audio_fs.fetch_audio(), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<List<Audio_FS.Audio_File>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Text('Awaiting result...');
              case ConnectionState.done:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                return list_from_snapshot(context, snapshot);
            }
            return null; // unreachable
          },
        ),
      ),
    );
  }

  Widget list_from_snapshot(BuildContext context, AsyncSnapshot snapshot) {
    List<Audio_FS.Audio_File> files = snapshot.data;
    return new ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          return new Column(
            children: <Widget>[
              new ListTile(
                title: new Text('${files[index].title}'),
                subtitle: new Text('${files[index].artist}'),
              ),
              new Divider(height: 2.0,),
            ],
          );
        },
    );
  }
}
