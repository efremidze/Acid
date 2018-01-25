//
//  Advect.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 21/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

struct Advect: ShaderCommand {
    static let functionName: String = "advect"
    
    private let pipelineState: MTLComputePipelineState
    private let timestep: Float = 0.125
    private let dissipation: Float = 0.99
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        self.pipelineState = try type(of: self).makePiplelineState(device: device, library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer, source: MTLTexture, velocity: MTLTexture, dest: MTLTexture, dissipation: Float) {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            return
        }
        
        var timestep = self.timestep
        var dissipation = self.dissipation
        
        let config = DispatchConfig(width: source.width, height: source.height)
        encoder.setComputePipelineState(pipelineState)
        encoder.setBytes(&timestep, length: MemoryLayout<Float>.size, index: 0)
        encoder.setBytes(&dissipation, length: MemoryLayout<Float>.size, index: 1)
        encoder.setTexture(source, index: 0)
        encoder.setTexture(velocity, index: 1)
        encoder.setTexture(dest, index: 2)
        encoder.dispatchThreadgroups(config.threadgroupCount, threadsPerThreadgroup: config.threadsPerThreadgroup)
        encoder.endEncoding()
    }
}
