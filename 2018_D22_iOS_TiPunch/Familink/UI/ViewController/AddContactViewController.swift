//
//  AddContactViewController.swift
//  Familink
//
//  Created by formation12 on 23/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//

import UIKit
import CoreData

class AddContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var imageUrl: String = ""
    var profile: String = "Senior"
    
    @IBOutlet weak var firstNameTextImput: UITextField!
    @IBOutlet weak var lastNameTextImput: UITextField!
    @IBOutlet weak var phoneTextImput: UITextField!
    @IBOutlet weak var mailTextImput: UITextField!
    @IBOutlet weak var firstNameTextLabel: UILabel!
    @IBOutlet weak var lastNameTextLabel: UILabel!
    @IBOutlet weak var phoneNumberTextLabel: UILabel!
    @IBOutlet weak var mailTextLabel: UILabel!
    @IBOutlet weak var profilPickerTextLabel: UILabel!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBAction func addImageButton(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Nouvel Image",
            message: "Entrez l'url de l'image souhaité :",
            preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "https://img.ohmymag.com/article/humour/mr-bean-s-incruste-dans-avatar_8d73c59406e9ab1833b2cb3cb403bf93ee3dfe26.jpg"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            self.imageUrl = textField.text!
            if let url = URL(string: self.imageUrl) {
                DispatchQueue.global().async {
                    guard let data = try? Data(contentsOf: url) else {return}
                    DispatchQueue.main.async {
                        let newImage = UIImage(data: data)
                        self.contactImageView.image = newImage
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    @IBOutlet weak var addContactprofilPicker: UIPickerView!
    @IBAction func addContactButton(_ sender: UIButton) {
        
        if(ConnectedClient.instance.isConnectedToNetwork()) {
            if self.firstNameTextImput.text == "" {
                alertVerif(message: "Le prénom est vide", toFocus: self.firstNameTextImput)
            } else if self.lastNameTextImput.text == "" {
                alertVerif(message: "Le nom est vide", toFocus: self.lastNameTextImput)
            } else if self.mailTextImput.text == "" {
                alertVerif(message: "Le mail est vide", toFocus: self.mailTextImput)
            } else if self.phoneTextImput.text == "" {
                alertVerif(message: "Le numéro est vide", toFocus: self.phoneTextImput)
            } else {
                let contact = Contact(context: self.getContext()!)
                contact.firstName =  self.firstNameTextImput.text
                contact.setValue(self.lastNameTextImput.text, forKey: "lastName")
                contact.setValue(self.mailTextImput.text, forKey: "email")
                contact.setValue(self.profile, forKey: "profile")
                contact.setValue(self.phoneTextImput.text, forKey: "phone")
                contact.setValue(self.imageUrl, forKey: "gravatar")
                let loader = UIViewController.displaySpinner(onView: self.view)
                APIClient.instance.createContact(c: contact, onSucces: { (_) in
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: loader)
                        NotificationCenter.default.post(name: Notification.Name("addContact"), object: self)
                        self.navigationController?.popViewController(animated: true)
                    }
                }) {error in
                    UIViewController.removeSpinner(spinner: loader)
                    if error == "Security token invalid or expired" {
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
    func alertVerif(message: String, toFocus: UITextField) {
        let alert = UIAlertController(
            title: "Erreur sur le formulaire",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        toFocus.becomeFirstResponder()
        self.present(alert, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addContactprofilPicker.delegate = self
        addContactprofilPicker.dataSource = self
        print(self.profile)
        phoneTextImput.delegate = self
        firstNameTextImput.delegate = self
        lastNameTextImput.delegate = self
        mailTextImput.delegate = self
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
    
    
    
        
    let profils = ["Senior", "Famille", "Medecin"]
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
        self.profile = profils[row]
    }
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor(red:0.38, green:0.55, blue:0.21, alpha:1.0)
        self.phoneTextImput.setBottomLine(borderColor: lineColor)
        self.lastNameTextImput.setBottomLine(borderColor: lineColor)
        self.mailTextImput.setBottomLine(borderColor: lineColor)
        self.firstNameTextImput.setBottomLine(borderColor: lineColor)
    }
}
