import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Pre-warmed explicit engine. Creating and running the engine *before* the
  // FlutterViewController is instantiated guarantees the engine's task runners
  // are ready by the time the view controller's viewDidLoad fires.
  //
  // This works around an iOS 26 / ProMotion crash where the implicit-engine
  // flow calls `createTouchRateCorrectionVSyncClientIfNeeded` in viewDidLoad
  // while `engine.platformTaskRunner` is still null, causing a SIGSEGV inside
  // -[VSyncClient initWithTaskRunner:callback:]. See flutter/flutter#183900.
  var flutterEngine: FlutterEngine?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let engine = FlutterEngine(name: "main_engine")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    flutterEngine = engine

    // Build the root view controller from the pre-warmed engine and hand it to
    // the (Flutter) UISceneDelegate, which moves it onto the scene's window.
    let flutterViewController = FlutterViewController(
      engine: engine, nibName: nil, bundle: nil)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = flutterViewController
    self.window = window

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
