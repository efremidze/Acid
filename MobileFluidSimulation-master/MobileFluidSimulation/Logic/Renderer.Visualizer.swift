//
//  Visualizer.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 27/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

extension Renderer {
    class Visualizer {
        let vertexData: [Float] = [
            -1,  1, 0, 0,
            -1, -1, 0, 1,
            1, -1, 1, 1,
            1, -1, 1, 1,
            1,  1, 1, 0,
            -1,  1, 0, 0
        ]
        
        private let vertexBuffer: MTLBuffer
        private let pipelineState: MTLRenderPipelineState
        private weak var view: MTKView?
        
        init?(view: MTKView, device: MTLDevice, library: MTLLibrary) {
            self.view = view
            
            guard let vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [.storageModeShared]) else {
                return nil
            }
            self.vertexBuffer = vertexBuffer
            
            // create render pipeline
            guard let vertexProgram = library.makeFunction(name: "vertex_function") else {
                return nil
            }
            
            guard let fragmentProgram = library.makeFunction(name: "fragment_function") else {
                return nil
            }
            
            let vertexDescriptor = MTLVertexDescriptor()
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            vertexDescriptor.attributes[0].format = .float2
            vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 2
            vertexDescriptor.attributes[1].bufferIndex = 0
            vertexDescriptor.attributes[1].format = .float2
            vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 4
            vertexDescriptor.layouts[0].stepRate = 1
            vertexDescriptor.layouts[0].stepFunction = .perVertex
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.label = "Fullscreen Quad Pipeline"
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
            
            do {
                self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            } catch {
                print("Failed to createRenderPipelineState: \(error)")
                return nil
            }
        }
        
        func encode(texture: MTLTexture, in buffer: MTLCommandBuffer) {
            if let renderPassDescriptor = view?.currentRenderPassDescriptor,
                let renderEncoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
                let drawable = view?.currentDrawable {
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                renderEncoder.setFragmentTexture(texture, index: 0)
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
                renderEncoder.endEncoding()
                buffer.present(drawable)
            }
        }
    }
}
