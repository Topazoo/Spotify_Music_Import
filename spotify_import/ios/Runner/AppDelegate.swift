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
      let permChannel = FlutterMethodChannel(name: "flutter.io.media/get_perm",
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
        let arguments = call.arguments as! NSDictionary
        self?.get_auth(result: result, args: arguments)
      })

      permChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        guard call.method == "get_perm" else {
            result(FlutterMethodNotImplemented)
            return
        }
        self?.get_perm(result: result)
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

  private func get_auth(result: FlutterResult, args: NSDictionary) { 
    let auth_url = args["auth_url"] as! String

    guard let url = URL(string: auth_url) else { return }
    UIApplication.shared.open(url)
  }
    
  private func get_perm(result: FlutterResult) {
    var res = false
    if MPMediaLibrary.authorizationStatus() == .authorized
    {
        result(true)
    } else {
        MPMediaLibrary.requestAuthorization { (status) in
            switch status {
                case .authorized:
                    res = true
                case .notDetermined: break // We are already request the authorization above
                case .denied,
                     .restricted:
                    res = false
            }
        }
    }
    
    result(res)
  }
}
