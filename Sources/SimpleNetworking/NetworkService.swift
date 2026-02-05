// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingFailed(Error)
}

@available(iOS 15.0, *)
public final class NetworkService {
    
    public init() {}
    
    // MARK: - Async/Await API
    
    /// Fetches and decodes data from the given URL
    /// - Parameters:
    ///   - urlString: The URL string to fetch from
    ///   - type: The type to decode to (can be inferred)
    /// - Returns: The decoded object
    /// - Throws: NetworkError if the request fails
    public func fetch<T: Decodable>(
        from urlString: String,
        as type: T.Type = T.self
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    // MARK: - Completion Handler API (for backwards compatibility)
    
    /// Fetches and decodes data from the given URL using completion handler
    /// - Parameters:
    ///   - urlString: The URL string to fetch from
    ///   - type: The type to decode to (can be inferred)
    ///   - completion: Result with decoded object or error
    public func fetch<T: Decodable>(
        from urlString: String,
        as type: T.Type = T.self,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        Task {
            do {
                let result = try await fetch(from: urlString, as: type)
                completion(.success(result))
            } catch let error as NetworkError {
                completion(.failure(error))
            } catch {
                completion(.failure(.requestFailed(error)))
            }
        }
    }
}
