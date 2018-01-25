//
//  DispatchConfig.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 21/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

struct DispatchConfig {
    var width: Int
    var height: Int
    
    init(viewSize: MTLSize) {
        self.width = viewSize.width
        self.height = viewSize.height
    }
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    var threadsPerThreadgroup: MTLSize = MTLSize(width: 16, height: 16, depth: 1)
    var threadgroupCount: MTLSize {
        let width = Int(ceilf(Float(self.width) / Float(threadsPerThreadgroup.width)))
        let height = Int(ceilf(Float(self.height) / Float(threadsPerThreadgroup.height)))
        return MTLSize(width: width, height: height, depth: 1)
    }
}
