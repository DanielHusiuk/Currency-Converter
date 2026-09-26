//
//  CurrencyViewController.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 22.09.2026.
//

import UIKit

final class CurrencyViewController: UIViewController {

    var currencies: [CurrencyModel] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    var selectedRowIndex: Int?
    var didSelectCurrency: ((CurrencyModel, Int) -> Void)?
    
    var currentCode: String?
    var disabledCodes: Set<String> = []
    
    @IBOutlet weak var currencyCollectionView: CurrencyCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupSearchController()
        setupCollectionView()
    }
    
    @objc private func closeView() {
        dismiss(animated: true)
    }
    
    private func setupNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeView)
        )
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString( "Search Currency", comment: "")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupCollectionView() {
        currencyCollectionView.currentCode = currentCode
        currencyCollectionView.disabledCodes = disabledCodes
        currencyCollectionView.model = currencies
        currencyCollectionView.reloadData()
        
        currencyCollectionView.didSelectCurrency = { [weak self] currency in
            guard let self, let selectedRowIndex else { return }
            
            didSelectCurrency?(currency, selectedRowIndex)
            closeView()
        }
    }
}

// MARK: - Extensions

extension CurrencyViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            currencyCollectionView.model = currencies
            return
        }
        
        let filteredCurrencies = currencies.filter {
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        currencyCollectionView.model = filteredCurrencies
    }
}
