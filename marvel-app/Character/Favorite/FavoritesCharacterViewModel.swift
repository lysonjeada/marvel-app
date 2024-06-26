import Foundation
import CoreData

class FavoritesCharacterViewModel {
    private var characterInfo: Set<CharacterInfo> = [] // Usando um conjunto para evitar duplicatas
    
    func returnFavorites(with context: NSManagedObjectContext) -> [CharacterInfo] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            characterInfo = []
            for data in result as! [NSManagedObject] {
                
                let favoriteCharacter = CharacterInfo(name: data.value(forKey: "name") as! String, description: data.value(forKey: "text") as! String, thumbnailPath: data.value(forKey: "imagePath") as? String ?? "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available", thumbnailExtension: data.value(forKey: "imageExtension") as? String ?? "jpg")
                characterInfo.insert(favoriteCharacter)
            }
            return Array(characterInfo)
        } catch {
            print("Failed")
            
            return []
        }
    }
    
    func deleteFavorite(withName name: String, from context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object as! NSManagedObject)
            }
            
            try context.save()
        } catch {
            print("Error deleting favorite: \(error)")
        }
    }
}
