//
//  ViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/17/25.
//

import UIKit

class ViewController: UIViewController {
    
    
    // MARK: - UI Components
    private let addItemButton: UIButton = UIButton(type: .system)
    

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemOrange
    
        didTappedAddItemButton()
        setupUI()
    }
    
    
    // MARK: - Functions
    private func didTappedAddItemButton() {
        addItemButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }
    
    
    // MARK: - Actions
    @objc private func addItem() {
        let addItemVC = AddPlanViewController()
        navigationController?.pushViewController(addItemVC, animated: true)
    }
}


// MARK: - Setting UI
extension ViewController {
    
    private func setupUI() {
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let plusImage = UIImage(systemName: "plus", withConfiguration: config)
        
        addItemButton.setImage(plusImage, for: .normal)
        addItemButton.tintColor = .label
        addItemButton.backgroundColor = .systemBackground
        addItemButton.layer.cornerRadius = 20
        addItemButton.layer.masksToBounds = true
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addItemButton)
        
        NSLayoutConstraint.activate([
            
            addItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addItemButton.widthAnchor.constraint(equalToConstant: 40),
            addItemButton.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }
}



