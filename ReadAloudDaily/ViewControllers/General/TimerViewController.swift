//
//  TimerViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/21/25.
//

import UIKit
import AudioToolbox


class TimerViewController: UIViewController {
    
    // MARK: - Variable
    private var readItem: ReadItemModel
    private var viewModel: ReadItemViewModel = ReadItemViewModel()
    
    private var timerCounting: Bool = false
    private var remainingSeconds: Int = 0
    private var scheduledTimer: Timer?
    private var baseRemainingSeconds: Int = 0
    
    
    
    private let startDateKeyPrefix = "timer_start_date_key_"
    private let userDefaults = UserDefaults.standard
    
    private var remainingTimeKey: String { "remaining_Time_\(readItem.id)" }
    private var countingKey: String { "counting_Key_\(readItem.id)" }
    private var startDateKey: String { startDateKeyPrefix + "\(readItem.id)" }
    
    // MARK: - UI Component
    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let trackLayer: CAShapeLayer = CAShapeLayer()
    private let modeLabel: UILabel = UILabel()
    private let iconImageView = UIImageView()
    private let startStopButton: UIButton = UIButton(type: .system)
    private let resetButton: UIButton = UIButton(type: .system)
    
    
    
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
        setupUI()
        configure()
        view.backgroundColor = .systemGreen
        
        restoreTimerState()
        
        startStopButton.addTarget(self, action: #selector(startStopAction), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        
        updateButtonUI()
        configureBackBarButton()
        
        NotificationPermissionManager.checkAndRequestPermission(from: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userDefaults.bool(forKey: countingKey) {
            print("📲 복귀 시 타이머 복원")
            refreshValue() // 먼저 label 즉시 업데이트
            startTimer() // 다시 화면 진입 시 자동 재시작 (백그라운드 포함)
        } else {
            updateLabel() // PAUSE 상태라면 그냥 라벨만 업데이트
        }
    }
    
    
    // MARK: - Functions
    private func restoreTimerState() {
        remainingSeconds = userDefaults.integer(forKey: remainingTimeKey)
        timerCounting = userDefaults.bool(forKey: countingKey)
        
        // 💡 여기가 중요! 복귀 시에도 기준 시간 다시 설정
        if let startDate = userDefaults.object(forKey: remainingTimeKey) as? Date {
            let elapsed = Int(Date().timeIntervalSince(startDate))
            baseRemainingSeconds = remainingSeconds + elapsed
        } else {
            baseRemainingSeconds = remainingSeconds
        }
        
        updateLabel()
    }
    
    
    private func configure() {
        titleLabel.text = readItem.title
        modeLabel.text = "Read Mode"
        iconImageView.image = UIImage(systemName: "book")
    }
}



// MARK: - 타이머 관련 메서드
extension TimerViewController {
    
    func startTimer() {
        guard remainingSeconds > 0 else {
            print("⛔️ 타이머 시작 불가: 남은 시간이 0 이하임 (\(remainingSeconds))")
            return
        }
        
        if userDefaults.object(forKey: startDateKey) == nil {
            userDefaults.set(Date(), forKey: startDateKey)
            baseRemainingSeconds = remainingSeconds
        }
        
        scheduledTimer?.invalidate()
        scheduledTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimeCounting(true)
        updateButtonUI()
        
        scheduleLocalNotification(after: remainingSeconds)
        
    }
    
    
    func stopTimer() {
        if let startDate = userDefaults.object(forKey: startDateKey) as? Date {
            let elapsed = Int(Date().timeIntervalSince(startDate))
            baseRemainingSeconds -= elapsed
            remainingSeconds = baseRemainingSeconds
            userDefaults.set(remainingSeconds, forKey: remainingTimeKey)
        }
        
        scheduledTimer?.invalidate()
        userDefaults.removeObject(forKey: startDateKey)
        setTimeCounting(false)
        updateButtonUI()
        updateLabel()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_\(readItem.id)"])
    }
    
    func setTimeCounting(_ value: Bool) {
        timerCounting = value
        userDefaults.set(value, forKey: countingKey)
    }
    
    func updateLabel() {
        let time = secondsToHoursMinutesSeconds(remainingSeconds)
        timeLabel.text = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        updateProgress()
    }
    
