//
//  parseRational.swift
//  Sharebill
//
//  Created by Jon Packer on 19.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

import Foundation

func parseRational(rational:String) -> Double {
  if rational == "" {
    return 0
  }
  let fraction = split(rational) {$0 == "/"}
  let base = split(fraction[0]) {$0 == " "}
  if fraction.count == 1 {
    return (rational as NSString).doubleValue
  } else {
    let baseNum = base.count > 1 ? (base[0] as NSString).doubleValue : 0
    let numerator = (base[base.count - 1] as NSString).doubleValue
    let denominator = (fraction[1] as NSString).doubleValue
    return baseNum + numerator/denominator
  }
}

func toRational(num:Double) -> String {
  let rational = RCRationalNumber(double: num, precision: 2)
  return String(format: "%d/%d", rational.numerator(), rational.denominator())
  
}