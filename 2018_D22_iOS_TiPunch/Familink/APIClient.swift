//
//  APIClient.swift
//  Familink
//
//  Created by formation3 on 23/01/2019.
//  Copyright © 2019 ti.punch. All rights reserved.
//
import Foundation
import CoreData
import UIKit

class APIClient {
    
    static let instance = APIClient()
    private let urlServer = "https://familink-api.cleverapps.io"
    private let urlLogin = "/public/login"
    private let urlContact = "/secured/users/contacts/"
    private let urlUserCurrent = "/secured/users/current"
    private let urlSignIn = "/public/sign-in"
    private let PHONE = "phone"
    private let PASSWORD = "password"
    private var TOKEN = "token"
    private init () {
        
    }
    
    func login (phone: String, password: String, onSucces: @escaping (String)->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlLogin)")! )
        let json: [String: Any] = [self.PHONE: phone, self.PASSWORD: password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
             if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                    onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if let dataReceive = data {
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: dataReceive, options: []) as! [String: String] {
                            self.TOKEN = jsonResponse["token"] ?? ""
                            print(self.TOKEN)
                        }
                        onSucces("Connexion réussi !")
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    func getAllContact (onSucces: @escaping ([Contact])->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContact)")! )
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("Bearer: \(self.TOKEN)", forHTTPHeaderField: "Authorization")
        // preparation de la tache de telechargezmebnt des données
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //test de la validation du token
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                   onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if let dataReceive = data {
                        DispatchQueue.main.async {
                            // Je la transforme en Array
                            let dataArray = try! JSONSerialization.jsonObject(with: dataReceive, options: []) as! [Any]
                            var contactToReturn = [Contact]()
                            for object in dataArray {
                                let objectDictionary = object as! [String: Any]
                                let c = Contact(context: self.getContext()!)
                                c.id = (objectDictionary["_id"] as! String)
                                c.phone = (objectDictionary["phone"] as! String)
                                c.firstName = (objectDictionary["firstName"] as! String)
                                c.lastName = (objectDictionary["lastName"] as! String)
                                c.email = (objectDictionary["email"] as! String)
                                c.profile = (objectDictionary["profile"] as! String)
                                c.gravatar = (objectDictionary["gravatar"] as! String)
                                c.isEmergencyUser = (objectDictionary["isEmergencyUser"] as! Bool)
                                c.isFamilinkUser = (objectDictionary["isFamilinkUser"] as! Bool)
                                contactToReturn.append(c)
                            }
                            onSucces(contactToReturn)
                        }
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    func createContact (c: Contact, onSucces: @escaping (String)->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContact)")! )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(self.TOKEN)", forHTTPHeaderField: "Authorization")
        let jsonData = getJsonForContact(c: c)
        request.httpBody = jsonData
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //test de la validation du token
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                   onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if data != nil {
                        onSucces("Contact ajouté !")
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    func deleteContact (c: Contact, onSucces: @escaping (String)->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContact)\(c.id ?? "50000")")! )
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(self.TOKEN)", forHTTPHeaderField: "Authorization")
        let jsonData = getJsonForContact(c: c)
        request.httpBody = jsonData
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //test de la validation du token
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                   onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if data != nil {
                        onSucces("Contact supprimé")
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    func updateContact (c: Contact, onSucces: @escaping (String)->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlContact)\(c.id ?? "50000")")! )
        print(request)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(self.TOKEN)", forHTTPHeaderField: "Authorization")
        let jsonData = getJsonForContact(c: c)
        request.httpBody = jsonData
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                    onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if data != nil {
                        onSucces("Contact modifié")
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    func getUser(onSucces: @escaping ([User])->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlUserCurrent)")! )
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("Bearer: \(self.TOKEN)", forHTTPHeaderField: "Authorization")
        // preparation de la tache de telechargezmebnt des données
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //test de la validation du token
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                    onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if let dataReceive = data {
                        var userToReturn = [User]()
                        DispatchQueue.main.async {
                            if let jsonResponse = try? JSONSerialization.jsonObject(with: dataReceive, options: [])
                                as! [String: String] {
                                
                                let u = User(context: self.getContext()!)
                                u.phone = jsonResponse["phone"]
                                u.firstName = jsonResponse["firstName"]
                                u.lastName = jsonResponse["lastName"]
                                u.email = jsonResponse["email"]
                                u.profile = jsonResponse["profile"]
                                userToReturn.append(u)
                            }
                            onSucces(userToReturn)
                        }
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // renvoie la tache pour pouvoir l'annuler
        return task
    }
    
    func createUser(u: User, password: String, onSucces: @escaping (String)->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)\(urlSignIn)")! )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json: [String: Any] = ["phone": u.phone ?? "",
                                    "password": password,
                                    "firstName": u.firstName ?? "",
                                    "lastName": u.lastName ?? "",
                                    "email": u.email ?? "",
                                    "profile": u.profile ?? ""
                                    ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //test de la validation du token
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                    onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if data != nil {
                        onSucces("Compte crée")
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    func updateUser (u: User, onSucces: @escaping (String)->(), onError: @escaping (String)->()) -> URLSessionTask {
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)/secured/users/")! )
        print(request)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer: \(self.TOKEN)", forHTTPHeaderField: "Authorization")
        let json: [String: Any] = ["firstName": u.firstName ?? "",
                                   "lastName": u.lastName ?? "",
                                   "email": u.email ?? "",
                                   "profile": u.profile ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let requestResponse = response as? HTTPURLResponse {
                if requestResponse.statusCode != 200 && requestResponse.statusCode != 204 {
                    onError(self.errorToken(data: data))
                } else {
                    // si j'ai de la donnée
                    if data != nil {
                        onSucces("User modifié")
                    }
                }
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    func errorToken(data: Data?) -> String {
        if let dataResponse = data {
            if let jsonResponse = try? JSONSerialization.jsonObject(with: dataResponse, options: [])
            as! [String: String] {
                return jsonResponse["message"] ?? ""
            }
            return "Erreur inconnue"
        }
        return "Erreur inconnue"
    }
    
    func getContext() -> NSManagedObjectContext? {
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
            }
            return appDelegate.persistentContainer.viewContext
        
    }
    
    func getJsonForContact (c: Contact) -> Data? {
        let json: [String: Any] = ["phone": c.phone ?? "",
                                    "firstName": c.firstName ?? "",
                                    "lastName": c.lastName ?? "",
                                    "email": c.email ?? "",
                                    "profile": c.profile ?? "",
                                    "gravatar": c.gravatar ?? "",
                                    "isFamilinkUser": c.isFamilinkUser,
                                    "isEmergencyUser": c.isEmergencyUser]
        return try? JSONSerialization.data(withJSONObject: json)
    }
}
