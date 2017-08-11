//
//  SayHello.swift
//  swiftTest
//
//  Created by Max Brodheim on 8/11/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import Foundation

//@objcMembers
@objc(SayHello)
class SayHello: NSObject {
//  var name: String = "";
  
//  init(inputname: String) {
//    name = inputname;
//  }

  @objc func greetings (_ name: String, callback: RCTResponseSenderBlock) -> Void {
//    return "Hello \(name)"
    NSLog("%@", name)
    let ret: [String:Any] = ["name": name];
    callback([ret])
  }
}



//var sayHello = SayHello(inputname : "Theo");
//sayHello.greetings();

