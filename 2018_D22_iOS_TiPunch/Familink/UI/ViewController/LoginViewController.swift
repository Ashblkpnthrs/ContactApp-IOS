//
//  LoginViewController.swift
//  Familink
//
//  Created by formation12 on 23/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneTextInput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    @IBOutlet weak var phoneNumberTextLabel: UILabel!
    @IBOutlet weak var passwordTextLabel: UILabel!
    @IBOutlet weak var rememberMeTextLabel: UILabel!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    let defaults = UserDefaults.standard
    
    var userPhone: String?
    var userPassword: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!ConnectedClient.instance.isConnectedToNetwork()) {
            let alert = UIAlertController(
                title: "Erreur de connexion",
                message: "Voulez-vous passer en mode hors-ligne ?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (sender) in
                NotificationCenter.default.post(name: Notification.Name("offline"), object: self)
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        loadUserFromCoreData()
        if userPhone != "" {
            phoneTextInput.text = userPhone
        }
        phoneTextInput.delegate = self
        passwordTextInput.delegate = self
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        swipe.cancelsTouchesInView = false
        view.addGestureRecognizer(swipe)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = view.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    @IBAction func tapOnLogin(_ sender: UIButton) {
        userPhone =  phoneTextInput.text
        userPassword = passwordTextInput.text
        if rememberMeSwitch.isOn {
            defaults.set(phoneTextInput.text, forKey: "Phone")
        } else {
            defaults.set("", forKey: "Phone")
        }
        if ConnectedClient.instance.isConnectedToNetwork() {
            let loader = UIViewController.displaySpinner(onView: self.view)
            APIClient.instance.login(phone: userPhone!, password: userPassword!, onSucces: { (Result) in
                DispatchQueue.main.async {
                    print("success login before notif")
                    NotificationCenter.default.post(name: Notification.Name("login"), object: self)
                    print(Result)
                    UIViewController.removeSpinner(spinner: loader)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    print(error)
                    UIViewController.removeSpinner(spinner: loader)
                    self.checkError(error: error)
                }
            }
        } else {
            let alert = UIAlertController(
                title: "Erreur de connexion",
                message: "Voulez-vous passer en mode hors-ligne ?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (sender) in
                NotificationCenter.default.post(name: Notification.Name("offline"), object: self)
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
    }
    @IBAction func tapOnSignUp(_ sender: UIButton) {
        if(ConnectedClient.instance.isConnectedToNetwork()) {
            let controller = UIStoryboard.init(
                name: "Main",
                bundle: nil).instantiateViewController(
                    withIdentifier: "SignUpViewController") as! SignUpViewController
            self.show(controller, sender: self)
        } else {
            let alert = UIAlertController(
                title: "Erreur de connexion",
                message: "Voulez-vous passer en mode hors-ligne ?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { (sender) in
                NotificationCenter.default.post(name: Notification.Name("offline"), object: self)
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    @IBAction func rememberMeSwitch(_ sender: Any) {
    }
    
    func loadUserFromCoreData() {
        let savedPhone = defaults.object(forKey: "Phone")
        userPhone = savedPhone as? String ?? ""
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor(red:0.38, green:0.55, blue:0.21, alpha:1.0)
        self.phoneTextInput.setBottomLine(borderColor: lineColor)
        self.passwordTextInput.setBottomLine(borderColor: lineColor)
    }
    func checkError(error: String) {
        switch error {
        case "User not found":
                let alert = UIAlertController(
                    title: "Erreur sur le formulaire",
                    message: "Le numéro de téléphone est incorrecte",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
        case "Password is not valid":
                let alert = UIAlertController(
                    title: "Erreur sur le formulaire",
                    message: "Le mot de passe est incorrecte",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
        default :
            let alert = UIAlertController(
                title: "Erreur sur le formulaire",
                message: "Une erreur est survenu, veuillez vérifier vos informations",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
}
