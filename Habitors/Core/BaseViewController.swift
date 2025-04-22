//  BaseViewController.swift

import Foundation
import UIKit
import RxSwift
import SwiftUI

open class BaseViewController: UIViewController {
    private(set) var viewWillAppeared: Bool = false
    private(set) var viewDidAppeared: Bool = false
    
    public var isDisplaying: Bool = false
    private var isLoadAdFailed: Bool = true
    var disposeBag = DisposeBag()
        
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return User.isTurnDarkMode ? .lightContent : .darkContent
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewWillAppeared {
            viewWillAppeared = true
            self.viewWillFirstAppear()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isDisplaying = true
        if !viewDidAppeared {
            viewDidAppeared = true
            self.viewDidFirstAppear()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisplaying = false
    }
    
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
    }
    
    
    open func viewWillFirstAppear() {
        // nothing
    }
    
    open func viewDidFirstAppear() {
        // nothing
    }
    
    open func viewWillDisappearByInteractive() {
        // nothing
    }
    
    func insertFullScreen<Content: View>(_ view: Content) {
        let vc = UIHostingController(rootView: view)
        vc.didMove(toParent: self)
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.view.backgroundColor = .clear
        vc.view.fitToSuperview()
    }
}
