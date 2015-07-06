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
    @IBOutlet var advanceOnRecordCheckbox: NSButton?

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)

        scrollView!.documentView = imageView
        if data.newFile {
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
                    clearMeasurements()
                }
            }
            data.newFile = false
        }
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        return "CartDocument"
    }

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return NSKeyedArchiver.archivedDataWithRootObject(data)
    }

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {       
        let newData: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
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
        imageView.clearMarker()
    }
    
    @IBAction func recordMeasurement(sender: AnyObject){
        if currentImage > 0 {
            let rawPoint = imageView.markerLocation
            let calibratedPoint = LBPoint(x: rawPoint.x * data.xCalCoeffs[1] + data.xCalCoeffs[0], y: rawPoint.y * data.yCalCoeffs[1] + data.yCalCoeffs[0])
            data.measurements[currentImage-1] = LBCalibratedPair(raw: rawPoint, calibrated: calibratedPoint)
//            data.imageFilenames[currentImage-1] = fileNameField!.stringValue
            if advanceOnRecordCheckbox!.state == NSOnState {
                self.advanceImage(self)
            }
        } else {
            NSBeep()
        }
    }
    
    @IBAction func deleteData(sender: AnyObject){
        let alert = NSAlert()
        alert.messageText = "Warning: Measurements will be lost"
        alert.addButtonWithTitle("Wait!")
        alert.addButtonWithTitle("Do it.")
        alert.informativeText = "If you go ahead with this you will have to measure your data again."
        alert.beginSheetModalForWindow((windowControllers[0].window as! NSWindow), completionHandler: {
            (response: NSModalResponse) -> Void in
            if response == 1001 {
                self.clearMeasurements()
            }
        })
    }
    
    func clearMeasurements() {
        data.measurements = [LBCalibratedPair](count: data.imageURLArray.count, repeatedValue: LBCalibratedPair(raw: LBPoint(x: Double.NaN, y: Double.NaN), calibrated: LBPoint(x: Double.NaN, y: Double.NaN)))
    }
    
    @IBAction func exportDataToCSV(sender: AnyObject){
        var calibrationString = "axis,gradient,offset\n"
        calibrationString += "x,\(data.xCalCoeffs[1]),\(data.xCalCoeffs[0])\n"
        calibrationString += "y,\(data.yCalCoeffs[1]),\(data.yCalCoeffs[0)"
        var dataString = "trial,filename,rawX,rawY,calibratedX,calibratedY\n"
        for i in 0..<data.measurements.count {
            dataString += "\(i),\(data.imageURLArray[i].lastPathComponent!),\(data.measurements[i].raw.x),\(data.measurements[i].raw.y),\(data.measurements[i].calibrated.x),\(data.measurements[i].calibrated.y)\n"
        }
        let savePanel = NSSavePanel()
        let result = savePanel.runModal()
        if result == NSModalResponseOK {
            let dataPath = savePanel.URL!.path! + ".csv"
            var writeError: NSError?
            if !dataString.writeToFile(dataPath, atomically: true, encoding: NSUnicodeStringEncoding, error: &writeError) {
                let errorAlert = NSAlert(error: writeError!)
                errorAlert.runModal()
            }
            let calibrationPath = savePanel.URL!.path! + "_calibration.csv"
            if !calibrationString.writeToFile(calibrationPath, atomically: true, encoding: NSUnicodeStringEncoding, error: &writeError) {
                let errorAlert = NSAlert(error: writeError!)
                errorAlert.runModal()
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
        let alert = NSAlert()
        alert.messageText = "Warning: Calibration data will be lost"
        alert.addButtonWithTitle("Wait!")
        alert.addButtonWithTitle("Do it.")
        alert.informativeText = "If you go ahead with this you will not be able to make more measurements with the current calibration."
        alert.beginSheetModalForWindow((windowControllers[0].window as! NSWindow), completionHandler: {
            (response: NSModalResponse) -> Void in
            if response == 1001 {
                self.data.calibrationPoints.removeAll(keepCapacity: false)
                self.data.xCalCoeffs = [0.0,1.0]
                self.data.yCalCoeffs = [0.0,1.0]
            }
            })
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
        } else {
            let gradient = (firstCalibrationPair!.calibrated.y - secondCalibrationPair!.calibrated.y) / (firstCalibrationPair!.raw.y - secondCalibrationPair!.raw.y)
            let offset = firstCalibrationPair!.calibrated.y - gradient * firstCalibrationPair!.raw.y
            data.yCalCoeffs[0] = offset
            data.yCalCoeffs[1] = gradient
        }
    }
    
    @IBAction func importCalibration(sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["csv","CSV"]
        let result = openPanel.runModal()
        if result == NSModalResponseOK {
            var error: NSError?
            let calibrationString = String(contentsOfURL: openPanel.URL!, encoding: NSUnicodeStringEncoding, error: &error)
            if error != nil {
                let errorAlert = NSAlert(error: error!)
                errorAlert.runModal()
            } else {
                let lines = calibrationString!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n"))
                let commaSet = NSCharacterSet(charactersInString: ",")
                let xCalibration = lines[1].componentsSeparatedByCharactersInSet(commaSet)
                data.xCalCoeffs[0] = NSString(string: xCalibration[2]).doubleValue
                data.xCalCoeffs[1] = NSString(string: xCalibration[1]).doubleValue
                let yCalibration = lines[2].componentsSeparatedByCharactersInSet(commaSet)
                data.yCalCoeffs[0] = NSString(string: yCalibration[2]).doubleValue
                data.yCalCoeffs[1] = NSString(string: yCalibration[1]).doubleValue
            }
        }
    }
}

