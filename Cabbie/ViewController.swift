//
//  ViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/24/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    
    var signUpMode = true
    var handle: AuthStateDidChangeListenerHandle!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            //...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    //MARK:- IBActions
    
    @IBAction func handleTopTapped(_ sender: UIButton) {
        guard let userEmail = emailTextField.text else { return }
        guard let userPassword = passwordTextField.text else { return }
        
        //make sure the user isn't submitting blank fields
        if userEmail == "" || userPassword == "" {
            displayAlert(title: "Missing Information", message: "You must provide both an email and password")
        } else {
            //let's handle our authentication
            //check whether log in or sign up
            if signUpMode {
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (authResult, error) in
                    if let err = error {
                        self.displayAlert(title: "Error", message: err.localizedDescription)
                    } else {
                        guard let user = authResult?.user else { return }
                        print("Sign up was successful!")
                        self.performSegue(withIdentifier: "riderSegue", sender: nil)
                    }
                }
            } else {
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
                    if let err = error {
                        self.displayAlert(title: "Error", message: err.localizedDescription)
                    } else {
                        guard let user = user?.user else { return }
                        print("Login in was successful")
                        //pass to the rider view
                        self.performSegue(withIdentifier: "riderSegue", sender: nil)
                    }
                }
            }
        }
    }
    
    private func displayAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func handleBottomTapped(_ sender: UIButton) {
        
        if signUpMode {
            //user wants to swtich to login
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            
            //remove the proper labels
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
        }
        
        signUpMode = !signUpMode
        
    }
    
    
}

