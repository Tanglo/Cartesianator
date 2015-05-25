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
        openPanel.runModal()
        data.imageDirectoryURL = openPanel.URL!
        let urlArray = data.arrayOfImageFileNames()
        if urlArray != nil {
            data.willChangeValueForKey("imageURLCount")
            data.imageURLArray = urlArray!
            data.didChangeValueForKey("imageURLCount")
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
            } else {
                imageView.image = nil
                imageView.needsDisplay = true
            }
        }
    }

}

