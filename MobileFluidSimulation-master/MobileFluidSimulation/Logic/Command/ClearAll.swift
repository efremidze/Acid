//
//  ClearAll.swift
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/10/15.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

struct ClearAll: ShaderCommand {
    static let functionName: String = "clearAll"
    
    private let pipelineState: MTLComputePipelineState
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        pipelineState = try type(of: self).makePiplelineState(device: device, library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer, target: MTLTexture, value: Float) {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        var _value = value
        
        let config = DispatchConfig(width: target.width, height: target.height)
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(target, index: 0)
        encoder.setBytes(&_value, length: MemoryLayout<Float>.size, index: 0)
        encoder.dispatchThreadgroups(config.threadgroupCount, threadsPerThreadgroup: config.threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
