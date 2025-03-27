//
//  ReviewDetailCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/25/25.
//

import UIKit

class ReviewDetailCell: UITableViewCell {
    
    
    // MARK: - Variables
    static let reuseIdentifier: String = "ReviewDetailCell"
    weak var delegate: ReviewDetailCellDelegate?
    private var currentMemo: ReadMemoModel?

    
    // MARK: - UI Component
    private let dateLabel: UILabel = UILabel()
    private let settingButton: UIButton = UIButton(type: .system)
    private let memoTextView: UITextView = UITextView()
    private let pageLabel: UILabel = UILabel()
    private let seperator: UIView = UIView()
    
    private let innerStackView: UIStackView = UIStackView()
    private let totalStackView: UIStackView = UIStackView()
    
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.backgroundColor = .white
        self.setupUI()
        tappedSettingButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    func configure(_ readMemo: ReadMemoModel) {
        self.currentMemo = readMemo
        let createDate = readMemo.createOn
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = formatter.string(from: createDate)
        
        memoTextView.text = readMemo.memo
        pageLabel.text = "여기까지 읽은 📃 페이지: \(readMemo.page)p "
    }
    
    
    private func tappedSettingButton() {
        settingButton.addTarget(self, action: #selector(didCalledSetting), for: .touchUpInside)
    }
    
    
    // MARK: - Actions
    @objc private func didCalledSetting() {
        print("didCalledSetting - called")
        guard let memo = currentMemo else { return }
        delegate?.didTappedSettingButton(for: memo, from: settingButton)
    }
}




// MARK: - Extension: UI 설정
extension ReviewDetailCell {
    
    private func setupUI() {
        dateLabel.text = "3월 12일"
        dateLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 14)
        dateLabel.textColor = .black
        dateLabel.numberOfLines = 1
        dateLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        settingButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingButton.tintColor = .black
        
        innerStackView.addArrangedSubview(dateLabel)
        innerStackView.addArrangedSubview(settingButton)
        innerStackView.axis = .horizontal
        innerStackView.distribution = .fill
        
        memoTextView.text = "평점 5.0, 5점 최고에요! 😀"
        memoTextView.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 14)
        memoTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        memoTextView.textColor = .black
        memoTextView.backgroundColor = .white
        memoTextView.isEditable = false
        memoTextView.textContainer.maximumNumberOfLines = 2
        memoTextView.isScrollEnabled = false 
        memoTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        pageLabel.text = "여기까지 읽은 페이지: 120p"
        pageLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 14)
        pageLabel.textColor = .black
        
        seperator.backgroundColor = .black
        
        totalStackView.addArrangedSubview(innerStackView)
        totalStackView.addArrangedSubview(memoTextView)
        totalStackView.addArrangedSubview(pageLabel)
        totalStackView.addArrangedSubview(seperator)
        totalStackView.axis = .vertical
        totalStackView.distribution = .fill
        totalStackView.spacing = 5
//        totalStackView.layer.cornerRadius = 5
//        totalStackView.layer.borderWidth = 2
//        totalStackView.layer.borderColor = UIColor.black.cgColor
        totalStackView.isLayoutMarginsRelativeArrangement = true
        totalStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        totalStackView.setCustomSpacing(3, after: pageLabel)
        
        contentView.addSubview(totalStackView)
        
        NSLayoutConstraint.activate([
            totalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            totalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            totalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            totalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            innerStackView.heightAnchor.constraint(equalToConstant: 34),
            settingButton.widthAnchor.constraint(equalToConstant: 34),
            memoTextView.heightAnchor.constraint(equalToConstant: 44),
            seperator.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
}



// MARK: - Protocol: settingButton을 눌렀을 때 동작할 델리게이트 패턴
protocol ReviewDetailCellDelegate: AnyObject {
    func didTappedSettingButton(for memo: ReadMemoModel, from sender: UIButton)
}
