//
//  DataProperty.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct DataProperty {
    let identifier: MQTTPropertyIdentifier
    let propertyLength: Int
    let value: Data
    
    init?(_ identifier: MQTTPropertyIdentifier, _ decoder: [UInt8], startIndex: Int) throws {
        self.identifier = identifier
        
        guard startIndex < decoder.count, decoder[startIndex] == identifier.rawValue else {
            return nil
        }
        
        let startIndex = UInt32(startIndex + 1)
        let data = try MQTTData(from: decoder, startIndex: startIndex)
        value = data.value
        
        propertyLength = Int(data.length) + 2
    }
}

