//
//  CurrencyCollectionView.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 22.09.2026.
//

import UIKit

final class CurrencyCollectionView: UICollectionView {
    
    var didSelectCurrency: ((CurrencyModel) -> Void)?
    var currentCode: String?
    var disabledCodes: Set<String> = []
    
    private var sections: [(title: String, currencies: [CurrencyModel])] = []
    let popularCodes = ["USD", "EUR", "UAH"]
    
    var model: [CurrencyModel] = [] {
        didSet {
            let popularCurrencies = popularCodes.compactMap { code in
                model.first { $0.code == code }
            }
            let otherCurrencies = model.filter {
                !popularCodes.contains($0.code)
            }
            
            let otherSections = Dictionary(grouping: otherCurrencies) {
                String($0.code.prefix(1)).uppercased()
            }
                .sorted { $0.key < $1.key }
                .map { (title: $0.key, currencies: $0.value.sorted { $0.code < $1.code }) }
            
            sections = ([(title: "Popular", currencies: popularCurrencies)] + otherSections)
                .filter { !$0.currencies.isEmpty }
            reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
        
        self.register(
            UICollectionViewListCell.self,
            forCellWithReuseIdentifier: "CurrencyListCell")
        
        self.register(
            UICollectionViewListCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header")
        configureLayout(for: self)
    }
    
    private func configureLayout(for collectionView: UICollectionView) {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = self
    }
    
    private func currency(at indexPath: IndexPath) -> CurrencyModel {
        sections[indexPath.section].currencies[indexPath.item]
    }
    
    private func isDisabled(_ currency: CurrencyModel) -> Bool {
        disabledCodes.contains(currency.code)
    }
}

// MARK: - Extensions

extension CurrencyCollectionView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
            !isDisabled(currency(at: indexPath))
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath) -> Bool {
            !isDisabled(currency(at: indexPath))
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
            
            let currency = currency(at: indexPath)
            guard !isDisabled(currency) else { return }
            didSelectCurrency?(currency)
        }
}

extension CurrencyCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            sections[section].currencies.count
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "Header",
                for: indexPath
            ) as? UICollectionViewListCell else {
                return UICollectionReusableView()
            }
            
            var content = UIListContentConfiguration.groupedHeader()
            content.text = sections[indexPath.section].title
            header.contentConfiguration = content
            return header
        }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CurrencyListCell",
                for: indexPath) as? UICollectionViewListCell else {
                return UICollectionViewCell()
            }
            
            let currency = currency(at: indexPath)
            let disabled = isDisabled(currency)
            
            var content = UIListContentConfiguration.cell()
            content.text = "\(currency.code) - \(currency.name)"
            content.secondaryText = "\(currency.price)"
            content.textProperties.color = disabled ? .tertiaryLabel : .label
            content.secondaryTextProperties.color = disabled ? .tertiaryLabel : .secondaryLabel
            cell.contentConfiguration = content
            
            if disabled {
                cell.accessories = []
                cell.accessibilityTraits.insert(.notEnabled)
            } else {
                cell.accessibilityTraits.remove(.notEnabled)
                cell.accessories = currency.code == currentCode ? [.checkmark()] : [.disclosureIndicator()]
            }
            return cell
        }
}
