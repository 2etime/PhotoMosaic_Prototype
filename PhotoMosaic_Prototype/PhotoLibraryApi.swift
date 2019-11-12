import MetalKit

struct PhotoData: Codable {
    let id: String
    let urls: Urls
}

struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb, custom: String
}

class PhotoLibraryApi {
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "photo_library", attributes: .concurrent)
    
    let url = URL(string: "https://api.unsplash.com/photos/random")!
    
    let clientId = "4457f794967c81aede9c72eefd52a15800ec3fd025326d71c564fda3e7b22a2e"
    let width = "400";
    let height = "400";
    let count = "100";
    func getPhotoDatas(keyword: String)->[PhotoData] {
        group.enter()
        var photoDatas: [PhotoData] = []
        queue.async {
            var urlComponents = URLComponents(url: self.url, resolvingAgainstBaseURL: true)
            let queryItems = [
                URLQueryItem(name: "client_id", value: self.clientId),
                URLQueryItem(name: "query", value: keyword),
                URLQueryItem(name: "w", value: self.width),
                URLQueryItem(name: "h", value: self.height),
                URLQueryItem(name: "count", value: self.count)
            ]
            urlComponents?.queryItems = queryItems
            let task = URLSession.shared.dataTask(with: urlComponents!.url!) { (data, response, error) in
                if let error = error {
                    print("error: \(error)")
                } else {
//                    if let response = response as? HTTPURLResponse {
//                        print("statusCode: \(response.statusCode)")
//                    }
                    if let data = data {
                        do {
                            let responseData = String(data: data, encoding: .utf8)
                            if(responseData! == "Rate Limit Exceeded") {
                                print("Rate Limit Exceeded")
                                return
                            }
                            let decoder = JSONDecoder()
                            let photoData = try decoder.decode(Array<PhotoData>.self, from: data)
                            photoDatas.append(contentsOf: photoData)
                        } catch let err {
                            print("ERROR::\(err)")
                        }
                    }
                }
                self.group.leave()
            }
            task.resume()
        }
        _ = group.wait(timeout: .distantFuture)
        return photoDatas
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func saveImage(keyword: String, photoID: String, image: NSImage) {
        let fileURL = Settings.FileURL(keyword: keyword)

        var isDir: ObjCBool = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: fileURL.absoluteString, isDirectory: &isDir)
        if !exists && !isDir.boolValue {
            try! FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)
        }

        let destinationURL = fileURL.appendingPathComponent(photoID + ".png")
        _ =  image.pngWrite(to: destinationURL)
    }
    
    func downloadImage(keyword: String, photoDatas: [PhotoData]) {
        for photoData in photoDatas {
            let downloadUrl = URL(string: photoData.urls.custom)
            getData(from: downloadUrl!) { data, response, error in
                guard let data = data, error == nil else { return }
                let image = NSImage(data: data)
                self.saveImage(keyword: keyword, photoID: photoData.id, image: image!)
            }
        }
    }
}
    
    
    
    
    
