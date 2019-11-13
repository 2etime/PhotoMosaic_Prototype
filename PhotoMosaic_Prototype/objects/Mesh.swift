import MetalKit

class Mesh {
    private var _vertices: [Vertex] = []
    private var _vertexCount: Int { return self._vertices.count }
    
    private var _indices: [UInt32] = []
    private var _indexCount: Int { return self._indices.count }
    
    private var _instanceCount: Int = 1
    
    private var _vertexBuffer: MTLBuffer!
    private var _indexBuffer: MTLBuffer!
    
    init() {
        buildMesh()
        buildBuffers()
    }
    
    func setInstanceCount(_ count: Int) { self._instanceCount = count }
    
    func addVertex(postion: float3,
                   textureCoordinate: float2 = float2(0,0)) {
        self._vertices.append(Vertex(position: postion,
                                     textureCoordinate: textureCoordinate))
    }
    
    func setIndices(_ indices: [UInt32]) { self._indices = indices }
    
    func buildMesh() { }
    
    private func buildBuffers() {
        _vertexBuffer = Engine.Device.makeBuffer(bytes: _vertices,
                                                 length: Vertex.stride(_vertices.count),
                                                 options: [])
        
        _indexBuffer = Engine.Device.makeBuffer(bytes: _indices,
                                                length: UInt32.stride(self._indices.count),
                                                options: [])
    }
    
    func drawPrimitives(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBuffer(_vertexBuffer,
                                             offset: 0,
                                             index: VertexBufferIndexes.VertexBuffer.rawValue)
        
        renderCommandEncoder.drawIndexedPrimitives(type: .triangle,
                                                   indexCount: _indexCount,
                                                   indexType: .uint32,
                                                   indexBuffer: _indexBuffer,
                                                   indexBufferOffset: 0,
                                                   instanceCount: _instanceCount)
    }
}

class QuadMesh: Mesh {
    override func buildMesh() {
        addVertex(postion: float3( 0.5, 0.5, 0.0), textureCoordinate: float2(1,0)) // Top Right
        addVertex(postion: float3(-0.5, 0.5, 0.0), textureCoordinate: float2(0,0)) // Top Left
        addVertex(postion: float3(-0.5,-0.5, 0.0), textureCoordinate: float2(0,1)) // Bottom Left
        addVertex(postion: float3( 0.5,-0.5, 0.0), textureCoordinate: float2(1,1)) // Bottom Right
        
        setIndices([ 0, 1, 2,    0, 2, 3 ])
    }
}
