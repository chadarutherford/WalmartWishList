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
    private func loadItems(completion: @escaping (Bool, Error?) -> ()) {
        let searchURL = "\(NetworkingConstants.baseURL)\(NetworkingConstants.apiKey)\(NetworkingConstants.finalUrl)\(searchTerm)"
        print(searchURL)
        guard let url = URL(string: searchURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            do {
                let itemInfo = try JSONDecoder().decode(ListItem.self, from: data)
                for item in itemInfo.items {
                    guard let imageURL = URL(string: item.largeImage) else { return }
                    do {
                        let newItem = ItemObject(name: item.name, salePrice: item.salePrice, shortDescription: item.shortDescription, thumbnailImage: try Data(contentsOf: imageURL), availableOnline: item.availableOnline, isPurchased: false)
                        self?.products.append(newItem)
                    } catch let error {
                        print(error)
                    }
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
        item = ItemObject(name: products[indexPath.item].name, salePrice: products[indexPath.item].salePrice, shortDescription: products[indexPath.item].shortDescription, thumbnailImage: products[indexPath.item].thumbnailImage, availableOnline: products[indexPath.item].availableOnline, isPurchased: false)
        performSegue(withIdentifier: SegueConstant.detailSegue, sender: self)
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.darkGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.width / 2)
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
