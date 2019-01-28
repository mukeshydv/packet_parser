//
//  StringProperty.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct StringProperty {
    let identifier: MQTTPropertyIdentifier
    let propertyLength: Int
    let value: String
    
    init?(_ identifier: MQTTPropertyIdentifier, _ decoder: [UInt8], startIndex: Int) throws {
        self.identifier = identifier
        
        guard startIndex < decoder.count, decoder[startIndex] == identifier.rawValue else {
            return nil
        }
        
        let startIndex = UInt32(startIndex + 1)
        let utf8Pair = try MQTTUTF8String(from: decoder, startIndex: startIndex)
        value = utf8Pair.value
        
        propertyLength = Int(utf8Pair.length) + 2
    }
}

