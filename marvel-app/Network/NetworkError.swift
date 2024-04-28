import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case customError(description: String)
    case unknownError
}

struct ErrorResponse: Decodable {
    let code: String
    let message: String
}
