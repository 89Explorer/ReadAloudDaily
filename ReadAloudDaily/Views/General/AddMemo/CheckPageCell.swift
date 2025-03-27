//
//  CheckPageCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/26/25.
//

import UIKit

class CheckPageCell: UITableViewCell {
    
    
    // MARK: - Variables
    static let reuseIdentifier: String = "CheckPageCell"
    weak var delegate: CheckPageCellDelegate?
    
    
    // MARK: - UI Components
    private let pageTextField: UITextField = UITextField()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        self.setupUI()
        pageTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    func configure(_ readMemo: ReadMemoModel) {
        pageTextField.text = "\(readMemo.page)"
    }
    
}



// MARK: - Extension: UI 설정
extension CheckPageCell {
    
    private func setupUI() {
        pageTextField.keyboardType = .numberPad
        pageTextField.attributedPlaceholder = NSAttributedString(string: "현재까지 읽으신 페이지를 입력해주세요 :)", attributes: [.foregroundColor: UIColor.systemGray])
        pageTextField.leftView = .init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        pageTextField.leftViewMode = .always
        pageTextField.backgroundColor = .secondarySystemBackground
        pageTextField.layer.cornerRadius = 5
        pageTextField.layer.masksToBounds = true
        pageTextField.translatesAutoresizingMaskIntoConstraints = false
        pageTextField.addTarget(self, action: #selector(addPage), for: .editingChanged)
        
        contentView.addSubview(pageTextField)
        
        NSLayoutConstraint.activate([
            pageTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pageTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func addPage() {
        guard let text = pageTextField.text,
              let page = Int(text) else { return }
        delegate?.checkPage(page)
    }
}



// MARK: - Extension: UITextFieldDelegate 설정
extension CheckPageCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let numberOnly = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
                
        return numberOnly && updatedText.count <= 3
    }
}



// MARK: - Protocol: CheckPageCellDelegate
protocol CheckPageCellDelegate: AnyObject {
    func checkPage(_ page: Int)
}
