//
//  Login2.swift
//  WeGotCompany2
//
//  Created by DARMAWAN Toby on 10/3/18.
//  Copyright © 2018 Toby Darmawan. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Login2 : UIViewController{
    var userID = String()
    var parentEmployeeNamesListDB = DatabaseReference()
    var employeeNamesList = [String : String]()
    var adminNamesList = [String : String]()
    var parentAdminNamesListDB = DatabaseReference()
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var emailTF : UITextField!
    @IBOutlet weak var passwordTF : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNames()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginUser(_ sender: Any) {
        let email : String = emailTF.text!
        let password : String = passwordTF.text!
        Auth.auth().signIn(withEmail: email, password: password, completion:{ (user,error) in
            if error != nil{
                print("Unable to sign in: \(error!)")
            }
            else{
                self.fetchCurrentUserId() {
                    (isFetched, error) in
                    if isFetched == true {
                       self.changeView()
                    }
                    else{
                        "unable to fetch user id"
                    }
                }
            }
        })
    }
    func fetchNames(){
        parentEmployeeNamesListDB = Database.database().reference().child("Employee Names List")
        parentAdminNamesListDB = Database.database().reference().child("Administrator Names List")
        parentEmployeeNamesListDB.observe(.value, with: {(snapshot) in
            self.employeeNamesList = snapshot.value as! [String : String]
        })
        
        parentAdminNamesListDB.observe(.value, with: {(snapshot) in
            self.adminNamesList = snapshot.value as! [String : String]
        })
    }
    func fetchCurrentUserId(completion: @escaping(_ completed: Bool, _ error: NSError?) -> Void) {
        if let user = Auth.auth().currentUser {
            self.userID = user.uid
            completion(true, nil)
        } else {
            completion(false, NSError(domain: "No User", code: 1, userInfo: nil))
        }
    }
    func changeView (){
        if (employeeNamesList[userID] != nil){
            self.performSegue(withIdentifier: "segueSignInEmployee", sender: self)
        }
        else if (adminNamesList[userID] != nil){
            self.performSegue(withIdentifier: "segueSignInAdmin", sender: self)
        }
    }
    func checkForAdmin (ID : String)->Bool{
        var boolean = Bool()
        
        return boolean
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSignInEmployee"{
            let secondVC = segue.destination as! Employee2
            secondVC.employeeInformation.email=emailTF.text!
        }
    }
}
