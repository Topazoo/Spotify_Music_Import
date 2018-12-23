import 'dart:io' as IO;
import 'package:flutter/services.dart';

class Audio_File {
  /* Contains information about audio file */

  String title;
  String artist;
  String path;

  Audio_File(String title, String artist, String path)
  {
    this.title = title;
    this.artist = artist;
    this.path = path;
  }
}

class Audio_Filesystem {

  List<String> exts = ["mp3", "aac", "wav", "ogg", "wma", "flac"];

  Map<String, Audio_File> cached = new Map<String, Audio_File>();

  //List of currently selected files
  List<Audio_File> selected = new List<Audio_File>();
  //List of known files
  List<Audio_File> files = new List<Audio_File>();
  //List of unknown files
  List<Audio_File> unknownFiles = new List<Audio_File>();

  Audio_Filesystem()
  {
    collect_files();
  }

  void collect_files()
  {
    /* Get all audio files  */

    fetch_audio();
    
    files.sort((a, b) => a.artist.compareTo(b.artist));
    unknownFiles.sort((a, b) => a.title.compareTo(b.title));
  }

  List<Audio_File> fetch_audio()
  {
    /* Allow for cross-platform audio file retrieval */
    
    if (IO.Platform.isAndroid)
      android_fetch();
    else
      iPhone_fetch();
  }

  List<String> parse_android_info(String fullName)
  {
      /* Parse title and artist
        @fullname - The name of the file */
      
      String title;
      String artist;

      //If '-' Separates the title and artist
      if (fullName.contains('-'))
      {
        
        int nameSplit = fullName.indexOf('-');

        artist = fullName.substring(0, nameSplit - 1);
        title = fullName.substring(nameSplit + 1);
      }

      //Otherwise no artist
      else
      {
        title = fullName;
        artist = "None";
      }

      return [title, artist];
  }

  void iPhone_fetch() async
  {
    /* Fetch iPhone music library */

    print("Fetching iOS library");

    const platform = const MethodChannel('flutter.io.media/get_media');

    try {
      final int result = await platform.invokeMethod('get_media');
      print(result);
    } on PlatformException catch (e) {
      print("Failed to get audio files: '${e.message}'.");
    }
  }

  void android_fetch() 
  {
    /* Fetch Android music library */
  
    //Access downloads directory
    IO.Directory root = IO.Directory('/sdcard/download');
    
    //Read all data
    List<IO.FileSystemEntity> all = root.listSync(recursive: true, followLinks: false);
    for (IO.FileSystemEntity entity in all)
    {
      //Fetch files
      if (entity is IO.File)
      {
        //Determine extension
        String strForm = entity.toString();
        int extStart = strForm.lastIndexOf('.') + 1;
        
        //Parse music files and add to list - All files initially selected
        if (exts.contains(strForm.substring(extStart, strForm.length - 1)))
        {
          Audio_File file = parse_android_file(entity);

          if(!cached.containsKey(file.title+file.artist))
          {
            if (file.artist != "None")
            {
              files.add(file);
              selected.add(file);
            }
            else
              unknownFiles.add(file);

            cached[file.title+file.artist] = file;
          }
        }
      }  
    }

    //Store in class
    this.files = files;
  }

  Audio_File parse_android_file(IO.FileSystemEntity file)
  {
      /* Get relevant information from collected files and convert it to class
        @file - The file to get info from */

      //Get path
      String path = file.absolute.toString();

      //Get name location
      int nameStart = path.lastIndexOf('/') + 1;
      int nameEnd = path.lastIndexOf('.');

      //Get name
      String fullName = path.substring(nameStart, nameEnd);

      //Get title and artist
      List<String> info = parse_android_info(fullName);

      //Create class representation
      return new Audio_File(info[0].trim(), info[1].trim(), path);     
  }
}