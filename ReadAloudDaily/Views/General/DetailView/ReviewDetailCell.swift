//
//  ReviewDetailCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/25/25.
//

import UIKit

class ReviewDetailCell: UITableViewCell {
    
    
    // MARK: - Variables
    static let reuseIdentifier: String = "ReviewDetailCell"

    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
