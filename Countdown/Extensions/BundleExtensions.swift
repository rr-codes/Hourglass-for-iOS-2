//
//  BundleExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-11.
//

import Foundation

extension Bundle {
    func apiKey(named keyName: String) -> String {
        let path = self.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: path!)
        return plist!.object(forKey: keyName) as! String
    }
    
    func data(forResource name: String?, ofType ext: String?, using encoding: String.Encoding) -> Data? {
        guard let path = Bundle.main.path(forResource: name, ofType: ext),
              let contents = try? String(contentsOfFile: path)
        else {
            return nil
        }
        
        return contents.data(using: encoding)
    }
}
