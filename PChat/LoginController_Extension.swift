//
//  LoginController_Extension.swift
//  
//
//  Created by Robin Ruf on 10.01.21.
//

import Foundation
import UIKit
import FirebaseAuth // Modul, die Methoden enthält, die wir brauchen um User erstellen/einloggen zu können
import FirebaseDatabase // Modul, damit wir mit der Datenbank auf firebase.com arbeiten können
import FirebaseStorage // Modul, damit wir Bilder etc. im Storage speichern können

// extension = Erweiterung zu einer anderen Datei - und dann angeben, zu welcher Datei? LoginController.swift
extension LoginController {
    
    // Methode ist verbunden mit dem Register-Button und mit dem Login-Button
    @objc func handleLoginRegister(_ sender: UIButton) {
        // Überprüfen, ob der Nutzer auf "login" oder "Register" klickt
        if sender.titleLabel?.text == "Login" {
            userLogin()
        } else {
            if !(self.nameTextField.text!.isEmpty) {
                createUser()
            } else {
                let alert = UIAlertController(title: "Forgot name", message: "Please type in your name", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in }
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func userLogin() {
        // Prüfen, ob User sich einloggen darf (Einlogdaten korrekt)
        // result, error = entweder alles hat geklappt, dann steckt der User in "result" oder es hat nicht geklappt, dann steckt die Fehlermeldung in "error"
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            // prüfen, ob ein Error stattgefunden hat, wenn ja, error printen und Methode sofort verlassen...
            if let err = error {
                print(err)
                return
            }
            // Wenn es keinen Error gab, User einloggen
            // und dann die Chats anzeigen
            self.showMainMessagesController()
        }
    }
    
    func createUser() {
        // User erstellen -> Firebase->Authentication
        // result, error = entweder alles hat geklappt, dann steckt der User in "result" oder es hat nicht geklappt, dann steckt die Fehlermeldung in "error"
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            // Error ist ein Optional, also Optional Binding zum überprüfen, obs einen Fehler gab
            if let err = error {
                // Fehler anzeigen und dann die Methode sofort verlassen
                print(err)
                return
                }
            
            // Da die Daten im "result" ein Optional sind, machen wir das mit einem Guard-Statement
            guard let newUser = result else { return }
            // User-ID in einer Konstanten speichern
            let uid = newUser.user.uid
            
            // Profilbild speichern -> Firebase->Storage
            // Storage-Referenz in Konstante erstellen und Eintrag im Storage erstellen
            let storageRef = Storage.storage().reference().child("profile_image").child(uid)
            
            // Bild aus imageView holen
            // Weil imageView.image immer ein Optional ist (es kann ein Bild drin sein, muss aber nicht) müssen wir mit Guard-Statement arbeiten
            guard let image = self.imageView.image else { return }
            
            // Bild für den Upload komprimieren, damit nicht soviel Speicherplatz verschwendet wird.
            // compressionQuality = Wert zwischen 0-1 (0 = schlechteste Quali, 1 = Beste)
            guard let uploadImage = image.jpegData(compressionQuality: 0.5) else { return }
            
            // Bild hochladen
            storageRef.putData(uploadImage, metadata: nil) { (metadata, error) in
                // Falls es einen Fehler gab, wird der in "error" zurückgegeben - dies überprüfen
                if let err = error {
                    print(err)
                    return
                }
                // ansonsten wird weitergemacht
                // Download der URL wo sich das Bild nun befindet
                storageRef.downloadURL { (url, error) in
                    // Wieder überprüfen, ob ein Error zurückgegeben wurde
                    if let err = error {
                        print(err)
                        return
                    }
                    // falls nicht, mach weiter
                    // damit das iPhone der anderen User das Bild im Chatbereich herunterladen kann, müssen wir die URL wo sich das Bild im Storage befinden, in die Datenbank speichern
                    
                    // in url?.absoluteString ist der Link des Bildes als String gespeichert. Das speichern wir nun in eine Konstante
                    let imageUrlAsString = url?.absoluteString
                    
                    
                    // Datenbank Eintrag erstellen -> Firebase->Database
                    // Falls alles geklappt hat, dann weiter (guard let newUser -> oberhalb)
                    // Username und Email abspeichern
                    let userName = self.nameTextField.text
                    let userEmail = self.emailTextField.text
                    // Das PASSWORT NIEMALS IN DER DATENBANK SPEICHERN
                    
                    // Datenbank-Referenz erstellen und eine Unterkategorie in der Datenbank erstellen
                    // darin werden die User-IDs gespeichert, als weitere "Subkategorien"
                    let ref = Database.database().reference().child("users").child(uid)
                    
                    // Email und Username als Dictionary in der DB-Tabelle "users" -> "uid" speichern
                    // ref.setValue([KEY : VALUE])
                    // "imageUrlAsString ?? "Kein Bild vorhanden" -> Weil imageUrlAsString ein Optional ist, kann es sein, dass keine Bild-URL gespeichert ist, dann machen wir "??" und bestimmen dahinter, was ansonsten gespeichert werden soll - also "Kein Bild vorhanden" würde dann an dem Punkt in der DB stehen.
                    ref.setValue(["uid" : uid, "username" : userName, "email" : userEmail, "profile_image" : imageUrlAsString ?? "Kein Bild vorhanden"])
                    
                    // Wenn der User erstellt wurde - Chats anzeigen
                    self.showMainMessagesController()
                }
            }
        }
    }
    
    func showMainMessagesController() {
        // TBV = TableViewController
        let MainMessagesTBV = MainMessagesTableViewController()
        // NavigationController erstellen, damit wir die obere Leiste erhalten, wo wir unseren BarButtonItem (Logout-Button) hinpacken können
        // NavigationController wo hinpacken? In den MessagesTableViewController, da das das Fenster wird, wo die Chats angegeigt werden
        let navController = UINavigationController(rootViewController: MainMessagesTBV)
        
        // Jetzt präsentieren wir den NavigationController, damit uns dieser angezeigt wird.
        // Und zwar den navController, da dieser in (rootViewController: messagesTBV) unseren MessagesTableViewController dabei hat
        // und noch angeben, dass es sich in Fullscreen präsentieren/darstellen soll
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
}
