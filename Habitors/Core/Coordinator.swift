//  Coordinator.swift

import Foundation
import UIKit

public protocol CoordinatorEvent {
}

open class Coordinator: NSObject {
    private(set) var started: Bool = false
    private(set) var children: [Coordinator] = []
    private(set) weak var parent: Coordinator?

    open func start() {
        if self.started {
            return
        }

        self.started = true
    }

    open func stop(completion: (() -> Void)? = nil) {
        if !self.started {
            return
        }

        self.children.forEach { child in
            child.stop()
        }

        self.started = false
        self.parent?.childDidStop(self)
        self.parent?.removeChild(self)
        completion?()
    }

    open func handle(event: CoordinatorEvent) -> Bool {
        return false
    }

    public func send(event: CoordinatorEvent) {
        if !self.handle(event: event) {
            self.parent?.send(event: event)
        }
    }

    public func addChild(_ coordinator: Coordinator?) {
        guard let coordinator else { return }
        coordinator.parent = self
        self.children.append(coordinator)
    }

    public func removeChild(_ coordinator: Coordinator) {
        coordinator.parent = nil
        let index = self.children.firstIndex { obj in
            return obj == coordinator
        }

        if index != nil {
            self.children.remove(at: index!)
        }
    }

    open func childDidStop(_ child: Coordinator) {

    }

    open override var debugDescription: String {
        return "Coordinator \(String(describing: self.self))\n\tchildren \(self.children)"
    }
}

class WindowBaseCoordinator: Coordinator {
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
}


class NavigationBaseCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

class PresentedCoordinator: Coordinator {
    weak var parentVC: UIViewController?
    
    init(controller: UIViewController) {
        weak var vc = controller
        self.parentVC = vc
    }
}

