//
//  Extensions.swift
//  NewGuidence(新手引导)
//
//  Created by 王宁 on 2017/8/30.
//  Copyright © 2017年 @David. All rights reserved.
//

import UIKit


extension String{
    
    func ks_sizeof(font:UIFont,maxWidth:CGFloat)->CGSize{
        
        let s = self as NSString

        let size = s.boundingRectWithSize(CGSize.init(width: maxWidth, height: .infinity), options: [NSStringDrawingOptions.UsesLineFragmentOrigin,.TruncatesLastVisibleLine,.UsesFontLeading], attributes: [NSFontAttributeName: font], context: nil).size
        return size
    }

}

extension UIImage{
    
    func ks_image(tintColor:UIColor)->UIImage?{
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        tintColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        drawInRect(bounds, blendMode: .Overlay, alpha: 1)
        drawInRect(bounds, blendMode: .DestinationIn, alpha: 1)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}






