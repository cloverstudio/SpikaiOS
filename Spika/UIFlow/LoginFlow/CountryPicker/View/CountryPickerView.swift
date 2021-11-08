//
//  CountryPickerView.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit
import Combine

enum Section {
    case main
}

class CountryPickerView: UIView, BaseView {
    
    let cancelButton = ActionButton()
    let searchBar = SearchBar(placeholder: "Find country...")
    let allCountriesLabel = UILabel()
    let countriesTableView = UITableView()
    
    private let countries: [Country] = CountryHelper.shared.getCountries()
    
    lazy var filteredCountries: [Country] = countries
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(cancelButton)
        addSubview(searchBar)
        addSubview(allCountriesLabel)
        addSubview(countriesTableView)
    }
    
    func styleSubviews() {
        cancelButton.setTitle("Cancel", for: .normal)
        
        allCountriesLabel.text = "ALL COUNTRIES"
        allCountriesLabel.font = UIFont(name: "Montserrat-Regular", size: 9)
        allCountriesLabel.textColor = UIColor(named: Constants.Colors.appGray)
        
        countriesTableView.backgroundColor = .clear
        countriesTableView.rowHeight = CountryTableViewCell.rowHeight
        countriesTableView.separatorStyle = .none
        countriesTableView.showsVerticalScrollIndicator = false
        countriesTableView.contentInsetAdjustmentBehavior = .never
        countriesTableView.allowsSelection = true
        countriesTableView.tableHeaderView = nil
        countriesTableView.register(CountryTableViewCell.self, forCellReuseIdentifier: CountryTableViewCell.cellIdentifier)
    }
    
    func positionSubviews() {
        cancelButton.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20))
        cancelButton.constrainWidth(60)
        
        searchBar.anchor(top: cancelButton.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 18, left: 20, bottom: 12, right: 20))
        
        allCountriesLabel.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor,trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
        
        countriesTableView.anchor(top: allCountriesLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
    }
    
    func setupBindings() {
        
    }
    
    func filterCountries(filter: String) {
        if filter.isEmpty {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter{ $0.name.contains(filter) }
        }
        countriesTableView.reloadData()
    }
    
}
