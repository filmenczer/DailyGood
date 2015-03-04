//
//  VolCell.swift
//  DailyGood
//
//  Created by Filippo Menczer on 2/23/15.
//  Copyright (c) 2015 kelly. All rights reserved.
//

import UIKit

class VolCell: UITableViewCell {

    @IBOutlet weak var volOppImage: UIImageView!
    @IBOutlet weak var volOppCharity: UILabel!
    @IBOutlet weak var volOppLocation: UILabel!
    @IBOutlet weak var volOppTagView: UIView!
    @IBOutlet weak var volOppTag: UILabel!
    @IBOutlet weak var volOppTitle: UILabel!
    @IBOutlet weak var volOppDescription: UILabel!
    @IBOutlet weak var volOppSponsor: UILabel!
    @IBOutlet weak var volOppTime: UILabel!
    @IBOutlet weak var volOppWhoJoined: UILabel!
    var volOpp: NSDictionary! // all data including imageURL
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        volOppTagView.layer.cornerRadius = 4
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)

        // Configure the view for the selected state
    }

}
