import 'dart:io' as IO;

class Audio_Filesystem {
  int fetch_audio()
  {
    /* Allow for cross-platform audio file retrieval */
    
    if (IO.Platform.isAndroid)
      return android_fetch();
    else
      return iPhone_fetch();
  }

  int iPhone_fetch()
  {
    /* Fetch iPhone music library */
    // TODO - IMPLEMENT

    return 2;
  }

  int android_fetch()
  {
    /* Fetch Android music library */
    IO.Directory root = IO.Directory('/sdcard/download');
    root.list(recursive: false, followLinks: false).listen((IO.FileSystemEntity entity) {
      print(entity.path);
    });    

    
    return 3;
  }

}