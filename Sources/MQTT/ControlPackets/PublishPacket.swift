//
//  PublishPacket.swift
//  MQTT
//
//  Created by Mukesh on 28/01/19.
//

import Foundation

struct PublishPacket {
    let dup: Bool
    let qos: UInt8
    let retain: Bool
    let header: Header
    let payload: Data?
    
    struct Header {
        let topicName: String
        let identifier: UInt16
        let properties: Property?
        
        struct Property {
            let payloadFormatIndicator: UInt8
            let messageExpiryInterval: UInt32?
            let topicAlias: UInt16?
            let responseTopic: String?
            let correlationData: Data?
            let userProperty: [String: String] = [:]
            let subscriptionIdentifier: [UInt32] = []
            let contentType: String
        }
    }
}
