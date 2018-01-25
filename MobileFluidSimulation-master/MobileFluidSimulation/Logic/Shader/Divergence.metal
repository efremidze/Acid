//
//  ComputeDivergence.metal
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/09/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void divergence(texture2d<half, access::sample> w [[texture(0)]],
                       texture2d<half, access::write> divergence [[texture(1)]],
                       uint2 gridPosition [[thread_position_in_grid]],
                       constant float &halfrdx [[buffer(0)]])
{
    float2 frame = float2(w.get_width(), w.get_height());
    
    constexpr sampler s(coord::normalized,
                        address::repeat,
                        filter::linear);
    
    float2 lPos = (float2(gridPosition) + float2(-1, 0) + float2(0.5))/frame;
    float2 rPos = (float2(gridPosition) + float2(1, 0) + float2(0.5))/frame;
    float2 tPos = (float2(gridPosition) + float2(0, 1) + float2(0.5))/frame;
    float2 bPos = (float2(gridPosition) + float2(0, -1) + float2(0.5))/frame;
    
    half4 wL = w.sample(s, lPos);
    half4 wR = w.sample(s, rPos);
    half4 wT = w.sample(s, tPos);
    half4 wB = w.sample(s, bPos);
    
    half newValue = half(halfrdx) * ((wR.x - wL.x) + (wT.y - wB.y));
    
    divergence.write(half4(newValue), gridPosition);
}
