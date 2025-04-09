//
//  UIViewController+Extensio.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 7/4/25.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
