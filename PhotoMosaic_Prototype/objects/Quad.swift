import MetalKit

class Quad: Object {
    
    init(textureName: String) {
        super.init(mesh: QuadMesh())
        
        setTexture(Textures.Get(textureName).mtlTexture)
    }
    
}
