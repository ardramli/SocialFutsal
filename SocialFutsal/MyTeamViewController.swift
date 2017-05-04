//
//  MyTeamViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 04/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit

class MyTeamViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func createButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "CreateTeamViewController") as?
            CreateTeamViewController else { return }
        
        navigationController?.pushViewController(controller, animated: true)
    }


}
