import UIKit
import Flutter
import FirebaseCore
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if FirebaseApp.app() == nil {
       FirebaseApp.configure()
    }
    GMSServices.provideAPIKey("AIzaSyDuQBMsITh4xes6OHMb6qskLKa5sxyF_m0")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
