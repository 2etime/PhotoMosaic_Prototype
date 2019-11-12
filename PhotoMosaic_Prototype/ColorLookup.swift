import MetalKit
import KDTree

class TextureData {
    var textureId: String!
    var averageColor: float4!
    
    init(cellId: String, averageColor: float4) {
        self.textureId = cellId
        self.averageColor = averageColor
    }
}

extension TextureData: KDTreePoint {
    public static var dimensions: Int { return 4 }
    
    public func kdDimension(_ dimension: Int) -> Double {
        if(dimension == 0) {
            return Double(self.averageColor.x)
        }else if(dimension == 1) {
            return Double(self.averageColor.y)
        }else if(dimension == 2) {
            return Double(self.averageColor.z)
        }else{
            return Double(self.averageColor.w)
        }
    }
    
    func squaredDistance(to otherPoint: TextureData) -> Double {
        let x = self.averageColor.x - otherPoint.averageColor.x
        let y = self.averageColor.y - otherPoint.averageColor.y
        let z = self.averageColor.z - otherPoint.averageColor.z
        let w = self.averageColor.w - otherPoint.averageColor.w
        return Double(x*x + y*y + z*z + w*w)
    }
    
    static func == (lhs: TextureData, rhs: TextureData) -> Bool {
        return lhs.averageColor == rhs.averageColor
    }
}

class ColorLookup {
    var colorLookupTree: KDTree<TextureData>!
    
    init(textureDatas: [TextureData]) {
        colorLookupTree = KDTree(values: textureDatas)
    }
    
    func getNearestTextureData(_ textureData: TextureData)->TextureData {
        let nearest = colorLookupTree.nearest(to: textureData)!
        return nearest
    }
}
