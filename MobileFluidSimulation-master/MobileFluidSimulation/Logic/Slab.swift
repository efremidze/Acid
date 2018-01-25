//
//  Slab.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 20/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import MetalKit

final class Slab {
    var source: MTLTexture
    var dest: MTLTexture
    
    init(source: MTLTexture, dest: MTLTexture) {
        self.source = source
        self.dest = dest
    }
    
    func swap() {
        let temp = source
        source = dest
        dest = temp
    }
}
