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

class TransactionTableViewController: UITableViewController {
  private var transactions:[JSON]? {
    didSet {
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    firstly { () -> Promise<(JSON, NSURLResponse)> in
      SwiftLoader.show(animated:true)
      return Sharebill.inst.get("recent")
    }.then { recents, response in
      self.transactions = recents["rows"].arrayValue.map { $0["value"]["meta"] }
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

    cell.textLabel?.text = transactions?[indexPath.row]["value"]["meta"]["description"].string ?? "Untitled Transaction"

    return cell
  }
  /*
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using [segue destinationViewController].
      // Pass the selected object to the new view controller.
  }
  */

}
