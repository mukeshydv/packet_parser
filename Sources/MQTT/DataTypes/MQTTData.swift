//
//  MQTTData.swift
//  MQTT
//
//  Created by Mukesh on 26/01/19.
//

import Foundation

struct MQTTData {
    let value: Data
    let bytes: [UInt8]
    let length: UInt16
    
    init(_ value: Data) throws {
        guard value.count < UInt16.max else {
            throw MQTTDataTypeError.invalidBinaryData
        }
        
        self.value = value
        self.length = UInt16(value.count)
        self.bytes = length.bytes + value.array
    }
    
    init(from decoder: [UInt8], startIndex: UInt32 = 0) throws {
        let startIndex = Int(startIndex + 2)
        
        guard startIndex <= decoder.count else {
            throw MQTTDataTypeError.invalidBinaryData
        }
        
        length = UInt16(decoder[startIndex-2], decoder[startIndex-1])
        
        let endIndex = startIndex + Int(length)
        
        guard endIndex <= decoder.count else {
            throw MQTTDataTypeError.invalidBinaryData
        }
        
        let bytes = decoder[startIndex..<endIndex].array
        self.bytes = [decoder[startIndex-2], decoder[startIndex-1]] + bytes
        
        self.value = Data(bytes)
    }
}
