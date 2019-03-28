//
//  ProductSearchViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/16/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit

class ProductSearchViewController: UIViewController, ItemDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    var products = [ItemObject]()
    private var searchTerm = ""
    var item: ItemObject?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Helper Methods
    private func loadItems(completion: @escaping (Bool, Error?) -> ()) {
        let searchURL = "\(NetworkingConstants.baseURL)\(NetworkingConstants.apiKey)\(NetworkingConstants.finalUrl)\(searchTerm)"
        guard let url = URL(string: searchURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            do {
                let itemInfo = try JSONDecoder().decode(ListItem.self, from: data)
                for item in itemInfo.items {
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
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.detailSegue:
            guard let productDetailVC = segue.destination as? ProductDetailViewController else { return }
            productDetailVC.delegate = self
        default:
            break
        }
    }
}

// MARK: - View Controller Extensions
extension ProductSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConstant.searchItemCell, for: indexPath) as? SearchItemCell else { return UICollectionViewCell() }
        return cell
    }
    
    // MARK: - CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.detailSegue, sender: self)
    }
}

extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        products.removeAll(keepingCapacity: false)
        collectionView.reloadData()
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
