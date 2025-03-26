//
//  ReadMemo+CoreDataProperties.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/26/25.
//
//

import Foundation
import CoreData


extension ReadMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadMemo> {
        return NSFetchRequest<ReadMemo>(entityName: "ReadMemo")
    }

    @NSManaged public var id: String?
    @NSManaged public var memo: String?
    @NSManaged public var page: Int32
    @NSManaged public var createOn: Date?
    @NSManaged public var parent: ReadItem?

}

extension ReadMemo : Identifiable {

}
