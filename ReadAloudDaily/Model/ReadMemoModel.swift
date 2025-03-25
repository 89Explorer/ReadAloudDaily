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
    
    init(parentID: UUID, memo: String, page: Int) {
        self.id = "\(parentID.uuidString)_\(UUID().uuidString)"
        self.memo = memo
        self.page = page
    }
}
