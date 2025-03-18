//
//  BookCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//

import UIKit

class BookCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "BookCell"
    
    
    // MARK: - UI Component
    private let titleTextField: UITextField = UITextField()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    private func setupUI() {
        titleTextField.placeholder = "📚 책 제목을 입력해주세요"
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.masksToBounds = true
        titleTextField.leftViewMode = .always
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        titleTextField.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        titleTextField.textColor = .black
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
