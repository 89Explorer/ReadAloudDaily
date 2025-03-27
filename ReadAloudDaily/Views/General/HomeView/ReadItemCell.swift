//
//  ReadItemCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/20/25.
//

import UIKit

class ReadItemCell: UITableViewCell {
    
    // MARK: - Variables
    static let reuseIdentifier: String = "ReadItemCell"
    weak var delegate: ReadItemSettingButtonDelegate?
    
    private var viewModel = ReadItemViewModel()
    
    // 수정, 삭제 목적으로 선택된 데이터 확인용 변수
    private var currentItem: ReadItemModel?
    
    
    // MARK: - UI Components
    private let titleLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let completeLabel: UILabel = UILabel()
    private let startReadButton: UIButton = UIButton(type: .system)
    private let settingButton: UIButton = UIButton(type: .system)
    private var innerStackView: UIStackView = UIStackView()
    private var totalStackView: UIStackView = UIStackView()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //backgroundColor = .secondarySystemGroupedBackground
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        setupUI()
        
        didTappedSettingButton()
        didTappedStartButton()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    
    
    // MARK: - Function: SetupUI
    private func setupUI() {
        //titleLabel.text = "해리포터 돌의 시리즈 해리포터 돌의 시리즈"
        titleLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //dateLabel.text = "📅: 3월 12일 ~ 3월 20일"
        dateLabel.font =  UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 16)
        dateLabel.textColor = .label
        dateLabel.numberOfLines = 1
        
        //timeLabel.text = "⏰: 30분"
        timeLabel.font =  UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 16)
        timeLabel.textColor = .label
        timeLabel.numberOfLines = 1
        
        //completeLabel.text = "⚪️ ⚪️ ⚪️ ⚪️ ⚪️"
        completeLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 16)
        completeLabel.numberOfLines = 0
        
        startReadButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        startReadButton.setTitleColor(.label, for: .normal)
        startReadButton.tintColor = .label
        startReadButton.backgroundColor = .systemIndigo
        startReadButton.layer.cornerRadius = 20
        startReadButton.layer.masksToBounds = true
        startReadButton.translatesAutoresizingMaskIntoConstraints = false
        
        settingButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingButton.tintColor = .label
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        
        innerStackView.axis = .horizontal
        innerStackView.backgroundColor = .clear
        innerStackView.spacing = 10
        innerStackView.distribution = .fill
        innerStackView.addArrangedSubview(titleLabel)
        innerStackView.addArrangedSubview(settingButton)
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        totalStackView.axis = .vertical
        totalStackView.spacing = 10
        totalStackView.distribution = .fill
        totalStackView.alignment = .fill
        totalStackView.addArrangedSubview(innerStackView)
        totalStackView.addArrangedSubview(dateLabel)
        totalStackView.addArrangedSubview(completeLabel)
        //totalStackView.addArrangedSubview(startReadButton)
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(totalStackView)
        contentView.addSubview(startReadButton)
        NSLayoutConstraint.activate([
            
            totalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            totalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            totalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            totalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            settingButton.widthAnchor.constraint(equalToConstant: 40),
            //titleLabel.heightAnchor.constraint(equalToConstant: 40),
            dateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            startReadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            startReadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            startReadButton.widthAnchor.constraint(equalToConstant: 40),
            startReadButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    
    func configure(_ readItem: ReadItemModel) {
        self.currentItem = readItem
        
        titleLabel.text = readItem.title
        let startDate = readItem.startDate
        let endDate = readItem.endDate
        let today = Date()
        
        let startReadDate = self.formattedDate(startDate)
        let endReadDate = self.formattedDate(endDate)
        dateLabel.text = "📅 " + startReadDate + " ~ " + endReadDate
        
        let calendar = Calendar.current
        let totalDays = daysBetween(startDate, endDate)
        
        var updatedArray: [String] = []
        
        for offset in 0...totalDays {
            if let date = calendar.date(byAdding: .day, value: offset, to: startDate) {
                let dateKey = isoDateString(date)
                
                if let wasCompleted = readItem.completedDates[dateKey] {
                    updatedArray.append(wasCompleted ? "🟢" : "🔴")
                } else {
                    if calendar.isDateInToday(date) || date > today {
                        updatedArray.append("⚪️") // 오늘이거나 미래
                    } else {
                        updatedArray.append("🔴") // 과거인데 기록 없음 = 실패
                    }
                }
            }
        }
        
        completeLabel.text = updatedArray.joined(separator: " ")
    }
    
    
    private func isoDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    
}



// MARK: - Extension: 날짜 및 완료 횟수 설정 메서드
extension ReadItemCell {
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func completedString(_ rating: Double) -> String {
        let fullStar = Int(rating)
        let emptyStars = 5 - fullStar
        return String(repeating: "⚪️", count: fullStar) + String(repeating: "☆", count: emptyStars)
    }
    
    /// 두 날짜 간의 차리를 일(day) 단위로 계산해주는 메서드
    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    
}



// MARK: - Extension: settingButton 메서드 적용
extension ReadItemCell {
    
    private func didTappedSettingButton() {
        settingButton.addTarget(self, action: #selector(tappedSettingButton), for: .touchUpInside)
    }
    
    @objc private func tappedSettingButton() {
        guard let item = currentItem else { return }
        delegate?.didTappedSettingButton(for: item, from: settingButton)
    }
    
    private func didTappedStartButton() {
        startReadButton.addTarget(self, action: #selector(tappedStartButton), for: .touchUpInside)
    }
    
    @objc private func tappedStartButton() {
        guard let item = currentItem else { return }
        delegate?.didTappedStartButton(for: item, from: startReadButton)
    }
}



// MARK: - Protocol: settingButton을 눌렀을 때 동작할 델리게이트 패턴
protocol ReadItemSettingButtonDelegate: AnyObject {
    func didTappedSettingButton(for item: ReadItemModel, from sender: UIButton)
    func didTappedStartButton(for item: ReadItemModel, from sender: UIButton)
}

