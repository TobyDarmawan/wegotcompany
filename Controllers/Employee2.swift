//
//  Employee2.swift
//  WeGotCompany2
//
//  Created by DARMAWAN Toby on 10/3/18.
//  Copyright © 2018 Toby Darmawan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
class Employee2 : UIViewController, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    let dateFormatter = DateFormatter()
    var timer : Timer?
    
    var parentEmployeeInformationDB : DatabaseReference = Database.database().reference(withPath: "Employee Information List")
    var childEmployeeInformationDB : DatabaseReference = DatabaseReference()
    var parentEmployeeNamesDB : DatabaseReference = Database.database().reference(withPath: "Employee Names List")
    
    var employeeInformation : Employee = Employee()
    
    var previousStatus : Bool = Bool()
    var timeStampExists : Bool = Bool()
    var currTimeStamp : Date = Date()
    var currTimeStampString : String = String()
    var latitude : Double = Double()
    var longitude : Double = Double()
    var employeeUID : String?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var absenceStatusLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text=""
        self.fetchCurrentUserId { (isFetched, error) in
            if isFetched == true {
                print("User ID fetched")
            } else {
                print("Error fetching User ID")
            }
        }
        getEmployeeInformation()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        //getEmployeeInformation(firstTime: false)
        
    }
    //MARK: Retrieving Employee Object from Database-------------
    func getEmployeeInformation (){
        childEmployeeInformationDB = self.parentEmployeeInformationDB.child(self.employeeUID!)
        childEmployeeInformationDB.observe(.value, with: { (snapshot) in

            
            let receivedData = snapshot.value as! Dictionary <String,Any>

                if snapshot.hasChild("timeStamp"){
                    self.timeStampExists = true
                }
                else{
                    self.timeStampExists=false
                }
                
                self.setEmployeeObject (employeeDictionary: receivedData)
                self.updateEmployeePage()
                self.setName()
                self.locationManager.startUpdatingLocation()
                    })
        
    }
    func setEmployeeObject (employeeDictionary : [String : Any]){
        if (timeStampExists){
            employeeInformation.timeStamp = employeeDictionary["timeStamp"] as! [String]
        }
        else{
            employeeInformation.timeStamp.removeAll()
        }
        employeeInformation.employeeID = employeeDictionary["employeeID"] as! String
        employeeInformation.absenceStatus = employeeDictionary["absenceStatus"] as! Bool
        employeeInformation.employeeName = employeeDictionary["employeeName"] as! String
        employeeInformation.minutesWorked = employeeDictionary["minutesWorked"] as! Double
        employeeInformation.dailyAbsence = employeeDictionary["dailyAbsence"] as! String
    }

    func fetchCurrentUserId(completion: @escaping(_ completed: Bool, _ error: NSError?) -> Void) {
        if let user = Auth.auth().currentUser {
            self.employeeUID = user.uid
            completion(true, nil)
        } else {
            completion(false, NSError(domain: "No User", code: 1, userInfo: nil))
        }
    }

    //MARK: Retrieving and checking coordinates & timestamp--------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations : [CLLocation]){
        errorLabel.text = ""
        let location = locations[locations.count-1]
        if location.horizontalAccuracy>0{
            latitude = Double(location.coordinate.latitude)
            longitude = Double(location.coordinate.longitude)
            currTimeStamp = location.timestamp
        }
        
        //checkCoordinates returns true if the employee's absence status has changed, false if it hasn't.
        if checkCoordinates(lat: latitude, lon: longitude){
            if (employeeInformation.dailyAbsence == ""){
                setDailyAbsenceStatus(time: currTimeStamp)
            }
            updateEmployeeDatabase()
            updateEmployeePage()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error)
        errorLabel.text="GPS Information could not be retrieved"
    }
    
    func setDailyAbsenceStatus(time : Date){
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute,from: time)
        if (hour<7){
            employeeInformation.dailyAbsence="On time"
        }
        else if (hour == 7 && minute < 30){
            employeeInformation.dailyAbsence="On time"
        }
        else if (hour<16){
            employeeInformation.dailyAbsence="Tardy"
        }
        else if (hour == 16 && minute < 30){
            
            employeeInformation.dailyAbsence="Tardy"
        }
        else{
            employeeInformation.dailyAbsence="Absent"
        }
    }
    func checkCoordinates (lat : Double, lon : Double )->Bool{
        previousStatus=employeeInformation.absenceStatus
        
        if (lat <= -6.175539 && lat >= -6.175763 && lon >= 106.802477 && lon <= 106.802719){
            employeeInformation.absenceStatus = true
        }
        else{
            employeeInformation.absenceStatus = false
        }
        
        if (employeeInformation.absenceStatus != previousStatus){
            employeeInformation.timeStamp.append(getCurrTimeStamp(date: currTimeStamp))
            return true
        }
        else{
            return false
        }
    }
    
    //MARK: Updating Database and Employee Page-----------------
    func updateEmployeeDatabase(){
    childEmployeeInformationDB.updateChildValues(employeeInformation.toDictionary()) {(error, ref) in
                if error != nil {
                    print("Error")
                } else {
                    print("Success")
                }
            }
        
    }
    func updateEmployeePage(){
        if (employeeInformation.absenceStatus){
            absenceStatusLabel.text="Present"
            absenceStatusLabel.backgroundColor=UIColor.green
        }
        else{
            absenceStatusLabel.text="Absent"
            absenceStatusLabel.backgroundColor=UIColor.red
        }
        if (employeeInformation.timeStamp.count != 0){
        timeStampLabel.text = employeeInformation.timeStamp[employeeInformation.timeStamp.count-1]
        }
        else{
            timeStampLabel.text = ""
        }
    }
    func getCurrTimeStamp(date: Date)->String{
        var hourString = ""
        var minuteString = ""
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute,from: date)
        //checking timestamp to make sure there are 4 digits
        if (hour<10){
            hourString = "0\(hour)"
        }
        else{
            hourString = "\(hour)"
        }
        if (minute<10){
            minuteString = "0\(minute)"
        }
        else{
            minuteString = "\(minute)"
        }
        currTimeStampString = "\(hourString) : \(minuteString)"
        return currTimeStampString
    }
    func setName(){
        parentEmployeeNamesDB.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let receivedData2 = snapshot.value as! Dictionary <String,String>
            print ("User ID is: \(self.employeeUID)")
            if (receivedData2 [self.employeeUID!] != nil){
                self.employeeInformation.employeeName = receivedData2 [self.employeeUID!]!
            }
            self.nameLabel.text = self.employeeInformation.employeeName
        })
    }
    
    @IBAction func signOutEmployee(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "segueSignOutEmployee", sender: self)
            locationManager.stopUpdatingLocation()
            employeeUID = ""
            childEmployeeInformationDB = DatabaseReference()
        }
        catch{
            print("Error in signing out")
        }
    }
    
}
//sets the timer to call the locationCheck method every 10 seconds.
//self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(locationCheck), userInfo: nil, repeats: true)
//calls the locationManager method which updates GPS coordinates.
//    @objc func locationCheck() {
//        print("Location Check")
//        locationManager.startUpdatingLocation()
//    }
//    func printEmployeeObject (){
//        print ("Employee info: retrieved. Below are employee details: ")
//        print("ID: \(employeeInformation.employeeID)")
//        print("absence status: \(employeeInformation.absenceStatus)")
//        print("name: \(employeeInformation.employeeName)")
//        print("hours worked: \(employeeInformation.minutesWorked)")
//        print("daily absence: \(employeeInformation.dailyAbsence)")
//    }
//    @objc func appMovedToBackground(){
//        print ("application in background!")
//
//    }
// if (!self.didRetrieveEmployeeInfo){
//self.didRetrieveEmployeeInfo = true
//NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_application:)), name: nil , object: nil)
//@objc func applicationWillTerminate(_application: UIApplication){
//    if (!didTerminate){
//        employeeInformation.appExitedWarning = "Exited"
//        updateEmployeeDatabase()
//        didTerminate = true
//}

