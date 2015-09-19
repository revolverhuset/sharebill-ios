//
//  TransactionTableViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit
import SwiftyJSON


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
