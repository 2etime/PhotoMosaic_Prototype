import Foundation

class Settings {
    /// REPLACE THIS PATH WITH YOUR PATH TO ADD / USE IMAGES
    static var PATH_TO_MOSAIC_IMAGES = "/Users/ricktwohyjr/Pictures/mosaic_images"
    
    static var TotalNodesCompleted: Double = 0
    static var CellsWide: Int = 40
    static var CellsHigh: Int = 40
    
    static var FileKeyword: String = "macaw"
    static var MainImageUrl: String = ""
    static var MainImagePath: String = ""
    
    static func FileURL(keyword: String)->URL {
        let fileURL = URL(fileURLWithPath: PATH_TO_MOSAIC_IMAGES).appendingPathComponent(keyword)
        return fileURL
    }
}
