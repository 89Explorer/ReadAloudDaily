//
//  DetailViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/24/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    // MARK: - Variable
    private var readItem: ReadItemModel
    
    
    // MARK: - UI Component
    private let detailTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
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
        view.backgroundColor = .systemGreen
        
        print("✅ 선택된 독서 계획은 : \(readItem.title)")
        self.configureBackBarButton()
        self.configureNavigationTitle()
        setupUI()
    }

}



// MARK: - Extension: UI 설정
extension DetailViewController {
    
    private func setupUI() {
        
        detailTableView.showsVerticalScrollIndicator = false
        detailTableView.backgroundColor = .clear
        detailTableView.separatorStyle = .none
        detailTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(detailTableView)
        
        NSLayoutConstraint.activate([
            
            detailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailTableView.topAnchor.constraint(equalTo: view.topAnchor),
            detailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
}



extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DetailViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "TEST"
        return cell
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
