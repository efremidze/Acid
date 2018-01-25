//
//  ClearAll.metal
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/10/15.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void clearAll(texture2d<half, access::write> target [[texture(0)]],
                     uint2 gridPosition [[thread_position_in_grid]],
                     constant float &value [[buffer(0)]])
{
    target.write(half4(value), gridPosition);
}
