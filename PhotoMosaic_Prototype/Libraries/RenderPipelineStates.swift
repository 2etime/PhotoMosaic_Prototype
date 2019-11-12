
import MetalKit

enum RenderPipelineStateTypes {
    case Basic
    case MosaicInstanced
}

class RenderPipelineStates {
    
    private static var _library: [RenderPipelineStateTypes: MTLRenderPipelineState] = [:]
    
    private static var VertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        // Texture Coordinate
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = float3.size
        
        vertexDescriptor.layouts[0].stride = Vertex.stride
        
        return vertexDescriptor
    }
    
    public static func Initialize() {
        generateBasicRenderPipelineState()
        generateMosaicInstancedRenderPipelineState()
    }
    
    public static func Get(_ renderPipelineStateType: RenderPipelineStateTypes)->MTLRenderPipelineState {
        return _library[renderPipelineStateType]!
    }
    
    private static func generateBasicRenderPipelineState() {
        let vertexFunction = Engine.DefaultLibrary.makeFunction(name: "vertex_shader")
        let fragmentFunction = Engine.DefaultLibrary.makeFunction(name: "fragment_shader")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        renderPipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        renderPipelineDescriptor.vertexDescriptor = VertexDescriptor
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        var renderPipelineState: MTLRenderPipelineState!
        do {
            renderPipelineState = try Engine.Device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print("ERROR::RENDERPIPELINESTATE::\(error)")
        }
        
        _library.updateValue(renderPipelineState, forKey: .Basic)
    }
    
    private static func generateMosaicInstancedRenderPipelineState() {
        let vertexFunction = Engine.DefaultLibrary.makeFunction(name: "instanced_vertex_shader")
        let fragmentFunction = Engine.DefaultLibrary.makeFunction(name: "mosaic_fragment_shader")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        renderPipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        renderPipelineDescriptor.vertexDescriptor = VertexDescriptor
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        var renderPipelineState: MTLRenderPipelineState!
        do {
            renderPipelineState = try Engine.Device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print("ERROR::RENDERPIPELINESTATE::\(error)")
        }
        
        _library.updateValue(renderPipelineState, forKey: .MosaicInstanced)
    }
}
