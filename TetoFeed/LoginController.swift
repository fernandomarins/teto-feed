//
//  LoginController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/24/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class LoginController: UIViewController {
    
    fileprivate(set) var currentHud: MBProgressHUD?
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(12, green: 101, blue: 180, alpha: 1)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        sampleData()
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    func sampleData() {
        emailTextField.text = "f.augustomarins@gmail.com"
        passwordTextField.text = "pirralho"
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Elements
    
    // UIView
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // UIButton
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(80, green: 101, blue: 161, alpha: 1)
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    // UITextField
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.isSecureTextEntry = true
        return tf
    }()
    
    // UIImageView
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    // UISegmentedControl
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    // Private methods
    
    private func presentTabBar() {
        let vc = TabBarController()
        present(vc, animated: true, completion: nil)
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        hudShow(message: "Logging in...")
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
            
            [weak self] (user, error) in
            
            guard let me = self else { return }
            
            me.hudDismiss()
            
            if error != nil {
                me.alert(message: error!.localizedDescription, title: "Atenção!")
                return
            }
            
            //successfully logged in our user
            me.presentTabBar()
            
        })
        
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        hudShow(message: "Creating user...")
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            
            [weak self] (user: FIRUser?, error) in
            
            guard let me = self else { return }
            
            me.hudDismiss()

            if error != nil {
                me.alert(message: error!.localizedDescription, title: "Atenção!")
                return
            }
            
            me.presentTabBar()
        })
    }
    
    func hudShow (message: String? = nil) {
        currentHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHud?.mode = .indeterminate
        
        if message != nil {
            currentHud?.label.text = message!
        }
    }
    
    func hudDismiss() {
        currentHud?.hide(animated: true)
        currentHud = nil
    }
}
