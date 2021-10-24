//
//  NmeaParse.swift
//  BLETest
//
//  Created by HiroakiSaito on 2021/10/24.
//

import Foundation
import CoreLocation

class NmeaParser{
    
    func parsesentence(data: String) -> CLLocation?{
        print("input sentence: \(data)")

        let splittedString = data.components(separatedBy: ",")

        if let type = splittedString.first{
            print("NMEA Type \(String(describing: type))")

            switch type{
            case "$GPRMC": fallthrough
            case "$GPGGA": let sentence = GpggaSentence(rawSentence: splittedString)
                return sentence.parse()
            case "$GPGSV": fallthrough
            case "$GPGSA":
                print("Type \(String(describing: type)) not supported yet.")
            default:
                print("Type \(String(describing: type)) unknown.")
            }
        }
        return nil
    }
}
