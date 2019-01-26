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
    
    init(from bytes: [UInt8], startIndex: UInt32 = 0) throws {
        let startIndex = Int(startIndex + 2)
        
        guard startIndex <= bytes.count else {
            throw MQTTDataTypeError.invalidBinaryData
        }
        
        length = UInt16(bytes[startIndex-2], bytes[startIndex-1])
        
        let endIndex = startIndex + Int(length)
        
        guard endIndex <= bytes.count else {
            throw MQTTDataTypeError.invalidBinaryData
        }
        
        let bytes = bytes[startIndex..<endIndex].map { $0 }
        self.bytes = [bytes[startIndex-2], bytes[startIndex-1]] + bytes
        
        self.value = Data(bytes)
    }
}
