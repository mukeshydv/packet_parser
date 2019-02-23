//
//  MQTTDecoder.swift
//  MQTT
//
//  Created by Mukesh on 23/02/19.
//

import Foundation
import NIO

enum MQTTPacket {
    case connect(ConnectPacket)
    case auth(AuthPacket)
    case connack(ConnackPacket)
    case disconnect(DisconnectPacket)
    case pingReq(PingReqPacket)
    case pingResp(PingRespPacket)
    case puback(PubackPacket)
    case pubcomp(PubcompPacket)
    case publish(PublishPacket)
    case pubrec(PubrecPacket)
    case pubrel(PubrelPacket)
    case suback(SubackPacket)
    case subscribe(SubscribePacket)
    case unsuback(UnsubackPacket)
    case unsubscribe(UnsubscribePacket)
}

class MQTTDecoder {
    private let stages = [parseFixedHeader, parsePacketLength, parsePayload]
    
    private var currentStage = 0
    private var cumulationBuffer = ByteBufferAllocator().buffer(capacity: 1024)
    private var currentPacketFixedHeader: MQTTPacketFixedHeader?
    private var packetLength: UInt32?
    
    var completionHandler: ((MQTTPacket) -> ())?
    
    func decode(_ buffer: inout ByteBuffer) throws {
        cumulationBuffer.write(buffer: &buffer)
        
        while cumulationBuffer.readableBytes > 0, try stages[currentStage](self)() {
            currentStage += 1
            if currentStage >= stages.count { currentStage = 0 }
        }
    }
    
    private func reset() {
        currentStage = 0
        currentPacketFixedHeader = nil
        packetLength = nil
    }
    
    private func parseFixedHeader() throws -> Bool {
        if let byte = cumulationBuffer.readBytes(length: 1)?.first {
            do {
                currentPacketFixedHeader = try MQTTPacketFixedHeader(networkByte: byte)
            } catch {
                reset()
                throw error
            }
            return true
        }
        return false
    }
    
    private func parsePacketLength() throws -> Bool {
        
        var multiplier: UInt32 = 1
        var value: UInt32 = 0
        var encodedByte: UInt8
        var index = 0
        
        do {
            
            repeat {
                guard index < cumulationBuffer.readableBytes else {
                    return false
                }
                
                let nextIndex = cumulationBuffer.readerIndex + index
                if let nextByte: UInt8 = cumulationBuffer.getInteger(at: nextIndex) {
                    encodedByte = nextByte
                    
                    value += UInt32(encodedByte & 127) * multiplier
                    if multiplier > 128 * 128 * 128 {
                        throw VariableByteError.error("Size error")
                    }
                    
                    multiplier *= 128
                    index += 1
                } else {
                    return false
                }
            } while (encodedByte & 128) != 0
        } catch {
            reset()
            throw error
        }
        
        cumulationBuffer.moveReaderIndex(forwardBy: index)
        packetLength = value
        return true
    }
    
    private func parsePayload() throws -> Bool {
        
        if let packetHeader = currentPacketFixedHeader,
            let packetLength = packetLength,
            cumulationBuffer.readableBytes >= packetLength,
            var bytes = cumulationBuffer.readBytes(length: Int(packetLength)) {
            
            bytes = [packetHeader.encoded()] + VariableByteInteger(packetLength).bytes + bytes
            
            do {
                
                let packetResponse: MQTTPacket
                switch packetHeader.packetType {
                case .AUTH:
                    let packet = try AuthPacket(decoder: bytes)
                    packetResponse = .auth(packet)
                case .CONNACK:
                    let packet = try ConnackPacket(decoder: bytes)
                    packetResponse = .connack(packet)
                case .CONNECT:
                    let packet = try ConnectPacket(decoder: bytes)
                    packetResponse = .connect(packet)
                case .DISCONNECT:
                    let packet = try DisconnectPacket(decoder: bytes)
                    packetResponse = .disconnect(packet)
                case .PINGREQ:
                    let packet = try PingReqPacket(decoder: bytes)
                    packetResponse = .pingReq(packet)
                case .PINGRESP:
                    let packet = try PingRespPacket(decoder: bytes)
                    packetResponse = .pingResp(packet)
                case .PUBACK:
                    let packet = try PubackPacket(decoder: bytes)
                    packetResponse = .puback(packet)
                case .PUBCOMP:
                    let packet = try PubcompPacket(decoder: bytes)
                    packetResponse = .pubcomp(packet)
                case .PUBLISH:
                    let packet = try PublishPacket(decoder: bytes)
                    packetResponse = .publish(packet)
                case .PUBREC:
                    let packet = try PubrecPacket(decoder: bytes)
                    packetResponse = .pubrec(packet)
                case .PUBREL:
                    let packet = try PubrelPacket(decoder: bytes)
                    packetResponse = .pubrel(packet)
                case .SUBACK:
                    let packet = try SubackPacket(decoder: bytes)
                    packetResponse = .suback(packet)
                case .SUBSCRIBE:
                    let packet = try SubscribePacket(decoder: bytes)
                    packetResponse = .subscribe(packet)
                case .UNSUBACK:
                    let packet = try UnsubackPacket(decoder: bytes)
                    packetResponse = .unsuback(packet)
                case .UNSUBSCRIBE:
                    let packet = try UnsubscribePacket(decoder: bytes)
                    packetResponse = .unsubscribe(packet)
                case .reserved:
                    throw PacketError.invalidPacket("Invalid packet identifier")
                }
                
                completionHandler?(packetResponse)
            } catch {
                reset()
                throw error
            }
            return true
        }
        
        return false
    }
}
