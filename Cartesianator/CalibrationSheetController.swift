//
//  CalibrationSheetController.swift
//  Cartesianator
//
//  Created by Lee Walsh on 26/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

class CalibrationSheetController: NSWindowController {
    @IBOutlet var xField: NSTextField?
    @IBOutlet var yField: NSTextField?

    override var windowNibName: String! {
        return "CalibrationSheet"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        xField!.doubleValue = 0.0
        yField!.doubleValue = 0.0
    }
    
    @IBAction func endCalibrationSheet(sender: AnyObject){
        if (sender as! NSButton).title == "Ok" {
            (document as! CartDocument).calibrationValue = LBPoint(x: xField!.doubleValue, y: yField!.doubleValue)
            window!.sheetParent!.endSheet(window!, returnCode: NSModalResponseOK)
        } else {
            window!.sheetParent!.endSheet(window!, returnCode: NSModalResponseCancel)
        }
    }

}
