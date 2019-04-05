//
//  ProfileViewController.swift
//  Familink
//
//  Created by formation12 on 23/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    let profils = ["Senior" ,"Famille" ,"Medecin"]
    
    func displayAlertForInvalidField(message: String, toFocus: UITextField) {
        let alert = UIAlertController(
            title: "Erreur sur le formulaire",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        toFocus.becomeFirstResponder()
        self.present(alert, animated: true)
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
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let validEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        return validEmail
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func isEnabledTextInput(bool: Bool) {
        self.firstNameTextImput.isUserInteractionEnabled = bool
        self.lastNameTextImput.isUserInteractionEnabled = bool
        self.mailTextImput.isUserInteractionEnabled = bool
        self.profilPicker.isUserInteractionEnabled = bool
    }
    func DeleteContactFromCoreData() {
        
    }
    
    @IBOutlet weak var firstNameTextImput: UITextField!
    @IBOutlet weak var lastNameTextImput: UITextField!
    @IBOutlet weak var mailTextImput: UITextField!
    @IBOutlet weak var profilPicker: UIPickerView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstNameTextLabel: UILabel!
    @IBOutlet weak var lastNameTextLabel: UILabel!
    @IBOutlet weak var profilPickerTextLabel: UILabel!
    @IBOutlet weak var mailTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilPicker.delegate = self
        self.profilPicker.dataSource = self
        self.saveButton.isHidden = true
        self.editButton.isHidden = false
        isEnabledTextInput(bool: false)
        
        APIClient.instance.getUser(onSucces: { (user) in
            let currentUser = user[0]
            self.firstNameTextImput.text = currentUser.firstName
            self.lastNameTextImput.text = currentUser.lastName
            self.mailTextImput.text = currentUser.email
        }) { (e) in
            if e == "Security token invalid or expired" {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Session expiré",
                        message: "Veuillez-vous reconnecter pour accèder aux fonctionnalités",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (sender) in
                        let controller = UIStoryboard.init(
                            name: "Main",
                            bundle: nil).instantiateViewController(
                                withIdentifier: "LoginViewController") as! LoginViewController
                        
                        self.navigationController?.show(controller, sender: self)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @IBAction func tapToSave(_ sender: UIButton) {
        
        if(ConnectedClient.instance.isConnectedToNetwork()) {
            if !isValidEmail(email: self.mailTextImput.text!){
                displayAlertForInvalidField(message: "Email invalide", toFocus: mailTextImput)
            } else {
                self.saveButton.isHidden = true
                self.editButton.isHidden = false
                isEnabledTextInput(bool: false)
                let currentUser = User(context: self.getContext()!)
                currentUser.firstName = self.firstNameTextImput.text
                currentUser.lastName = self.lastNameTextImput.text
                currentUser.email = self.mailTextImput.text
                
                APIClient.instance.updateUser(u: currentUser, onSucces: { (user) in
                }) { (e) in
                    if e == "Security token invalid or expired" {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(
                                title: "Session expiré",
                                message: "Veuillez-vous reconnecter pour accèder aux fonctionnalités",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (sender) in
                                let controller = UIStoryboard.init(
                                    name: "Main",
                                    bundle: nil).instantiateViewController(
                                        withIdentifier: "LoginViewController") as! LoginViewController
                                
                                self.navigationController?.show(controller, sender: self)
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        } else {
            ConnectedClient.instance.errorConnectingAlert(view: self) { (alert) in
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        
        
    }
    @IBAction func tapToEdit(_ sender: UIButton) {
        if(ConnectedClient.instance.isConnectedToNetwork()) {
            self.saveButton.isHidden = false
            self.editButton.isHidden = true
            isEnabledTextInput(bool: true)
        } else {
            ConnectedClient.instance.errorConnectingAlert(view: self) { (alert) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func tapToDisconnect(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let contactsFromCoreData = CoreDataClient.instance.getContacts()
        DispatchQueue.main.async {
            UserDefaults.standard.set("", forKey: "Phone")
            for contact in contactsFromCoreData {
                context.delete(contact)
            }
            try? context.save()
        }
    }
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor(red:0.38, green:0.55, blue:0.21, alpha:1.0)
        self.firstNameTextImput.setBottomLine(borderColor: lineColor)
        self.lastNameTextImput.setBottomLine(borderColor: lineColor)
        self.mailTextImput.setBottomLine(borderColor: lineColor)
    }
}
