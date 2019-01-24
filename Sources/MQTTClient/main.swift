//
//  main.swift
//  MQTT
//
//  Created by Mukesh on 24/01/19.
//

import Foundation
import NIO
import MQTT

private final class MQTTClientHandler: ChannelInboundHandler {
    public typealias InboundIn = MQTTResponseMessage
    public typealias OutboundOut = MQTTRequestMessage
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let response = unwrapInboundIn(data)
        print(response)
    }
}

class MQTTClient {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    var channel: Channel?
    
    init() {
    }
    
    func close() throws {
        try channel?.close().wait()
    }
    
    func connect() throws -> EventLoopFuture<Void> {
        let bootstrap = ClientBootstrap(group: group)
            .channelInitializer { (channel) -> EventLoopFuture<Void> in
                channel.pipeline.configureClientPipeline().then {
                    channel.pipeline.add(handler: MQTTClientHandler())
                }
        }
        
        let host = "::1"
        let port = 8080
        
        return bootstrap.connect(host: host, port: port)
            .then { (channel) -> EventLoopFuture<Void> in
                print("Client connected to server: \(channel.remoteAddress!).")
                self.channel = channel
                return channel.writeAndFlush(NIOAny(MQTTRequestMessage.connect))
            }
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
}

let client = MQTTClient()
try! client.connect().wait()

try client.channel?.closeFuture.wait()
