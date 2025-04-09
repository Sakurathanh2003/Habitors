//
//  UIApplication+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 9/4/25.
//

import UIKit

extension UIApplication {
    func openAppleHealthSources() {
        guard let url = URL(string: "x-apple-health://sharingOverview"),
              self.canOpenURL(url) else {
            return
        }
        self.open(url)
    }
}
