//
//  Sharebill.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit
import OMGHTTPURLRQ

class Sharebill {
  private static let InstanceURL = "http://sharebill.qpgc.org"
  
  // todo - make these configured outside source code somewhere.
  static let inst = Sharebill(instance: InstanceURL)
  
  let instance: String
  
  init(instance: String) {
    self.instance = instance
  }
  
  func endpoint(path:String) -> String {
    return "\(self.instance)/\(path)"
  }
  
  private func parseResult(request:Promise<(NSData, NSURLResponse)>) -> Promise<(JSON, NSURLResponse)> {
    return request.then { (data:NSData, resp:NSURLResponse) -> (JSON, NSURLResponse) in
      return (JSON(data: data, options: .allZeros, error: nil), resp)
    }
  }
  
  func put(path:String, json:[String:AnyObject]) -> Promise<(JSON, NSURLResponse)> {
    var request = OMGHTTPURLRQ.PUT(endpoint(path), JSON: json)
    return parseResult(NSURLConnection.promise(request))
  }
  
  func get(apiPath:String) -> Promise<(JSON, NSURLResponse)> {
    var request = NSURLRequest(URL: NSURL(string:endpoint(apiPath))!)
    return parseResult(NSURLConnection.promise(request));
  }
  
  func get(apiPath:String, query:[String:AnyObject]) -> Promise<(JSON, NSURLResponse)> {
    var request = OMGHTTPURLRQ.GET(endpoint(apiPath), query)
    return parseResult(NSURLConnection.promise(request))
  }
}