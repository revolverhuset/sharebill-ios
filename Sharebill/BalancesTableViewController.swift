//
//  BalancesTableViewController.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import SwiftLoader

class BalancesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  var balances:[JSON]? {
    didSet {
      tableView.reloadData()
    }
  }
  
  @IBOutlet weak var tableView:UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    firstly { () -> Promise<(JSON, NSURLResponse)> in
      SwiftLoader.show(animated:true)
      return Sharebill.inst.get("balances")
    }.then { recents, response in
      self.balances = recents["rows"].arrayValue.filter { $0["value"].string != "0" }
    }.finally {
      SwiftLoader.hide()
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return balances?.count ?? 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let balanceRow = balances![indexPath.row]
    let balance = parseRational(balanceRow["value"].stringValue)
    let cell = tableView.dequeueReusableCellWithIdentifier(balance < 0 ? "debitCell" : "creditCell", forIndexPath: indexPath) as! UITableViewCell
    
    cell.textLabel?.text = balanceRow["key"].string
    cell.detailTextLabel?.text = String(format: "%.02f", balance)

    return cell
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 32
  }
}
