import 'dart:io' as IO;

class Audio_Filesystem {
  int fetch_audio()
  {
    /* Allow for cross-platform audio file retrieval */
    
    String os = IO.Platform.operatingSystem;
    if (os == 'android')
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
    
    return 3;
  }

}