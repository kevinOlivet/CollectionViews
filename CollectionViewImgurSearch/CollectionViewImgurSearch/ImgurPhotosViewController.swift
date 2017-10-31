//
//  ImgurPhotosViewController.swift
//  CollectionViewImgurSearch
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

final class ImgurPhotosViewController: UICollectionViewController {
  
  fileprivate let reuseIdentifier = "ImgurCell"
  
  fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  fileprivate var searches = [ImgurSearchResults]()
  fileprivate let imgur = Imgur()
  fileprivate let itemsPerRow: CGFloat = 3
  
  var largePhotoIndexPath: IndexPath? {
    didSet {
      var indexPaths = [IndexPath]()
      if let largePhotoIndexPath = largePhotoIndexPath {
        indexPaths.append(largePhotoIndexPath as IndexPath)
      }
      if let oldValue = oldValue {
        indexPaths.append(oldValue as IndexPath)
      }
      collectionView?.performBatchUpdates({
        self.collectionView?.reloadItems(at: indexPaths)
      }) { completed in
        if let largePhotoIndexPath = self.largePhotoIndexPath {
          self.collectionView?.scrollToItem(
            at: largePhotoIndexPath as IndexPath,
            at: .centeredVertically,
            animated: true)
        }
      }
    }
  }
  
  fileprivate var selectedPhotos = [ImgurPhoto]()
  fileprivate let shareTextLabel = UILabel()
  
  var sharing: Bool = false {
    didSet {
      collectionView?.allowsMultipleSelection = sharing
      collectionView?.selectItem(at: nil, animated: true, scrollPosition: UICollectionViewScrollPosition())
      selectedPhotos.removeAll(keepingCapacity: false)
      
      guard let shareButton = self.navigationItem.rightBarButtonItems?.first else {
        return
      }
      
      guard sharing else {
        navigationItem.setRightBarButtonItems( [shareButton], animated: true)
        return
      }
      
      if let _ = largePhotoIndexPath {
        largePhotoIndexPath = nil
      }
      
      updateSharedPhotoCount()
      let sharingDetailItem = UIBarButtonItem(customView: shareTextLabel)
      navigationItem.setRightBarButtonItems([shareButton, sharingDetailItem], animated: true)
    }
  }
  
  @IBAction func share(_ sender: UIBarButtonItem) {
    guard !searches.isEmpty else {
      return
    }
    
    guard !selectedPhotos.isEmpty else {
      sharing = !sharing
      return
    }
    
    guard sharing else  {
      return
    }
    
    var imageArray = [UIImage]()
    for selectedPhoto in selectedPhotos {
      if let thumbnail = selectedPhoto.thumbnail {
        imageArray.append(thumbnail)
      }
    }
    
    if !imageArray.isEmpty {
      let shareScreen = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
      shareScreen.completionWithItemsHandler = { _ in
        self.sharing = false
      }
      let popoverPresentationController = shareScreen.popoverPresentationController
      popoverPresentationController?.barButtonItem = sender
      popoverPresentationController?.permittedArrowDirections = .any
      present(shareScreen, animated: true, completion: nil)
    }
  }
  
}

// MARK: - Private
private extension ImgurPhotosViewController {
  func photoForIndexPath(indexPath: IndexPath) -> ImgurPhoto {
    return searches[(indexPath as NSIndexPath).section].searchResults[(indexPath as IndexPath).row]
  }
  
  func updateSharedPhotoCount() {
    shareTextLabel.textColor = themeColor
    shareTextLabel.text = "\(selectedPhotos.count) photos selected"
    shareTextLabel.sizeToFit()
  }
}

// MARK: - TextField Delegate Methods
extension ImgurPhotosViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    textField.addSubview(activityIndicator)
    activityIndicator.frame = textField.bounds
    activityIndicator.startAnimating()
    
    imgur.searchImgurForTerm(textField.text!) { (results, error) in
      activityIndicator.removeFromSuperview()
      
      if let error = error {
        print("Error searching : \(error)")
        return
      }
      
      if let results = results {
        print("Found \(results.searchResults.count) matching \(results.searchTerm)")
        self.searches.insert(results, at: 0)
        
        self.collectionView?.reloadData()
      }
    }
    
    textField.text = nil
    textField.resignFirstResponder()
    return true
  }
}

//MARK: - UICollectionViewDataSource Methods
extension ImgurPhotosViewController {
  //1
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return searches.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searches[section].searchResults.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ImgurPhotoHeaderView", for: indexPath) as! ImgurPhotoHeaderView
      headerView.label.text = searches[(indexPath as NSIndexPath).section].searchTerm
      return headerView
    default:
      assert(false, "Unexpected element kind")
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImgurPhotoCell
    
    let imgurPhoto = photoForIndexPath(indexPath: indexPath)
    cell.backgroundColor = UIColor.white
    
    cell.activityIndicator.stopAnimating()
    
    guard indexPath == largePhotoIndexPath else {
      cell.imageView.image = imgurPhoto.thumbnail
      return cell
    }
    
    guard imgurPhoto.largeImage == nil  else {
      cell.imageView.image = imgurPhoto.largeImage
      return cell
    }
    
    cell.imageView.image = imgurPhoto.thumbnail
    cell.activityIndicator.startAnimating()
    
    imgurPhoto.loadLargeImage { (loadedImgurPhoto, error) in
      cell.activityIndicator.stopAnimating()
      
      guard loadedImgurPhoto.largeImage != nil && error == nil else {
        return
      }
      
      if let cell = collectionView.cellForItem(at: indexPath) as? ImgurPhotoCell, indexPath == self.largePhotoIndexPath {
        cell.imageView.image = loadedImgurPhoto.largeImage
      }
    }
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    var sourceResults = searches[sourceIndexPath.section].searchResults
    let imgurPhoto = sourceResults.remove(at: sourceIndexPath.row)
    searches[sourceIndexPath.section].searchResults = sourceResults
    
    var destinationResults = searches[destinationIndexPath.section].searchResults
    destinationResults.insert(imgurPhoto, at: destinationIndexPath.row)
    searches[destinationIndexPath.section].searchResults = destinationResults
  }
}

//MARK: - UICollectionViewDelegate
extension ImgurPhotosViewController {
  
  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    guard !sharing else {
      return true
    }
    
    largePhotoIndexPath = largePhotoIndexPath == indexPath ? nil : indexPath
    return false
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard sharing else {
      return
    }
    
    let photo = photoForIndexPath(indexPath: indexPath)
    selectedPhotos.append(photo)
    updateSharedPhotoCount()
  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard sharing else {
      return
    }
    
    let photo = photoForIndexPath(indexPath: indexPath)
    
    if let index = selectedPhotos.index(of: photo){
      selectedPhotos.remove(at: index)
      updateSharedPhotoCount()
    }
  }
}

extension ImgurPhotosViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath == largePhotoIndexPath {
      let imgurPhoto = photoForIndexPath(indexPath: indexPath)
      var size = collectionView.bounds.size
      size.height -= topLayoutGuide.length
      size.height -= (sectionInsets.top + sectionInsets.bottom)
      size.width -= (sectionInsets.left + sectionInsets.right)
      return imgurPhoto.sizeToFillWidthOfSize(size)
    }
    
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
