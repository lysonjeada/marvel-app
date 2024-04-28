import Foundation

class CharacterListUseCase: UseCaseProtocol {
    typealias ResponseType = CharacterResponse
    
    func fetch(completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        let publicKey = "079a73178747afd6070a2a57d934a551"
        let privateKey = "330f505638834d5e451aa39ac3e5cc7b893fb170"
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = "\(timestamp)\(privateKey)\(publicKey)".md5
        
        let urlString = "https://gateway.marvel.com:443/v1/public/characters?apikey=\(publicKey)&hash=\(hash)&ts=\(timestamp)&limit=100"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let marvelResponse = try JSONDecoder().decode(CharacterResponse.self, from: data)
                        completion(.success(marvelResponse))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
            case 409:
                if let data = data {
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        completion(.failure(NetworkError.customError(description: errorResponse.message)))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkError.unknownError))
                }
            default:
                completion(.failure(NetworkError.unknownError))
            }
        }.resume()
    }
}

