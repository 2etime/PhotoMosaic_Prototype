import Cocoa

class PhotoLibrary {
    var keyword: String
    var libraryName: String
    
    init(libraryName: String, photoCount: Int) {
        self.keyword = libraryName
        self.libraryName = libraryName + "   ( \(photoCount) photos )"
    }
}
