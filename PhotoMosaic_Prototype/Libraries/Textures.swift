import MetalKit
import MetalPerformanceShaders

class Textures {
    private static var _colorLookup: ColorLookup!
    private static var _library: [String: Texture] = [:]
    public static func Initialize() {
        _library.updateValue(createTextureFromBundle(imageName: "sample_image", ext: ".png"), forKey: "MainImage")
    }
    
    static func SetMainImage(nsImage: NSImage) {
        let cgImage = nsImage.CGImage
        let texture = Texture(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
        _library.updateValue(texture, forKey: "MainImage")
    }
    
    static func LoadMosaicLibrary() {
        let path = Settings.FileURL(keyword: Settings.FileKeyword)

        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(atPath: path.path)
            var textureDatas: [TextureData] = []
            for filename in items {
                if(filename != ".DS_Store") {
                    let textureData = addTexture(filename: filename, filepath: path.path)
                    textureDatas.append(textureData)
                }
            }
            _colorLookup = ColorLookup(textureDatas: textureDatas)
        } catch {
            print(error)
        }
    }
    
    private static func createTextureFromBundle(imageName: String, ext: String)->Texture {
        let url = Bundle.main.url(forResource: imageName, withExtension: ext)
        let image = NSImage(byReferencing: url!)
        let cgImage = image.CGImage
        return Texture(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
    }
    
    static func getMatchingTextureId(texture: Texture)->String {
        let average = texture.averageColor
        let nearest = _colorLookup.getNearestTextureData(TextureData(cellId: "Don't Matter",
                                                                     averageColor: average))
        return nearest.textureId
    }
    
    static func Add(_ path: String) {
        
    }
    
    static func Get(_ key: String)->Texture {
        return self._library[key]!
    }
    
    static func addTexture(filename: String, filepath: String)->TextureData {
        let fileTitle = filename.matches(for: "[ \\w-]+?(?=\\.)").first!
        let ext = filename.matches(for: "((?<=\\.)[^.]*$)").first!
        let texture = Texture(filepath: filepath + "/" + filename,
                              textureName: fileTitle,
                              ext: ext)
        _library.updateValue(texture,
                             forKey: fileTitle)
        
        return TextureData(cellId: fileTitle, averageColor: texture.averageColor)
    }
}

class Texture {
    var title: String = ""
    var mtlTexture: MTLTexture!
    var cgImage: CGImage!
    var averageColor = float4(0,0,0,0)
    var pixelsWide: Int { return cgImage.width }
    var pixelsHigh: Int { return cgImage.height }
    
    init(cgImage: CGImage, width: Int, height: Int) {
        let texture: MTLTexture = TextureLoader.LoadTexture(cgImage: cgImage)
        self.mtlTexture = texture
        self.cgImage = cgImage
        self.averageColor = getAverageColor()
    }
    
    init(_ textureName: String, ext: String = "png", origin: MTKTextureLoader.Origin = .topLeft){
        let texture: MTLTexture = TextureLoader.LoadTexture(textureName: textureName,
                                                            textureExtension: ext,
                                                            origin: origin)
        self.mtlTexture = texture
        self.setCgImageFromBundle(imagePath: textureName, ext: ext)
        self.averageColor = getAverageColor()
    }
    
    init(filepath: String, textureName: String, ext: String = "png", origin: MTKTextureLoader.Origin = .topLeft){
        let texture: MTLTexture = TextureLoader.LoadTexture(filepath: filepath)
        mtlTexture = texture
        setCgImageFromFilepath(imagePath: filepath, ext: ext)
        averageColor = getAverageColor()
    }
    
    func grabCroppedTexture(x: Int, y: Int, width: Int, height: Int)->Texture {
        let crop = NSRect(x: x,
                          y: y,
                          width: width,
                          height: height)
        
        let croppedCgImage = cgImage.cropping(to: crop)!
        
        return Texture(cgImage: croppedCgImage, width: width, height: height)
    }

    private func getAverageColor()->float4 {
        let bmp = NSBitmapImageRep(cgImage: cgImage)
        
        let width: Int = bmp.pixelsWide
        let height: Int = bmp.pixelsHigh
        var colorSum = float4(0,0,0,1)
        
        let colorSampleCount: Int = 100
        
        for _ in 0..<colorSampleCount {
            let x: Int = Int.random(in: 0..<width)
            let y: Int = Int.random(in: 0..<height)
            let color = bmp.colorAt(x: x, y: y)!
            colorSum += float4(Float(color.redComponent),
                               Float(color.greenComponent),
                               Float(color.blueComponent),
                               Float(color.alphaComponent))
        }
        return colorSum / Float(colorSampleCount)
    }
    
    private func setCgImageFromBundle(imagePath: String, ext: String) {
        let url = Bundle.main.url(forResource: imagePath, withExtension: ext)
        let image = NSImage(byReferencing: url!)
        self.cgImage = image.CGImage
    }
    
    private func setCgImageFromFilepath(imagePath: String, ext: String) {
        let url = URL(fileURLWithPath: imagePath)
        let image = NSImage(byReferencing: url)
        self.cgImage = image.CGImage
    }
}

class TextureLoader {
    public static func LoadTexture(cgImage: CGImage)->MTLTexture {
        var result: MTLTexture!
        let textureLoader = MTKTextureLoader(device: Engine.Device)
        do{
            result = try textureLoader.newTexture(cgImage: cgImage, options: [MTKTextureLoader.Option.generateMipmaps: true])
        } catch {
            print(error)
        }
        return result
    }
    
    public static func LoadTexture(filepath: String, origin: MTKTextureLoader.Origin = .topLeft)->MTLTexture {
        var result: MTLTexture!
        if FileManager.default.fileExists(atPath: filepath) {
            let url = URL(fileURLWithPath: filepath)
            let textureLoader = MTKTextureLoader(device: Engine.Device)
            let options: [MTKTextureLoader.Option : MTKTextureLoader.Origin] = [MTKTextureLoader.Option.origin : origin]
            do{
                result = try textureLoader.newTexture(URL: url, options: options)
                result.label = filepath
            }catch let error as NSError {
                print("ERROR::CREATING::TEXTURE::__\(filepath)__::\(error)")
            }
        }else {
            print("ERROR::CREATING::TEXTURE::__\(filepath) does not exist")
        }

        return result
    }
    
    public static func LoadTexture(textureName: String,
                            textureExtension: String = "png",
                            origin: MTKTextureLoader.Origin = .topLeft)->MTLTexture{
        var result: MTLTexture!
        if let url = Bundle.main.url(forResource: textureName, withExtension: textureExtension) {
            let textureLoader = MTKTextureLoader(device: Engine.Device)
            
            let options: [MTKTextureLoader.Option : MTKTextureLoader.Origin] = [MTKTextureLoader.Option.origin : origin]
            
            do{
                result = try textureLoader.newTexture(URL: url, options: options)
                result.label = textureName
            }catch let error as NSError {
                print("ERROR::CREATING::TEXTURE::__\(textureName)__::\(error)")
            }
        }else {
            print("ERROR::CREATING::TEXTURE::__\(textureName) does not exist")
        }
        
        return result
    }
}


