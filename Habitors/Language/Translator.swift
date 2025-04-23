//
//  Translator.swift
//  Habitors
//
//  Created by Thanh Vu on 23/4/25.
//

import Foundation

class Translator {
    static func translate(key: String, isVietnamese: Bool) -> String {
        let language = isVietnamese ? "vi" : "en"
        if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
            let bundle = Bundle(path: path)
            return NSLocalizedString(key, bundle: bundle!, comment: "")
        }
        
        return key
    }
}
