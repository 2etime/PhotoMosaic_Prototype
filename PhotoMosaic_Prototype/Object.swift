import MetalKit

class Object: Node {
    
    private var _modelConstants = ModelConstants()
    private var _mesh: Mesh!
    var renderPipelineStateType: RenderPipelineStateTypes { return .Basic }
    var texture: MTLTexture!
    
    init(mesh: Mesh) {
        super.init()
        
        self._mesh = mesh
    }
    
    override func update() {
        self._modelConstants.modelMatrix = self.modelMatrix
        super.update()
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStates.Get(renderPipelineStateType))
        
        renderCommandEncoder.setVertexBytes(&_modelConstants,
                                            length: ModelConstants.stride,
                                            index: VertexBufferIndexes.ModelConstants.rawValue)
        
        renderCommandEncoder.setFragmentSamplerState(SamplerStates.get(.Less), index: 0)
        
        if(texture != nil) {
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
        }
        
        _mesh.drawPrimitives(renderCommandEncoder)
        
        super.render(renderCommandEncoder)
    }
    
}

extension Object {
    func setTexture(_ texture: MTLTexture) { self.texture = texture }
}
