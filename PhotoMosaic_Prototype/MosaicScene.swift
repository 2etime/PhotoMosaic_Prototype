import MetalKit

class MosaicScene: Scene {
    var mosaic: Mosaic!
    override func buildScene() {

    }
    
    func useAverage(isOn: Bool) {
        self.mosaic.useAverage = isOn
    }

    func updateMosaic() {
        camera.setPositionX(Float(Settings.CellsWide) / 2)
        camera.setPositionY(Float(Settings.CellsHigh) / 2 - 0.5)
        camera.setPositionZ(Float(Settings.CellsHigh) / 2 + 1)
        
        if(mosaic == nil) {
            mosaic = Mosaic()
            mosaic.createMosaicGroup(cellsWide: Settings.CellsWide, cellsHigh: Settings.CellsHigh)
            addChild(mosaic)
        }else{
            mosaic.createMosaicGroup(cellsWide: Settings.CellsWide, cellsHigh: Settings.CellsHigh)
        }
    }
    
    override func doUpdate() {
        if(Mouse.IsMouseButtonPressed(button: .left)) {
            camera.moveX(Mouse.GetDX() * 0.5 * -(camera.getPositionZ() / Float(Settings.CellsHigh)))
            camera.moveY(Mouse.GetDY() * 0.5 * (camera.getPositionZ() / Float(Settings.CellsHigh)))
        }
        
        let zoom = -Mouse.GetDWheel() * 0.3
        if(camera.getPositionZ() + zoom >= 0.5) {
            camera.moveZ(zoom)
        }
    }
}
