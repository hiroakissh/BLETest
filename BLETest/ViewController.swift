//
//  ViewController.swift
//  BLETest
//
//  Created by HiroakiSaito on 2021/10/09.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counter2Label: UILabel!
    let kUARTServiceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b" // サービス
    let kRXCharacteristicUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8" // ペリフェラルからの受信用


    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var serviceUUID : CBUUID!
    var kRXCBCharacteristic: CBCharacteristic?
    var charcteristicUUIDs: [CBUUID]!

    var nmeaParse = NmeaParser()


    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sampledata = "$GPGGA,085120.307,3541.1493,N,13945.3994,E,1,08,1.0,6.9,M,35.9,M,,0000*5E"

        let location = nmeaParse.parsesentence(data: sampledata)
        print(location! as CLLocation)
        setup()
    }

    
    
    private func setup() {
        print("setup...")

        centralManager = CBCentralManager()
        centralManager.delegate = self as CBCentralManagerDelegate

        serviceUUID = CBUUID(string: kUARTServiceUUID)
        charcteristicUUIDs = [CBUUID(string: kRXCharacteristicUUID)]
   }


}



//MARK : - CBCentralManagerDelegate
extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManager didUpdateState")

        switch central.state {
            
        //電源ONを待って、スキャンする
        case CBManagerState.poweredOn:
            let services: [CBUUID] = [serviceUUID]
            centralManager?.scanForPeripherals(withServices: services,
                                               options: nil)
        default:
            break
        }
    }
    
    /// ペリフェラルを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        self.peripheral = peripheral
        centralManager?.stopScan()
        
        //接続開始
        central.connect(peripheral, options: nil)
        print("  - centralManager didDiscover")
    }
    
    /// 接続されると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        print("  - centralManager didConnect")
    }
    
    /// 切断されると呼ばれる？
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(#function)
        if error != nil {
            print(error.debugDescription)
            setup() // ペアリングのリトライ
            return
        }
    }
}

//MARK : - CBPeripheralDelegate
extension ViewController: CBPeripheralDelegate {
    
    /// サービス発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        //キャリアクタリスティク探索開始
        if let service = peripheral.services?.first {
            print("Searching characteristic...")
            peripheral.discoverCharacteristics(charcteristicUUIDs,
                                               for: service)
        }
    }
    
    /// キャリアクタリスティク発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print(error.debugDescription)
            return
        }

        print("service.characteristics.count: \(service.characteristics!.count)")
        for characteristics in service.characteristics! {
            if(characteristics.uuid == CBUUID(string: kRXCharacteristicUUID)) {
                self.kRXCBCharacteristic = characteristics
                print("kTXCBCharacteristic did discovered!")
            }
        }
        
        if(self.kRXCBCharacteristic != nil) {
            startReciving()
        }
        print("  - Characteristic didDiscovered")

    }
    
    private func startReciving() {
        guard let kRXCBCharacteristic = kRXCBCharacteristic else {
            return
        }
        peripheral.setNotifyValue(true, for: kRXCBCharacteristic)
        print("Start monitoring the message from Arduino.\n\n")
    }


    /// データ送信時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        if error != nil {
            print(error.debugDescription)
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print(#function)
    }
    
    /// データ更新時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)

        if error != nil {
            print(error.debugDescription)
            return
        }
        updateWithData(data: characteristic.value!)
    }
    
    private func updateWithData(data : Data) {
        if let data = String(data: data, encoding: String.Encoding.utf8) {
            print(data)


            
            let location = nmeaParse.parsesentence(data: data)
            print(location! as CLLocation)
            
            
        }
    }
}
