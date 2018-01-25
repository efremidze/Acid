//
//  Divergence.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 25/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

// Texture0: w
// Texture1: divergence
// Buffer0: halfrdx

struct Divergence: ShaderCommand {
    static let functionName: String = "divergence"
    
    private let pipelineState: MTLComputePipelineState
    private let halfrdx: Float = 0.5
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        self.pipelineState = try type(of: self).makePiplelineState(device: device, library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer, source: MTLTexture, dest: MTLTexture) {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        var halfrdx = self.halfrdx
        
        let config = DispatchConfig(width: source.width, height: source.height)
        encoder.setComputePipelineState(pipelineState)
        encoder.setBytes(&halfrdx, length: MemoryLayout<Float>.size, index: 0)
        encoder.setTexture(source, index: 0)
        encoder.setTexture(dest, index: 1)
        encoder.dispatchThreadgroups(config.threadgroupCount, threadsPerThreadgroup: config.threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
