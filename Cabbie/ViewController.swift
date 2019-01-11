//
//  ViewController.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 12/24/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI

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
    var testEmailAccounts: [String] = ["charlesmartinreed@icloud.com"]
    var handle: AuthStateDidChangeListenerHandle!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.createAnimatedGradient(colorOne: Colors.lightPink, colorTwo: Colors.hotPink, toColorThree: Colors.passionPurple, toColorFour: Colors.plumPurple)
        
        //view.createSimpleGradient(colorOne: Colors.lightPink, colorTwo: Colors.hotPink)
        //view.createComplexGradient(colors: Colors.lightPink, Colors.hotPink, Colors.passionPurple, Colors.plumPurple)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            //...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    private func signUpNewUser(userEmail: String, userPassword: String) {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (authResult, error) in
            if let err = error {
                self.displayAlert(title: "Error", message: err.localizedDescription)
            } else {
                //guard let user = authResult?.user else { return }
                if self.riderDriverSwitch.isOn {
                    //if on, user is a DRIVER
                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                    req?.displayName = "Driver"
                    req?.commitChanges(completion: nil)
                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                } else {
                    //user is a RIDER
                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                    req?.displayName = "Rider"
                    req?.commitChanges(completion: nil)
                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                }
            }
        }
    }
    
    private func loginExistingUser(userEmail: String, userPassword: String) {
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            if let err = error {
                self.displayAlert(title: "Error", message: err.localizedDescription)
            } else {
                guard let user = user?.user else { return }
                if user.displayName == "Driver" {
                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                } else {
                    //pass to the rider view
                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                }
            }
        }
    }
    
    func showMailComposer() {
        //check whether or not the user can send me
        guard MFMailComposeViewController.canSendMail() else {
            displayAlert(title: "Unable to send email", message: "Sorry, but this application does not have permission to access your email client.")
            return
        }
        
        //create the mail composer
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(testEmailAccounts)
        composer.setSubject("Support email test")
        composer.setMessageBody("If you're reading this, the mail composer functionality is working as intended!", isHTML: false)
        
        present(composer, animated: true, completion: nil)
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
               signUpNewUser(userEmail: userEmail, userPassword: userPassword)
            } else {
                loginExistingUser(userEmail: userEmail, userPassword: userPassword)
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
    
    @IBAction func handleContactSupportTapped(_ sender: UIButton) {
        //slide up the mail control view controller
        //MessageUI seems to run a little... jankily on the simulator.
        showMailComposer()
    }
}

//MARK:- MFMailComposeViewController conformance extension
extension ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let error = error {
            displayAlert(title: "Uh-oh!", message: error.localizedDescription)
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed to send")
        case .saved:
            print("saved")
        case .sent:
            print("email was sent")
        }
        
        controller.dismiss(animated: true)
    }
}

