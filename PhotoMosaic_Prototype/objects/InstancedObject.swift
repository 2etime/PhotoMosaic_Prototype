import MetalKit

class InstancedObject: Node {
    private var _modelConstants: [ModelConstants] = []
    private var _modelConstantBuffer:MTLBuffer!
    private var _mesh: Mesh!
    var renderPipelineStateType: RenderPipelineStateTypes! { return nil }
    
    init(mesh: Mesh, instanceCount: Int) {
        super.init()
        
        _mesh = mesh
        
        buildObject(instanceCount)
    }
    
    private func buildObject(_ instanceCount: Int) {
        _mesh.setInstanceCount(instanceCount)
        
        for _ in 0..<instanceCount {
            addChild(Node())
        }
        
        _modelConstantBuffer = Engine.Device.makeBuffer(length: ModelConstants.stride(instanceCount), options: [])
    }
    
    override func update() {
        var pointer = _modelConstantBuffer.contents().bindMemory(to: ModelConstants.self, capacity: children.count)
        for node in children {
            if let mosaicCell = node as? MosaicCell {
                pointer.pointee.slice = Int32(mosaicCell.slice)
                pointer.pointee.averageColor = mosaicCell.averageColor
            }
            pointer.pointee.modelMatrix = matrix_multiply(self.modelMatrix, node.modelMatrix)
            pointer = pointer.advanced(by: 1)
        }
        super.update()
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setRenderPipelineState(RenderPipelineStates.Get(renderPipelineStateType))
        renderCommandEncoder.setDepthStencilState(DepthStencilStates.Get(.Less))
        
        renderCommandEncoder.setVertexBuffer(_modelConstantBuffer,
                                             offset: 0,
                                             index: VertexBufferIndexes.ModelConstants.rawValue)

        
        _mesh.drawPrimitives(renderCommandEncoder)
        
        super.render(renderCommandEncoder)
    }
    
}