    func updateProgress() {
        let total = max(Int(readItem.dailyReadingTime), 1)
        let progress = CGFloat(total - remainingSeconds) / CGFloat(total)
        progressLayer.strokeEnd = progress
    }
    
    func updateButtonUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let symbolName = timerCounting ? "pause.fill" : "play.fill"
        startStopButton.setImage(UIImage(systemName: symbolName, withConfiguration: config), for: .normal)
        startStopButton.tintColor = .white
    }
    
    // 알람이 완료되면 경고창 띄우기
    func presentTimerFinishedAlert() {
        let alert = UIAlertController(title: "타이머 종료", message: "읽기 시간이 완료되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // 백그라운드에 앱이 있을 때 대비하여 알림 서비스 등록
    func scheduleLocalNotification(after seconds: Int) {
        guard seconds > 0 else {
            print("⚠️ 알림 예약 실패: seconds가 0 이하입니다 (\(seconds))")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "타이머 종료"
        content.body = "\(readItem.title) 읽기 시간이 끝났어요!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "timer_\(readItem.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    
    @objc func refreshValue() {
        guard let startDate = userDefaults.object(forKey: startDateKey) as? Date else { return }
        
        let elapsed = Int(Date().timeIntervalSince(startDate))
        let updatedRemaining = baseRemainingSeconds - elapsed
        
        if updatedRemaining > 0 {
            remainingSeconds = updatedRemaining
            updateLabel()
        } else {
            stopTimer()
            timeLabel.text = "00:00:00"
            presentTimerFinishedAlert()
            AudioServicesPlaySystemSound(SystemSoundID(1005))
            
            // ✅ 읽기 완료 저장
            viewModel.markReadingCompleted(for: readItem)
        }
    }
    
    
    
    
    @objc func startStopAction() {
        
        if timerCounting {
            stopTimer()
        } else {
            startTimer()
        }
        
    }
    
    @objc func resetAction() {
        stopTimer()
        remainingSeconds = Int(readItem.dailyReadingTime)
        userDefaults.set(remainingSeconds, forKey: remainingTimeKey)
        updateLabel()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_\(readItem.id)"])
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        String(format: "%02d:%02d:%02d", hour, min, sec)
    }
}



// MARK: - UI 구성
extension TimerViewController {
    
    private func setupUI() {
        
        titleLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 50)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        modeLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        modeLabel.textColor = .white
        modeLabel.textAlignment = .center
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.isUserInteractionEnabled = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 70)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Circular Progress Path
        let center = view.center
        let radius: CGFloat = 150
        let circularPath = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 15
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.position = center
        view.layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 20
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        progressLayer.position = center
        view.layer.addSublayer(progressLayer)
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        startStopButton.setImage(UIImage(systemName: "play.fil", withConfiguration: config), for: .normal)
        startStopButton.tintColor = .white
        startStopButton.backgroundColor = .white.withAlphaComponent(0.3)
        startStopButton.layer.cornerRadius = 45
        startStopButton.clipsToBounds = true
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        resetButton.setImage(UIImage(systemName: "arrow.trianglehead.counterclockwise", withConfiguration: config),for: .normal)
        resetButton.tintColor = .white
        resetButton.backgroundColor = .white.withAlphaComponent(0.3)
        resetButton.layer.cornerRadius = 45
        resetButton.clipsToBounds = true
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(titleLabel)
        view.addSubview(modeLabel)
        view.addSubview(iconImageView)
        view.addSubview(timeLabel)
        view.addSubview(startStopButton)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            
            modeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            modeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeLabel.widthAnchor.constraint(equalToConstant: 200),
            
            iconImageView.topAnchor.constraint(equalTo: modeLabel.bottomAnchor, constant: 10),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            startStopButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 180),
            startStopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 90),
            startStopButton.heightAnchor.constraint(equalToConstant: 90),
            startStopButton.widthAnchor.constraint(equalToConstant: 90),
            
            
            resetButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 180),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            resetButton.heightAnchor.constraint(equalToConstant: 90),
            resetButton.widthAnchor.constraint(equalToConstant: 90)
            
        ])
    }
    
    
    // 뒤로가기 버튼 커스텀 메서드
    private func configureBackBarButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        
        let backButton = UIButton(type: .system)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        
        let backBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarItem
    }
    
    @objc private func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}






