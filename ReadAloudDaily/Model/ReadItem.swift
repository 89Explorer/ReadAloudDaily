//
//  ReadItem.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//

import Foundation

// MARK: - 데이터 모델 생성: 독서계획 저장 관리 목적
class ReadItemModel {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var dailyReadingTime: TimeInterval
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, dailyReadingTime: TimeInterval, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.dailyReadingTime = dailyReadingTime
        self.isCompleted = isCompleted
    }
}


// MARK - Extension: 날짜별 독서 완료 여부
extension ReadItemModel {
    var completedDates: [String: Bool] {
        let key = "completed_dates_\(self.id.uuidString)"
        return UserDefaults.standard.dictionary(forKey: key) as? [String: Bool] ?? [:]
    }
}

