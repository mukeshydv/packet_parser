//
//  MaximumPacketSize.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct FourByteProperty {
    let identifier: MQTTPropertyIdentifier
    let propertyLength = 4
    let value: UInt32
    
    init?(_ identifier: MQTTPropertyIdentifier, _ decoder: [UInt8], startIndex: Int) throws {
        self.identifier = identifier
        
        guard startIndex < decoder.count, decoder[startIndex] == identifier.rawValue else {
            return nil
        }
        
        guard startIndex + 4 < decoder.count else {
            throw PropertyError.notAvailable("\(identifier) value not available")
        }
        
        value = UInt32(
            decoder[startIndex+1],
            decoder[startIndex+2],
            decoder[startIndex+3],
            decoder[startIndex+4]
        )
    }
}
