//
//  Keys.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation

enum APIKey {
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "API", ofType: "plist")
        else {
            fatalError("Couldn't find file!")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Coulnd't find API key!")
        }
        if value.starts(with: "_") {
            fatalError("Dumbass")
        }
        return value
    }
}

