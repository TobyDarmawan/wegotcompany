//
//  Employee.swift
//  WeGotCompany2
//
//  Created by DARMAWAN Toby on 10/3/18.
//  Copyright © 2018 Toby Darmawan. All rights reserved.
//

import Foundation

class Employee{
    var employeeName : String = String()
    var absenceStatus : Bool = false
    var dailyAbsence : String = String()
    var timeStamp : [String] = [String]()
    var email : String = ""
    var minutesWorked : Double = 0
    var employeeID : String = String()
    
    func toDictionary() -> [String: Any] {
        return [
            "employeeName": employeeName,
            "absenceStatus": absenceStatus,
            "dailyAbsence": dailyAbsence,
            "timeStamp": timeStamp,
            "email": email,
            "minutesWorked": minutesWorked,
            "employeeID" : employeeID
        ]
        
    }
    
    convenience init(dict: [String : Any]) {
        self.init()
        employeeID = dict["employeeID"] as! String
        absenceStatus = dict["absenceStatus"] as! Bool
        employeeName = dict["employeeName"] as! String
        minutesWorked = dict["minutesWorked"] as! Double
        dailyAbsence = dict["dailyAbsence"] as! String
        email = dict["email"] as! String
        if (dict["timeStamp"] != nil){
            timeStamp = dict["timeStamp"] as! [String]
        }
        
    }
    
}
