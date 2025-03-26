//
//  AddMemoCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/26/25.
//

import UIKit

class AddMemoCell: UITableViewCell {
    
    
    // MARK: Variable
    static let reuseIdentifier: String = "AddMemoCell"
    weak var delegate: AddMemoCellDelegate?
    
    
    
    // MARK: - UI Components
    private let memoTextView: UITextView = UITextView()
    
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        self.setupUI()
        
        memoTextView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



// MARK: - Extension: UI 설정
extension AddMemoCell {
    
    private func setupUI() {
        memoTextView.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        memoTextView.textColor = .systemGray
        memoTextView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        memoTextView.text = "📝 독서 메모를 남겨보세요! (최대 300자)"
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(memoTextView)
        
        NSLayoutConstraint.activate([
            memoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            memoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            memoTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            memoTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            memoTextView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
}



// MARK: - Extension: UITextViewDelegate 설정
extension AddMemoCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "📝 독서 메모를 남겨보세요! (최대 200자)"
            textView.textColor = .systemGray
            delegate?.didAddMemo("")   // 플레이스홀더일 땐 빈 문자열 전달
        } else if textView.textColor != .systemGray {
            delegate?.didAddMemo(textView.text)
        }
    }
}



// MARK: - Protocol
protocol AddMemoCellDelegate: AnyObject {
    func didAddMemo(_ memo: String) 
}
