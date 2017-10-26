//
//  ViewController.swift
//  CollectionViewStackOverflow
//
//  Created by Jon Olivet on 5/15/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  let reuseIdentifier = "cell"
  var items = [Int]()
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    items += 0...100
  }
  
  // MARK: - UICollectionViewDataSource methods
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
    
    cell.myLabel.text = String(items[indexPath.item])
    cell.backgroundColor = UIColor.cyan
    cell.layer.borderColor = UIColor.blue.cgColor
    cell.layer.borderWidth = 1
    cell.layer.cornerRadius = 8
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate methods
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("You selected cell #\(indexPath.item)!")
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) {
      cell.backgroundColor != UIColor.cyan ? (cell.backgroundColor = UIColor.cyan) : (cell.backgroundColor = randomColor())
    }
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout methods
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    let insets = UIEdgeInsets(top: 5, left: 2.5, bottom: 5, right: 2.5)
    return insets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: (collectionView.frame.width/4) - 5, height: 50)
    return size
  }
  
  // MARK: - Actions
  func randomColor() -> UIColor {
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
  }
  
}


