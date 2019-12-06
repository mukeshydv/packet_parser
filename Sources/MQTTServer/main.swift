//
//  main.swift
//  MQTT
//
//  Created by Mukesh on 24/01/19.
//

import Foundation
import NIO
import MQTT

let host = "::1"
let port = 8080

private final class MQTTHandler: ChannelInboundHandler {
    public typealias InboundIn = MQTTPacket
    public typealias OutboundOut = MQTTPacket
    
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let request = unwrapInboundIn(data)
        handlePacket(ctx: ctx, request)
        print(request)
    }
    
    private func handlePacket(ctx: ChannelHandlerContext, _ packet: MQTTPacket) {
        switch packet {
        case .connect(let packet):
            handleConnect(ctx: ctx, packet)
        case .pingReq(let packet):
            handlePing(ctx: ctx, packet)
        case .publish(let packet):
            handlePublish(ctx: ctx, packet)
        default:
            break
        }
    }
    
    private func handleConnect(ctx: ChannelHandlerContext, _ packet: ConnectPacket) {
        let headers = ConnackPacket.Header(sessionPresent: true, reasonCode: .success)
        let responsePacket = ConnackPacket(header: headers)
        
        let response = wrapOutboundOut(.connack(responsePacket))
        ctx.writeAndFlush(response, promise: nil)
    }
    
    private func handlePing(ctx: ChannelHandlerContext, _ packet: PingReqPacket) {
        let responsePacket = PingRespPacket()
        
        let response = wrapOutboundOut(.pingResp(responsePacket))
        ctx.writeAndFlush(response, promise: nil)
    }
    
    private func handlePublish(ctx: ChannelHandlerContext, _ packet: PublishPacket) {
        let header = PubackPacket.Header(identifier: packet.header.identifier ?? 0)
        let responsePacket = PubackPacket(header: header)
        
        let response = wrapOutboundOut(.puback(responsePacket))
        ctx.writeAndFlush(response, promise: nil)
        
        let publishResponse = wrapOutboundOut(.publish(packet))
        ctx.writeAndFlush(publishResponse, promise: nil)
    }
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let threadPool = BlockingIOThreadPool(numberOfThreads: 6)
threadPool.start()

let fileIO = NonBlockingFileIO(threadPool: threadPool)

let bootstrap = ServerBootstrap(group: group)
    .childChannelInitializer { (channel) -> EventLoopFuture<Void> in
        channel.pipeline.configureServerPipeline().then {
            channel.pipeline.add(handler: MQTTHandler())
        }
}

defer {
    try! group.syncShutdownGracefully()
    try! threadPool.syncShutdownGracefully()
}

let channel = try bootstrap.bind(host: host, port: port).wait()

guard let localAddress = channel.localAddress else {
    fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
}
print("Server started and listening on \(localAddress)")

// This will never unblock as we don't close the ServerChannel
try channel.closeFuture.wait()

print("Server closed")
