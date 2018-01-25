//
//  Advect.metal
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/09/13.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void advect(texture2d<half, access::sample> source [[texture(0)]],
                   texture2d<half, access::sample> velocity [[texture(1)]],
                   texture2d<half, access::write> target [[texture(2)]],
                   uint2 gridPosition [[thread_position_in_grid]],
                   constant float &timeStep [[buffer(0)]],
                   constant float &dissipation [[buffer(1)]])
{
    float2 texturePos = float2(gridPosition) + float2(0.5);
    float2 frame = float2(source.get_width(), source.get_height());
    float2 fpos = texturePos / frame;
    constexpr sampler s(coord::normalized,
                        address::repeat,
                        filter::linear);
    float2 vel = float2(velocity.sample(s, fpos).xy)/frame;
    half4 newValue = source.sample(s, fpos - timeStep * vel);
    target.write(newValue, gridPosition);
}
