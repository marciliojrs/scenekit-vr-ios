import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navController = UINavigationController(rootViewController: ViewController())
        navController.delegate = self
        navController.isNavigationBarHidden = true

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    // Make the navigation controller defer the check of supported orientation to its topmost view
    // controller. This allows |GVRCardboardViewController| to lock the orientation in VR mode.
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return navigationController.topViewController!.supportedInterfaceOrientations
    }
}
