//
//  PlanDetailCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/24/25.
//

import UIKit

class PlanDetailCell: UITableViewCell {
    
    // MARK: - Variables
    static let reuseIdentifier: String = "PlanDetailCell"
    
    var readDates: [Date] = []
    var updatedArray: [Bool?] = []
    
    weak var delegate: FinishedSwitchDelegate?
    
    
    // MARK: - UI Components
    private let titleLabel: UILabel = UILabel()
    private let titleValueLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()
    private let dateValueLabel: UILabel = UILabel()
    
    private let completedLabel: UILabel = UILabel()
    private let completedCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    private let timeLabel: UILabel = UILabel()
    private let timePickerView: UIDatePicker = UIDatePicker()
    
    private let finishedLabel: UILabel = UILabel()
    private let finishedSwitch: UISwitch = UISwitch()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    func configure(with readItem: ReadItemModel) {
        titleValueLabel.text = readItem.title
        
        let startDate = readItem.startDate
        let endDate = readItem.endDate
        let calendar = Calendar.current
        let today = Date()
        
        readDates = generateDates(from: startDate, to: endDate)
        
        updatedArray = []
        
        let startReadDate = self.formattedDate(startDate)
        let endReadDate = self.formattedDate(endDate)
        dateValueLabel.text = startReadDate + " ~ " + endReadDate
        
        for date in readDates {
            let dateKey = isoDateString(date)
            
            if let wasCompleted = readItem.completedDates[dateKey] {
                updatedArray.append(wasCompleted ? true : false)
            } else {
                if calendar.isDateInToday(date) || date > today {
                    updatedArray.append(nil)
                } else {
                    updatedArray.append(false)
                }
            }
        }
        
        timePickerView.countDownDuration = readItem.dailyReadingTime
        
        finishedSwitch.isOn = readItem.isCompleted
        
        //print("✅ updatedArray: \(updatedArray.count), readDates: \(readDates.count)")
        
        // 변경 사항 적용
        DispatchQueue.main.async {
            self.completedCollectionView.reloadData()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func isoDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // 날짜 비교를 "시간단위"
//    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
//        var dates: [Date] = []
//        var current = startDate
//        while current <= endDate {
//            dates.append(current)
//            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
//        }
//        return dates
//    }
    
    // 날짜 비교를 "날짜단위"
    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var current = startDate

        let calendar = Calendar.current

        while calendar.startOfDay(for: current) <= calendar.startOfDay(for: endDate) {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return dates
    }

}

// MARK: - Extension: UI 설정
extension PlanDetailCell {
    
    private func setupUI() {
        titleLabel.text = "📖 책 제목"
        titleLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        
        titleValueLabel.text = "과학을 보다"
        titleValueLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 16)
        titleValueLabel.textColor = .black
        titleValueLabel.textAlignment = .left
        
        dateLabel.text = "📅 독서 기간"
        dateLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .left
        
        dateValueLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 16)
        dateValueLabel.textColor = .black
        dateValueLabel.textAlignment = .left
        
        completedLabel.text = "✅ 기간 내 독서 여부"
        completedLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        completedLabel.textColor = .black
        completedLabel.textAlignment = .left
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        
        completedCollectionView.register(DateDetailCell.self, forCellWithReuseIdentifier: DateDetailCell.reuseIdentifier)
        completedCollectionView.collectionViewLayout = layout
        completedCollectionView.delegate = self
        completedCollectionView.dataSource = self
        
        timeLabel.text = "⏰ 독서 시간"
        timeLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        timeLabel.textColor = .black
        timeLabel.textAlignment = .left
        
        timePickerView.datePickerMode = .countDownTimer
        timePickerView.preferredDatePickerStyle = .wheels
        timePickerView.locale = Locale(identifier: "ko_KR")
        timePickerView.isEnabled = false
        timePickerView.tintColor = .black
        
        finishedLabel.text = "🎚️ 완료 여부"
        finishedLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        finishedLabel.textColor = .black
        finishedLabel.textAlignment = .left
        
        finishedSwitch.isOn = false
        finishedSwitch.onTintColor = .systemGreen
        finishedSwitch.addTarget(self, action: #selector(selectedFinished), for: .valueChanged)
        
        
        let finishedStackView: UIStackView = UIStackView()
        finishedStackView.axis = .horizontal
        finishedStackView.distribution = .fill
        
        finishedStackView.addArrangedSubview(finishedLabel)
        finishedStackView.addArrangedSubview(finishedSwitch)
        
        
        let innerStackView: UIStackView = UIStackView(frame: .zero)
        innerStackView.addArrangedSubview(titleLabel)
        innerStackView.addArrangedSubview(titleValueLabel)
        innerStackView.addArrangedSubview(dateLabel)
        innerStackView.addArrangedSubview(dateValueLabel)
        innerStackView.addArrangedSubview(completedLabel)
        innerStackView.addArrangedSubview(completedCollectionView)
        innerStackView.addArrangedSubview(timeLabel)
        innerStackView.addArrangedSubview(timePickerView)
        innerStackView.addArrangedSubview(finishedStackView)
        innerStackView.axis = .vertical
        innerStackView.spacing = 3
        innerStackView.distribution = .fill
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(innerStackView)
        
        NSLayoutConstraint.activate([
            innerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            innerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            innerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            innerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 25),
            titleValueLabel.heightAnchor.constraint(equalToConstant: 40),
            dateLabel.heightAnchor.constraint(equalToConstant: 25),
            dateValueLabel.heightAnchor.constraint(equalToConstant: 40),
            completedLabel.heightAnchor.constraint(equalToConstant: 25),
            completedCollectionView.heightAnchor.constraint(equalToConstant: 60),
            timeLabel.heightAnchor.constraint(equalToConstant: 25),
            timePickerView.heightAnchor.constraint(equalToConstant: 40),
            
            finishedStackView.heightAnchor.constraint(equalToConstant: 25),
            finishedSwitch.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    // MARK: - Action
    @objc private func selectedFinished() {
        delegate?.didfinishedSwitch(finishedSwitch)
    }
}



// MARK: - Extension: UICollectionViewDelegate, UICollectionViewDataSource
extension PlanDetailCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return readDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateDetailCell.reuseIdentifier, for: indexPath) as? DateDetailCell else { return UICollectionViewCell() }
        
        let date = readDates[indexPath.row]
        let isCompleted = updatedArray[indexPath.row]
        cell.configure(with: date, isCompleted: isCompleted)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false // 선택 막기
    }

}



// MARK: - Protocol: finishedSwitchDelegate (스위치를 통해 완료 여부 선택)
protocol FinishedSwitchDelegate: AnyObject {
    func didfinishedSwitch(_ sender: UISwitch)
}
