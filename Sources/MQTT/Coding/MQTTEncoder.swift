//
//  MQTTEncoder.swift
//  MQTT
//
//  Created by Mukesh on 23/02/19.
//

import Foundation

class MQTTEncoder {
    func encode<T: MQTTPacketEncodable>(packet: T) throws -> [UInt8] {
        return try packet.encoded()
    }
}
