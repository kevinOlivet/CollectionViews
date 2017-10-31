//
//  ImgurPhoto.swift
//  CollectionViewImgurSearch
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

class ImgurPhoto : Equatable {
  var thumbnail : UIImage?
  var largeImage : UIImage?
  let photoID : String
  let title: String
  
  init (id:String, title: String) {
    self.photoID = id
    self.title = title
  }
  
  func imgurImageURL(_ size:String = "m") -> URL? {
    if let url =  URL(string: "https://i.imgur.com/\(photoID)\(size).jpg") {
      return url
    }
    return nil
  }
  
  func loadLargeImage(_ completion: @escaping (_ imgurPhoto:ImgurPhoto, _ error: NSError?) -> Void) {
    guard let loadURL = imgurImageURL("l") else {
      DispatchQueue.main.async {
        completion(self, nil)
      }
      return
    }
    
    var loadRequest = URLRequest(url:loadURL)
    loadRequest.setValue(clientID, forHTTPHeaderField: "authorization")
    
    URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
      if let error = error {
        DispatchQueue.main.async {
          completion(self, error as NSError?)
        }
        return
      }
      
      guard let data = data else {
        DispatchQueue.main.async {
          completion(self, nil)
        }
        return
      }
      
      let returnedImage = UIImage(data: data)
      self.largeImage = returnedImage
      DispatchQueue.main.async {
        completion(self, nil)
      }
    }).resume()
  }
  
  func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
    
    guard let thumbnail = thumbnail else {
      return size
    }
    
    let imageSize = thumbnail.size
    var returnSize = size
    
    let aspectRatio = imageSize.width / imageSize.height
    
    returnSize.height = returnSize.width / aspectRatio
    
    if returnSize.height > size.height {
      returnSize.height = size.height
      returnSize.width = size.height * aspectRatio
    }
    
    return returnSize
  }
  
}

func == (lhs: ImgurPhoto, rhs: ImgurPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}
