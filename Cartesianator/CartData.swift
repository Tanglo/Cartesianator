//
//  CartData.swift
//  Cartesianator
//
//  Created by Lee Walsh on 19/05/2015.
//  Copyright (c) 2015 Lee David Walsh. All rights reserved.
//

import Cocoa

class CartData: NSObject, NSCoding {
    var imageDirectoryURL: NSURL
    var imageURLArray: [NSURL]
    
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
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(imageDirectoryURL, forKey: "imageDirectoryURL")
        aCoder.encodeObject(imageURLArray, forKey: "imageURLArray")
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
                return fileList
            }
        } else {
            let errorAlert = NSAlert(error: error!)
            errorAlert.runModal()
            return nil
        }
        return nil
    }

}
