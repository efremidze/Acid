//
//  SubtractGradient.metal
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/09/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void subtractGradient(texture2d<half, access::sample> p [[texture(0)]],
                             texture2d<half, access::sample> w [[texture(1)]],
                             texture2d<half, access::write> target [[texture(2)]],
                             uint2 gridPosition [[thread_position_in_grid]],
                             constant float &halfrdx [[buffer(0)]])
{
    float2 frame = float2(p.get_width(), p.get_height());
    
    constexpr sampler s(coord::normalized,
                        address::repeat,
                        filter::linear);
    
    float2 lPos = (float2(gridPosition) + float2(-1, 0) + float2(0.5))/frame;
    float2 rPos = (float2(gridPosition) + float2(1, 0) + float2(0.5))/frame;
    float2 tPos = (float2(gridPosition) + float2(0, 1) + float2(0.5))/frame;
    float2 bPos = (float2(gridPosition) + float2(0, -1) + float2(0.5))/frame;
    
    half pL = p.sample(s, lPos).x;
    half pR = p.sample(s, rPos).x;
    half pT = p.sample(s, tPos).x;
    half pB = p.sample(s, bPos).x;
    
    float2 pos = (float2(gridPosition) + float2(0.5))/frame;
    half2 newValue = w.sample(s, pos).xy;
    newValue = newValue - half(halfrdx)*half2(pR - pL, pT - pB);
    
    target.write(half4(newValue, 0, 0), gridPosition);
}
