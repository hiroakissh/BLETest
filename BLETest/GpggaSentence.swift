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
        case LATITUDEDIR = 2
        case LATITUDE = 3
        case LONGITUDEDIR = 4
        case LONGITUDE = 5
        case ACCURACY = 6
        case SATELATENUMBER = 7
        case LOSSRATE = 8
        case ANTENNAHEIGHT = 9
        case ANTENNAHEIGHTUINT = 10
        case GEOIDHEGHT = 11
        case GEOIDHEGHTUNIT = 12
        case EFFECTIVETIME = 13
        case BASEID = 14
        case CHECKSUM = 15
    }
    
    required init(rawSentence: [String]) {
        self.rawSentence = rawSentence
    }
    
    func type() -> String {
        return "$GPGGA"
    }
    
    func parse() -> CLLocation? {
        let splittedString = self.rawSentence
        
        if splittedString.count < 15 {
            print("Invalid GPGGA")
            return nil
        }
        
        let rawTime = splittedString[GpggaSentence.GpggaParam.TIME.rawValue]
        print(rawTime)
        let rawLatitude = (splittedString[GpggaSentence.GpggaParam.LATITUDE.rawValue],splittedString[GpggaSentence.GpggaParam.LATITUDEDIR.rawValue])
        print(rawLatitude)
        let rawLongitude = (splittedString[GpggaSentence.GpggaParam.LONGITUDE.rawValue],splittedString[GpggaSentence.GpggaParam.LONGITUDEDIR.rawValue])
        print(rawLongitude)
        let rawAccuracy = splittedString[GpggaSentence.GpggaParam.ACCURACY.rawValue]
        print(rawAccuracy)
        //let rawLossrate = splittedString[GpggaSentence.GpggaParam.LOSSRATE.rawValue]

        let latitudeInDegree = convertLatitudeToDegree(with: rawLatitude.1)

        print("Latitude in degrees: \(latitudeInDegree)")
        let longitudeInDegree = convertLongitudeToDegree(with: rawLongitude.1)
        print("Longitude in degrees: \(longitudeInDegree)")
        
        let coordinate = CLLocationCoordinate2D(latitude: latitudeInDegree, longitude: longitudeInDegree)
        
        //コースとスピードは分からないので-1
        let course = CLLocationDirection(-1)
        let speed = CLLocationSpeed(-1)
        let now = Date()
        print("今日\(now)")
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier: "GMT")
//        let rawDate = dateFormatter.string(from: Date())
//        let nowtime = rawDate + rawTime
//        let timestamp = dateFormatter.date(from: nowtime)
//        print(nowtime)
//        print(timestamp)

        //標高の計算がわかるまで０
        let altitude = CLLocationDistance(0)
        let horizontalAccuracy = CLLocationAccuracy(0)
        let verticalAccuracy = CLLocationAccuracy(0)
        
//        return (CLLocation(coordinate: coordinate,altitude: altitude, horizontalAccuracy: horizontalAccuracy,verticalAccuracy: verticalAccuracy, course: course,speed: speed,timestamp: timestamp!),rawAccuracy)
        return CLLocation(coordinate: coordinate,altitude: altitude, horizontalAccuracy: horizontalAccuracy,verticalAccuracy: verticalAccuracy, course: course,speed: speed, timestamp: now)
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
