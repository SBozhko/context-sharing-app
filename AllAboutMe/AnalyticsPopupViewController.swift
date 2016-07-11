//
//  AnalyticsPopupViewController.swift
//  AllAboutMe
//
//  Created by Abhishek Sen on 7/11/16.
//  Copyright © 2016 NE. All rights reserved.
//

import UIKit
import NEContextSDK
import Alamofire
import SwiftyJSON
import Charts

class AnalyticsPopupViewController : UIViewController {

  @IBOutlet weak var pieChartView: PieChartView!
  @IBOutlet weak var analyticsPopupTitleLabel: UILabel!
  
  var contextGroup : NEContextGroup?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    switch (contextGroup!) {
    case .Situation:
      analyticsPopupTitleLabel.text = "Your Situations History"
    case .Activity:
      analyticsPopupTitleLabel.text = "Your Activities History"
    case .Place:
      analyticsPopupTitleLabel.text = "Your Places History"
    case .IndoorOutdoor:
      analyticsPopupTitleLabel.text = "Your Indoor/Outdoor History"
    default:
      analyticsPopupTitleLabel.text = "Your History"
    }
    loadCharts()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    
  func loadCharts() {
    let historyEndpoint = "\(getContextHistoryEndpoint)/\(Logging.sharedInstance.getUniqueDeviceIdentifier)/\(Logging.sharedInstance.getUniqueDeviceIdentifier)?ctx=\(contextGroup!.name)"
    //    ctx=DayCategory,TimeOfDay,IndoorOutdoor,Activity,Situation,Mood,Weather,Lightness,Loudness,Place"

    Alamofire.request(.GET, historyEndpoint, encoding: .JSON)
      .responseJSON { response in
        if let unwrappedResult = response.data {
          let json = JSON(data: unwrappedResult)
          let contextTypes = json["userStats"]
          for (_, subJson):(String, JSON) in contextTypes {
            var dataEntries: [ChartDataEntry] = []
            var dataPoints : [String] = []
            for (innerIndex, contextJson):(String, JSON) in subJson["values"] {
              let dataEntry = ChartDataEntry(value: contextJson["percentage"].doubleValue, xIndex: Int(innerIndex)!)
              dataPoints.append(contextJson["ctxName"].stringValue)
              dataEntries.append(dataEntry)
            }
            let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "\(self.contextGroup!.name)")
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
  
  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
