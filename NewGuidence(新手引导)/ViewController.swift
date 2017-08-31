//
//  ViewController.swift
//  KSGuideController
//
//  Created by Kyle Sun on 2017/5/8.
//  Copyright © 2017年 Kyle Sun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    let string = "GitHub is a web-based Git or version control repository and Internet hosting service. It is mostly used for code. It offers all of the distributed version control and source code management (SCM) functionality of Git as well as adding its own features. It provides access control and several collaboration features such as bug tracking, feature requests, task management, and wikis for every project."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showGuides()
    }
    
    @IBAction func guideButtonPressed(sender: UIButton) {
        showGuides()
    }

    func showGuides() {
        // Reset to show everytime.
//        KSGuideDataManager.reset("MainGuide")
        
        var items = [KSGuideItem]()
        for button in buttons {
            let n = Int(arc4random()) % string.characters.count
            let index = string.startIndex.advancedBy(Int(n))
            let text = string.substringToIndex(index)
            let item = KSGuideItem(sourceView: button, text: text)
            items.append(item)
        }
        
        
        let vc = KSGuideController(items: items, key: "MainGuide")
        vc.setIndexWillChangeBlock { (index, item) in
            print("Index will change to \(index)")
        }
        vc.setIndexDidChangeBlock { (index, item) in
            print("Index did change to \(index)")
        }
        vc.show(from: self) { 
            print("Guide controller has been dismissed")
        }
    }
    
}

