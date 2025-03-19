//
//  TimeCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//

import UIKit

class TimeCell: UITableViewCell {
    
    // MARK: - Variables
    static let reuseIdentifier: String = "TimeCell"
    private var remainingSeconds: Int = 0
    weak var delegate: TimeCellDelegate?
    
    
    // MARK: - UI Component
    private let timeLabel: UILabel = UILabel()
    private let datePicker: UIDatePicker = UIDatePicker()
    private let selectedTimeLabel: UILabel = UILabel()
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
    
    
    // MARK: - Function
    private func setupUI() {
        timeLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        
        //        selectedTimeLabel.text = "00:00:00"
        //        selectedTimeLabel.textColor = .black
        //        selectedTimeLabel.numberOfLines = 1
        //        selectedTimeLabel.backgroundColor = .systemGray6
        //        selectedTimeLabel.font = .systemFont(ofSize: 16, weight: .regular)
        //        selectedTimeLabel.isUserInteractionEnabled = true
        
        datePicker.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        datePicker.datePickerMode = .countDownTimer
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.addTarget(self, action: #selector(selectedTime(_ :)), for: .valueChanged)
        
        innerStackView.axis = .horizontal
        innerStackView.spacing = 10
        innerStackView.distribution  = .fill
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        innerStackView.addArrangedSubview(timeLabel)
        innerStackView.addArrangedSubview(datePicker)
        
        contentView.addSubview(innerStackView)
        
        NSLayoutConstraint.activate([
            innerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            innerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            innerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            datePicker.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    /// 테이블 셀에 데이터 전달
    func configure(with title: String) {
        timeLabel.text = title
    }
    
    
    /// 타이머를 눌러서, 타이머 설정하는 메서드
    private func selectedTimeTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectedTime(_ :)))
        selectedTimeLabel.addGestureRecognizer(tap)
    }
    
    
    // MARK: Actions
    @objc private func selectedTime(_ sender: UIDatePicker) {
        let selectedTime = Int(datePicker.countDownDuration)
        delegate?.didUpdateReadingTime(selectedTime)
        
        // 확인용
        let timer = secondsToHoursMinutesSeconds(selectedTime)
        print("선택된 시간: \(makeTimeString(hour: timer.0, min: timer.1, sec: timer.2))")
    }
}


// MARK: - Protocol: TimeCellDelegate (데이터 전달 목적)
protocol TimeCellDelegate: AnyObject {
    func didUpdateReadingTime(_ time: Int)
}




// MARK: - Extension: 날짜 선택 관련 설정 메서드 - UILabel 사용할 경우
extension TimeCell {
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    func updateLabel() {
        let time = secondsToHoursMinutesSeconds(remainingSeconds)
        selectedTimeLabel.text = makeTimeString(hour: time.0, min: time.1, sec: time.2)
    }
    
    /// 탭하면 타이머를 선택하고, 이를 라벨에 전달하는 메서드
    private func showSelectingTimer() {
        let alert = UIAlertController(title: "시간 선택", message: nil, preferredStyle: .actionSheet)
        
        // ✅ 별도의 UIViewController를 추가하여 UIDatePicker를 포함시키기
        let pickerViewController = UIViewController()
        pickerViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .countDownTimer
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.countDownDuration = TimeInterval(remainingSeconds) // 기존 선택된 시간 유지
        timePicker.locale = Locale(identifier: "ko_KR")
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        
        pickerViewController.view.addSubview(timePicker)
        
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: pickerViewController.view.centerXAnchor),
            timePicker.centerYAnchor.constraint(equalTo: pickerViewController.view.centerYAnchor)
        ])
        
        alert.setValue(pickerViewController, forKey: "contentViewController")
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // ✅ 선택한 시간 적용
            self.remainingSeconds = Int(timePicker.countDownDuration)
            self.updateLabel()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // ✅ iOS 13 이상에서는 `rootViewController`를 올바르게 찾아서 present
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
            .last {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
}



