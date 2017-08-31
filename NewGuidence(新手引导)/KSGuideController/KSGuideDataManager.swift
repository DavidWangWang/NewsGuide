//
//  KSGuideDataManager.swift
//  NewGuidence(新手引导)
//
//  Created by 王宁 on 2017/8/30.
//  Copyright © 2017年 @David. All rights reserved.
//

import UIKit

class KSGuideDataManager: NSObject {

    static let userDefaults = NSUserDefaults.standardUserDefaults()
    static let dataKey = "KSGuideDataKey"
    
    static func reset(key:String){
        if var data = userDefaults.objectForKey(dataKey) as? [String: Bool]{
            data.removeValueForKey(key)
            userDefaults.setObject(data, forKey: dataKey)
        }
    }
    static func resetAll() {
        userDefaults.setObject(nil, forKey: dataKey)
    }
    static func shouldShowGuide(with key: String) -> Bool {
        if var data = userDefaults.objectForKey(dataKey) as? [String: Bool]{
            if let _ = data[key] {
                return false
            }
            data[key] = true
            userDefaults.setObject(data, forKey: dataKey)
            return true
        }
        let data = [key: true]
        userDefaults.setObject(data, forKey: dataKey)
        return true
    }
}
