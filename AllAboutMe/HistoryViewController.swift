//
//  HistoryViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 6/30/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

class HistoryViewController: UIViewController {

  @IBOutlet weak var pieChartView: PieChartView!
  override func viewDidLoad() {
    super.viewDidLoad()
    Alamofire.request(.GET, getContextHistoryEndpoint, encoding: .JSON)
      .responseJSON { response in
        
        if let unwrappedResult = response.data {
          let json = JSON(data: unwrappedResult)
          let contextTypes = json["userStats"]
          for (_, subJson):(String, JSON) in contextTypes {
            if subJson["ctxGroup"] == "Situation" {
              var dataEntries: [ChartDataEntry] = []
              var dataPoints : [String] = []
              for (innerIndex, contextJson):(String, JSON) in subJson["values"] {
                let dataEntry = ChartDataEntry(value: contextJson["percentage"].doubleValue, xIndex: Int(innerIndex)!)
                dataPoints.append(contextJson["ctxName"].stringValue)
                dataEntries.append(dataEntry)
              }
              let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Situations")
              let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
              self.pieChartView.data = pieChartData
              var colors: [UIColor] = []
              
              for _ in 0..<dataPoints.count {
                let red = Double(arc4random_uniform(256))
                let green = Double(arc4random_uniform(256))
                let blue = Double(arc4random_uniform(256))
                
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
              }
              
              pieChartDataSet.colors = colors
              self.pieChartView.usePercentValuesEnabled = true
              
              break
            }
          }
        }
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

}
