//
//  AddPlanViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/17/25.
//

import UIKit
import Combine


class AddPlanViewController: UIViewController {
    
    // MARK: - Variables
    private var viewModel: ReadItemViewModel = ReadItemViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private let mode: AddPlanMode
    private var readItem: ReadItemModel
    private var isFormValid: Bool = false
    
    /// 선택된 날짜 저장
    private var selectedDates: [DateType: Date] = [
        .startDate: Date(),
        .endDate: Date()
    ]
    
    // MARK: - UI Components
    private let addItemTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let saveButton: UIButton = UIButton(type: .system)
    
    
    // MARK: - init
    
    init(mode: AddPlanMode, readItem: ReadItemModel? = nil) {
        self.mode = mode
        switch mode {
        case .create:
            self.readItem = readItem ?? ReadItemModel(
                title: "",
                startDate: Date(),
                endDate: Date(),
                dailyReadingTime: 0,
                isCompleted: false
            )
        case .edit:
            self.readItem = readItem!
        }
        
        self.viewModel.newCreatedItem = self.readItem
        super.init(nibName: nil, bundle: nil)
       
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "SheetBackgroundColor")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupBackButton()
        titleLabel(mode: mode)
        //titleLabel()
        //setupUI()
        setupUI(mode: mode)
        
