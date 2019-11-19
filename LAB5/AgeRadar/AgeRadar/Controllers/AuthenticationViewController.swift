//
//  AuthenticationViewController.swift
//  AgeRadar
//
//  Created by Jing Su on 11/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController, UITextFieldDelegate {
    
    private let mlServiceClient: MLServiceClient = .shared
    private let settingsManage: SettingsManage = .shared
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if settingsManage.settings.username != "" {
            let result = mlServiceClient.login(username: settingsManage.settings.username, password: settingsManage.settings.password)
            if result {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func login(_ sender: UIButton) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let result = mlServiceClient.login(username: username, password: password)
        if result {
            settingsManage.settings.username = username
            settingsManage.settings.password = password
            settingsManage.save()
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Login Failed", message: "Please check your username and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func signup(_ sender: UIButton) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let result = mlServiceClient.signup(username: username, password: password)
        if result {
            settingsManage.settings.username = username
            settingsManage.settings.password = password
            settingsManage.save()
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Signup Failed", message: "Username invalid or existed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
}
