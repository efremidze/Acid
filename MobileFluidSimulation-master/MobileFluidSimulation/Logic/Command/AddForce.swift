//
//  AddForce.swift
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/10/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

struct AddForce: ShaderCommand {
    struct TouchEvent {
        let delta: float2
        let center: float2
    }
    
    static let functionName: String = "addForce"
    private var radius: Float = 100
    
    private let pipelineState: MTLComputePipelineState
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        pipelineState = try type(of: self).makePiplelineState(device: device, library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer, texture: Slab, touchEvents: [Renderer.TouchEvent]) {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        var touches: [TouchEvent] = touchEvents.map { touchEvent in
            let delta = touchEvent.delta
            let center = touchEvent.point
            return TouchEvent(delta: float2(10 * Float(delta.x), Float(10 * delta.y)), center: float2(Float(center.x), Float(center.y)))
        }
        
        var numberOfTouches = touchEvents.count
        var radius = self.radius
        
        let config = DispatchConfig(width: texture.source.width, height: texture.source.height)
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(texture.source, index: 0)
        encoder.setTexture(texture.dest, index: 1)
        encoder.setBytes(&touches, length: touches.count * MemoryLayout<TouchEvent>.stride, index: 0)
        encoder.setBytes(&numberOfTouches, length: 1 * MemoryLayout<Int>.size, index: 1)
        encoder.setBytes(&radius, length: 1 * MemoryLayout<Float>.size, index: 2)
        encoder.dispatchThreadgroups(config.threadgroupCount, threadsPerThreadgroup: config.threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
