//
//  ViewController.swift
//  WeeMenu
//
//  Created by Federico Gentile on 20/04/17.
//  Copyright © 2017 Gens. All rights reserved.
//

import UIKit

class DemoViewController: WeeMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "gattiniController")
        super.roundCorners = false
        super.animateStatusBar = false
        super.rootViewAnimation = .none
        super.rootViewBackgroundColor = .red
        super.menuPosition = .front
        
        super.setWeeMenu(ViewController: vc)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        super.openMenu()
    }
}
