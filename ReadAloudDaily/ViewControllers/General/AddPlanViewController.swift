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
        view.backgroundColor = UIColor(named: "SheetBackgroundColor")
        
        setupBackButton()
        titleLabel()
    }
}


// MARK: - 뒤로가기 버튼 설정
extension AddPlanViewController {
    
    // MARK: - 뒤로가기 버튼 설정
    private func setupBackButton() {

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
        
        view.addSubview(customView)
        customView.addSubview(xmarkImageView)
        
        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            customView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
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
    }

    
    // MARK: - Actions
    /// 뒤로가기 액션
    @objc private func popVC() {
        dismiss(animated: true)
    }
}


extension AddPlanViewController {
    
    private func titleLabel() {
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "무슨 책인가요?"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 22)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
    }
}

