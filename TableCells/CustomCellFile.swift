//
//  CustomCellFile.swift
//  WeGotCompany2
//
//  Created by DARMAWAN Toby on 1/7/19.
//  Copyright © 2019 Toby Darmawan. All rights reserved.
//

import UIKit

class CustomCellFile: UITableViewCell {


    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCell(currEmployee : Employee){
        
        
        Name.text = currEmployee.employeeName
        if (!currEmployee.timeStamp.isEmpty){
            Timestamp.text = currEmployee.timeStamp[currEmployee.timeStamp.count-1]
        }
        else{
            Timestamp.text = ""
        }
        if (currEmployee.absenceStatus){
            Status.text = "Present"
            Status.backgroundColor = UIColor.green
        }
        else {
            Status.text = "Absent"
            Status.backgroundColor = UIColor.red
        }
    }

}
