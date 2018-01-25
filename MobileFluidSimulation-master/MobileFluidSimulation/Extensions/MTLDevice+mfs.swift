//
//  MTLDevice+mfs.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 26/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

extension MTLDevice {
    func makeSurface(width: Int, height: Int, format: SurfaceFloatFormat, numberOfComponents: Int) -> MTLTexture? {
        let pixelFormat: MTLPixelFormat
        switch (format, numberOfComponents) {
        case (.half, 1):
            pixelFormat = .r16Float
        case (.half, 2):
            pixelFormat = .rg16Float
        case (.half, 3), (.half, 4):
            pixelFormat = .rgba16Float
        case (.float, 1):
            pixelFormat = .r32Float
        case (.float, 2):
            pixelFormat = .rg32Float
        case (.float, 3), (.float, 4):
            pixelFormat = .rgba32Float
        default:
            pixelFormat = .r16Float
        }
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        desc.usage = [.shaderRead, .shaderWrite]
        return makeTexture(descriptor: desc)
    }
    
    func makeSlab(width: Int, height: Int, format: SurfaceFloatFormat, numberOfComponents: Int) -> Slab? {
        guard let source = makeSurface(width: width, height: height, format: format, numberOfComponents: numberOfComponents),
            let dest = makeSurface(width: width, height: height, format: format, numberOfComponents: numberOfComponents) else {
                return nil
        }
        return Slab(source: source, dest: dest)
    }
}
