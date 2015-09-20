//
//  NewEntryViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit
import QuartzCore

struct SharebillEntry {
  var credits:[(String, String)] {
    didSet {
      _creditsTotal = nil
    }
  }
  var debits:[(String, String)] {
    didSet {
      _debitsTotal = nil
    }
  }
  private var _creditsTotal:Double? = nil
  private var _debitsTotal:Double? = nil
  var creditsTotal:Double {
    mutating get {
      if let creditsTotal = _creditsTotal {
        return creditsTotal
      }
      _creditsTotal = credits.reduce(0.0) { $0! + parseRational($1.1) }
      return _creditsTotal!
    }
  }
  var debitsTotal:Double {
    mutating get {
      if let debitsTotal = _debitsTotal {
        return debitsTotal
      }
      _debitsTotal = debits.reduce(0.0) { $0! + parseRational($1.1) }
      return _debitsTotal!
    }
  }
}

class NewEntryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EntryInputTableViewCellDelegate {
  @IBOutlet weak var tableView:UITableView!
  @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
  @IBOutlet weak var submitButton:UIButton!
  
  var debitsSectionHeader:UITableViewHeaderFooterView? {
    get {
      return tableView.headerViewForSection(0)
    }
  }
  var creditsSectionHeader:UITableViewHeaderFooterView? {
    get {
      return tableView.headerViewForSection(1)
    }
  }
  
  var entry:SharebillEntry = SharebillEntry(credits: [], debits: [], _creditsTotal: nil, _debitsTotal: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    submitButton.layer.cornerRadius = 5
    submitButton.layer.masksToBounds = true
    submitButton.layer.borderColor = UIColor.redColor().CGColor
    submitButton.layer.borderWidth = 1
    submitButton.setTitle("No Values", forState: .Normal)
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return entry.debits.count + 1
    } else {
      return entry.credits.count + 1
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("entryRow", forIndexPath: indexPath) as! EntryInputTableViewCell
    
    cell.delegate = self
    
    if indexPath.section == 0 {
      if indexPath.row < entry.debits.count {
        let entryRow = entry.debits[indexPath.row]
        cell.account.text = entryRow.0
        cell.value.text = entryRow.1
      }
    } else {
      if indexPath.row < entry.credits.count {
        let entryRow = entry.credits[indexPath.row]
        cell.account.text = entryRow.0
        cell.value.text = entryRow.1
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return String(format: "DEBITS (%.02f)", entry.debitsTotal)
    } else {
      return String(format: "CREDITS (%.02f)", entry.creditsTotal)
    }
  }
  
  func insertNewRowInSection(section:Int) {
    let indexPath = NSIndexPath(forRow: [entry.debits, entry.credits][section].count, inSection: section)
    tableView.beginUpdates()
    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    tableView.endUpdates()
  }
  
  private func updateEntriesWithArray(array:[(String,String)], forIndex index:Int) {
    if index == 0 {
      entry.debits = array
    } else {
      entry.credits = array
    }
  }
  
  @IBAction func submitEntry() {
    if entry.debits.count == 0 || entry.credits.count == 0 || entry.creditsTotal != entry.debitsTotal || entry.creditsTotal == 0 {
      return
    }
    
    for var i = 0; i < entry.credits.count; ++i {
      if entry.credits[i].0 == "" {
        return
      }
    }
    
    for var i = 0; i < entry.debits.count; ++i {
      if entry.debits[i].0 == "" {
        return
      }
    }
    
    
  }
  
  private func recalculateTotals() {
    debitsSectionHeader?.textLabel.text = tableView(tableView, titleForHeaderInSection:0)
    debitsSectionHeader?.textLabel.sizeToFit()
    creditsSectionHeader?.textLabel.text = tableView(tableView, titleForHeaderInSection:1)
    creditsSectionHeader?.textLabel.sizeToFit()
    if entry.creditsTotal == entry.debitsTotal {
      submitButton.setTitle("Submit", forState: .Normal)
      submitButton.layer.borderColor = UIColor.greenColor().CGColor
    } else {
      submitButton.setTitle(String(format:"%.02f != %.02f", entry.debitsTotal, entry.creditsTotal), forState: .Normal)
      submitButton.layer.borderColor = UIColor.redColor().CGColor
    }
  }
  
  func cell(cell: EntryInputTableViewCell, didUpdateAccount newAccount: String) {
    if let indexPath = self.tableView.indexPathForCell(cell) {
      var targetArray = indexPath.section == 0 ? entry.debits : entry.credits
      if indexPath.row == targetArray.count {
        targetArray.append(newAccount, "")
        updateEntriesWithArray(targetArray, forIndex: indexPath.section)
        insertNewRowInSection(indexPath.section)
      } else {
        targetArray[indexPath.row].0 = newAccount
        updateEntriesWithArray(targetArray, forIndex: indexPath.section)
      }
    }
  }
  
  func cell(cell: EntryInputTableViewCell, didUpdateValue newValue: String) {
    if let indexPath = self.tableView.indexPathForCell(cell) {
      var targetArray = indexPath.section == 0 ? entry.debits : entry.credits
      if indexPath.row == targetArray.count {
        targetArray.append("", newValue)
        updateEntriesWithArray(targetArray, forIndex: indexPath.section)
        insertNewRowInSection(indexPath.section)
      } else {
        targetArray[indexPath.row].1 = newValue
        updateEntriesWithArray(targetArray, forIndex: indexPath.section)
      }
      recalculateTotals()
    }
  }
  
  func cellDidRequestFocusInNextRow(cell: EntryInputTableViewCell) {
    if let indexPath = self.tableView.indexPathForCell(cell) {
      let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
      if let nextRow = self.tableView.cellForRowAtIndexPath(nextIndexPath) {
        let nextRowEntry = nextRow as! EntryInputTableViewCell
        nextRowEntry.account.becomeFirstResponder()
      }
    }
  }
}

protocol EntryInputTableViewCellDelegate {
  func cell(cell:EntryInputTableViewCell, didUpdateAccount newAccount:String)
  func cell(cell:EntryInputTableViewCell, didUpdateValue newValue:String)
  func cellDidRequestFocusInNextRow(cell:EntryInputTableViewCell)
}

class EntryInputTableViewCell:UITableViewCell {
  @IBOutlet weak var account:UITextField!
  @IBOutlet weak var value:UITextField!
  
  var delegate:EntryInputTableViewCellDelegate?
  
  @IBAction func didUpdateAccount(sender:UITextField!) {
    delegate?.cell(self, didUpdateAccount: sender.text)
  }
  
  @IBAction func didUpdateValue(sender:UITextField!) {
    delegate?.cell(self, didUpdateValue: sender.text)
  }
  
  @IBAction func didRequestFocusInValue(sender:UITextField!) {
    value.becomeFirstResponder()
  }
  
  @IBAction func didRequestFocusInNextRow(sender:UITextField!) {
    delegate?.cellDidRequestFocusInNextRow(self)
  }
}
