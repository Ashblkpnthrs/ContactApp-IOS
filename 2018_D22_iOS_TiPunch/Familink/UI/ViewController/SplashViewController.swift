//
//  SplashViewController.swift
//  Familink
//
//  Created by formation12 on 31/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let originFrameLogo = self.logoImage.frame
        
        self.logoImage.frame = CGRect(x: originFrameLogo.origin.x+80, y: originFrameLogo.origin.y+80, width: 0, height: 0)
        UIView.animate(withDuration: 1, animations: {
            
            self.logoImage.frame = CGRect(x: originFrameLogo.origin.x, y: originFrameLogo.origin.y, width: 160, height: 160)
        }) { (completed) in
            UIView.animate(withDuration: 0.5, animations: {
                self.logoImage.frame = CGRect(x: originFrameLogo.origin.x+15, y: originFrameLogo.origin.y+15, width: 130, height: 130)
            }, completion: { (completed) in
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.logoImage.frame = CGRect(x: originFrameLogo.origin.x+80, y: originFrameLogo.origin.y+80, width: 0, height: 0)
                    }, completion: { (completed) in
                        let controller = UIStoryboard.init(
                            name: "Main",
                            bundle: nil).instantiateViewController(
                                withIdentifier: "MasterViewController") as! MasterViewController
                        
                        self.show(controller, sender: self)
                    })
                })
                
            })
        }
    }
    
    
    
}
