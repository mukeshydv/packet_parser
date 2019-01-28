//
//  ByteProperty.swift
//  CNIOAtomics
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct ByteProperty {
    let identifier: MQTTPropertyIdentifier
    let propertyLength = 1
    let value: UInt8
    
    init?(_ identifier: MQTTPropertyIdentifier, _ decoder: [UInt8], startIndex: Int) throws {
        self.identifier = identifier
        
        guard startIndex < decoder.count, decoder[startIndex] == identifier.rawValue else {
            return nil
        }
        
        guard startIndex + 1 < decoder.count else {
            throw PropertyError.notAvailable("\(identifier) value not available")
        }
        
        value = decoder[startIndex+1]
    }
}