        viewModel.validReadItemForm()
        populateUI()
        setupBinding()
        
    }
    
    
    // MARK: - Function
    // 바인딩 함수
    private func setupBinding() {
        
        viewModel.$isFormValid
            .sink { [weak self] isValid in
                self?.saveButton.isEnabled = isValid
                self?.saveButton.backgroundColor = isValid ? UIColor.systemGreen : UIColor.systemGray
                print("🔄 saveButton 상태 변경: \(isValid ? "활성화됨" : "비활성화됨")")
            }
            .store(in: &cancellables)
        
        viewModel.$isDateValid
            .sink { [weak self] isValid in
                guard let self = self else { return }
                if !isValid {
                    // ✅ 현재 `presentedViewController`가 있으면 먼저 닫기
                    if let presentedVC = self.presentedViewController {
                        presentedVC.dismiss(animated: true) {
                            DispatchQueue.main.async {
                                self.showAlert(title: "날짜 오류", message: "선택하신 시작일과 종료일을 다시 확인해주세요 😅")
                            }
                        }
                    } else {
                        self.showAlert(title: "날짜 오류", message: "선택하신 시작일과 종료일을 다시 확인해주세요 😅")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    /// 기존 데이터를 수정할 때, 기존 데이터를 받아오고, 테이블을 새로고침하는 메서드
    private func populateUI() {
        DispatchQueue.main.async {
            self.addItemTableView.reloadData()
        }
    }
    
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}



// MARK: - 뒤로가기 버튼 설정
extension AddPlanViewController {
    
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



// MARK: - Extension: 화면에 제목 생성하기
extension AddPlanViewController {
 
    private func titleLabel(mode: AddPlanMode) {
        let titleLabel: UILabel = UILabel()
        switch mode {
        case .create:
            titleLabel.text = "독서 계획을 세워주세요 :)"
        case .edit:
            titleLabel.text = "독서 계획을 수정해주세요 :)"
        }
        //titleLabel.text = "독서 계획을 세워주세요:)"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 26)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
    }
}



// MARK: - Extension: 테이블 및 버튼 설정
extension AddPlanViewController {
    
    private func setupUI(mode: AddPlanMode) {
        
        switch mode {
        case .create:
            saveButton.setTitle("일정 생성", for: .normal)
        case .edit:
            saveButton.setTitle("일정 수정", for: .normal)
        }
        
        //saveButton.setTitle("일정 생성", for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 24)
        saveButton.tintColor = .black
        saveButton.backgroundColor = .systemGray
        saveButton.layer.cornerRadius = 15
        saveButton.layer.masksToBounds = true
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.addTarget(self, action: #selector(didTappedSaveButton), for: .touchUpInside)
        
        addItemTableView.showsVerticalScrollIndicator = false
        addItemTableView.isScrollEnabled = false
        addItemTableView.backgroundColor = .clear
        addItemTableView.translatesAutoresizingMaskIntoConstraints = false
        
        addItemTableView.register(TimeCell.self, forCellReuseIdentifier: TimeCell.reuseIdentifier)
        addItemTableView.register(DateCell.self, forCellReuseIdentifier: DateCell.reuseIdentifier)
        addItemTableView.register(BookCell.self, forCellReuseIdentifier: BookCell.reuseIdentifier)
        addItemTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        addItemTableView.dataSource = self
        addItemTableView.delegate = self
        
        view.addSubview(addItemTableView)
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            addItemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addItemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addItemTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            addItemTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Actions
    /// 저장 버튼을 눌렀을 때 동작하는 저장 메서드
    @objc private func didTappedSaveButton() {
        print("✅ didTappedSaveButton - called")
        
        switch mode {
        case .create:
            viewModel.createNewReadItem(viewModel.newCreatedItem)
            print("🎉 새로운 데이터 저장: \(readItem)")
        case .edit:
            viewModel.updateReadItem(viewModel.newCreatedItem)
            print("🔨수정된 데이터 저장: \(readItem)")
        }
        dismiss(animated: true)
    }
    
}



// MARK: - Extension: 테이블 델리게이트 설정
extension AddPlanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AddItemTableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = AddItemTableSection.allCases[section]
        
        switch sectionType {
        case .book:
            return 1
        case .date:
            return DateType.allCases.count
        case .time:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch AddItemTableSection.allCases[indexPath.section] {
        case .book:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.reuseIdentifier, for: indexPath) as? BookCell else { return UITableViewCell() }
            
            cell.delegate = self
            cell.configure(readItem)
            return cell
            
        case .date:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DateCell.reuseIdentifier, for: indexPath) as? DateCell else {
                return UITableViewCell() }
            
            let dateType = DateType.allCases[indexPath.row]
            let date: Date?
            
            switch dateType {
            case .startDate:
                date = readItem.startDate
            case .endDate:
                date = readItem.endDate
            }
            
            cell.configure(with: dateType, date: date)
            cell.delegate = self
            
            return cell
            
        case .time:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCell.reuseIdentifier, for: indexPath) as? TimeCell else { return UITableViewCell() }
            
            cell.configure(with: "1회 독서 시간", time: readItem.dailyReadingTime)
            cell.delegate = self
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return AddItemTableSection.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        header.textLabel?.textColor = .black
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear // 투명한 뷰 추가
        return spacerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}



// MARK: - Enum: AddItemTable의 셀 관리 목적 섹션
enum AddItemTableSection: CaseIterable {
    case book
    case date
    case time
    
    var title: String {
        switch self {
        case .book:
            return "📖 책을 정해요"
        case .date:
            return "📆 독서 기간을 정해요"
        case .time:
            return "⏰ 독서 시간을 돌려서 정해요"
        }
    }
}


// MARK: - Enum: AddPlanViewController를 수정 / 생성을 구분하기 위한 열거형
enum AddPlanMode {
    case create
    case edit
}



// MARK: - Extension: BookCellDelegate
extension AddPlanViewController: BookCellDelegate {
    func didUpdateTitle(_ title: String) {
        //readItem.title = title
        //self.validReadItemForm()
        viewModel.newCreatedItem.title = title
        viewModel.validReadItemForm()
    }
}



// MARK: - Extension: TimeCellDelegate
extension AddPlanViewController: TimeCellDelegate {
    func didUpdateReadingTime(_ time: Int) {
        //readItem.dailyReadingTime = TimeInterval(time)
        //self.validReadItemForm()
        viewModel.newCreatedItem.dailyReadingTime = TimeInterval(time)
        viewModel.validReadItemForm()
    }
}



// MARK: - Extension: DateCellDelegate
extension AddPlanViewController: DateCellDelegate {
    func didSelectedDate(with type: DateType, date: Date) {
        
        switch type {
            
        case .startDate:
            //readItem.startDate = date
            viewModel.newCreatedItem.startDate = date
            viewModel.validReadItemForm()
            viewModel.validDateForm()
        case .endDate:
            //readItem.endDate = date
            viewModel.newCreatedItem.endDate = date
            viewModel.validReadItemForm()
            viewModel.validDateForm()
        }
        
        // selectedDates[type] = date
        // printSelectedDates()
    }
    
    /// 달력 선택 확인용 메서드
    private func printSelectedDates() {
        print("선택된 날짜 목록:")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        // ✅ DateType.allCases를 사용해 순서대로 출력
        for type in DateType.allCases {
            if let date = selectedDates[type] {
                let dateString = formatter.string(from: date)
                print("- \(type.title): \(dateString)")
            }
        }
    }
}



// MARK: - Extension: 경고창 메서드 구현
extension AddPlanViewController {
    /// 경고창
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}



// MARK: - Extension: Toast 메세지 기능 구현
extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let textSize = toastLabel.intrinsicContentSize
        let padding: CGFloat = 20
        let width = textSize.width + padding
        let height = textSize.height + padding
        
        // ✅ 토스트 메시지 위치 설정 (화면 하단)
        toastLabel.frame = CGRect(
            x: (view.frame.width - width) / 2,
            y: view.frame.height - 120,
            width: width,
            height: height
        )
        
        view.addSubview(toastLabel)
        
        // ✅ 애니메이션 (나타났다 사라지기)
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}


