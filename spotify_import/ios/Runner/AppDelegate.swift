import UIKit
import Flutter
import MediaPlayer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let mediaChannel = FlutterMethodChannel(name: "flutter.io.media/get_media",
                                              binaryMessenger: controller)
      let authChannel = FlutterMethodChannel(name: "flutter.io.media/get_auth",
                                              binaryMessenger: controller)
                                  
      mediaChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        guard call.method == "get_media" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.get_media(result: result)
      })

      authChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        guard call.method == "get_auth" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.get_auth(result: result)
      })

      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func get_media(result: FlutterResult) { 
    var songsDict = [String: String]()
    for song in MPMediaQuery.songs().items! {
      songsDict[String(song.title!)] = String(song.artist!)
    }

    let nsSongDict = songsDict as NSDictionary
    result(nsSongDict)
  }

  private func get_auth(result: FlutterResult) { 
    result(String("Fetching auth using Swift"))
  }
}
