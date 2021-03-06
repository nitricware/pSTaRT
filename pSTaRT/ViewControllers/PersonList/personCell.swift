//
//  personCell.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import UIKit

class personCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var plsNumber: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    public var pls: PLSStorage?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setPLS(pls: PLSStorage) {
        self.pls = pls
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        
        self.plsNumber.text = pls.plsNumber
        self.startDate.text = dateFormatter.string(from: pls.startTime!)
        self.endDate.text = dateFormatter.string(from: pls.endTime!)
    }

}
