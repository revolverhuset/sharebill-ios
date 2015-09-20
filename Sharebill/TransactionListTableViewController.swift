//
//  TranscationTableViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import SwiftLoader
import DateTools
import FontAwesome_swift

class TransactionListTableViewController: UITableViewController {
  private var transactions:[JSON]? {
    didSet {
      self.tableView.reloadData()
    }
  }
  private let dateFormatter:NSDateFormatter = NSDateFormatter()

  override func viewDidLoad() {
    super.viewDidLoad()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
  }
  
  override func awakeFromNib() {
    self.tabBarItem = UITabBarItem(title: "Transactions", image: UIImage.fontAwesomeIconWithName(.Book, textColor: UIColor.blackColor(), size: CGSizeMake(30,30)), tag: 1)
    super.awakeFromNib()
  }
  
  override func viewDidAppear(animated: Bool) {
    firstly { () -> Promise<(JSON, NSURLResponse)> in
      SwiftLoader.show(animated:true)
      return Sharebill.inst.get("recent")
    }.then { recents, response in
      self.transactions = recents["rows"].arrayValue.map { $0["value"] }
    }.finally {
      SwiftLoader.hide()
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return transactions?.count ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("transactionCell", forIndexPath: indexPath) as! UITableViewCell

    let transaction = transactions?[indexPath.row]
    cell.textLabel?.text = transaction?["meta"]["description"].string ?? "Untitled Transaction"
    if let dateString = transaction?["meta"]["timestamp"].string {
      cell.detailTextLabel?.text = dateFormatter.dateFromString(dateString)?.timeAgoSinceNow()
    }

    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showTransaction" {
      let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
      let target = segue.destinationViewController as! TransactionTableViewController
      target.transaction = transactions![indexPath.row]
    }
  }

}
