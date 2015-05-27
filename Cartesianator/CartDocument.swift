//
//  Document.swift
//  Cartesianator
//
//  Created by Lee Walsh on 19/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

class CartDocument: NSDocument {
    var data = CartData()
    @IBOutlet var scrollView: NSScrollView?
    var imageView = LBImageView(frame: NSRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
    var currentImage = 0
    @IBOutlet var fileNameField: NSTextField?
    var setCalibrationPointSheetController: SetCalibrationPointSheetController?
    var calibrationValue: LBPoint?
    var calibrateAxisSheetController: CalibrateAxisSheetController?
    var firstCalibrationPair: LBCalibratedPair?
    var secondCalibrationPair: LBCalibratedPair?

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
        scrollView!.documentView = imageView
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let result = openPanel.runModal()
        if result == NSModalResponseOK {
            data.imageDirectoryURL = openPanel.URL!
            let urlArray = data.arrayOfImageFileNames()
            if urlArray != nil {
                data.willChangeValueForKey("imageURLCount")
                data.imageURLArray = urlArray!
                data.didChangeValueForKey("imageURLCount")
            }
        }
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "CartDocument"
    }

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return NSKeyedArchiver.archivedDataWithRootObject(data)
    }

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        
        let newData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)    //testData)
        if let testData = newData as? CartData {
            self.data = newData! as! CartData
            return true
        }
        
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return false
    }
    
    @IBAction func advanceImage(sender: AnyObject){
        if data.imageURLArray.count > 0 {
            if data.imageURLArray.count > currentImage {
                self.willChangeValueForKey("currentImage")
                currentImage++
                self.didChangeValueForKey("currentImage")
                imageView.image = NSImage(byReferencingURL:data.imageURLArray[currentImage-1])
                imageView.needsDisplay = true
                fileNameField!.stringValue = data.imageURLArray[currentImage-1].lastPathComponent!
            } else {
                imageView.image = nil
                imageView.needsDisplay = true
            }
        }
    }
    
    @IBAction func loadImage(sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["png","PNG","tif","tiff","TIF","TIFF","jpg","JPG","jpeg","JPEG"]
        let result = openPanel.runModal()
        if result == NSModalResponseOK {
            imageView.image = NSImage(byReferencingURL:openPanel.URL!)
            imageView.needsDisplay = true
            fileNameField!.stringValue = openPanel.URL!.lastPathComponent!
            
        }
    }
    
    @IBAction func resetCalibration(sender: AnyObject){
        data.calibrationPoints.removeAll(keepCapacity: false)
        data.xCalCoeffs = [0.0,1.0]
        data.yCalCoeffs = [0.0,1.0]
    }
    
    @IBAction func setCalibrationPoint(sender: AnyObject){
        let markerLocation = imageView.markerLocation
        if markerLocation.x >= 0 && markerLocation.y >= 0 {
            showSetCalibrationPointSheet(windowControllers[0].window as! NSWindow)
        } else {
            let alert = NSAlert()
            alert.messageText = "Set a marker first"
            alert.addButtonWithTitle("Gotcha")
            alert.informativeText = "You need to have a marker on the current image to use as a calibration point.  Click on the image to place a marker."
            alert.runModal()
        }
    }
    
    @IBAction func calibrate(sender: AnyObject){
        //need to select which calibrations points to use if there are more than 2
        if data.calibrationPoints.count >= 2 {
            if data.calibrationPoints.count == 2 {
                firstCalibrationPair = data.calibrationPoints[0]
                secondCalibrationPair = data.calibrationPoints[1]
                doCalibrationFor(sender as! NSButton)
            } else {
                showCalibrateAxisSheet(windowControllers[0].window as! NSWindow, sender: sender as! NSButton)
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "You don't have two calibration points"
            alert.addButtonWithTitle("Sorry")
            alert.informativeText = "You two points to do a linear calibration and you don't have two points set.  Push 'Set calibration point' to add a point."
            alert.runModal()
        }
    }

    func showSetCalibrationPointSheet(window: NSWindow){
        if setCalibrationPointSheetController == nil {
            var objects: NSArray?
            setCalibrationPointSheetController = SetCalibrationPointSheetController()
            setCalibrationPointSheetController!.document = self
        }
        windowControllers[0].window.beginSheet(setCalibrationPointSheetController!.window!, completionHandler: {
            (response: NSModalResponse) -> Void in
            if response == NSModalResponseOK {
                self.data.calibrationPoints.append(LBCalibratedPair(raw: self.imageView.markerLocation, calibrated: self.calibrationValue!))
            }
        })
    }
    
    func showCalibrateAxisSheet(window: NSWindow, sender: NSButton){
        if calibrateAxisSheetController == nil {
            var objects: NSArray?
            calibrateAxisSheetController = CalibrateAxisSheetController()
            calibrateAxisSheetController!.document = self
        }
        windowControllers[0].window.beginSheet(calibrateAxisSheetController!.window!, completionHandler: {
            (response: NSModalResponse) -> Void in
            if response == NSModalResponseOK {
                self.doCalibrationFor(sender)
            }
        })
    }
    
    func doCalibrationFor(sender: NSButton){
        if sender.title == "Calibrate X Axis" {
            let gradient = (firstCalibrationPair!.calibrated.x - secondCalibrationPair!.calibrated.x) / (firstCalibrationPair!.raw.x - secondCalibrationPair!.raw.x)
            let offset = firstCalibrationPair!.calibrated.x - gradient * firstCalibrationPair!.raw.x
            data.xCalCoeffs[0] = offset
            data.xCalCoeffs[1] = gradient
//            println("m = \(gradient), C = \(offset)")
        } else {
            let gradient = (firstCalibrationPair!.calibrated.y - secondCalibrationPair!.calibrated.y) / (firstCalibrationPair!.raw.y - secondCalibrationPair!.raw.y)
            let offset = firstCalibrationPair!.calibrated.y - gradient * firstCalibrationPair!.raw.y
            data.yCalCoeffs[0] = offset
            data.yCalCoeffs[1] = gradient
//            println("m = \(gradient), C = \(offset)")
        }
    }
}

