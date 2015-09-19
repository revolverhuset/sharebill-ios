//
//  TransactionTableViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit
import SwiftyJSON
import Regex

func parseRational(rational:String) -> Double {
  let parseResult = rational.grep("(\\d+)\\s?(\\d+)?/?(\\d+)?")
  if parseResult.captures.count == 1 {
    return (rational as NSString).doubleValue
  } else if parseResult.captures.count == 3 {
    let base = (parseResult.captures[0] as NSString).doubleValue
    let numerator = (parseResult.captures[1] as NSString).doubleValue
    let denominator = (parseResult.captures[2] as NSString).doubleValue
    return base + numerator/denominator
  } else {
    assert(false, "Couldn't parse rational number: '" + rational + "'")
  }
}

class TransactionTableViewController: UITableViewController {
  private var transaction:JSON! {
    didSet {
      var debitsDict = transaction["transaction"]["debets"].dictionaryValue
      var creditsDict = transaction["transaction"]["credits"].dictionaryValue
      debits = debitsDict.keys.map {($0, parseRational(debitsDict[$0]!.stringValue))}.array
      credits = creditsDict.keys.map {($0, parseRational(creditsDict[$0]!.stringValue))}.array
      self.tableView.reloadData()
    }
  }
  private var debits:[(String, Double)]!
  private var credits:[(String, Double)]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = transaction["meta"]["title"].string
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
}
