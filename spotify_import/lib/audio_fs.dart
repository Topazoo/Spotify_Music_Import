import 'dart:io' as IO;
import 'dart:async';

class Audio_File {
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
  Future<List<Audio_File>> fetch_audio() async
  {
    /* Allow for cross-platform audio file retrieval */
    
    if (IO.Platform.isAndroid)
      return android_fetch();
    else
      return iPhone_fetch();
  }

  List<Audio_File> iPhone_fetch()
  {
    /* Fetch iPhone music library */
    // TODO - IMPLEMENT

    return null;
  }

  Future<List<Audio_File>> android_fetch() async
  {
    /* Fetch Android music library */

    Completer c = new Completer<List<Audio_File>>();
    List<Audio_File> files = new List<Audio_File>();
  
    //Access downloads directory
    IO.Directory root = IO.Directory('/sdcard/download');
    
    //Read all data
     root.list(recursive: true, followLinks: false).listen((IO.FileSystemEntity entity) {
      
      //Fetch music files
      if (entity is IO.File)
      {
        String strForm = entity.toString();
        int extStart = strForm.lastIndexOf('.') + 1;
        
        //Parse music files and add to list
        if (strForm.substring(extStart, strForm.length - 1) == "mp3") //TODO - All music files
        {
          Audio_File file = parse_android_file(entity);
          files.add(file);
        }
      }
    }).onDone(() => c.complete(files));    

    return c.future;
  }

  List<String> parse_android_info(String fullName)
  {
      /* Parse title and artist */
      
      String title;
      String artist;

      //If '-' Separates the title and artist
      if (fullName.contains('-'))
      {
        
        int nameSplit = fullName.indexOf('-');

        artist = fullName.substring(0, nameSplit - 1);
        title = fullName.substring(nameSplit + 1);
      }

      else
      {
        title = fullName;
        artist = "None";
      }

      return [title, artist];
  }


  Audio_File parse_android_file(IO.FileSystemEntity file)
  {
      /* Get relevant information from collected files */

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