//
//  currentDate.swift
//  WeGotCompany2
//
//  Created by DARMAWAN Toby on 1/10/19.
//  Copyright © 2019 Toby Darmawan. All rights reserved.
//

import Foundation

class currentDate{
    var day = String()
    var month = String()
    var year = String()
    var date = Date()
    func setDates(){
        let calendar = Calendar.current
        year = "\(calendar.component(.year, from: date))"
        month = "\(calendar.component(.month, from: date))"
        day = "\(calendar.component(.day, from: date))"
    }
//init (currDate : Date){
//    self.init()
//        let calendar = Calendar.current
//        let day = "\(calendar.component(.day, from: currDate))"
//        let year = "\(calendar.component(.year, from: currDate))"
//        let month = "\(calendar.component(.month, from: currDate))"
//    print ("year: \(year), month: \(month), day: \(day)")
//    }
}

