//
//  NewEntryViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit

struct SharebillEntry {
  var credits:[(String, String)]
  var debits:[(String, String)]
}

class NewEntryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EntryInputTableViewCellDelegate {
  @IBOutlet weak var tableView:UITableView!
  
  var entry:SharebillEntry = SharebillEntry(credits: [], debits: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Debits"
    } else {
      return "Credits"
    }
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
