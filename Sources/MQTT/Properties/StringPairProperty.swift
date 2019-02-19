//
//  StringPairProperty.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct StringPairProperty  {
    let identifier: MQTTPropertyIdentifier
    let propertyLength: Int
    let key: String
    let value: String
    
    init?(_ identifier: MQTTPropertyIdentifier, _ decoder: [UInt8], startIndex: Int) throws {
        self.identifier = identifier
        
        guard startIndex < decoder.count, decoder[startIndex] == identifier.rawValue else {
            return nil
        }
        
        let startIndex = startIndex + 1
        let utf8Pair = try MQTTUTF8StringPair(from: decoder, startIndex: startIndex)
        key = utf8Pair.key
        value = utf8Pair.value
        
        propertyLength = Int(utf8Pair.keyLength) + Int(utf8Pair.valueLength) + 4
    }
}

