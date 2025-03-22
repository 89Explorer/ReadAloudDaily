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
        
        view.backgroundColor = .systemOrange
    }
}
