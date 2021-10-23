//
//  NmeaParser.swift
//  BLETest
//
//  Created by HiroakiSaito on 2021/10/23.
//

import Foundation
import CoreLocation

protocol NmeaSentence {
    
    var rawSentence: [String] {get}
    
    init(rawSentence: [String])
    
    func type() -> String
    
    func parse() -> (CLLocation?,String)
    
}
