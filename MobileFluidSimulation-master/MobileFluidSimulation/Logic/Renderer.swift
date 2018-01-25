import Foundation
import MetalKit
import Accelerate

class Renderer: NSObject {
    struct TouchEvent {
        let point: CGPoint
        let delta: CGPoint
    }
    
    static let maxInflightBuffers = 1
    
    weak var view: MTKView?
    weak var device: MTLDevice?
    var library: MTLLibrary
    var commandQueue: MTLCommandQueue
    
    private var inflightSemaphore = DispatchSemaphore(value: Renderer.maxInflightBuffers)
    
    private var textureQueue = [MTLTexture]()
    var currentStateTexture: MTLTexture?
    
    private var visualizer: Visualizer?
    private var simulator: Simulator?
    
    private var gridSize: MTLSize = MTLSize()
    
    private let startDate: Date = Date()
    private var nextResizeTimestamp = Date()
    
    var touchEvents: [TouchEvent]?
    
    init?(with view: MTKView) {
        self.view = view
        
        self.device = MTLCreateSystemDefaultDevice()
        self.view?.device = self.device
        
        guard let device = self.device else {
            print("Failed to create device")
            return nil
        }
        
        guard let library = device.makeDefaultLibrary() else {
            print("Failed to create Library")
            return nil
        }
        self.library = library
        
        guard let commandQueue = device.makeCommandQueue() else {
            print("Failed to create command queue")
            return nil
        }
        self.commandQueue = commandQueue
        
        visualizer = Visualizer(view: view, device: device, library: library)
        simulator = Simulator(device: device, library: library, width: Int(view.drawableSize.width), height: Int(view.drawableSize.height))
        
        super.init()
        
        view.delegate = self
        reshape(with: view.drawableSize)
    }
    
    func reset() {
        simulator?.initializeFluid(with: gridSize.width, height: gridSize.height)
    }
    
    private func reshape(with drawableSize: CGSize) {
        guard let scale = view?.layer.contentsScale else {
            return
        }
        let propsedGridSize = MTLSize(width: Int(drawableSize.width / scale),
                                      height: Int(drawableSize.height / scale),
                                      depth: 1)
        if gridSize.width != propsedGridSize.width || gridSize.height != propsedGridSize.height {
            gridSize = propsedGridSize
            buildComputeResources()
        }
    }
    
    private func buildComputeResources() {
        if let fluid = simulator?.fluid, (fluid.width != gridSize.width || fluid.height != gridSize.height) {
            reset()
        }
    }
}

extension Renderer: MTKViewDelegate {
    static let resizeHysteresis: TimeInterval = 0.2
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        nextResizeTimestamp = Date(timeIntervalSinceNow: type(of: self).resizeHysteresis)
        
        let dispatchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            guard let gridSize = self.view?.drawableSize else {
                return
            }
            if self.nextResizeTimestamp.timeIntervalSinceNow <= 0 {
                self.reshape(with: gridSize)
            }
        }
    }
    
    func draw(in view: MTKView) {
        _ = inflightSemaphore.wait(timeout: .distantFuture)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.addCompletedHandler { _ in
            _ = self.inflightSemaphore.signal()
        }

        simulator?.encode(in: commandBuffer, touchEvents: touchEvents)
        if let texture = simulator?.currentTexture {
            visualizer?.encode(texture: texture, in: commandBuffer)
        }
        
        commandBuffer.commit()
    }
}
