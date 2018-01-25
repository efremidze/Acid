//
//  Simulator.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 27/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

extension Renderer {
    class Simulator {
        private weak var device: MTLDevice?
        
        // Resources
        private(set) var fluid: Fluid
        
        // Commands
        private let advect: Advect
        private let addForce: AddForce
        private let divergence: Divergence
        private let jacobi: Jacobi
        private let subtractGradient: SubtractGradient
        private let clearAll: ClearAll
        
        init?(device: MTLDevice, library: MTLLibrary, width: Int, height: Int) {
            self.device = device
            
            do {
                advect = try Advect(device: device, library: library)
                addForce = try AddForce(device: device, library: library)
                divergence = try Divergence(device: device, library: library)
                jacobi = try Jacobi(device: device, library: library)
                subtractGradient = try SubtractGradient(device: device, library: library)
                clearAll = try ClearAll(device: device, library: library)
            } catch {
                print("Failed to create shader program: \(error)")
                return nil
            }
            
            guard let fluid = Fluid(device: device, width: width, height: height) else {
                print("Failed to create Fluid")
                return nil
            }
            
            self.fluid = fluid
        }
        
        func initializeFluid(with width: Int, height: Int) {
            guard let device = device, let fluid = Fluid(device: device, width: width, height: height) else {
                return
            }
            
            self.fluid = fluid
        }
        
        func encode(in buffer: MTLCommandBuffer, touchEvents: [TouchEvent]? = nil) {
            // Advect Velocity
            advect.encode(in: buffer, source: fluid.velocity.source, velocity: fluid.velocity.source, dest: fluid.velocity.dest, dissipation: 0.99)
            fluid.velocity.swap()

            // Advect Pressure
            advect.encode(in: buffer, source: fluid.pressure.source, velocity: fluid.velocity.source, dest: fluid.pressure.dest, dissipation: 0.99)
            fluid.pressure.swap()

            // Advect Density
            advect.encode(in: buffer, source: fluid.density.source, velocity: fluid.velocity.source, dest: fluid.density.dest, dissipation: 0.99)
            fluid.density.swap()

            // Add Force
            if let touchEvents = touchEvents {
                addForce.encode(in: buffer, texture: fluid.velocity, touchEvents: touchEvents)
                fluid.velocity.swap()
            }

            // Compute Divergence
            divergence.encode(in: buffer, source: fluid.velocity.source, dest: fluid.divergence)

            // Compute Jacobi
            jacobi.encode(in: buffer, slab: fluid.pressure, divergence: fluid.divergence)

            // Subtract Gradient
            subtractGradient.encode(in: buffer, pressure: fluid.pressure.source, w: fluid.velocity.source, target: fluid.velocity.dest)
            fluid.velocity.swap()

            // Clear Pressure
            clearAll.encode(in: buffer, target: fluid.pressure.source, value: 0.0)
        }
        
        var currentTexture: MTLTexture {
            return fluid.density.source
        }
    }
}
