import Foundation
import CoreData

protocol CharacterListViewModelProtocol {
    func fetchCharacters(completion: @escaping ([CharacterInfo]?, Error?) -> ())
    var characters: [CharacterInfo] { get }
    var error: Error? { get }
    func returnDescriptionAndTextIfItsEmpty(character: MarvelCharacter) -> String
    func saveFavorite(with context: NSManagedObjectContext)
}

class CharacterListViewModel: CharacterListViewModelProtocol {
    
    private let useCase: CharacterListUseCase
    
    var characters: [CharacterInfo] = []
    var favoritedCharacters: Set<CharacterInfo> = []
    var error: Error?
    
    var characterInfoClosure: ([CharacterInfo]?, Error?) -> ()
    
    init(useCase: CharacterListUseCase) {
        self.useCase = useCase
        self.characterInfoClosure = { _, _ in }
    }
    
    func fetchCharacters(completion: @escaping ([CharacterInfo]?, Error?) -> ()) {
        useCase.fetch { [weak self] result in
            switch result {
            case .success(let characters):
                characters.data.results.forEach { character in
                    self?.createInfoAndAppend(with: character)
                }
                DispatchQueue.main.async {
                    completion(self?.characters, nil)
                }
//                self?.fetchCharacters(completion: completion)
            case .failure(let error):
                self?.fetchFailureCharacters(completion: completion)
                self?.error = error
            }
        }
    }

    func createInfoAndAppend(with character: MarvelCharacter) {
        let characterInfo = CharacterInfo(name: character.name,
                                          description: self.returnDescriptionAndTextIfItsEmpty(character: character) ,
                                          thumbnailPath: character.thumbnail?.path ?? "",
                                          thumbnailExtension: character.thumbnail?.extension ?? "")
        self.characters.append(characterInfo)
    }
    
    func returnFavorites(with context: NSManagedObjectContext) -> [CharacterInfo] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Characters")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            favoritedCharacters = []
            for data in result as! [NSManagedObject] {
                
                let favoriteCharacter = CharacterInfo(name: data.value(forKey: "name") as! String, description: data.value(forKey: "text") as! String, thumbnailPath: data.value(forKey: "imagePath") as? String ?? "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available", thumbnailExtension: data.value(forKey: "imageExtension") as? String ?? "jpg")
                favoritedCharacters.insert(favoriteCharacter)
            }
            return Array(favoritedCharacters)
        } catch {
            print("Failed")
            
            return []
        }
    }
    
    func fetchSuccessCharacters(completion: @escaping ([CharacterInfo]?, Error?) -> ()) {
        
    }
    
    func fetchFailureCharacters(completion: @escaping ([CharacterInfo]?, Error?) -> ()) {
        DispatchQueue.main.async {
            completion(nil, self.error)
        }
    }
    
    func returnDescriptionAndTextIfItsEmpty(character: MarvelCharacter) -> String {
        if character.description.isEmpty {
            return "No description :("
        }
        return character.description
    }
    
    func saveFavorite(with context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("error-Saving data")
        }
    }

}

struct CharacterInfo: Equatable, Hashable {
    let name: String
    let description: String
    let thumbnailPath: String
    let thumbnailExtension: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(thumbnailPath)
        hasher.combine(thumbnailExtension)
    }
    
    static func ==(lhs: CharacterInfo, rhs: CharacterInfo) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description && lhs.thumbnailPath == rhs.thumbnailPath && lhs.thumbnailExtension == rhs.thumbnailExtension
    }
}
