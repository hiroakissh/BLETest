//
//  GpggaSentence.swift
//  BLETest
//
//  Created by HiroakiSaito on 2021/10/23.
//

import Foundation
import CoreLocation

class GpggaSentence: NmeaSentence{
    var rawSentence: [String]
    
    enum GpggaParam: Int {
        case TYPE = 0
        case TIME = 1
        case STATUS = 2
        case LATITUDEDIR = 3
        case LATITUDE = 4
        case LONGITUDEDIR = 5
        case LONGITUDE = 6
        case ACCURACY = 7
        case SATELATENUMBER = 8
        case LOSSRATE = 9
        case ANTENNAHEIGHT = 10
        case ANTENNAHEIGHTUINT = 11
        case GEOIDHEGHT = 12
        case GEOIDHEGHTUNIT = 13
        case EFFECTIVETIME = 14
        case BASEID = 15
        case CHECKSUM = 16
    }
    
    required init(rawSentence: [String]) {
        self.rawSentence = rawSentence
    }
    
    func type() -> String {
        return "$GPGGA"
    }
    
    func parse() -> CLLocation? {
        let splittedString = self.rawSentence
        
        if splittedString.count < 17 {
            print("Invalid GPGGA")
            return nil
        }
        
        let rawTime = splittedString[GpggaSentence.GpggaParam.TIME.rawValue]
        let rawLatitude = (splittedString[GpggaSentence.GpggaParam.LATITUDE.rawValue],splittedString[GpggaSentence.GpggaParam.LATITUDEDIR.rawValue])
        let rawLongitude = (splittedString[GpggaSentence.GpggaParam.LONGITUDE.rawValue],splittedString[GpggaSentence.GpggaParam.LONGITUDEDIR.rawValue])
        let rawAccuracy = splittedString[GpggaSentence.GpggaParam.ACCURACY.rawValue]
        //let rawLossrate = splittedString[GpggaSentence.GpggaParam.LOSSRATE.rawValue]
        
        let latitudeInDegree = convertLatitudeToDegree(with: rawLatitude.0)
        print("Latitude in degrees: \(latitudeInDegree)")
        let longitudeInDegree = convertLongitudeToDegree(with: rawLongitude.0)
        print("Longitude in degrees: \(longitudeInDegree)")
        
        let coordinate = CLLocationCoordinate2D(latitude: latitudeInDegree, longitude: longitudeInDegree)
        
        //コースとスピードは分からないので-1
        let course = CLLocationDirection(-1)
        let speed = CLLocationSpeed(-1)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        let rawDate = dateFormatter.string(from: Date())
        let nowtime = rawDate + rawTime
        let timestamp = dateFormatter.date(from: nowtime)
        
        //標高の計算がわかるまで０
        let altitude = CLLocationDistance(0)
        let horizontalAccuracy = CLLocationAccuracy(0)
        let verticalAccuracy = CLLocationAccuracy(0)
        
//        return (CLLocation(coordinate: coordinate,altitude: altitude, horizontalAccuracy: horizontalAccuracy,verticalAccuracy: verticalAccuracy, course: course,speed: speed,timestamp: timestamp!),rawAccuracy)
        return CLLocation(coordinate: coordinate,altitude: altitude, horizontalAccuracy: horizontalAccuracy,verticalAccuracy: verticalAccuracy, course: course,speed: speed,timestamp: timestamp!)
    }
    
    //緯度の形式変換
    func convertLatitudeToDegree(with stringValue: String) -> Double {
        return Double(stringValue.prefix(2))! +
            Double(stringValue.suffix(from: String.Index.init(encodedOffset: 2)))! / 60
    }
    
    //経度の形式変換
    func convertLongitudeToDegree(with stringValue: String) -> Double {
        return Double(stringValue.prefix(3))! +
            Double(stringValue.suffix(from: String.Index.init(encodedOffset: 3)))! / 60
    }
}
