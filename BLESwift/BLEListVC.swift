//
//  BLEListVC.swift
//  BLESwift
//
//  Created by Giresh Dora on 13/11/18.
//  Copyright © 2018 Giresh Dora. All rights reserved.
//

import UIKit

import CoreBluetooth

class BLEListVC: UIViewController {

   private var bleArray = [CBPeripheral]()
    var centralManager :CBCentralManager?
    
    @IBOutlet weak var bleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.init(label: "BLESwiftCentral"))
    }
}

extension BLEListVC: UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CBPeripheralDelegate{

    
    // MARK: Central manager delagate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOff:
            break
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        if peripheral.name != nil{
            bleArray.append(peripheral)
            DispatchQueue.main.async {
                self.bleTableView.reloadData()
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        print("\(peripheral.name ?? "") is connected sucess")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        central.stopScan()
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("Connection fail")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print("Disconnect")
    }
    
    // MARK: Peripheral delagate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        print("Discover services")
        for services in peripheral.services! {
            print("Servies is \(services)")
            peripheral.discoverCharacteristics(nil, for: services)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        print("discover characteristics")
        for characteristics in service.characteristics! {
            print(characteristics)
            peripheral.readValue(for: characteristics)
            if characteristics.properties == CBCharacteristicProperties.write {
                
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if (error != nil){
            return
        }
        let charValue = String(data: characteristic.value!, encoding: .utf8)
        print(charValue!)
        
//        let charValue = String(data: characteristic.value!, encoding: .utf8)
//        print(charValue!)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        
    }
    
    //MARK: Table view delagate and datastore methdos
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let peripheral = bleArray[indexPath.row]
        //print(peripheral)
        cell.textLabel?.text = "Peripheral name: \(peripheral.name ?? "(Null)")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = bleArray[indexPath.row]
        centralManager?.connect(peripheral, options: nil)
        
    }
    
}
