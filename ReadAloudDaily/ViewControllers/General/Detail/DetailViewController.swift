//
//  DetailViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/24/25.
//

import UIKit
import Combine

class DetailViewController: UIViewController {
    
    
    // MARK: - Variable
    private var readItem: ReadItemModel
    var viewModel = ReadItemViewModel()
    var memoViewModel = AddMemoViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Component
    private let detailTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addMemoButton: UIButton = UIButton(type: .system)
    
    
    // MARK: - Init
    init(readItem: ReadItemModel) {
        self.readItem = readItem
        
        memoViewModel.readItemModel = readItem
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
        self.configureBackBarButton()
        self.configureNavigationTitle()
        setupUI()
        
        didTappAddMemoButton()
        setupBindings()
        //memoViewModel.fetchReadMemos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoViewModel.fetchReadMemos()
    }
    
    
    // MARK: - Function
    func didTappAddMemoButton() {
        addMemoButton.addTarget(self, action: #selector(addMemo), for: .touchUpInside)
    }
    
    private func setupBindings() {
        memoViewModel.$readMemos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.detailTableView.reloadData()
                print("✅✅ DetailViewController: detailTableView 데이터 업데이트")
            }
            .store(in: &cancellables)
        
        
    }
    
    
    
    
    // MARK: - Action
    @objc private func addMemo() {
        print("🌟 AddMemoButton - called")
        
        let addMemoVC = AddMemoViewController(mode: .create, readItem: readItem, readMemo: nil)
        
        if let sheet = addMemoVC.sheetPresentationController {
            sheet.detents = [.large()
            ]
            
//            sheet.detents = [
//                .custom { _ in
//                    550.0
//                }
//            ]
            
            sheet.preferredCornerRadius = 25
            sheet.prefersGrabberVisible = true
            
        }
        
        present(addMemoVC, animated: true)
    }
}



// MARK: - Extension: UI 설정
extension DetailViewController {
    
    private func setupUI() {
        
        detailTableView.showsVerticalScrollIndicator = false
        detailTableView.backgroundColor = .clear
        detailTableView.separatorStyle = .none
        detailTableView.register(ReviewDetailCell.self, forCellReuseIdentifier: ReviewDetailCell.reuseIdentifier)
        detailTableView.register(PlanDetailCell.self, forCellReuseIdentifier: PlanDetailCell.reuseIdentifier)
        detailTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        
        addMemoButton.setTitle("메모 작성하기", for: .normal)
        addMemoButton.titleLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        addMemoButton.setTitleColor(.black, for: .normal)
        addMemoButton.backgroundColor = .systemOrange
        addMemoButton.layer.cornerRadius = 15
        addMemoButton.layer.masksToBounds = true
        addMemoButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(detailTableView)
        view.addSubview(addMemoButton)
        
        NSLayoutConstraint.activate([
            
            detailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailTableView.topAnchor.constraint(equalTo: view.topAnchor),
            detailTableView.bottomAnchor.constraint(equalTo: addMemoButton.topAnchor, constant: 10),
            
            addMemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            addMemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addMemoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            addMemoButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
}



// MARK: - Extension: UITableViewDelegate, UITableViewDataSource 델리게이트 설정
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DetailViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = DetailViewSection.allCases[section]
        
        switch section {
        case .planInfo:
            return 1
        case .reviewInfo:
            return memoViewModel.readMemos.count
        }
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = DetailViewSection.allCases[indexPath.section]
        
        switch section {
        case .planInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanDetailCell.reuseIdentifier, for: indexPath) as? PlanDetailCell else { return UITableViewCell() }
            
            cell.configure(with: readItem)
            cell.delegate = self
            return cell
            
        case .reviewInfo:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewDetailCell.reuseIdentifier, for: indexPath) as? ReviewDetailCell else { return UITableViewCell()}
            
            let selectedMemo = memoViewModel.readMemos[indexPath.row]
            cell.configure(selectedMemo)
            cell.delegate = self
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DetailViewSection.allCases[section].title
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        header.textLabel?.textColor = .black
    }
    
    
}



// MARK: - Extension: 네비게이션 컨트롤 설정
extension DetailViewController {
    
    // 뒤로가기 버튼 커스텀 메서드
    private func configureBackBarButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        
        let backButton = UIButton(type: .system)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        
        let backBarItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarItem
    }
    
    @objc private func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    private func configureNavigationTitle() {
        let customView = UILabel(frame: .zero)
        customView.text = "상세 페이지"
        customView.textColor = .black
        customView.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 30)
        
        navigationItem.titleView = customView
    }
    
}


// MARK: - Protocol: ReviewDetailCellDelegate 설정 (settingButton 수정 / 삭제)
extension DetailViewController: ReviewDetailCellDelegate {
    func didTappedSettingButton(for memo: ReadMemoModel, from sender: UIButton) {
        print("⚙️ 설정 버튼 누름 - ID: \(memo.id)")
        
        let alert = UIAlertController(title: "수정 또는 삭제를 하시겠습니까?", message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "수정", style: .default) { _ in
            let editVC = AddMemoViewController(mode: .edit, readItem: self.readItem, readMemo: memo)
            
            if let sheet = editVC.sheetPresentationController {
                sheet.detents = [
                    .large()
                ]
                sheet.preferredCornerRadius = 25
                sheet.prefersGrabberVisible = true
            }
            self.present(editVC, animated: true)
        }
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            print("🗑️ 삭제를 진행합니다. 삭제되는 메모 ID: \(memo.id)")
            self?.memoViewModel.deleteReadMemo(with: memo.id)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}




// MARK: - Extension: FinishedSwitchDelegate (완료 버튼 메서드)
extension DetailViewController: FinishedSwitchDelegate {
    
    func didfinishedSwitch(_ sender: UISwitch) {
        if sender.isOn {
            readItem.isCompleted = sender.isOn
            viewModel.updateReadItem(readItem)
        } else {
            readItem.isCompleted = sender.isOn
            viewModel.updateReadItem(readItem)
        }
    }
}




// MARK: - Enum: 상세페이지 테이블뷰 섹션 구분
enum DetailViewSection: CaseIterable {
    case planInfo
    case reviewInfo
    
    var title: String {
        switch self {
        case .planInfo:
            return "🗒️ 독서 계획 상세 정보"
        case .reviewInfo :
            return "📝 독서 메모"
        }
    }
}
