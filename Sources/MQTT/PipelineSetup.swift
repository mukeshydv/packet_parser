//
//  PipelineSetup.swift
//  MQTT
//
//  Created by Mukesh on 24/01/19.
//

import Foundation
import NIO

public extension ChannelPipeline {
    func configureServerPipeline() -> EventLoopFuture<Void> {
        let handlers: [ChannelHandler] = [MQTTPacketDecoder(), MQTTPacketEncoder()]
        return addHandlers(handlers, first: true)
    }
    
    func configureClientPipeline() -> EventLoopFuture<Void> {
        let handlers: [ChannelHandler] = [MQTTPacketDecoder(), MQTTPacketEncoder()]
        return addHandlers(handlers, first: true)
    }
}
