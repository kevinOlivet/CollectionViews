//
//  Imgur.swift
//  CollectionViewImgurSearch
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

let clientID = "Client-ID e27f0e33654849b"

class Imgur {
    
  func searchImgurForTerm(_ searchTerm: String, completion : @escaping (_ results: ImgurSearchResults?, _ error : NSError?) -> Void){
    var imgurPhotos = [ImgurPhoto]()
    
    guard let searchURL = imgurSearchURLForSearchTerm(searchTerm) else {
      let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"searchURL error"])
      completion(nil, APIError)
      return
    }
    
    var searchRequest = URLRequest(url: searchURL)
    searchRequest.addValue(clientID, forHTTPHeaderField: "authorization")
    
    
    URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
      
      if let _ = error {
        let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"dataTask error"])
        OperationQueue.main.addOperation({
          completion(nil, APIError)
        })
        return
      }
      
      guard let _ = response as? HTTPURLResponse else {
        let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"response error"])
        OperationQueue.main.addOperation({
          completion(nil, APIError)
        })
        return
      }
      guard let data = data else {
        let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"data error"])
        OperationQueue.main.addOperation({
          completion(nil, APIError)
        })
        return
      }
      
      do {
        
        guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
          let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"serialization error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
        }
        
        guard let newData = resultsDictionary["data"] as? [String: AnyObject] else {
          
          let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"newData error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
        }
        
        guard let items = newData["items"] as? [[String: AnyObject]] else {
          
          let APIError = NSError(domain: "ImgurSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"items error"])
          OperationQueue.main.addOperation({
            completion(nil, APIError)
          })
          return
        }
        
        
        for item in items {
          guard let title = item["id"] as? String  else {
            break
          }
          guard let images = item["images"] as? [[String:AnyObject]] else {
            break
          }
          for image in images {
            guard let photoID = image["id"] as? String else {
              print("image problem"); break
            }
            
            let imgurrPhoto = ImgurPhoto(id: photoID, title: title)
            
            guard let url = imgurrPhoto.imgurImageURL(),
              let imageData = try? Data(contentsOf: url as URL) else {
                print("photoURL problem"); break
            }
            
            if let image = UIImage(data: imageData) {
              imgurrPhoto.thumbnail = image
              imgurPhotos.append(imgurrPhoto)
            }
            print("Here is the photoID: \(photoID)")
            
          }
          
          
        }
        OperationQueue.main.addOperation({
          completion(ImgurSearchResults(searchTerm: searchTerm, searchResults: imgurPhotos), nil)
        })
        
        
      } catch _ {
        completion(nil, nil)
        return
      }
      
      
    }).resume()
  }
  
  fileprivate func imgurSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
    
    guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
      return nil
    }
    // For other possibilities see https://apidocs.imgur.com
    // For example it's possible to append "/{{sort}}/{{window}}/{{page}}" to limit the responses
    let URLString = "https://api.imgur.com/3/gallery/t/\(escapedTerm)"
    
    
    guard let url = URL(string:URLString) else {
      return nil
    }
    
    return url
  }
}
