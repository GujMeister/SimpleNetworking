// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum DataFetchError: Error {
    case networkError(Error)
    case decodingError(Error)
}

public class WebService {
    
    public init() {}
    
    public func fetchData<T: Decodable>(from urlString: String, resultType: T.Type, completion: @escaping (Result<T, DataFetchError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.networkError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(.networkError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
