//
//  ViewController.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 15.09.2026.
//

import UIKit

private struct CurrencyRow {
    let button: UIButton
    let textField: CustomTextField
}

final class ViewController: UIViewController {
    
    @IBOutlet weak var darkBlueView: UIView!
    @IBOutlet weak var regularBlueView: UIView!
    @IBOutlet weak var lightBlueView: UIView!
    
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var firstCurrencyButton: UIButton!
    @IBOutlet weak var secondCurrencyButton: UIButton!
    @IBOutlet weak var thirdCurrencyButton: UIButton!
    
    @IBOutlet weak var firstCurrencyTextField: CustomTextField!
    @IBOutlet weak var secondCurrencyTextField: CustomTextField!
    @IBOutlet weak var thirdCurrencyTextField: CustomTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastUpdateDateLabel: UILabel!
    
    private let currencyService: CurrencyServiceProtocol = CurrencyService(
        apiManager: ApiManager(),
        cachedCurrency: CurrencyCache()
    )
    private var currencyArray: [CurrencyModel] = []
    
    private var rows: [CurrencyRow] = []
    private var selectedCodes: [String] = ["USD", "EUR", "UAH"]
    private var lastEditedIndex = 0
    
    private let spread = 0.01
    private var isSellMode = true
    private var currentMultiplier: Double { isSellMode ? 1 - spread : 1 + spread }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRows()
        setupUI()
        setupKeyboardLayout()
        loadCurrency()
        setupAccessibilityIdentifiers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
              let destination = navigationController.topViewController as? CurrencyViewController,
              let rowIndex = sender as? Int else {
            return
        }
        
        destination.currencies = currencyArray
        destination.selectedRowIndex = rowIndex
        
        destination.currentCode = selectedCodes[rowIndex]
        destination.disabledCodes = Set(
            selectedCodes.enumerated()
                .filter { $0.offset != rowIndex }
                .map(\.element)
        )
        
        destination.didSelectCurrency = { [weak self] currency, rowIndex in
            guard let self else { return }
            
            selectedCodes[rowIndex] = currency.code
            updateButtonTitle(at: rowIndex)
            convert(fromRowAt: lastEditedIndex)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Setup
    
    private func setupRows() {
        rows = [
            CurrencyRow(button: firstCurrencyButton, textField: firstCurrencyTextField),
            CurrencyRow(button: secondCurrencyButton, textField: secondCurrencyTextField),
            CurrencyRow(button: thirdCurrencyButton, textField: thirdCurrencyTextField)
        ]
    }
    
    private func setupKeyboardLayout() {
        scrollViewBottomConstraint.isActive = false
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        if #available(iOS 17.0, *) {
            view.keyboardLayoutGuide.usesBottomSafeArea = false
        }
    }
    
