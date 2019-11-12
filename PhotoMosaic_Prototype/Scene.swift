import MetalKit

class Scene: Node {
    
    var camera = Camera()
    
    private var _sceneConstants = SceneConstants()
    var queue = DispatchQueue(label: "scene_queue", attributes: .concurrent)
    override init() {
        super.init()
        
        queue.async {
            self.buildScene()            
        }
    }
    
    func buildScene() { }
    
    override func update() {
        _sceneConstants.viewMatrix = camera.viewMatrix
        _sceneConstants.projectionMatrix = camera.projectionMatrix
        super.update()
    }
    
    override func setRenderPipelineValues(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBytes(&_sceneConstants,
                                            length: SceneConstants.stride,
                                            index: VertexBufferIndexes.SceneConstants.rawValue)
    }
    
}
