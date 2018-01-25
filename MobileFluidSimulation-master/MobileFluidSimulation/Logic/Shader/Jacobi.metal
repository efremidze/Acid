//
//  Jacobi.metal
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/09/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void jacobi(texture2d<half, access::sample> source [[texture(0)]],
                   texture2d<half, access::sample> divergence [[texture(1)]],
                   texture2d<half, access::write> target [[texture(2)]],
                   uint2 gridPosition [[thread_position_in_grid]],
                   constant float &alpha [[buffer(0)]],
                   constant float &inverseBeta [[buffer(1)]])
{
    float2 frame = float2(source.get_width(), source.get_height());
    
    constexpr sampler s(coord::normalized,
                        address::repeat,
                        filter::linear);
    
    float2 lPos = (float2(gridPosition) + float2(-1, 0) + float2(0.5))/frame;
    float2 rPos = (float2(gridPosition) + float2(1, 0) + float2(0.5))/frame;
    float2 tPos = (float2(gridPosition) + float2(0, -1) + float2(0.5))/frame;
    float2 bPos = (float2(gridPosition) + float2(0, 1) + float2(0.5))/frame;
    
    half4 sL = source.sample(s, lPos);
    half4 sR = source.sample(s, rPos);
    half4 sT = source.sample(s, tPos);
    half4 sB = source.sample(s, bPos);
    
    half4 dC = divergence.sample(s, (float2(gridPosition) + float2(0.5)) / frame);
    
    half4 newValue = (sL + sR + sT + sB + half(alpha) * dC) * half(inverseBeta);
    
    target.write(newValue, gridPosition);
}
