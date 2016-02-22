//
//  ImageDownloader.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 21/02/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import Alamofire

class ImageDownloader {
    var semaphore:dispatch_semaphore_t?
    
    func downloadImagesIfNeeded(var images:[String], splashscreen:Splashscreen) {
        if let destination = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(destination + "/HSTracker/cards", withIntermediateDirectories: true, attributes: nil)
            }
            catch {}
            
            // check for images already present
            for image in images {
                let path = "\(destination)/HSTracker/cards/\(image).png"
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    images.remove(image)
                }
            }
            
            if (images.isEmpty) {
                // we already have all images
                return
            }
            
            if let lang = Settings.instance.hearthstoneLanguage {
                semaphore = dispatch_semaphore_create(0)
                let total = Double(images.count)
                dispatch_async(dispatch_get_main_queue()) {
                    splashscreen.display("Downloading images", total: total)
                }
                
                downloadImages(images, language: lang.lowercaseString, destination: destination, splashscreen: splashscreen)
            }
            if let semaphore = semaphore {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
    }
    
    private func downloadImages(var images:[String], language:String, destination:String, splashscreen:Splashscreen) {
        if images.isEmpty {
            if let semaphore = semaphore {
                dispatch_semaphore_signal(semaphore)
            }
            return
        }
        
        if let image = images.popLast() {
            dispatch_async(dispatch_get_main_queue()) {
                splashscreen.increment("Downloading \(image).png")
            }
            
            let path = "\(destination)/HSTracker/cards/\(image).png"
            let url = NSURL(string: "https://wow.zamimg.com/images/hearthstone/cards/\(language)/medium/\(image).png")!
            DDLogDebug("downloading \(url) to \(path)")
            
            let task = NSURLSession.sharedSession().downloadTaskWithRequest(NSURLRequest(URL: url), completionHandler: { (url, response, error) -> Void in
                if error != nil {
                    DDLogError("download error \(error)")
                    self.downloadImages(images, language: language, destination: destination, splashscreen: splashscreen)
                    return
                }
                
                if let url = url {
                    if let data = NSData(contentsOfURL: url) {
                        data.writeToFile(path, atomically: true)
                    }
                }
                self.downloadImages(images, language: language, destination: destination, splashscreen: splashscreen)
            })
            task.resume()
        }
    }
    
}