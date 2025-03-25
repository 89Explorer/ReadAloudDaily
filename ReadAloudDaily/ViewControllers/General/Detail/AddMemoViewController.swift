//
//  AddMemoViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/25/25.
//

import UIKit

class AddMemoViewController: UIViewController {

    
    // MARK: - UI Components
    private let addMemoTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let saveMemoButton: UIButton = UIButton(type: .system)
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemOrange
        setupUI()
        setupBackButton()
        titleLabel(mode: .create)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

}



// MARK: - Extension: UI 설정
extension AddMemoViewController {
    
    // MARK: - Function: UI 설정
    private func setupUI() {
        addMemoTableView.separatorStyle = .none
        addMemoTableView.backgroundColor = .clear
        addMemoTableView.translatesAutoresizingMaskIntoConstraints = false
        
        addMemoTableView.register(CheckPageCell.self, forCellReuseIdentifier: CheckPageCell.reuseIdentifier)
        addMemoTableView.register(AddMemoCell.self, forCellReuseIdentifier: AddMemoCell.reuseIdentifier)
        addMemoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        addMemoTableView.delegate = self
        addMemoTableView.dataSource = self
        
        
        saveMemoButton.setTitle("독서 메모 저장", for: .normal)
        saveMemoButton.titleLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 24)
        saveMemoButton.setTitleColor(.black, for: .normal)
        saveMemoButton.backgroundColor = .systemGreen
        saveMemoButton.layer.cornerRadius = 15
        saveMemoButton.layer.masksToBounds = true
        saveMemoButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addMemoTableView)
        view.addSubview(saveMemoButton)
        
        NSLayoutConstraint.activate([
            addMemoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addMemoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addMemoTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            addMemoTableView.bottomAnchor.constraint(equalTo: saveMemoButton.topAnchor, constant: -10),
            
            saveMemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            saveMemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            saveMemoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveMemoButton.heightAnchor.constraint(equalToConstant: 40)
            
        ])
        
    }
}



// MARK: - Extension: 테이블 델리게이트 설정
extension AddMemoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AddMemoTableSection.allCases.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = AddMemoTableSection.allCases[section]
        
        switch sectionType {
        case .review:
            return 1
        case .pageCount:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch AddMemoTableSection.allCases[indexPath.section] {
            
        case .review:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddMemoCell.reuseIdentifier, for: indexPath) as? AddMemoCell else { return UITableViewCell() }
            return cell
            
        case .pageCount:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckPageCell.reuseIdentifier, for: indexPath) as? CheckPageCell else { return UITableViewCell() }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return AddMemoTableSection.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        header.textLabel?.textColor = .black
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
    
}



// MARK: - 뒤로가기 버튼 설정
extension AddMemoViewController {
    
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
            customView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
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



extension AddMemoViewController {
 
    private func titleLabel(mode: AddMemoMode) {
        let titleLabel: UILabel = UILabel()
        switch mode {
        case .create:
            titleLabel.text = "독서 메모를 입력해주세요:)"
        case .edit:
            titleLabel.text = "독서 메모을 수정해주세요 :)"
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




// MARK: - Enum: AddMemoTable의 셀 관리 목적 섹션
enum AddMemoTableSection: CaseIterable {
    case review
    case pageCount
    
    var title: String {
        switch self {
        case .review:
            return "📝 메모를 남겨보세요"
        case .pageCount:
            return "📖 페이지를 입력하세요"
        }
    }
}



// MARK: - Enum: AddMemoViewController를 수정 / 생성을 구분하기 위한 열거형
enum AddMemoMode {
    case create
    case edit
}
