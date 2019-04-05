//
//  ViewController.swift
//  Familink
//
//  Created by formation12 on 23/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var contactListContainer: UIView!
    var isConnect: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        contactListContainer.isHidden = true
        loginContainer.isHidden = true
        registerToLogInNotification()
    }
    override func viewDidAppear(_ animated: Bool) {
        if isConnect {
            loginContainer.isHidden = false
        } else {
            contactListContainer.isHidden = false
        }
    }
    func registerToLogInNotification() {
        print("register")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector (goToContactList),
            name: Notification.Name("login"), object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector (goToContactList),
            name: Notification.Name("offline"), object: nil)
    }
    @objc func goToContactList() {
        loginContainer.isHidden = true
        contactListContainer.isHidden = false
    }

}
