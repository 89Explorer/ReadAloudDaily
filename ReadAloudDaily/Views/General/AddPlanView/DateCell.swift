//
//  DateCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//

import UIKit

class DateCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "DateCell"
    private var dateType: DateType = .startDate
    weak var delegate: DateCellDelegate?
    
    
    // MARK: - UI Component
    private let dateLabel: UILabel = UILabel()
    private let datePicker: UIDatePicker = UIDatePicker()
    private let innerStackView: UIStackView = UIStackView()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
    
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    private func setupUI() {
        dateLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        
        datePicker.datePickerMode = .date
        datePicker.tintColor = .black
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.timeZone = TimeZone(identifier: "Asia/Seoul")
        datePicker.date = Date()
        
        datePicker.addTarget(self, action: #selector(selectedDate), for: .valueChanged)
        
        innerStackView.axis = .horizontal
        innerStackView.spacing = 10
        innerStackView.distribution  = .fill
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        innerStackView.addArrangedSubview(dateLabel)
        innerStackView.addArrangedSubview(datePicker)
        
        contentView.addSubview(innerStackView)
        
        NSLayoutConstraint.activate([
            innerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            innerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            innerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dateLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// 선택일, 종료일 선택 메서드
    func configure(with type: DateType, date: Date?) {
        self.dateType = type
        dateLabel.text = type.title
        datePicker.date = date ?? Date()
        //datePicker.countDownDuration = date?.timeIntervalSince1970 ?? 0
    }
    
    
    // MARK: - Actions
    @objc private func selectedDate() {
        delegate?.didSelectedDate(with: dateType, date: datePicker.date)
    }
}


// MARK: - Enum: 날짜선택 구분
enum DateType: CaseIterable {
    case startDate
    case endDate
    
    var title: String {
        switch self {
        case .startDate:
            return "시작일"
        case .endDate:
            return "종료일"
        }
    }
}


// MARK: - Protocol:
protocol DateCellDelegate: AnyObject {
    func didSelectedDate(with type: DateType, date: Date)
}

