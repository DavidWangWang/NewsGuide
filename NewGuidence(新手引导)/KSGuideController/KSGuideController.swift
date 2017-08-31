//
//  KSGuideController.swift
//  NewGuidence(新手引导)
//
//  Created by 王宁 on 2017/8/30.
//  Copyright © 2017年 @David. All rights reserved.
//

import UIKit

class KSGuideController: UIViewController {

    enum Region {
        case upperLeft
        case upperRight
        case lowerLeft
        case lowerRight
    }
    
     typealias CompletionBlock = (() -> Void)
     typealias IndexChangeBlock = (( index: Int,  item: KSGuideItem) -> Void)
    
    private let arrowImageView = UIImageView()
    private let textLabel = UILabel()
    private let maskLayer = CAShapeLayer()
    private var completion: CompletionBlock?
    private var indexWillChangeBlock: IndexChangeBlock?
    private var indexDidChangeBlock: IndexChangeBlock?
    private var guideKey: String?
    
     var maskCornerRadius: CGFloat = 5
     var backgroundAlpha: CGFloat = 0.7
     var spacing: CGFloat = 20
     var padding: CGFloat = 50
     var maskInsets = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
     var font = UIFont.systemFontOfSize(14)
     var textColor = UIColor.whiteColor()
     var arrowColor = UIColor.whiteColor()
     var arrowImage: UIImage?
     var animationDuration = 0.3
     var animatedMask = true
     var animatedText = true
     var animatedArrow = true
    
     var statusBarHidden = false
    
    private var maskCenter: CGPoint {
        get {
            return CGPoint(x: hollowFrame.midX, y: hollowFrame.midY)
        }
    }
    
    private var items = [KSGuideItem]()
     var currentIndex: Int = -1 {
        didSet {
            indexWillChangeBlock?(index: currentIndex, item: currentItem)
            configViews()
            indexDidChangeBlock?(index: currentIndex, item: self.currentItem)
        }
    }
    private var currentItem: KSGuideItem {
        get {
            return items[currentIndex]
        }
    }
    
    private var hollowFrame: CGRect {
        get {
            var rect: CGRect = .zero
            if let sourceView = currentItem.sourceView {
                let systemVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
                if systemVersion >= 8.0 && systemVersion < 9.0 {
                    // Unwrap the superView to ensure that we call `convert(_ rect: CGRect, from coordinateSpace: UICoordinateSpace) -> CGRect`
                    // instead of `convert(_ rect: CGRect, from view: UIView?) -> CGRect`
                    if let superView = sourceView.superview {
                        rect = view.convertRect(sourceView.frame, fromView: superView)
                    } else {
                        assertionFailure("sourceView must have a superView!")
                    }
                } else {
                  
                    rect = view.convertRect(sourceView.frame, fromView: sourceView.superview)

                }
            } else {
                rect = currentItem.rect
            }
            rect.origin.x += maskInsets.left
            rect.origin.y += maskInsets.top
            rect.size.width -= maskInsets.right + maskInsets.left
            rect.size.height -= maskInsets.bottom + maskInsets.top
            return rect
        }
    }
    private var region: Region {
        get {
            let center = maskCenter
            let bounds = view.bounds
            if center.x <= bounds.midX && center.y <= bounds.midY {
                return .upperLeft
            } else if center.x > bounds.midX && center.y <= bounds.midY {
                return .upperRight
            } else if center.x <= bounds.midX && center.y > bounds.midY {
                return .lowerLeft
            } else {
                return .lowerRight
            }
        }
    }


    // Give a nil key to ignore the cache logic.
    init(items: [KSGuideItem], key: String?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
        self.items += items
        self.guideKey = key
    }
    // Give a nil key to ignore the cache logic.
    convenience init(item: KSGuideItem, key: String?) {
        self.init(items: [item], key: key)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(from vc: UIViewController, completion:CompletionBlock?) {
        self.completion = completion
        if let key = guideKey {
            if KSGuideDataManager.shouldShowGuide(with: key) {

                vc.presentViewController(self, animated: true, completion: nil)
            }
        } else {
            
            vc.presentViewController(self, animated: true, completion: nil)

        }
    }

     func setIndexWillChangeBlock(block: IndexChangeBlock?) {
        indexWillChangeBlock = block
    }
    
     func setIndexDidChangeBlock(block: IndexChangeBlock?) {
        indexDidChangeBlock = block;
    }

    override func prefersStatusBarHidden() -> Bool {
         return statusBarHidden
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (ctx) in
            
            self.configMask()
            self.configViewFrames()
            
            }, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = 0
    }
    
