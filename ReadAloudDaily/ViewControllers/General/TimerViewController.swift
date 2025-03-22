//
//  TimerViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/21/25.
//

import UIKit

class TimerViewController: UIViewController {
    
    
    // MARK: - Variable
    private var readItem: ReadItemModel
    private var timerCounting: Bool = false
    private var remainingSeconds: Int = 0
    private var scheduledTimer: Timer?
    private let startDateKey = "timer_start_date_key"
    
    
    private let userDefaults = UserDefaults.standard
    private let remaining_Time_Key: String = "remaining_Time_key"
    private let counting_Key: String = "counting_Key"
    
    
    // MARK: - UI Component
    private let timeLabel: UILabel = UILabel()
    private let titleView: UIView = UIView()
    private let targetImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private var titleStack: UIStackView = UIStackView()
    private var startStopButton: UIButton = UIButton(type: .system)
    private var resetButton: UIButton = UIButton(type: .system)
    private var innerStackView: UIStackView = UIStackView()
    
    
    
    // MARK: - Init
    init(readItem: ReadItemModel) {
        self.readItem = readItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.setupBackButton()
        self.setupUI()
        configure()
        view.backgroundColor = .systemBrown
        
        // remainingSeconds 복원
        remainingSeconds = userDefaults.integer(forKey: remaining_Time_Key)
        updateLabel()
        
        timerCounting = userDefaults.bool(forKey: counting_Key)
        
        if timerCounting {
            print("🚙 타이머 실행 중 → 타이머 복구")
            startTimer()
        } else {
            print("🚗 타이머 멈춘 상태 → 대기")
            stopTimer()
        }
        
        startStopButton.addTarget(self, action: #selector(startStopAction), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            if timerCounting {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    
    
    // MARK: - Functions
    func configure() {
        titleLabel.text = "Read Mode"
    }
    
}


// MARK: - Extension: 타이머 설정 함수
extension TimerViewController {
    
    func startTimer() {
        // 시작 시간 저장
        userDefaults.set(Date(), forKey: startDateKey)
        
        scheduledTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimeCounting(true)
        startStopButton.setTitle("PAUSE", for: .normal)
        startStopButton.setTitleColor(.systemRed, for: .normal)
    }
    
    func stopTimer() {
        if let startDate = userDefaults.object(forKey: startDateKey) as? Date {
            let elapsed = Int(Date().timeIntervalSince(startDate))
            remainingSeconds -= elapsed
            userDefaults.set(remainingSeconds, forKey: remaining_Time_Key)
        }
        
        scheduledTimer?.invalidate()
        userDefaults.removeObject(forKey: startDateKey)
        setTimeCounting(false)
        
        startStopButton.setTitle("START", for: .normal)
        startStopButton.setTitleColor(.white, for: .normal)
        updateLabel()
    }
    
    
    
    /// 타이머 실행 상태를 변경하는 메서드
    func setTimeCounting(_ value: Bool) {
        timerCounting = value
        userDefaults.set(timerCounting, forKey: counting_Key)
    }
    
    /// 초 단위 시간을 시간:분:초로 변환하는 메서드
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return (hour, min, sec)
    }
    
    /// 시간을 00:00:00 형식의 문자열로 변환하는 메서드
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    func updateLabel() {
        let time = secondsToHoursMinutesSeconds(remainingSeconds)
        timeLabel.text = makeTimeString(hour: time.0, min: time.1, sec: time.2)
    }
    
    @objc private func refreshValue() {
        if let startDate = userDefaults.object(forKey: startDateKey) as? Date {
            let elapsed = Int(Date().timeIntervalSince(startDate))
            let updatedRemaining = remainingSeconds - elapsed
            
            if updatedRemaining > 0 {
                let setTime = secondsToHoursMinutesSeconds(updatedRemaining)
                timeLabel.text = makeTimeString(hour: setTime.0, min: setTime.1, sec: setTime.2)
            } else {
                print("✅ 타이머 완료 ✅")
                stopTimer()
                timeLabel.text = "00:00:00"
            }
        }
    }
    
    @objc func startStopAction() {
        if timerCounting {
            stopTimer()
        } else {
            if remainingSeconds > 0 {
                userDefaults.set(remainingSeconds, forKey: remaining_Time_Key)
            }
            startTimer()
        }
    }
    
    @objc func resetAction() {
        stopTimer()
        let readTime = Int(readItem.dailyReadingTime)
        remainingSeconds = readTime
        userDefaults.set(remainingSeconds, forKey: remaining_Time_Key)
        updateLabel()
    }
    
}




// MARK: - Extension: Setup UI 설정
extension TimerViewController {
    
    private func setupUI() {
        
        timeLabel.text = "00:00:00"
        timeLabel.textColor = .black
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 80)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        let targetImage = UIImage(systemName: "book", withConfiguration: config)
        
        
        targetImageView.image = targetImage
        targetImageView.tintColor = .black
        targetImageView.contentMode = .scaleAspectFit
        targetImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        titleLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 18)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        
        titleStack.axis = .vertical
        titleStack.spacing = 5
        titleStack.alignment = .center
        titleStack.distribution = .fill
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        startStopButton.setTitle("START", for: .normal)
        startStopButton.setTitleColor(.white, for: .normal)
        startStopButton.backgroundColor = .systemGreen
        startStopButton.titleLabel?.font = .systemFont(ofSize: 40, weight: .bold)
        startStopButton.layer.cornerRadius = 20
        startStopButton.layer.masksToBounds = true
        
        
        resetButton.setTitle("RESET", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .systemRed
        resetButton.titleLabel?.font = .systemFont(ofSize: 40, weight: .bold)
        resetButton.layer.cornerRadius = 20
        resetButton.layer.masksToBounds = true
        
        
        innerStackView.axis = .horizontal
        innerStackView.distribution = .fillEqually
        innerStackView.spacing = 30
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(timeLabel)
        view.addSubview(titleStack)
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(targetImageView)
        
        
        innerStackView.addArrangedSubview(startStopButton)
        innerStackView.addArrangedSubview(resetButton)
        
        view.addSubview(innerStackView)
        
        NSLayoutConstraint.activate([
            
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 350),
            timeLabel.heightAnchor.constraint(equalToConstant: 100),
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            titleStack.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor),
            titleStack.widthAnchor.constraint(equalToConstant: 100),
            titleStack.heightAnchor.constraint(equalToConstant: 100),
            titleStack.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            
            innerStackView.centerXAnchor.constraint(equalTo: titleStack.centerXAnchor),
            innerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            innerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            innerStackView.heightAnchor.constraint(equalToConstant: 50),
            innerStackView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 60)
            
        ])
    }
}





// MARK: - Extension: 뒤로가기 버튼 설정
extension TimerViewController {
    
    // MARK: - 뒤로가기 버튼 설정
    private func setupBackButton() {
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let xmarkImage = UIImage(systemName: "xmark", withConfiguration: config)
        
        let customView = UIView()
        customView.backgroundColor = .systemBackground
        customView.layer.cornerRadius = 15
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
            customView.widthAnchor.constraint(equalToConstant: 30),
            customView.heightAnchor.constraint(equalToConstant: 30),
            
            xmarkImageView.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            xmarkImageView.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            xmarkImageView.widthAnchor.constraint(equalToConstant: 15),
            xmarkImageView.heightAnchor.constraint(equalToConstant: 15)
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


