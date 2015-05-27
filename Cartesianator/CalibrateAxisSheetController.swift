//
//  CalibrateAxisController.swift
//  Cartesianator
//
//  Created by Lee Walsh on 27/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

class CalibrateAxisSheetController: NSWindowController {
    @IBOutlet var firstPointPopup: NSPopUpButton?
    @IBOutlet var secondPointPopup: NSPopUpButton?

    override var windowNibName: String! {
        return "CalibrateAxisSheet"
    }
    
    override func windowDidLoad() {
        let calibrationPairs = (document! as! CartDocument).data.calibrationPoints
        firstPointPopup!.removeAllItems()
        secondPointPopup!.removeAllItems()
        for i in 0..<calibrationPairs.count {       //calibrationPair in calibrationPairs {
            var newMenuItem = NSMenuItem(title: "raw: \((calibrationPairs[i].raw as! LBPoint).x),\((calibrationPairs[i].raw as! LBPoint).y) -> calibrated: \((calibrationPairs[i].calibrated as! LBPoint).x),\((calibrationPairs[i].calibrated as! LBPoint).y)", action: nil, keyEquivalent: "")
            newMenuItem.tag = i
            firstPointPopup!.menu!.addItem(newMenuItem)
            newMenuItem = NSMenuItem(title: "raw: \(calibrationPairs[i].raw.x),\(calibrationPairs[i].raw.y) -> calibrated: \(calibrationPairs[i].calibrated.x),\(calibrationPairs[i].calibrated.y)", action: nil, keyEquivalent: "")
            newMenuItem.tag = i
            secondPointPopup!.menu!.addItem(newMenuItem)
        }
    }
    
    @IBAction func endCalibrateAxisSheet(sender: AnyObject){
        if (sender as! NSButton).title == "Ok" {
            if firstPointPopup!.selectedItem != nil && secondPointPopup!.selectedItem != nil {
                (document! as! CartDocument).firstCalibrationPair = (document! as! CartDocument).data.calibrationPoints[firstPointPopup!.selectedItem!.tag]
                (document! as! CartDocument).secondCalibrationPair = (document! as! CartDocument).data.calibrationPoints[secondPointPopup!.selectedItem!.tag]
                window!.sheetParent!.endSheet(window!, returnCode: NSModalResponseOK)
            } else {
                NSBeep()
            }
        } else {
            window!.sheetParent!.endSheet(window!, returnCode: NSModalResponseCancel)
        }
    }
    
}
