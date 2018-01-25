//
//  Jacobi.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 21/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

// Texture0: Source
// Texture1: Divergence
// Texture2: Target
// Buffer0: alpha
// Buffer1: InverseBeta

struct Jacobi: ShaderCommand {
    static let functionName: String = "jacobi"
    
    private static let numberOfIteration: Int = 20
    
    private let pipelineState: MTLComputePipelineState
    private let alpha: Float = -1
    private let inverseBeta: Float = 0.25
    
    init(device: MTLDevice, library: MTLLibrary) throws {
        self.pipelineState = try type(of: self).makePiplelineState(device: device, library: library)
    }
    
    func encode(in buffer: MTLCommandBuffer, slab: Slab, divergence: MTLTexture) {
        let width = slab.source.width
        let height = slab.source.height
        
        var alpha = self.alpha
        var inverseBeta = self.inverseBeta
        
        for _ in 0..<type(of: self).numberOfIteration {
            guard let encoder = buffer.makeComputeCommandEncoder() else {
                continue
            }
            
            let config = DispatchConfig(width: width, height: height)
            encoder.setComputePipelineState(pipelineState)
            encoder.setBytes(&alpha, length: MemoryLayout<Float>.size, index: 0)
            encoder.setBytes(&inverseBeta, length: MemoryLayout<Float>.size, index: 1)
            encoder.setTexture(slab.source, index: 0)
            encoder.setTexture(divergence, index: 1)
            encoder.setTexture(slab.dest, index: 2)
            encoder.dispatchThreadgroups(config.threadgroupCount, threadsPerThreadgroup: config.threadsPerThreadgroup)
            encoder.endEncoding()
            
            slab.swap()
        }
    }
}
