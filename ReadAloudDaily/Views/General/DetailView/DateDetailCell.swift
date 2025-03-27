//
//  DateDetailCell.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/25/25.
//

import UIKit

class DateDetailCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DateDetailCell"

       let label = UILabel()

       override init(frame: CGRect) {
           super.init(frame: frame)
           //contentView.backgroundColor = .clear
           contentView.addSubview(label)
           label.textAlignment = .center
           label.textColor = .label 
           label.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               label.topAnchor.constraint(equalTo: contentView.topAnchor),
               label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
               label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
               label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
           ])
           contentView.layer.cornerRadius = 8
           contentView.layer.masksToBounds = true
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

       func configure(with date: Date, isCompleted: Bool?) {
           let day = Calendar.current.component(.day, from: date)
           label.text = "\(day)"
           switch isCompleted {
           case true:  contentView.backgroundColor = .systemGreen
           case false: contentView.backgroundColor = .systemRed
           case nil:   contentView.backgroundColor = .lightGray
           case .some(_):
               contentView.backgroundColor = .systemBackground
           }
       }
}
