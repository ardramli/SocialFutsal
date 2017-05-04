//
//  TeamViewController.swift
//  SocialFutsal
//
//  Created by ardMac on 03/05/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

import UIKit
import Charts

class TeamViewController: UIViewController {
    @IBOutlet weak var playersListView: UIView!
    @IBOutlet weak var playerListTableView: UITableView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChartView: PieChartView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
//        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
//        
//        setChart(dataPoints: months, values: unitsSold)
        
        pieChartView.isHidden = true
        playersListView.isHidden = false
        
        let month = ["Jan", "Feb" , "March"]
        let amount = [123,421,661]
        
        
        var pcDataEntries = [PieChartDataEntry]()
        for i in 0..<month.count {
            let pcDataEntry = PieChartDataEntry(value: Double(amount[i]), label: month[i])
            pcDataEntries.append(pcDataEntry)
        }
        let pcDataSet = PieChartDataSet(values: pcDataEntries, label: "Legend Information")
        pcDataSet.colors = [.blue,.red,.green,.black]
        pcDataSet.valueColors = [.yellow , .blue,.red,.green,.black]
        
        
        let pcData = PieChartData(dataSets: [pcDataSet])
        
        
        pieChartView.data = pcData
        pieChartView.centerText = "ALallal"
        pieChartView.chartDescription?.text = "Monthly Sale"
        
    }
    
    
//    func setChart(dataPoints: [String], values: [Double]) {
//        
//        var dataEntries: [ChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
////            let dataEntry = ChartDataEntry(x: Double(i), y: Double(i), data: values[i] as AnyObject?)
//            let dataEntry = ChartDataEntry(x: Double(i), y: values[i], data : dataPoints[i] as? AnyObject)
//            dataEntries.append(dataEntry)
//        }
//        
//        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Units Sold")
//        let pieChartData = PieChartData(dataSets: [pieChartDataSet])
//        pieChartView.data = pieChartData
//        
//        var colors: [UIColor] = []
//        
//        for i in 0..<dataPoints.count {
//            let red = Double(arc4random_uniform(256))
//            let green = Double(arc4random_uniform(256))
//            let blue = Double(arc4random_uniform(256))
//            
//            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//            colors.append(color)
//        }
//        
//        pieChartDataSet.colors = colors
//    }
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            pieChartView.isHidden = true
            playersListView.isHidden = false
        case 1:
            pieChartView.isHidden = false
            playersListView.isHidden = true
        default:
            break;
        }
    }
    
    
}
