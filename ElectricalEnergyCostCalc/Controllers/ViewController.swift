//
//  ViewController.swift
//  ElectricalEnergyCostCalc
//
//  Created by Sümeyye Kazancı on 22.08.2022.
//

import UIKit

class ViewController: UIViewController {
    
    let coreDM: CoreDataManager = CoreDataManager.shared
    private var consumptions: [Consumption] = []
    private var consumptionList: [Double] = []
    private var users: [User] = []
    private var user: User?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Energy Cost Calc"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 42)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let serviceNumberTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.placeholder = "Enter Service Number"
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let serviceNumberErrorMessage: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.text = "*Must be 10 chars and contains only numbers and letters."
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let consumptionTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemPink.cgColor
        textField.placeholder = "Enter Consumption Value"
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.keyboardType = .decimalPad
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let consumptionErrorMessage: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = "Invalid value. Please check again."
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("SUBMIT", for: UIControl.State.normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemPink
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let costLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 4
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemPink.cgColor
//        label.textColor = UIColor.white
        label.text = "Cost"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: UIControl.State.normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemPink
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(serviceNumberTextField)
        view.addSubview(serviceNumberErrorMessage)
        view.addSubview(consumptionTextField)
        view.addSubview(consumptionErrorMessage)
        view.addSubview(submitButton)
        view.addSubview(tableView)
        view.addSubview(costLabel)
        view.addSubview(saveButton)
        
        applyConstraints()
        serviceNumberTextField.delegate = self
        consumptionTextField.delegate = self
        tableView.dataSource = self
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    private func calculate(lastConsumption: Double) -> String {
        var cost: Double = 0
        if lastConsumption <= 100 {
            cost = lastConsumption * Constants.firstUnit
        }else if lastConsumption <= 500 {
            cost = (lastConsumption - 100) * Constants.secondUnit
            cost += 100 * Constants.firstUnit
        }else {
            cost = (lastConsumption - 500) * Constants.thirdUnit
            cost += 400 * Constants.secondUnit
            cost += 100 * Constants.firstUnit
        }
        return String(format: "%.2f", cost) + "$"
    }
    
    @objc func didTapSubmitButton() {
        consumptionTextField.resignFirstResponder()
        consumptionList.removeAll()
        guard let serviceNumber = serviceNumberTextField.text else {
            return
        }
        
        if serviceNumber.count < 10 {
            let alert = UIAlertController(title: "Error", message: "Please fill the required field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        showSubView()
        
        user = coreDM.getUser(name: serviceNumber)
        print("user \(String(describing: user))")
        
        if let user = user {
            consumptions = coreDM.consumptions(user: user)
            print("consumptions \(consumptions)")
            for cons in consumptions.suffix(3) {
                consumptionList.append(cons.value)
            }
            guard let consumptionVal = Double(consumptionTextField.text ?? "0") else { return }
            
            if let lastValue = consumptionList.last {
                if lastValue > consumptionVal {
                    let alert = UIAlertController(title: "Error", message: "A new electric meter reading must not be lower than the previous meter reading", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    present(alert, animated: true)
                    return
                }else {
                    consumptionList.append(consumptionVal)
                    tableView.reloadData()
                }
                
                let actualConsumption = consumptionVal - lastValue
                costLabel.text = calculate(lastConsumption: actualConsumption)
            }
            
            
        }else {
            guard let consumptionVal = Double(consumptionTextField.text ?? "0") else { return }
            consumptionList.append(consumptionVal)
            costLabel.text = calculate(lastConsumption: consumptionVal)
            tableView.reloadData()
        }
        
    }
    
    @objc func didTapSaveButton() {
        hideSubView()
        serviceNumberTextField.text = ""
        consumptionTextField.text = ""
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        guard let serviceNumber = serviceNumberTextField.text else {
            return
        }
        consumptions.removeAll()
        user = coreDM.getUser(name: serviceNumber)
        print("user \(String(describing: user))")
        if let user = user {
            consumptions = coreDM.consumptions(user: user)
            print("consumptions \(consumptions)")
            guard let consumptionVal = Double(consumptionTextField.text ?? "0") else { return }
            let consumption = coreDM.consumption(consumption: consumptionVal, date: dateString, user: user)
            consumptions.append(consumption)
            coreDM.saveContext()
            print("new value added")
        }else {
            let newUser = coreDM.user(serviceNumber: serviceNumber)
            guard let consumptionVal = Double(consumptionTextField.text ?? "0") else { return }
            let consumption = coreDM.consumption(consumption: consumptionVal, date: dateString, user: newUser)
            consumptions.append(consumption)
            coreDM.saveContext()
            print("new user and value added")
        }
    }
    
    private func hideSubView() {
        tableView.isHidden = true
        costLabel.isHidden = true
        saveButton.isHidden = true
    }
    
    private func showSubView() {
        tableView.isHidden = false
        costLabel.isHidden = false
        saveButton.isHidden = false
    }
    
    private func applyConstraints() {
        
        let titleLabelConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60)
        ]
        
        let serviceNumberTextFieldConstraints = [
            serviceNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            serviceNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            serviceNumberTextField.topAnchor.constraint(equalTo:titleLabel.bottomAnchor, constant: 20),
            serviceNumberTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let serviceNumberErrorMessageConstraints = [
            serviceNumberErrorMessage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            serviceNumberErrorMessage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            serviceNumberErrorMessage.topAnchor.constraint(equalTo: serviceNumberTextField.bottomAnchor, constant: 10)
        ]
        
        let consumptionTextFieldConstraints = [
            consumptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            consumptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            consumptionTextField.topAnchor.constraint(equalTo: serviceNumberErrorMessage.bottomAnchor, constant: 10),
            consumptionTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let consumptionErrorMessageConstraints = [
            consumptionErrorMessage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            consumptionErrorMessage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            consumptionErrorMessage.topAnchor.constraint(equalTo: consumptionTextField.bottomAnchor, constant: 10),
            
        ]
        
        let submitButtonConstraints = [
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            submitButton.topAnchor.constraint(equalTo: consumptionErrorMessage.bottomAnchor, constant: 10),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let tableViewConstraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            tableView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 30),
            tableView.bottomAnchor.constraint(equalTo: costLabel.topAnchor, constant: -10)
        ]
        
        let costLabelConstraints = [
            costLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            costLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
//            costLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            costLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10)
        ]
        
        let saveButtonConstraints = [
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(serviceNumberTextFieldConstraints)
        NSLayoutConstraint.activate(serviceNumberErrorMessageConstraints)
        NSLayoutConstraint.activate(consumptionTextFieldConstraints)
        NSLayoutConstraint.activate(consumptionErrorMessageConstraints)
        NSLayoutConstraint.activate(submitButtonConstraints)
        NSLayoutConstraint.activate(tableViewConstraints)
        NSLayoutConstraint.activate(costLabelConstraints)
        NSLayoutConstraint.activate(saveButtonConstraints)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consumptionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(consumptionList[indexPath.item])
        return cell
    }
    
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == serviceNumberTextField {
            guard let serviceNumber = textField.text else {
                return
            }
            
            if serviceNumber.count < 10 || !serviceNumber.isAlphanumeric{
                serviceNumberErrorMessage.isHidden = false
            }else {
                serviceNumberErrorMessage.isHidden = true
            }
        }else if textField == consumptionTextField {
            guard let consumptionValue = textField.text else {
                return
            }
            
            if consumptionValue.isValidDouble(maxDecimalPlaces: 10) {
                consumptionErrorMessage.isHidden = true
            }else {
                consumptionErrorMessage.isHidden = false
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == serviceNumberTextField {
            let currentText = serviceNumberTextField.text ?? ""
                // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }
                // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                // make sure the result is under 10 characters
            return updatedText.count <= 10
            
        }else if textField == consumptionTextField {
            let allowedCharacters = CharacterSet(charactersIn:".0123456789")//Only number and dot allowed
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == serviceNumberTextField {
            consumptionTextField.becomeFirstResponder()
        }else if textField == consumptionTextField {
            didTapSubmitButton()
        }
        return true
    }
}

