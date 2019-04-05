//
//  SignUpViewController.swift
//  Familink
//
//  Created by formation12 on 24/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import UIKit
import CoreData

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    let profils = ["Senior", "Famille", "Medecin"]
    
    @IBOutlet weak var phoneTextImput: UITextField!
    @IBOutlet weak var lastNameTextImput: UITextField!
    @IBOutlet weak var firstNameTextImput: UITextField!
    @IBOutlet weak var mailTextImput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    @IBOutlet weak var confirmPasswordTextInput: UITextField!
    @IBOutlet weak var profilPicker: UIPickerView!
    @IBOutlet weak var lastNameTextLabel: UILabel!
    @IBOutlet weak var phoneNumberTextLabel: UILabel!
    @IBOutlet weak var firstNameTextLabel: UILabel!
    @IBOutlet weak var mailTextLabel: UILabel!
    @IBOutlet weak var profilPickerTextLabel: UILabel!
    @IBOutlet weak var passwordTextLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextLabel: UILabel!

    var password: String!
    var userPhone: String?
    var profile: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilPicker.delegate = self
        profilPicker.dataSource = self
        phoneTextImput.delegate = self
        firstNameTextImput.delegate = self
        lastNameTextImput.delegate = self
        mailTextImput.delegate = self
        passwordTextInput.delegate = self
        confirmPasswordTextInput.delegate = self
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
    
    @IBAction func signUpUiButton(_ sender: UIButton) {
        if(ConnectedClient.instance.isConnectedToNetwork()){
                let newUser = User(context: self.getContext()!)
                newUser.phone = self.phoneTextImput.text
                newUser.firstName = self.firstNameTextImput.text
                newUser.lastName = self.lastNameTextImput.text
                newUser.email = self.mailTextImput.text
                newUser.profile = self.profile ?? "SENIOR"
            if phoneTextImput.text == "" {
                self.getAlert(message: "Le champ téléphone est vide")
            } else if firstNameTextImput.text == "" { 
                self.getAlert(message: "Le champ prénom est vide")
            } else if lastNameTextImput.text == "" {
                self.getAlert(message: "Le champ nom est vide")
            } else if mailTextImput.text == "" {
                self.getAlert(message: "Le champ email est vide")
            }
            
            if passwordTextInput.text == confirmPasswordTextInput.text {
                password = passwordTextInput.text
                createUser(u: newUser, password: password)
            } else {
                self.getAlert(message: "Les mots de passes sont différents")
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profils[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        profile = profils[row].uppercased()
    }
    
    func getContext() -> NSManagedObjectContext? {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
            }
            return appDelegate.persistentContainer.viewContext
    }
    
    func getAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Erreur sur le formulaire",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor(red:0.38, green:0.55, blue:0.21, alpha:1.0)
        self.phoneTextImput.setBottomLine(borderColor: lineColor)
        self.lastNameTextImput.setBottomLine(borderColor: lineColor)
        self.mailTextImput.setBottomLine(borderColor: lineColor)
        self.firstNameTextImput.setBottomLine(borderColor: lineColor)
        self.passwordTextInput.setBottomLine(borderColor: lineColor)
        self.confirmPasswordTextInput.setBottomLine(borderColor: lineColor)
    }
    func createUser(u: User, password: String) {
        let loader = UIViewController.displaySpinner(onView: self.view)
        APIClient.instance.createUser(u: u, password: password, onSucces: { (success) in
            DispatchQueue.main.async {
                UIViewController.removeSpinner(spinner: loader)
                let controller = UIStoryboard.init(
                    name: "Main",
                    bundle: nil).instantiateViewController(
                        withIdentifier: "LoginViewController") as! LoginViewController
                
                controller.userPhone = u.phone 
                
                self.navigationController?.show(controller, sender: self)
            }
        }) { (error) in
            DispatchQueue.main.async {
                UIViewController.removeSpinner(spinner: loader)
                print(error)
            }
        }
    }
}
