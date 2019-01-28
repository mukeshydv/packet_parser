//
//  TwoByteProperty.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct TwoByteProperty {
    let identifier: MQTTPropertyIdentifier
    let propertyLength = 2
    let value: UInt16
    
    init?(_ identifier: MQTTPropertyIdentifier, _ decoder: [UInt8], startIndex: Int) throws {
        self.identifier = identifier
        
        guard startIndex < decoder.count, decoder[startIndex] == identifier.rawValue else {
            return nil
        }
        
        guard startIndex + 2 < decoder.count else {
            throw PropertyError.notAvailable("\(identifier) value not available")
        }
        
        value = UInt16(decoder[startIndex+1], decoder[startIndex+2])
    }
}
