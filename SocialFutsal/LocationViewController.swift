//
//  LocationViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 08/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
protocol LocationDelegate {
    func passLocation (_ selectedVenue: Location)
}


class LocationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(LocationTableViewCell.cellNib, forCellReuseIdentifier: LocationTableViewCell.cellIdentifier)
        }
    }
    
    var locations = [Location]()
    var selectedVenue : Location!
    var delegate : LocationDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://api.foursquare.com/v2/venues/search?client_id=50A1UXNAPKTLJ0TO10HTKENXVUZPCVZVGOITYQODEX5SFU4X&client_secret=YOGAMPANGSCGSWVNQLTHD0JNL0ENAD3ZGAS3ZA3O2FPBDALN&v=20130815&ll=3.134973,101.630629&query=futsal"
        guard let url = URL(string: urlString)
            else {return}
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let err = error {
                print("Error \(err.localizedDescription)" )
                return
            }
            guard let data = data
                else {
                    print ("Data error")
                    return
            }
            print(data)
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let dictData = jsonData as? [String : Any] {
                    if let response = dictData["response"] as? [String : Any]{
                        if let venue = response["venues"] as? [[String : Any]] {
                            self.populateVenue(venue)
                        }
                    }
                }
            }catch {
                print ("Error when converting to JSON")
            }
        }
        task.resume()
    }
    func populateVenue(_ array : [[String: Any]]){
        for venue in array {
            locations.append(Location(dict: venue))
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LocationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 256
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.cellIdentifier) as? LocationTableViewCell
            else { return UITableViewCell()}
        
        cell.locationLabel.text = locations[indexPath.row].name
        cell.addressLabel.text = locations[indexPath.row].address
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedVenue = locations[indexPath.row]
        delegate?.passLocation(selectedVenue)
        dismiss(animated: true, completion: nil)
    }
}
