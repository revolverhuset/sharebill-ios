//
//  TransactionTableViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit
import SwiftyJSON

func parseRational(rational:String) -> Double {
  let nsrational = rational as NSString
  let expr = NSRegularExpression(pattern: "(\\d+)\\s?(\\d+)?/?(\\d+)?", options: nil, error: nil)!
  let results = expr.matchesInString(rational, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(rational))) as! [NSTextCheckingResult]
  assert(results.count > 0, "Couldn't parse rational number: '" + rational + "'")
  let matches = results[0];
  if matches.rangeAtIndex(3).length == 0 {
    return (rational as NSString).doubleValue
  } else {
    let base = (nsrational.substringWithRange(matches.rangeAtIndex(1)) as NSString).doubleValue
    let numerator = (nsrational.substringWithRange(matches.rangeAtIndex(2)) as NSString).doubleValue
    let denominator = (nsrational.substringWithRange(matches.rangeAtIndex(3)) as NSString).doubleValue
    return base + numerator/denominator
  } 
}

class TransactionTableViewController: UITableViewController {
  var transaction:JSON! {
    didSet {
      var debitsDict = transaction["transaction"]["debets"].dictionaryValue
      var creditsDict = transaction["transaction"]["credits"].dictionaryValue
      debits = debitsDict.keys.map {($0, parseRational(debitsDict[$0]!.stringValue))}.array
      credits = creditsDict.keys.map {($0, parseRational(creditsDict[$0]!.stringValue))}.array
      self.title = transaction["meta"]["description"].string
      self.tableView.reloadData()
    }
  }
  private var debits:[(String, Double)]!
  private var credits:[(String, Double)]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = transaction["meta"]["description"].string
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return debits.count
    } else {
      return credits.count
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let id = indexPath.section == 0 ? "debitCell" : "creditCell"
    let cell = tableView.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath) as! UITableViewCell
    
    let (user, amount) = [debits, credits][indexPath.section][indexPath.row]
    
    cell.textLabel?.text = user
    cell.detailTextLabel?.text = String(format: "%.2f", amount)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Debits"
    } else {
      return "Credits"
    }
  }
}
