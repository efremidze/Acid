# MobileFluidSimulation
Fluid Simulation with Metal

<p align="center">
  <img src="https://github.com/hagmas/MobileFluidSimulation/blob/master/Images/Fluid.gif" alt="Fluid Simulation with Metal"/>
</p>

# About MobileFluidSimulation
  MobileFluidSimulation is a metal implementation of [Fast Fluid Dynamics Simualtion on the GPU](http://developer.download.nvidia.com/books/HTML/gpugems/gpugems_ch38.html). In the simualtion part, the velocity field of the fluid is calculated using Navier-Stokes Equations which is implemented using metal kernel functions and it advects the color field. The color field is visualized on `MTKView` by a normal rendering pipeline.
  
# How to play
1. Donwload & build the project.
2. Run the application on actual devices. The example application doesn't work on Simulator since Metal is not available on Simulator.
3. Drag the view with multiple fingers or double tap to reset the view.
