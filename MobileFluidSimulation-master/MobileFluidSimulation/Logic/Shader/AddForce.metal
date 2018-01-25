//
//  AddForce.metal
//  MobileFluidSimulation
//
//  Created by Masaki Haga on 2017/10/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct TouchEvent {
    float2 delta;
    float2 center;
};

kernel void addForce(texture2d<half, access::sample> source [[texture(0)]],
                     texture2d<half, access::write> target [[texture(1)]],
                     uint2 gridPosition [[thread_position_in_grid]],
                     constant TouchEvent *touchEvent [[buffer(0)]],
                     constant int &numberOfTouches [[buffer(1)]],
                     constant float &radius [[buffer(2)]])
{
    float2 frame = float2(source.get_width(), source.get_height());
    
    constexpr sampler s(coord::normalized,
                        address::repeat,
                        filter::linear);
    
    half4 sumOfChanges = half4(0.0);
    for (int i = 0; i<numberOfTouches; i++) {
        float dx = touchEvent[i].center.x - gridPosition.x;
        float dy = touchEvent[i].center.y - gridPosition.y;
        half2 change = half2(touchEvent[i].delta * exp(-(dx * dx + dy * dy) / radius));
        sumOfChanges += half4(change, 0, 0);
    }
    
    half4 sampled = source.sample(s, (float2(gridPosition) + float2(0.5)) / frame);
    
    target.write(sampled + sumOfChanges, gridPosition);
}
