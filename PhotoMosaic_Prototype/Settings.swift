import Foundation

class Settings {
    static var TotalNodesCompleted: Double = 0
    static var CellsWide: Int = 30
    static var CellsHigh: Int = 30
    
    static var FileKeyword: String = "macaw"
    static var MainImageUrl: String = ""
    static var MainImagePath: String = ""
    
    static func FileURL(keyword: String)->URL {
        let fileURL = URL(fileURLWithPath: "")
        return fileURL
    }
}
