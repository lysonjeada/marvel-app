import Foundation

struct CharacterInfo {
    let name: String
    let description: String
    let thumbnailPath: String
    let thumbnailExtension: String
}

protocol CharacterListPresenterProtocol {
    func didFetchCharacters(characters: [MarvelCharacter])
    func didFailToFetchCharacters(error: Error)
}

class CharacterListPresenter: CharacterListPresenterProtocol {
    
    private let view: CharacterListViewProtocol?
    
    init(view: CharacterListViewProtocol?) {
        self.view = view
    }
    
    func didFetchCharacters(characters: [MarvelCharacter]) {
        DispatchQueue.main.async { [weak self] in
            let formattedCharacters = characters.map { character in
                self?.returnCharacterInfo(character: character)
            }
            
           
            self?.view?.displayCharacters(characteres: formattedCharacters)
        }
    }
    
    func returnCharacterInfo(character: MarvelCharacter) -> CharacterInfo {
        CharacterInfo(name: character.name,
                      description: self.returnDescriptionAndTextIfItsEmpty(character: character),
                      thumbnailPath: character.thumbnail.path,
                      thumbnailExtension: character.thumbnail.extension)
    }
    
    func returnDescriptionAndTextIfItsEmpty(character: MarvelCharacter) -> String {
        if character.description.isEmpty {
            return "No description :("
        }
        return character.description
    }
    
    func didFailToFetchCharacters(error: Error) {
        
    }
}
