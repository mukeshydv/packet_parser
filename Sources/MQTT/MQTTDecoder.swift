//
//  MQTTDecoder.swift
//  MQTT
//
//  Created by Mukesh on 22/01/19.
//

import Foundation
import NIO

public class MQTTRequestDecoder: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = MQTTRequestMessage
    public var cumulationBuffer: ByteBuffer?
    
    public func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        return .needMoreData
    }
}

public class MQTTResponseDecoder: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = MQTTResponseMessage
    
    public var cumulationBuffer: ByteBuffer?
    
    public func decode(ctx: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        return .needMoreData
    }
}
