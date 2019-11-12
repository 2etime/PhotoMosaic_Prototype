import MetalKit

class MainView: MTKView {
    public static var ScreenSize = float2(0,0)
    public static var AspectRatio: Float { return ScreenSize.x / ScreenSize.y }

    static var handler: Handler!
    private let queue = DispatchQueue(label: "queue", attributes: .concurrent)
    private let group = DispatchGroup()
    @IBOutlet weak var txtKeyword: NSTextField!
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()
        
        Engine.Ignite(device!)
        
        clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        colorPixelFormat = .bgra8Unorm_srgb
        
        depthStencilPixelFormat = .depth32Float_stencil8
        
        RenderPipelineStates.Initialize()
        
        DepthStencilStates.Initialize()
        
        SamplerStates.Initialize()
        
        Textures.Initialize()
        
        MainView.handler = Handler(self)
        
        delegate = MainView.handler
    }

    @IBAction func btnSearchKeyword(_ sender: NSButton) {
        let value = txtKeyword.stringValue
        sender.isEnabled = false
     
        DispatchQueue.global(qos: .utility).async {
            _ = MainView.handler.getPhotos(keyword: value)
            Settings.FileKeyword = value
            Textures.LoadMosaicLibrary()
            MainView.handler.resetMosaic()
            
            DispatchQueue.main.async {
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func btnUseLibrary(_ sender: NSButton) {
        let value = txtKeyword.stringValue
        sender.isEnabled = false

        DispatchQueue.global(qos: .utility).async {
            Settings.FileKeyword = value
            Textures.LoadMosaicLibrary()
            MainView.handler.resetMosaic()

            DispatchQueue.main.async {
                sender.isEnabled = true
            }
        }
    }
    
    
}


//--- Keyboard Input ---
extension MainView {
    override var acceptsFirstResponder: Bool { return true }
    
    override func keyDown(with event: NSEvent) {
        Keyboard.SetKeyPressed(event.keyCode, isOn: true)
    }
    
    override func keyUp(with event: NSEvent) {
        Keyboard.SetKeyPressed(event.keyCode, isOn: false)
    }
}

//--- Mouse Button Input ---
extension MainView {
    override func mouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    override func mouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    override func otherMouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
}

// --- Mouse Movement ---
extension MainView {
    override func mouseMoved(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        Mouse.ScrollMouse(deltaY: Float(event.deltaY))
    }
    
    override func mouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func otherMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    private func setMousePositionChanged(event: NSEvent){
        let overallLocation = float2(Float(event.locationInWindow.x),
                                     Float(event.locationInWindow.y))
        let deltaChange = float2(Float(event.deltaX),
                                 Float(event.deltaY))
        Mouse.SetMousePositionChange(overallPosition: overallLocation,
                                     deltaPosition: deltaChange)
    }
    
    override func updateTrackingAreas() {
        let area = NSTrackingArea(rect: self.bounds,
                                  options: [NSTrackingArea.Options.activeAlways,
                                            NSTrackingArea.Options.mouseMoved,
                                            NSTrackingArea.Options.enabledDuringMouseDrag],
                                  owner: self,
                                  userInfo: nil)
        self.addTrackingArea(area)
    }
}

