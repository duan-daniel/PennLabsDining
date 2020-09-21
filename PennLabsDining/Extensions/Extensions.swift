//
//  Extensions.swift
//  PennLabsDining
//
//  Created by Daniel Duan on 9/21/20.
//
// Extension to the UIImageView to help with asynchronous loading

import Foundation
import UIKit

var imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    // load is an extension to UIImageView that asynchronously loads an image from a remote URL
    // Code taken from this code-along: https://www.youtube.com/watch?v=OTcQnf6ziew&ab_channel=PushpendraSaini
    func load(urlString: String) {
        
        if let image = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = image as! UIImage
            return
        }
        
        // verifying it is a valid url
        guard let url = URL(string: urlString) else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // put image into cache
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self?.image = image
                    }
                }
            }
        }
        
    }
}
