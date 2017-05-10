//
//  LocationTableViewCell.swift
//  SocialFutsal
//
//  Created by ardMac on 08/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    static let cellIdentifier = "LocationTableViewCell"
    static let cellNib = UINib(nibName: LocationTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
