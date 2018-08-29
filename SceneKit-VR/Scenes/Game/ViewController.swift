import UIKit
import SpriteKit

final class ViewController: UIViewController, GVRCardboardViewDelegate {
    private var vrController: VRController
    private var renderer: SceneKitVRRenderer?
    private var renderLoop: RenderLoop?

    override func loadView() {
        view = createCardboardView()
    }

    private var cardboardView: GVRCardboardView {
        return view as! GVRCardboardView
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        vrController = VRController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        vrController = VRController()
        super.init(coder: aDecoder)
    }

    private func createCardboardView() -> GVRCardboardView {
        let cardboardView: GVRCardboardView = GVRCardboardView(frame: .zero)
        cardboardView.delegate = self
        cardboardView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]

        #if targetEnvironment(simulator)
        cardboardView.vrModeEnabled = false
        #else
        cardboardView.vrModeEnabled = true
        #endif

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(toggleVR))
        doubleTap.numberOfTapsRequired = 2
        cardboardView.addGestureRecognizer(doubleTap)

        return cardboardView
    }

    @objc func toggleVR() {
        cardboardView.vrModeEnabled = !cardboardView.vrModeEnabled
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        renderLoop = RenderLoop(renderTarget: cardboardView,
                                selector: #selector(GVRCardboardView.render))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        renderLoop?.invalidate()
        renderLoop = nil
    }

    func cardboardView(_ cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!) {
        renderer = SceneKitVRRenderer(scene: vrController.scene)
        renderer?.cardboardView(cardboardView, willStartDrawing: headTransform)
    }

    func cardboardView(_ cardboardView: GVRCardboardView!, prepareDrawFrame headTransform: GVRHeadTransform!) {
        vrController.prepareFrame(with: headTransform)
        renderer?.cardboardView(cardboardView, prepareDrawFrame: headTransform)
    }

    func cardboardView(_ cardboardView: GVRCardboardView!, draw eye: GVREye, with headTransform: GVRHeadTransform!) {
        renderer?.cardboardView(cardboardView, draw: eye, with: headTransform)
    }

    func cardboardView(_ cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool) {
        renderLoop?.paused = pause
    }

    func cardboardView(_ cardboardView: GVRCardboardView!, didFire event: GVRUserEvent) {
        if event == .trigger {
            vrController.eventTriggered()
        }
    }
}
