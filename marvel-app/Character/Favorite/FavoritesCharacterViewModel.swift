import Foundation
import CoreData

class FavoritesCharacterViewModel {
    private var characterInfo: Set<CharacterInfo> = [] // Usando um conjunto para evitar duplicatas
    
    func returnFavorites(with context: NSManagedObjectContext) -> [CharacterInfo] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            
            for data in result as! [NSManagedObject] {
                
                let favoriteCharacter = CharacterInfo(name: data.value(forKey: "name") as! String, description: data.value(forKey: "text") as! String, thumbnailPath: data.value(forKey: "imagePath") as? String ?? "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available", thumbnailExtension: data.value(forKey: "imageExtension") as? String ?? "jpg")
                characterInfo.insert(favoriteCharacter)
            }
            
        } catch {
            print("Failed")
        }
        return Array(characterInfo) // Convertendo o conjunto de volta para um array antes de retornar
    }
}
