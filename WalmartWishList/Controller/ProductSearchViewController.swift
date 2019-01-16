//
//  ProductSearchViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/16/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit

class ProductSearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var products = [ItemObject]()
    private var searchTerm = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func loadItems(completion: @escaping (Bool, Error?) -> ()) {
        let searchURL = "\(NetworkingConstants.baseURL)\(NetworkingConstants.apiKey)\(NetworkingConstants.finalUrl)\(searchTerm)"
        guard let url = URL(string: searchURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            do {
                let itemInfo = try JSONDecoder().decode(ListItem.self, from: data)
                for item in itemInfo.items {
                    let newItem = ItemObject(name: item.name, salePrice: item.salePrice, shortDescription: item.shortDescription, largeImage: item.largeImage, availableOnline: item.availableOnline)
                    self?.products.append(newItem)
                }
                completion(true, nil)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } catch let error {
                completion(false, error)
            }
        }.resume()
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

extension ProductSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConstant.searchItemCell, for: indexPath) as? SearchItemCell else { return UICollectionViewCell() }
        guard let url = URL(string: products[indexPath.item].largeImage) else { return UICollectionViewCell() }
        guard let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) else { return UICollectionViewCell() }
        cell.configure(withImage: image, withName: products[indexPath.item].name, withPrice: products[indexPath.item].salePrice, withAvailability: products[indexPath.item].availableOnline)
        return cell
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        collectionView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        guard let text = searchBar.text else { return }
        searchTerm = text.replacingOccurrences(of: " ", with: "%20").lowercased()
        searchBar.resignFirstResponder()
        loadItems { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                }
            } else {
                guard let _ = error else { return }
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    self?.displayAlert(title: "Loading Error", message: "There are no items in our stores that match your search. Please try again.")
                }
            }
        }
    }
}
