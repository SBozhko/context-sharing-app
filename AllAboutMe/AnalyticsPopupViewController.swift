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
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  var contextGroup : NEContextGroup?
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    loadCharts(AnalyticsPeriod.Day)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  func loadCharts(analyticsPeriod : AnalyticsPeriod) {
    let historyEndpoint = "\(getContextHistoryEndpoint)/\(VendorInfo.getId())/\(VendorInfo.getId())?ctx=\(contextGroup!.name)&period=\(analyticsPeriod.name)"
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
            var colors: [UIColor] = []

            for _ in 0..<dataPoints.count {
              let red = Double(arc4random_uniform(256))
              let green = Double(arc4random_uniform(256))
              let blue = Double(arc4random_uniform(256))
              let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
              colors.append(color)
            }

            let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "\(self.contextGroup!.name)")
            let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
            pieChartDataSet.colors = colors
            self.pieChartView.data = pieChartData
            self.pieChartView.rotationEnabled = false
            self.pieChartView.drawSliceTextEnabled = false
            self.pieChartView.usePercentValuesEnabled = true
            let legend:ChartLegend = self.pieChartView.legend
            legend.position = ChartLegend.Position.AboveChartCenter
            self.pieChartView.animate(xAxisDuration: NSTimeInterval(1.0))
            break
          }
        }
    }
  }
  
  @IBAction func segmentSelected(sender: AnyObject) {
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      loadCharts(AnalyticsPeriod.Day)
    case 1:
      loadCharts(AnalyticsPeriod.Week)
    default:
      loadCharts(AnalyticsPeriod.Month)
    }
  }
  
  @IBAction func closeButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
