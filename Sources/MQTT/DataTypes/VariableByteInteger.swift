//
//  VariableByteInteger.swift
//  MQTT
//
//  Created by Mukesh on 25/01/19.
//

import Foundation

struct VariableByteInteger {
    let value: UInt32
    let bytes: [UInt8]
    
    init(_ value: UInt32) {
        self.value = value
        
        var bytes: [UInt8] = []
        var x = value;
        repeat {
            var encodedByte: UInt8 = UInt8(x % 128)
            x = x / 128
            
            if x > 0 {
                encodedByte = encodedByte | 128
            }
            
            bytes.append(encodedByte)
        } while x > 0
        
        self.bytes = bytes
    }
    
    init(_ bytes: [UInt8]) {
        self.bytes = bytes
        
        var multiplier: UInt32 = 1
        var value: UInt32 = 0
        var encodedByte: UInt8
        var index = 0
        
        repeat {
            encodedByte = bytes[index]
            value += UInt32(encodedByte & 127) * multiplier
            if multiplier > 128 * 128 * 128 {
                // Errror
            }
            
            multiplier *= 128
            index += 1
        } while (encodedByte & 128) != 0
        
        self.value = value
    }
}
