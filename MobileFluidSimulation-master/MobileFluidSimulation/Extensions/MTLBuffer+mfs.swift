//
//  MTLBuffer+mfs.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 27/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import Metal

extension MTLBuffer {
    func set<T>(singleValue: T) {
        let binded = contents().bindMemory(to: T.self, capacity: 1)
        binded[0] = singleValue
    }
    
    func set<T>(multipleValues: [T]) {
        let binded = contents().bindMemory(to: T.self, capacity: multipleValues.count)
        for i in 0..<multipleValues.count {
            binded[i] = multipleValues[i]
        }
    }
}
