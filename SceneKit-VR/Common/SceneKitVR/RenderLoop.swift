import UIKit

final class RenderLoop: NSObject {
    private var displayLink: CADisplayLink?
    private var renderThread: Thread?
    var paused = false {
        didSet {
            displayLink?.isPaused = paused
        }
    }

    init(renderTarget: AnyObject, selector: Selector) {
        super.init()

        displayLink = CADisplayLink(target: renderTarget, selector: selector)
        renderThread = Thread(target: self, selector: #selector(threadMain), object: nil)
        renderThread?.start()

        addNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    @objc func applicationWillResignActive(_ notification : Notification) {
        guard let thread = renderThread else { return }
        perform(#selector(renderThreadSetPaused), on: thread, with: nil, waitUntilDone: true)
    }
    
    @objc func applicationDidBecomeActive(_ notification : Notification) {
        displayLink?.isPaused = paused
    }
    
    func invalidate() {
        guard let thread = renderThread else { return }
        perform(#selector(renderThreadInvalidate), on: thread, with: nil, waitUntilDone: false)
    }
    
    @objc func threadMain() {
        displayLink?.add(to: .current, forMode: .commonModes)
        CFRunLoopRun()
    }
    
    @objc func renderThreadSetPaused() {
        displayLink?.isPaused = true
    }
    
    @objc func renderThreadInvalidate() {
        displayLink?.invalidate()
        displayLink = nil
        let currentRunloop = CFRunLoopGetCurrent()

        CFRunLoopStop(currentRunloop)
        
        DispatchQueue.main.async {
            self.renderThread?.cancel()
            self.renderThread = nil
        }
    }
}
