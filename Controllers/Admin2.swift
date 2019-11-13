//
//  AdminVC.swift
//  WeGotCompany2
//
//  Created by DARMAWAN Toby on 10/3/18.
//  Copyright © 2018 Toby Darmawan. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics

class Admin2 : UIViewController, UITableViewDelegate, UITableViewDataSource{
    var size = 0
    var employeeList = [Employee](){
        didSet{
            if employeeList.count == size{
                employeeTV.reloadData()
            }
        }
    }
    //var employeeIDDictionary = [String]()

    var dateFormatter = DateFormatter()
    var date = Date()
    var currDate = String()
    var dailyReportList = [Int : String]()
    
    var parentEmployeeInformationDB = Database.database().reference(withPath: "Employee Information List")
    var parentDailyReportDB = Database.database().reference(withPath: "Daily Report")
    
    @IBOutlet weak var employeeTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        employeeTV.delegate = self
        employeeTV.dataSource = self
        
        loadEmployeeTable()
    }
    
    //MARK: Setting Table properties and contents-----------------------------
    //Sets number of rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeList.count
    }
    //Sets content for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellFile
        let currEmployee = employeeList[indexPath.row]
        cell.setCell(currEmployee : currEmployee)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func configureTableView(){
        employeeTV.rowHeight = UITableViewAutomaticDimension
        employeeTV.estimatedRowHeight = 120
    }
        //MARK: Retrieving Employee Objects List----------------------------------
    
    func loadEmployeeTable(){
        setEmployeeObjectList()
        configureTableView()
    }

    func setEmployeeObjectList(){
        parentEmployeeInformationDB.observe(.value) { (snapshot) in
            self.employeeList.removeAll()
            self.size = Int(snapshot.childrenCount)
            snapshot.children.forEach({ (snap) in
                
                let shot = snap as! DataSnapshot
                let employeeInformationDictionary = shot.value as! [String : Any]
                let employee = Employee(dict: employeeInformationDictionary)
                self.employeeList.append(employee)
                
            })
            self.employeeTV.reloadData()
        }
    }
    
    //MARK: Sign out---------------------------------------------
    @IBAction func signOutAdmin(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "segueSignOutAdmin", sender: self)
        }
        catch{
            print("Error in signing out")
        }
    }
    //MARK: Daily Reports---------------------------------------------
    @IBAction func fileDailyReport(_ sender: Any) {
        let calendar = Calendar.current
        let todayDate = currentDate()
    //WARNING: CHANGE HOUR COMPONENT OF X*60 BELOW WHEN ALL TESTING IS COMPLETE, SET IT TO END OF WORKING HOURS.
        if (calendar.component(.hour, from: date)*60 + calendar.component(.minute, from: date) > ((6*60)+30)){
            var currMinutes = Int()
            var csvText = "Name, Daily Absence Status, Total Hours Worked\n"
            setEmployeeObjectList()
            for employee in employeeList{
                if employee.minutesWorked == 0 && !employee.timeStamp.isEmpty{
                    for num in (1..<employee.timeStamp.count){
                        if (num%2 != 0){
                            currMinutes = getTimeStamp(timeString: employee.timeStamp[num])-getTimeStamp(timeString: employee.timeStamp[num-1])
                            employee.minutesWorked+=Double(currMinutes)
                        }
                    }
            parentEmployeeInformationDB.child(employee.employeeID).updateChildValues(employee.toDictionary())
                }
            }
            for employee in employeeList{
                let employeeString = "\(employee.employeeName),\(employee.dailyAbsence),\(employee.minutesWorked)\n"
                csvText.append(employeeString)
            }
            todayDate.setDates()
            let childDailyReportDB = parentDailyReportDB.child(todayDate.year).child(todayDate.month).child(todayDate.day)
            childDailyReportDB.setValue(csvText)
        }
        
    }
    
    @IBAction func clearDBData(_ sender: Any) {
        parentEmployeeInformationDB.observeSingleEvent(of: .value, with: {snapshot in

        //parentEmployeeInformationDB.observe(.value){(snapshot) in
            snapshot.children.forEach({ (snap) in
                let shot = snap as! DataSnapshot
                if (shot.hasChild("timeStamp")){
                    let employeeInformationDictionary = shot.value as! [String : Any]
                    let currEmployee = Employee(dict: employeeInformationDictionary)
                    
                        currEmployee.absenceStatus = false
                        currEmployee.dailyAbsence = ""
                        currEmployee.minutesWorked = 0
                        currEmployee.timeStamp.removeAll()
                    print (currEmployee.toDictionary().description)
                self.parentEmployeeInformationDB.child(currEmployee.employeeID).updateChildValues(currEmployee.toDictionary())
                }
            })
        })
        }

    func getTimeStamp(timeString : String)->Int{
        let hourString = timeString.dropLast(5)
        let minuteString = timeString.dropFirst(5)
        print ("hours string is : \(hourString)")
        let hour = Int(hourString)!
        let minute = Int(minuteString)!
        var time = Int()
        time = time + hour * 60
        time = time + minute
        
        return time
    }
}

