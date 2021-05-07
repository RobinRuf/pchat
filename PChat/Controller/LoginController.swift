//
//  LoginController.swift
//  PChat
//
//  Created by Robin Ruf on 10.01.21.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - create elements
    let titleLabel: UILabel = {
        // Style des Labels
        let label = UILabel()
        label.text = "PChat"
        label.font = UIFont(name: "Chalkduster", size: 40)
        label.textAlignment = .center
        label.textColor = UIColor.white
        // Damit wir die Ausrichtung/Position des Labels nachher selber in einer Methode bestimmen können
        label.translatesAutoresizingMaskIntoConstraints = false
       
        return label
    }()
    
    let imageView: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "default_profile")
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.masksToBounds = false
        image.layer.borderWidth = 1.0
        image.frame.size.width = 140
        image.frame.size.height = 140
        // Rund machen
        image.layer.cornerRadius = image.frame.size.width / 2
        image.clipsToBounds = true
        // Erstmal unsichtbar, weil erst Einlogfeld und es nur auf Register erscheinen soll
        image.alpha = 0.0
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    let viewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let nameTextField: UITextField = {
        let name = UITextField()
        name.placeholder = "Name"
        name.translatesAutoresizingMaskIntoConstraints = false
        
        return name
    }()
    
    let nameSeparator: UIView = {
        let lineUp = UIView()
        lineUp.backgroundColor = UIColor.gray
        lineUp.translatesAutoresizingMaskIntoConstraints = false
        
        return lineUp
    }()
    
    let passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.isSecureTextEntry = true
        password.translatesAutoresizingMaskIntoConstraints = false
        
        password.addTarget(self, action: #selector(handleUserInput(_:)), for: .editingChanged)
        
        return password
    }()
    
    let emailSeparator: UIView = {
        let lineUp = UIView()
        lineUp.backgroundColor = UIColor.gray
        lineUp.translatesAutoresizingMaskIntoConstraints = false
        
        return lineUp
    }()
    
    let emailTextField: UITextField = {
       let email = UITextField()
        email.placeholder = "Email"
        email.keyboardType = .emailAddress
        email.translatesAutoresizingMaskIntoConstraints = false
        
        email.addTarget(self, action: #selector(handleUserInput(_:)), for: .editingChanged)
        
        return email
    }()
    
    let loginRegisterButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        button.layer.cornerRadius = 5
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleLoginRegister(_:)), for: .touchDown)
        
        return button
    }()
    
    let noAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("No Account? Register now!", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Funktion hinzufügen (Target) damit wir auf die Register-Page kommen
        button.addTarget(self, action: #selector(register(_:)), for: .touchDown)
        
        return button
    }()
    
    // MARK: - add Targets
    
    @objc func register(_ sender: UIButton) {
        if sender.titleLabel?.text == "No Account? Register now!" {
            imageView.alpha = 1.0
            loginRegisterButton.setTitle("Register", for: .normal)
            noAccountButton.setTitle("Login", for: .normal)
            
            viewContainerHeightAnchor?.isActive = false
            viewContainerHeightAnchor = viewContainer.heightAnchor.constraint(equalToConstant: 150)
            viewContainerHeightAnchor?.isActive = true
            
            nameTextFieldHeightAnchor?.isActive = false
            nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/3)
            nameTextFieldHeightAnchor?.isActive = true
            
            emailTextFieldHeightAnchor?.isActive = false
            emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/3)
            emailTextFieldHeightAnchor?.isActive = true
            
            passwordTextFieldHeightAnchor?.isActive = false
            passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/3)
            passwordTextFieldHeightAnchor?.isActive = true
            
        } else if sender.titleLabel?.text == "Login" {
            imageView.alpha = 0.0
            loginRegisterButton.setTitle("Login", for: .normal)
            noAccountButton.setTitle("No Account? Register now!", for: .normal)
            
            viewContainerHeightAnchor?.isActive = false
            viewContainerHeightAnchor = viewContainer.heightAnchor.constraint(equalToConstant: 100)
            viewContainerHeightAnchor?.isActive = true
            
            nameTextFieldHeightAnchor?.isActive = false
            nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalToConstant: 0)
            nameTextFieldHeightAnchor?.isActive = true
            
            emailTextFieldHeightAnchor?.isActive = false
            emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/2)
            emailTextFieldHeightAnchor?.isActive = true
            
            passwordTextFieldHeightAnchor?.isActive = false
            passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/2)
            passwordTextFieldHeightAnchor?.isActive = true
        }
    }
    
    @objc func handleUserInput(_ sender: UITextField) {
        if !(emailTextField.text!.isEmpty) && !(passwordTextField.text!.isEmpty) {
            loginRegisterButton.isEnabled = true
            loginRegisterButton.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            loginRegisterButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            loginRegisterButton.isEnabled = false
            loginRegisterButton.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        }
    }
    
    // MARK: - Choose Profile Image
    
    func addTapGestureToImageView() {
        // Erkennen, wenn der User auf das Profilbild klickt
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage))
        // GestureRecognizer (Gesten-Erkenner) dem ImageView adden
        imageView.addGestureRecognizer(tapGesture)
        // Dem ImageView sagen, dass der User mit ihm interagieren KANN
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func handleSelectProfileImage() {
        // Picker erstellen - der sorgt dafür, dass wenn der User auf das Profilbild klickt, dass die Mediathek geöffnet wird und dort seine Bilder sieht
        let pickerController = UIImagePickerController()
        pickerController.delegate = self // muss einfach gemacht werden
        pickerController.allowsEditing = true // erlaubt, dass man das ausgewählte Bild editieren kann (zoomen)
        present(pickerController, animated: true, completion: nil) // jetzt noch den Picker präsentieren
    }
    
    // Durch diese Methode kommen wir an das Bild, welches vom Nutzer ausgewählt wurde
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // info: [UIImage... : Any] = Dictionary (ähnlich wie Array nur mit freiwählbarem Key und Value) also das Dictionary heisst "info"
        // Mit Optional Binding
        // [.editedImage] ist ein vorgefertigter Key in diesem Dictionary, der für editierte Bilder da ist (also wenn der User z.B. das Bild gezoomt hat)
        // as? UIImage = Hol den Wert (das Bild) aus dem Dictionary an der Stelle [.editedImage] und schau bitte, ob du es in ein "UIImage" machen kannst
        if let editImage = info[.editedImage] as? UIImage {
            // Jetzt das Bild zu unserem ImageView hinzufügen, damit es dem User angezeigt wird
            imageView.image = editImage
        } else if let originalImage = info[.originalImage] as? UIImage { // Falls der User ein Bild genommen und nicht editiert hat (nicht gezoomt)
            // und das dann unserem ImageView hinzufügen
            imageView.image = originalImage
        }
        // Dismiss sorgt dafür, dass der PickerController nach dem auswählen des Bildes geschlossen/rausgeworfen wird, damit wir wieder bei dem Register-Fenster sind
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(viewContainer)
        view.addSubview(loginRegisterButton)
        view.addSubview(noAccountButton)
        
        setupLabel()
        setupProfileImage()
        setupViewContainer()
        setupLoginRegisterButton()
        setupNoAccountButton()
        
        addTapGestureToImageView()
    }
    
    // MARK: - viewDidAppear
    // Wird noch VOR der viewDidLoad aufgerufen, da "Appear" "auftauchen/erscheinen" heisst und das bekannt vor dem "load" kommt
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Auto-Login
        if Auth.auth().currentUser != nil {
            // Wenn der User automatisch eingeloggt wird, zeige direkt die Chats an
            self.showMainMessagesController()
        }
    }
    
    // MARK: - setup elements
    
    func setupLabel() {
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setupProfileImage() {
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: viewContainer.topAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    var viewContainerHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupViewContainer() {
        // Komplett mittig fixieren
        viewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        viewContainerHeightAnchor = viewContainer.heightAnchor.constraint(equalToConstant: 100)
        viewContainerHeightAnchor?.isActive = true
        
        viewContainer.addSubview(nameTextField)
        viewContainer.addSubview(nameSeparator)
        viewContainer.addSubview(emailTextField)
        viewContainer.addSubview(emailSeparator)
        viewContainer.addSubview(passwordTextField)
        
        nameTextField.leftAnchor.constraint(equalTo: viewContainer.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: viewContainer.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: viewContainer.widthAnchor).isActive = true
        // Bestimmen, dass die Höhe 1/3 von dem ViewContainer haben soll - da 3 Textfelder drin platz haben sollen
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalToConstant: 0)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextField.leftAnchor.constraint(equalTo: viewContainer.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: viewContainer.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/2)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextField.leftAnchor.constraint(equalTo: viewContainer.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: viewContainer.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, multiplier: 1/2)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // Trennlinie designen
        nameSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparator.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        nameSeparator.leftAnchor.constraint(equalTo: viewContainer.leftAnchor, constant: 10).isActive = true
        nameSeparator.widthAnchor.constraint(equalTo: viewContainer.widthAnchor, constant: -20).isActive = true
        
        emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparator.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        emailSeparator.leftAnchor.constraint(equalTo: viewContainer.leftAnchor, constant: 10).isActive = true
        emailSeparator.widthAnchor.constraint(equalTo: viewContainer.widthAnchor, constant: -20).isActive = true
    }
    
    func setupLoginRegisterButton() {
        loginRegisterButton.topAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: 10).isActive = true
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupNoAccountButton() {
        noAccountButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 10).isActive = true
        noAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noAccountButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        noAccountButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
}