    private func setupUI() {
        for (index, row) in rows.enumerated() {
            row.textField.delegate = self
            row.textField.addTarget(self, action: #selector(amountChanged(_:)), for: .editingChanged)
            updateButtonTitle(at: index)
        }
    }
    
    private func loadCurrency() {
        Task { @MainActor in
            guard let result = await currencyService.fetchCurrencyService() else {
                lastUpdateDateLabel.text = "Немає даних"
                return
            }
            
            self.currencyArray = result.currencies
            updateLastUpdateLabel(with: result.date)
            convert(fromRowAt: lastEditedIndex)
        }
    }
    
    private func setupAccessibilityIdentifiers() {
        sellButton.accessibilityIdentifier = "sellButton"
        buyButton.accessibilityIdentifier = "buyButton"
        shareButton.accessibilityIdentifier = "shareButton"
        
        firstCurrencyButton.accessibilityIdentifier = "firstCurrencyButton"
        secondCurrencyButton.accessibilityIdentifier = "secondCurrencyButton"
        thirdCurrencyButton.accessibilityIdentifier = "thirdCurrencyButton"
        
        firstCurrencyTextField.accessibilityIdentifier = "firstCurrencyTextField"
        secondCurrencyTextField.accessibilityIdentifier = "secondCurrencyTextField"
        thirdCurrencyTextField.accessibilityIdentifier = "thirdCurrencyTextField"
    }
    
    // MARK: - Actions
    
    @IBAction private func currencyButtonTapped(_ sender: UIButton) {
        guard let index = rows.firstIndex(where: { $0.button === sender }) else { return }
        performSegue(withIdentifier: "CurrencyListSegue", sender: index)
    }
    
    @IBAction func modeButtonTapped(_ sender: CustomButtonView) {
        isSellMode = (sender == sellButton)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.sellButton.backgroundColor = self.isSellMode ? .tintColor : .clear
            self.sellButton.setTitleColor(self.isSellMode ? .white : .label, for: .normal)
            
            self.buyButton.backgroundColor = self.isSellMode ? .clear : .tintColor
            self.buyButton.setTitleColor(self.isSellMode ? .label : .white, for: .normal)
        })
        convert(fromRowAt: lastEditedIndex)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let message = makeShareMessage() else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        
        activityViewController.popoverPresentationController?.sourceView = sender
        present(activityViewController, animated: true)
    }
    
    private func makeShareMessage() -> String? {
        guard let nationalCurrency = currencyArray.first(where: { $0.code == "UAH" }),
              nationalCurrency.price != 0 else { return nil }
        
        let lines: [String] = selectedCodes
            .filter { $0 != "UAH" }
            .compactMap { code in
                currencyArray.first { $0.code == code }
            }
            .map { currency in
                let formattedRate = String(format: "%.3f", currency.price)
                return "1 \(currency.code) = \(formattedRate) \(nationalCurrency.code)"
            }
        
        guard !lines.isEmpty else { return nil }
        return (["Курс обміну (НБУ):"] + lines).joined(separator: "\n")
    }
    
    @objc private func amountChanged(_ textField: UITextField) {
        guard let index = rows.firstIndex(where: { $0.textField === textField }) else { return }
        lastEditedIndex = index
        convert(fromRowAt: index)
    }
    
    private func updateLastUpdateLabel(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "uk_UA")
        lastUpdateDateLabel.text = formatter.string(from: date)
    }
    
    // MARK: - Conversion
    
    private func parseAmount(_ text: String?) -> Double? {
        guard let text, !text.isEmpty else { return nil }
        return Double(text.replacingOccurrences(of: ",", with: "."))
    }
    
    private func currency(at index: Int) -> CurrencyModel? {
        currencyArray.first { $0.code == selectedCodes[index] }
    }
    
    private func updateButtonTitle(at index: Int) {
        let button = rows[index].button
        let code = selectedCodes[index]
        
        if button.configuration != nil {
            button.configuration?.title = code
        } else {
            button.setTitle(code, for: .normal)
        }
    }
    
    private func convert(fromRowAt sourceIndex: Int) {
        guard let amount = parseAmount(rows[sourceIndex].textField.text) else {
            clearRows(except: sourceIndex)
            return
        }
        guard let source = currency(at: sourceIndex) else { return }
        let converter = CurrencyConverter(multiplier: currentMultiplier)
        
        for index in rows.indices where index != sourceIndex {
            guard let target = currency(at: index), target.price != 0 else { continue }
            
            let convertedAmount = converter.convertCurrency(amount: amount, from: source, to: target)
            rows[index].textField.text = String(format: "%.3f", convertedAmount)
        }
    }
    
    private func clearRows(except sourceIndex: Int) {
        for index in rows.indices where index != sourceIndex {
            rows[index].textField.text = ""
        }
    }
}

// MARK: - Extensions

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textField = textField as? CustomTextField else { return }
        textField.updateBorderColor(isEditing: true)
        
        if let index = rows.firstIndex(where: { $0.textField === textField }) {
            lastEditedIndex = index
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? CustomTextField else { return }
        textField.updateBorderColor(isEditing: false)
    }
}
