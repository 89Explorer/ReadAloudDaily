//
//  BookCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//

import UIKit
import Combine

class BookCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "BookCell"
    var readItemViewModel: ReadItemViewModel?
    weak var delegate: BookCellDelegate?
    
    
    // MARK: - UI Component
    private let titleTextField: UITextField = UITextField()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        titleTextField.delegate = self
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
        titleTextField.textColor = .white
        titleTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    
    func configure(_ readItem: ReadItemModel) {
        titleTextField.text = readItem.title
    }
    
    
    // MARK: - Actions
    @objc private func textChanged() {
        let title = titleTextField.text ?? ""
        delegate?.didUpdateTitle(title)
    }
}


// MARK: - Extension: UITextFieldDelegate - 조건에 따라 테두리 스타일 변경 
extension BookCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text?.count == 0 {
            textField.layer.borderWidth = 1.5
            textField.layer.borderColor = UIColor.systemRed.cgColor
            textField.placeholder = "📚 책 제목은 꼭 입력해주세요"
        } else {
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}


// MARK: - Protocol: BookCellDelegate (데이터 전달 목적)
protocol BookCellDelegate: AnyObject {
    func didUpdateTitle(_ title: String)
}
