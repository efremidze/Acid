//
//  KernelCommand.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 21/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

protocol ShaderCommand {
    static var functionName: String { get }
}

enum ShaderCommandError: Error {
    case failedToCreateFunction
}

extension ShaderCommand {
    static func makePiplelineState(device: MTLDevice, library: MTLLibrary) throws -> MTLComputePipelineState {
        guard let function = library.makeFunction(name: functionName) else {
            throw ShaderCommandError.failedToCreateFunction
        }
        return try device.makeComputePipelineState(function: function)
    }
}
