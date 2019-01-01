//
//  ProductSearchViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

final class ProductSearchViewController: UIViewController, ItemDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    private var products = [ItemObject]()
    private var searchTerm = ""
    
    // MARK: - Item Delegate
    var item: ItemObject?
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Actions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    private func loadItems() {
        let searchURL = "\(NetworkingConstants.baseURL)\(NetworkingConstants.apiKey)\(NetworkingConstants.finalUrl)\(searchTerm)"
        print(searchURL)
        guard let url = URL(string: searchURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            do {
                let itemInfo = try JSONDecoder().decode(ListItem.self, from: data)
                for item in itemInfo.items {
                    let newItem = ItemObject()
                    newItem.name = item.name
                    newItem.salePrice = item.salePrice
                    newItem.shortDescription = item.shortDescription
                    guard let imageURL = URL(string: item.thumbnailImage) else { return }
                    do {
                        newItem.thumbnailImage = try Data(contentsOf: imageURL)
                    } catch let error {
                        print(error)
                    }
                    newItem.availableOnline = item.availableOnline
                    self?.products.append(newItem)
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } catch let error {
                print(error)
            }
            }.resume()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.detailSegue:
            if let destinationVC = segue.destination as? ProductDetailViewController {
                destinationVC.delegate = self
            }
        default:
            break
        }
    }
}

// MARK: - CollectionView Extension
extension ProductSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - CollectionView DataSource Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConstant.searchItemCell, for: indexPath) as? SearchItemCell else { return UICollectionViewCell() }
        guard let image = UIImage(data: products[indexPath.item].thumbnailImage) else { fatalError() }
        cell.configure(withImage: image, withName: products[indexPath.item].name, withPrice: products[indexPath.item].salePrice, withAvailability: products[indexPath.item].availableOnline)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        item = ItemObject(name: products[indexPath.item].name, salePrice: products[indexPath.item].salePrice, shortDescription: products[indexPath.item].shortDescription, thumbnailImage: products[indexPath.item].thumbnailImage, availableOnline: products[indexPath.item].availableOnline)
        performSegue(withIdentifier: SegueConstant.detailSegue, sender: self)
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchTerm = text.replacingOccurrences(of: " ", with: "%20")
        searchBar.resignFirstResponder()
        loadItems()
    }
}
