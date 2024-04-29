public class FavoritedCharacter: NSManagedObject {
}

extension FavoritedCharacter {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritedCharacter> {
        return NSFetchRequest<FavoritedCharacter>(entityName: "Characters")
    }
    @NSManaged public var name: String?
    @NSManaged public var text: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var imageExtension: String?
}

import Foundation
import CoreData

class FavoritesCharacterViewModel {
    func returnFavorites(with context: NSManagedObjectContext) -> [FavoritedCharacter] {
        var collegeData = [FavoritedCharacter]()
            do {
                collegeData =
                    try context.fetch(FavoritedCharacter.fetchRequest())
            } catch {
                print("couldnt fetch")
            }
            return collegeData
    }
}
