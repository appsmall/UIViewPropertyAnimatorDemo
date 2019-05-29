//
//  ViewController.swift
//  UIViewPropertyAnimatorDemo
//
//  Created by apple on 28/05/19.
//  Copyright © 2019 appsmall. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let items: [City] = City.buildCities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = CityCollectionViewFlowLayout(itemSize: CityCollectionViewCell.cellSize);
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.identifier, for: indexPath) as! CityCollectionViewCell
        cell.configure(with: items[indexPath.item], collectionView: collectionView, index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! CityCollectionViewCell
        selectedCell.toggle()
    }
}
