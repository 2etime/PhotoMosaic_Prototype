import MetalKit

class Handler: NSObject {
    var scene: MosaicScene!
    var photoLibraryApi = PhotoLibraryApi()
    
    init(_ view: MTKView) {
        super.init()
        
        updateScreenSize(view: view)
        
        scene = MosaicScene()
    }
    
    func resetMosaic() {
        scene.updateMosaic()
    }
    
    func setAverage(isOn: Bool) {
        self.scene.useAverage(isOn: isOn)
    }
    
    func getPhotos(keyword: String) {
        let photos = photoLibraryApi.getPhotoDatas(keyword: keyword)
        photoLibraryApi.downloadImage(keyword: keyword, photoDatas: photos)
    }
}

extension Handler: MTKViewDelegate {
    public func updateScreenSize(view: MTKView){
        MainView.ScreenSize = float2(Float(view.bounds.width), Float(view.bounds.height))
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = Engine.CommandQueue.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        
        GameTime.UpdateTime(1 / Float(view.preferredFramesPerSecond))
        
        scene.update()
        
        scene.render(renderCommandEncoder!)
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
    
    
}