    private func configViews() {
        view.backgroundColor = UIColor(white: 0, alpha: backgroundAlpha)
        
        if let image = arrowImage {
            arrowImageView.image = image.ks_image(arrowColor)
        } else {
            
         arrowImageView.image =    UIImage.init(named: "guide_arrow", inBundle: NSBundle.init(forClass: KSGuideController.self), compatibleWithTraitCollection: nil)?.ks_image(arrowColor)
        }
        arrowImageView.tintColor = arrowColor
        view.addSubview(arrowImageView)
        
        textLabel.textColor = textColor
        textLabel.font = font
        textLabel.textAlignment = .Left
        textLabel.text = currentItem.text
        textLabel.numberOfLines = 0
        view.addSubview(textLabel)
        
        configMask()
        configViewFrames()
    }
    
    
    func configMask(){
        let fromPath = maskLayer.path
        maskLayer.fillColor = UIColor.blackColor().CGColor
        var radius = maskCornerRadius
        let frame = hollowFrame
        
        radius = min(radius, min(frame.width / 2.0, frame.height / 2.0))
        let highlightedPath = UIBezierPath(roundedRect: hollowFrame, cornerRadius: radius)
        let toPath = UIBezierPath(rect: view.bounds)
        toPath.appendPath(highlightedPath)
        maskLayer.path = toPath.CGPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        view.layer.mask = maskLayer
        if animatedMask {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = animationDuration
            animation.fromValue = fromPath
            animation.toValue = toPath
            maskLayer.addAnimation(animation, forKey: nil)
        }
    }
    
    private func configViewFrames() {
        maskLayer.frame = view.bounds
        
        var textRect: CGRect!
        var arrowRect: CGRect!
        var transform: CGAffineTransform = CGAffineTransformIdentity
        let imageSize = arrowImageView.image!.size
        let maxWidth = view.frame.size.width - padding * 2
        let size = currentItem.text.ks_sizeof(font, maxWidth: maxWidth)
        let maxX = padding + maxWidth - size.width
        switch region {
        case .upperLeft:
            transform = CGAffineTransformMakeScale(-1, 1)
            
            arrowRect = CGRect(x: hollowFrame.midX - imageSize.width / 2,
                               y: hollowFrame.maxY + spacing,
                               width: imageSize.width,
                               height: imageSize.height)
            let x: CGFloat = max(padding, min(maxX, arrowRect.maxX - size.width / 2))
            textRect = CGRect(x: x,
                              y: arrowRect.maxY + spacing,
                              width: size.width,
                              height: size.height)
        case .upperRight:
            arrowRect = CGRect(x: hollowFrame.midX - imageSize.width / 2,
                               y: hollowFrame.maxY + spacing,
                               width: imageSize.width,
                               height: imageSize.height)
            let x: CGFloat = max(padding, min(maxX, arrowRect.minX - size.width / 2))
            textRect = CGRect(x: x,
                              y: arrowRect.maxY + spacing,
                              width: size.width,
                              height: size.height)
            
        case .lowerLeft:
            transform = CGAffineTransformMakeScale(-1, -1)
            arrowRect = CGRect(x: hollowFrame.midX - imageSize.width / 2,
                               y: hollowFrame.minY - spacing - imageSize.height,
                               width: imageSize.width,
                               height: imageSize.height)
            let x: CGFloat = max(padding, min(maxX, arrowRect.maxX - size.width / 2))
            textRect = CGRect(x: x,
                              y: arrowRect.minY - spacing - size.height,
                              width: size.width,
                              height: size.height)
        case .lowerRight:
            transform = CGAffineTransformMakeScale(1, -1)
            arrowRect = CGRect(x: hollowFrame.midX - imageSize.width / 2,
                               y: hollowFrame.minY - spacing - imageSize.height,
                               width: imageSize.width,
                               height: imageSize.height)
            let x: CGFloat = max(padding, min(maxX, arrowRect.minX - size.width / 2))
            textRect = CGRect(x: x,
                              y: arrowRect.minY - spacing - size.height,
                              width: size.width,
                              height: size.height)
       
        }
        if animatedArrow && animatedText {
            UIView.animateWithDuration(animationDuration, animations: {
                self.arrowImageView.transform = transform
                self.arrowImageView.frame = arrowRect
                self.textLabel.frame = textRect
                }, completion: nil)
            
            return
        }
        if animatedArrow {
          UIView.animateWithDuration(animationDuration, animations: { 
            self.arrowImageView.transform = transform
            self.arrowImageView.frame = arrowRect
            }, completion: nil)
            
          self.textLabel.frame = textRect
          return
        }
        if animatedText{
            
            UIView.animateWithDuration(animationDuration, animations: { 
                self.textLabel.frame = textRect
                }, completion: nil)
            self.arrowImageView.transform = transform
            self.arrowImageView.frame = arrowRect
            return
        }
        arrowImageView.transform = transform
        arrowImageView.frame = arrowRect
        textLabel.frame = textRect
    }
    
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentIndex < items.count - 1 {
            currentIndex += 1
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
