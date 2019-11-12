import MetalKit

class MosaicCell: Node {
    var slice: Int = -1
    var averageColor: float4 = float4(0,0,0,0)
}

class Mosaic: Node {
    var mainTexture: Texture!
    var useAverage: Bool = false
    var currentMosaicGroup: MosaicGroup!
    func createMosaicGroup(cellsWide: Int, cellsHigh: Int) {
        children = []
        self.mainTexture = Textures.Get("MainImage")
        addMosaicGroup(cellsWide: cellsWide, cellsHigh: cellsHigh, offsetX: 0, offsetY: 0, backingTexture: mainTexture)
    }
    
    private func addMosaicGroup(cellsWide: Int, cellsHigh: Int, offsetX: Float, offsetY: Float, backingTexture: Texture) {
        let queue = DispatchQueue(label: "queue", attributes: .concurrent)
        queue.async {
            self.currentMosaicGroup = MosaicGroup(cellsWide: cellsWide, cellsHigh: cellsHigh, backingTexture: backingTexture, useAverage: self.useAverage)
            self.currentMosaicGroup.moveX(offsetX)
            self.currentMosaicGroup.moveY(offsetY)
            self.addChild(self.currentMosaicGroup)
        }
    }
    
}

class MosaicGroup: InstancedObject {
    override var renderPipelineStateType: RenderPipelineStateTypes! { return .MosaicInstanced }
    var backingTexture: Texture!
    
    var mosaicTextures: TextureArray!
    private var _cellsWide: Int = 0
    private var _cellsHigh: Int = 0
    var useAverage: Bool = false
    var totalCellCount: Int { return _cellsHigh * _cellsWide}
    var queue = DispatchQueue(label: "Mosaic Group", attributes: .concurrent)
    init(cellsWide: Int, cellsHigh: Int, backingTexture: Texture, useAverage: Bool) {
        super.init(mesh: QuadMesh(), instanceCount: cellsHigh * cellsWide)
        self._cellsWide = cellsWide
        self._cellsHigh = cellsHigh
        self.useAverage = useAverage
        
        self.backingTexture = backingTexture
        
        queue.async {
            self.buildMosaicTiles()
        }
        
        queue.async {
            self.buildTextureArray()
        }
    }
    
    func buildMosaicTiles() {
        var index: Int = 0
        for row in (0..<_cellsHigh).reversed() { // flip the y axis
            for column in 0..<_cellsWide {
                let cell = MosaicCell()
                children[index] = cell
                cell.setPosition(float3(Float(column), Float(row), 0))
                index += 1
            }
        }
    }
    
    private var cellTextures:[String:Int] = [:]
    private var currentSlice: Int = 0
    private func setCellPartialPhoto(column: Int, row: Int) {
        let index: Int = _cellsWide * row + column
        let divWidth = backingTexture.pixelsWide / _cellsWide
        let divHeight = backingTexture.pixelsHigh / _cellsHigh
        
        let tex = backingTexture.grabCroppedTexture(x: column * divWidth,
                                                    y: row * divHeight,
                                                    width: divWidth,
                                                    height: divHeight)
        
        let croppedTexId = Textures.getMatchingTextureId(texture: tex)
        
        let cell = children[index] as? MosaicCell
        
        if(cellTextures[croppedTexId] != nil) {
            cell?.slice = cellTextures[croppedTexId]!
        }else{
            cellTextures.updateValue(currentSlice, forKey: croppedTexId)
            cell?.slice = cellTextures[croppedTexId]!
            currentSlice += 1
        }
        
        cell?.averageColor = tex.averageColor

        let croppedTex = Textures.Get(croppedTexId)
        let id =  Int32(cellTextures[croppedTexId]!)
        mosaicTextures.setSlice(slice: id, tex: croppedTex.mtlTexture)
    }
    
    func buildTextureArray() {
        mosaicTextures = TextureArray(arrayLength: 2046)
        for row in 0..<_cellsHigh {
            for column in 0..<_cellsWide {
                Settings.TotalNodesCompleted += 1
                setCellPartialPhoto(column: column, row: row)
            }
        }
    }
    
    override func doUpdate() {
//        for (i, child) in children.enumerated() {
////            child.rotateY(GameTime.DeltaTime * (Float(i) / Float(totalCellCount)))
//            child.rotateZ(GameTime.DeltaTime * (Float(i) / Float(totalCellCount)))
//        }
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setFragmentSamplerState(SamplerStates.get(.Less), index: 0)

        renderCommandEncoder.setFragmentTexture(mosaicTextures.texture, index: 0)
        renderCommandEncoder.setFragmentBytes(&useAverage, length: Bool.size, index: 1)
        super.render(renderCommandEncoder)
    }
    
}
