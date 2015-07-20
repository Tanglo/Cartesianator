//
//  CartData.swift
//  Cartesianator
//
//  Created by Lee Walsh on 19/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa
import LabBot

class CartData: NSObject, NSCoding {
    var imageDirectoryURL: NSURL
    var imageURLArray: [NSURL]
    var xCalCoeffs = [0.0, 1.0]
    var yCalCoeffs = [0.0, 1.0]
    var calibrationPoints = [LBCalibratedPair]()
    var rawMeasurements = [LBPoint]()
    var measurements = [LBCalibratedPair]()
    var measurementIndexes = [Int]()
    var measurementsPerImage = 1
    var newFile = true
    
    override init(){
        var homePath = "~"
        homePath = homePath.stringByExpandingTildeInPath
        imageDirectoryURL = NSURL(fileURLWithPath: homePath, isDirectory: true)!
        imageURLArray = [NSURL]()
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        imageDirectoryURL = aDecoder.decodeObjectForKey("imageDirectoryURL") as! NSURL
        imageURLArray = aDecoder.decodeObjectForKey("imageURLArray") as! [NSURL]
        xCalCoeffs = aDecoder.decodeObjectForKey("xCalCoeffs") as! [Double]
        yCalCoeffs = aDecoder.decodeObjectForKey("yCalCoeffs") as! [Double]
        calibrationPoints = aDecoder.decodeObjectForKey("calibrationPoints") as! [LBCalibratedPair]
        measurements = aDecoder.decodeObjectForKey("measurements") as! [LBCalibratedPair]
        measurementIndexes = aDecoder.decodeObjectForKey("measurementIndexes") as! [Int]
        measurementsPerImage = aDecoder.decodeIntegerForKey("measurementsPerImage")
        newFile = aDecoder.decodeBoolForKey("newFile")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(imageDirectoryURL, forKey: "imageDirectoryURL")
        aCoder.encodeObject(imageURLArray, forKey: "imageURLArray")
        aCoder.encodeObject(xCalCoeffs, forKey: "xCalCoeffs")
        aCoder.encodeObject(yCalCoeffs, forKey: "yCalCoeffs")
        aCoder.encodeObject(calibrationPoints, forKey: "calibrationPoints")
        aCoder.encodeObject(measurements, forKey: "measurements")
        aCoder.encodeObject(measurementIndexes, forKey: "measurementIndexes")
        aCoder.encodeInteger(measurementsPerImage, forKey: "measurementsPerImage")
        aCoder.encodeBool(newFile, forKey: "newFile")
    }
    
    func arrayOfImageFileNames() -> [NSURL]?{
        var error: NSError?
        var fileList = NSFileManager.defaultManager().contentsOfDirectoryAtURL(imageDirectoryURL, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: &error) as! [NSURL]?
        if fileList != nil {
            for url:NSURL in fileList! {
                var isDirectory: AnyObject?
                var urlError: NSError?
                if !url.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: &urlError) {
                    let errorAlert = NSAlert(error: urlError!)
                    errorAlert.runModal()
                    return nil
                }
//                return fileList
            }
            return fileList
        } else {
            let errorAlert = NSAlert(error: error!)
            errorAlert.runModal()
            return nil
        }
//        return nil
    }
    
    override func valueForKey(key: String) -> AnyObject? {
        if key == "imageURLCount" {
            return imageURLArray.count
        }
        super.valueForKey(key)
        return nil
    }

}
