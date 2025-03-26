//
//  ReadItem+CoreDataProperties.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/26/25.
//
//

import Foundation
import CoreData


extension ReadItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadItem> {
        return NSFetchRequest<ReadItem>(entityName: "ReadItem")
    }

    @NSManaged public var dailyReadingTime: Double
    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var memos: NSSet?

}

// MARK: Generated accessors for memos
extension ReadItem {

    @objc(addMemosObject:)
    @NSManaged public func addToMemos(_ value: ReadMemo)

    @objc(removeMemosObject:)
    @NSManaged public func removeFromMemos(_ value: ReadMemo)

    @objc(addMemos:)
    @NSManaged public func addToMemos(_ values: NSSet)

    @objc(removeMemos:)
    @NSManaged public func removeFromMemos(_ values: NSSet)

}

extension ReadItem : Identifiable {

}
