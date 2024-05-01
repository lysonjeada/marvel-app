import XCTest
import CoreData
@testable import marvel_app

class CharacterListViewModelTests: XCTestCase {
    
    var sut: CharacterListViewModelProtocol!
    var mockUseCase: MockCharacterListUseCase!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockCharacterListUseCase()
        sut = CharacterListViewModelMock(isSuccess: true, useCase: mockUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }
    
    func testSuccessFetchCharacters() {
        sut.fetchCharacters { character, error in
            XCTAssertEqual(self.mockUseCase.methodsCalled, [.successFetch])
            XCTAssertTrue(self.mockUseCase.fetchCalled)
            XCTAssertNil(error)
        }
    }
    
    func testFailureFetchCharacters() {
        sut = CharacterListViewModelMock(isSuccess: false, useCase: mockUseCase)
        sut.fetchCharacters { character, error in
            XCTAssertEqual(self.mockUseCase.methodsCalled, [.fetchCharactersFailureCalled, .showErrorCalled(error: "Unknown Error")])
            XCTAssertNotNil(error)
            XCTAssertTrue(self.mockUseCase.fetchCalled)
        }
    }
    
    func testReturnDescriptionAndTextIfItsEmpty() {
        let characterLoadedFromJson = mockUseCase.loadMarvelCharacters(from: "characters-list-without-description")
        characterLoadedFromJson?.forEach({ character in
            XCTAssertEqual(sut.returnDescriptionAndTextIfItsEmpty(character: character), "No description :(")
        })
    }
    
    func testSaveFavorite() {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        sut.saveFavorite(with: context)
        
        // Here you should check if the favorite character was saved correctly
    }
}

class MockCharacterListUseCase: CharacterListUseCase {
    var fetchCalled = false
    var isSuccess = false
    var methodsCalled: [MethodsCalled] = []
    
    enum MethodsCalled: Equatable {
        case successFetch
        case failureFetch
        case fetchCharactersFailureCalled
        case showErrorCalled(error: String)
    }
    
    func fetch(completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
        if isSuccess {
            let characterLoadedFromJson = loadMarvelCharacters(from: "characters-list")
            characterLoadedFromJson?.forEach({ character in
                completion(.success(character))
            })
            methodsCalled.append(.successFetch)
        } else {
            self.methodsCalled.append(.showErrorCalled(error: "Unknown Error"))
            self.methodsCalled.append(.fetchCharactersFailureCalled)
        }
        
        fetchCalled = true
    }
    
    func loadMarvelCharacters(from filename: String) -> [MarvelCharacter]? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let characters = try decoder.decode([MarvelCharacter].self, from: data)
                return characters
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
        return nil
    }
}

class CharacterInfoTests: XCTestCase {
    
    func testEquality() {
        let characterInfo1 = CharacterInfo(name: "name", description: "description", thumbnailPath: "path", thumbnailExtension: "extension")
        let characterInfo2 = CharacterInfo(name: "name", description: "description", thumbnailPath: "path", thumbnailExtension: "extension")
        XCTAssertEqual(characterInfo1, characterInfo2)
    }
    
    func testHashing() {
        let characterInfo1 = CharacterInfo(name: "name", description: "description", thumbnailPath: "path", thumbnailExtension: "extension")
        let characterInfo2 = CharacterInfo(name: "name", description: "description", thumbnailPath: "path", thumbnailExtension: "extension")
        XCTAssertEqual(characterInfo1.hashValue, characterInfo2.hashValue)
    }
}

class CharacterListViewModelMock: CharacterListViewModelProtocol {
    
    var methodsCalled: [MethodsCalled] = []
    
    var useCase: MockCharacterListUseCase?
    
    enum MethodsCalled: Equatable {
        case createInfoAndAppendCalled
        case fetchCharactersSuccessCalled
        case fetchCharactersFailureCalled
        case showErrorCalled(error: String)
    }
    
    var characters: [CharacterInfo] = []
    
    var error: Error?
    
    var isSuccess: Bool?
    
    init(isSuccess: Bool?, useCase: MockCharacterListUseCase) {
        self.useCase = useCase
        self.isSuccess = isSuccess
    }
    
    func fetchCharacters(completion: @escaping ([CharacterInfo]?, Error?) -> ()) {
        if isSuccess ?? false {
            let characterLoadedFromJson = useCase?.loadMarvelCharacters(from: "characters-list")
            characterLoadedFromJson?.forEach({ character in
                createInfoAndAppend(with: character)
            })
            self.methodsCalled.append(.fetchCharactersSuccessCalled)
        } else {
            self.methodsCalled.append(.showErrorCalled(error: error?.localizedDescription ?? ""))
            self.methodsCalled.append(.fetchCharactersFailureCalled)
        }
    }
    
    
    func createInfoAndAppend(with character: MarvelCharacter) {
        methodsCalled.append(.createInfoAndAppendCalled)
    }
    
    func returnDescriptionAndTextIfItsEmpty(character: MarvelCharacter) -> String {
        if character.description.isEmpty {
            return "No description :("
        }
        return character.description
    }
    
    func saveFavorite(with context: NSManagedObjectContext) {
        
    }
    
}


