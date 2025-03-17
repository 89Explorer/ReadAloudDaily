//
//  AddPlanViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/17/25.
//

import UIKit

class AddPlanViewController: UIViewController {
    
    
    // MARK: - Life Cycle 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        
        setupBackButton()
        
    }
}


// MARK: - NavigationBar 설정
extension AddPlanViewController {
    
    // MARK: - 뒤로가기 버튼 설정
    private func setupBackButton() {
        
        navigationItem.hidesBackButton = true

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let xmarkImage = UIImage(systemName: "xmark", withConfiguration: config)
        
        let customView = UIView()
        customView.backgroundColor = .systemBackground
        customView.layer.cornerRadius = 20
        customView.clipsToBounds = true
        customView.translatesAutoresizingMaskIntoConstraints = false

        let xmarkImageView = UIImageView(image: xmarkImage)
        xmarkImageView.tintColor = .label
        xmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        xmarkImageView.isUserInteractionEnabled = true
        
        customView.addSubview(xmarkImageView)
        
        NSLayoutConstraint.activate([
            customView.widthAnchor.constraint(equalToConstant: 40),
            customView.heightAnchor.constraint(equalToConstant: 40),
            
            xmarkImageView.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            xmarkImageView.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            xmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            xmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(popVC))
        customView.addGestureRecognizer(tapGesture)
        customView.isUserInteractionEnabled = true
        
        let xmarkBarButtonItem = UIBarButtonItem(customView: customView)
        
        self.navigationItem.leftBarButtonItem = xmarkBarButtonItem
    }

    @objc private func popVC() {
        navigationController?.popViewController(animated: true)
    }
}


