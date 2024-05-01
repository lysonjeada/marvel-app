import Foundation

protocol UseCaseProtocol {
    associatedtype ResponseType: Decodable
        
    func fetch(completion: @escaping (Result<ResponseType, Error>) -> ())
}
