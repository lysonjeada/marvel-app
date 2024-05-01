import Foundation

enum FetchError: Error {
    case errorConnection
    case invalidUrl
    case executionError
    case invalidResponse
    case invalidDecode
    case unknownError
    case invalidData
}

class CharacterListUseCase: UseCaseProtocol {
    typealias ResponseType = CharacterResponse
    
    func fetch(completion: @escaping (Result<CharacterResponse, FetchError>) -> ()) {
        let publicKey = "079a73178747afd6070a2a57d934a551"
        let privateKey = "330f505638834d5e451aa39ac3e5cc7b893fb170"
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = "\(timestamp)\(privateKey)\(publicKey)".md5
        
        let urlString = "https://gateway.marvel.com:443/v1/public/characters?apikey=\(publicKey)&hash=\(hash)&ts=\(timestamp)&limit=100"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(FetchError.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(FetchError.executionError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(FetchError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let marvelResponse = try JSONDecoder().decode(CharacterResponse.self, from: data)
                        completion(.success(marvelResponse))
                    } catch {
                        completion(.failure(FetchError.invalidDecode))
                    }
                } else {
                    completion(.failure(FetchError.invalidData))
                }
            case 409:
                if let data = data {
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        completion(.failure(FetchError.errorConnection))
                    } catch {
                        completion(.failure(FetchError.errorConnection))
                    }
                } else {
                    completion(.failure(FetchError.errorConnection))
                }
            default:
                completion(.failure(FetchError.unknownError))
            }
        }.resume()
    }
}

