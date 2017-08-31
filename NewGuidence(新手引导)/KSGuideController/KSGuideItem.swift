//
//  KSGuideItem.swift
//  NewGuidence(新手引导)
//
//  Created by 王宁 on 2017/8/30.
//  Copyright © 2017年 @David. All rights reserved.
//

import UIKit

public class KSGuideItem: NSObject {
    public var sourceView: UIView?
    public var rect: CGRect = .zero
    public var text: String!
    
    public init(sourceView: UIView, text: String) {
        self.sourceView = sourceView
        self.text = text
    }
    
    public init(rect: CGRect, text: String) {
        self.rect = rect
        self.text = text
    }
}
