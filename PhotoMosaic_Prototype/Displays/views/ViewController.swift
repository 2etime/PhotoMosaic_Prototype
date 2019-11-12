import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var imgMainImage: NSImageCell!
    @IBOutlet weak var mosaicProgressBar: NSProgressIndicator!
    @IBOutlet weak var lblCurrentCompleted: NSTextField!
    @IBOutlet weak var lblOutOfCompleted: NSTextField!
    @IBOutlet weak var txtCellsWide: NSTextField!
    @IBOutlet weak var txtCellsHigh: NSTextField!
    @IBOutlet weak var txtTotalLoadTime: NSTextField!
    @IBOutlet weak var btnGenerateMosaic: NSButton!
    @IBOutlet weak var tblPhotoLibrary: NSOutlineView!
    @IBOutlet weak var txtPhotoLibraryText: NSTextField!
    
    var photoLibraries = [PhotoLibrary]()
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        loadImageLibraries()
    }
    
    private func loadImageLibraries() {
        photoLibraries = []
//        let path = try! FileManager.default.url(for: .documentDirectory,
//                                                   in: .userDomainMask,
//                                                   appropriateFor: nil,
//                                                   create: true).appendingPathComponent("mosaic_images")
//        let fm = FileManager.default
//        do {
//            let items = try fm.contentsOfDirectory(atPath: path.path)
//            for libraryItem in items {
//                let imagePath = path.appendingPathComponent(libraryItem)
//                let imageItems = try fm.contentsOfDirectory(atPath: imagePath.path)
//                
//                let photoLibrary = PhotoLibrary(libraryName: libraryItem, photoCount: imageItems.count)
//                photoLibraries.append(photoLibrary)
//            }
//        }catch {
//            print(error)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tblPhotoLibrary.dataSource = self
//        tblPhotoLibrary.delegate = self
//        
//        let total = String(Settings.CellsHigh * Settings.CellsWide)
//        lblOutOfCompleted.stringValue = total
//        
//        txtCellsWide.stringValue = String(Settings.CellsWide)
//        txtCellsHigh.stringValue = String(Settings.CellsHigh)
    }
    
    @IBAction func btnGenerateMosaic(_ sender: NSButton) {
        Settings.TotalNodesCompleted = 0
        
        Settings.CellsWide = Int(txtCellsWide.stringValue)!
        Settings.CellsHigh = Int(txtCellsHigh.stringValue)!
        
        let total = String(Settings.CellsHigh * Settings.CellsWide)
        lblOutOfCompleted.stringValue = total
        
        runProgressBarStartup()
        MainView.handler.resetMosaic()
    }
    
    @IBAction func btnSelectMainImage(_ sender: NSButton) {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a .png file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["png", "jpg"]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                let image = NSImage(byReferencing: result!)
                Textures.SetMainImage(nsImage: image)
                imgMainImage.image = image
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func btnUpdatePhotoLibrary(_ sender: NSButton) {
        let value = txtPhotoLibraryText.stringValue
        sender.isEnabled = false
        
        DispatchQueue.global(qos: .default).async {
            MainView.handler.getPhotos(keyword: value)
            
            DispatchQueue.main.async {
                self.loadImageLibraries()
                self.tblPhotoLibrary.reloadData()
                sender.isEnabled = true
            }
        }
    }
    
    func runProgressBarStartup() {
        let currentTime = CACurrentMediaTime()
        btnGenerateMosaic.isEnabled = false
        let val: Double = Double(Settings.CellsWide * Settings.CellsHigh) / 100.0
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async(execute: {
                    let total = Settings.TotalNodesCompleted / val
                    let totalString = String(Int(Settings.TotalNodesCompleted))
                    self.mosaicProgressBar.doubleValue = total
                    self.lblCurrentCompleted.stringValue = totalString
                    let newTime = CACurrentMediaTime()
                    self.txtTotalLoadTime.stringValue = String(format: "%g", floor((newTime - currentTime) * 10) / 10) + " secs"
                    if self.mosaicProgressBar.doubleValue >= 100.0 {
                        self.btnGenerateMosaic.isEnabled = true
                        timer.invalidate()
                    }
                })
            }
        })
    }
    
    @IBAction func toggleUseAverage(_ sender: NSButton) {
        MainView.handler.setAverage(isOn: Bool(sender.state == .on ? true : false))
    }
}

extension ViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let photoLibrary = item as? PhotoLibrary {
            return photoLibrary.libraryName
        }
        return photoLibraries[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return photoLibraries.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var text = ""
        var key = ""
        if let photoLibrary = item as? PhotoLibrary {
            text = photoLibrary.libraryName
            key = photoLibrary.keyword
        } else {
            text = item as! String
        }
        
        let tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "photoLibraryCell"),
                                             owner: self) as! NSTableCellView
        
        if(Settings.FileKeyword == key) {
            let index = photoLibraries.firstIndex { (item) -> Bool in
                return item.keyword == key
            }!
            tblPhotoLibrary.selectRowIndexes([index], byExtendingSelection: true)
        }
        tableCell.textField!.stringValue = text
        return tableCell
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let selectedItem = tblPhotoLibrary.item(atRow: tblPhotoLibrary.selectedRow) as? PhotoLibrary {
            txtPhotoLibraryText.stringValue = selectedItem.keyword
            Settings.FileKeyword = selectedItem.keyword
            Textures.LoadMosaicLibrary()
        }
    }
}
