import Foundation

struct CharacterResponse: Codable {
    let code: Int
    let status: String
    let data: MarvelData
    let etag: String
}

struct MarvelData: Codable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [MarvelCharacter]
}

struct MarvelCharacter: Codable {
    let id: Int
    let name: String
    let description: String
    let modified: String
    let resourceURI: String
    let urls: [MarvelURL]
    let thumbnail: MarvelThumbnail
    let comics: MarvelInfo
    let stories: MarvelInfo
    let events: MarvelInfo
    let series: MarvelInfo
}

struct MarvelURL: Codable {
    let type: String
    let url: String
}

struct MarvelThumbnail: Codable {
    let path: String
    let `extension`: String
}

struct MarvelInfo: Codable {
    let available: Int
    let returned: Int
    let collectionURI: String
    let items: [MarvelItem]
}

struct MarvelItem: Codable {
    let resourceURI: String
    let name: String
}
