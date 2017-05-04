//
//  UsersListTableViewCell.swift
//  SocialFutsal
//
//  Created by ardMac on 04/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit

class UsersListTableViewCell: UITableViewCell {
    static let cellIdentifier = "UsersListTableViewCell"
    static let cellNib = UINib(nibName: UsersListTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    @IBOutlet weak var profileImageView: UIImageView!{
        didSet{
            profileImageView.layer.cornerRadius = profileImageView.frame.width/2
            profileImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func inviteButtonTapped(_ sender: Any) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
