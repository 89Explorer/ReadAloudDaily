//
//  ReadMemoModel.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/26/25.
//

import Foundation


class ReadMemoModel {
    var id: String        // ex) "readItemID_memoID"
    var memo: String
    var page: Int
    var createOn: Date
    
    /// 🚗 새 독서 메모를 생성할 때 사용
    init(parentID: UUID, memo: String, page: Int) {
        self.id = "\(parentID.uuidString)_\(UUID().uuidString)"
        self.memo = memo
        self.page = page
        self.createOn = Date()
    }
    
    
    /// 🚗 기존 독서 메모를 불러오기 할 때 사용
    init(id: String, memo: String, page: Int, createOn: Date) {
        self.id = id
        self.memo = memo
        self.page = page
        self.createOn = createOn
    }
}
