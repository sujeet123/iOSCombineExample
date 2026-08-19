//
//  NetworkService.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 08/08/26.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchUserProfile(userID: Int) -> AnyPublisher<UserProfile, NetworkError>
}

enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknown(message: String)
    case clientError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .clientError(let code):
            return "The client Error while api calling: \(code)."
        case .serverError(let code):
            return "Server returned an error status code: \(code)."
        case .decodingError:
            return "Failed to parse the server response."
        case .unknown(let message):
            return "The unknown error occurrs during api calling"
        }
    }
}

class NetworkService: NetworkServiceProtocol {
    
    
    func fetchUserProfile(userID: Int) -> AnyPublisher<UserProfile, NetworkError> {
        guard let url = URL(string: "https://api.example.com/users/\(userID)") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
        // 1. Validate the HTTP response code
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    let code = (output.response as? HTTPURLResponse)?.statusCode ?? 500
                    throw NetworkError.serverError(statusCode: code)
                }
                return output.data
            }
        // 2. Decode JSON into UserProfile model
            .decode(type: UserProfile.self, decoder: JSONDecoder())
        // 3. Map any upstream errors to custom NetworkError
            .mapError { error -> NetworkError in
                if let netError = error as? NetworkError {
                    return netError
                } else if error is DecodingError {
                    return NetworkError.decodingError(error)
                } else {
                    return NetworkError.unknown(message: "")
                }
            }
        // 4. Type erase to clean up publisher signature
            .eraseToAnyPublisher()
    }
}

func fetchUserProfileWithoutCombine(userId: Int) async -> Result<UserProfile, Error> {
    guard let url = URL(string: "") else {
        return .failure(NetworkError.invalidURL)
    }
    do {
        
        let (data, urlResponse) = try await URLSession.shared.data(from: url)
        
        guard let urlResponse = urlResponse as? HTTPURLResponse,(200...299).contains(urlResponse.statusCode) else {
            guard let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode else {
                return .failure(NetworkError.unknown(message: ""))
            }
            
            if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode, (400...499).contains(statusCode) {
                return .failure(NetworkError.clientError(statusCode: statusCode))
            }
            return .failure(NetworkError.serverError(statusCode: statusCode))
        }
        
        let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
        return .success(userProfile)

    } catch  {
        return .failure(error)
    }
}

enum ProfileError: Error {
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case urlCorruptedError
    case otherError(message: String)
}

func fetchProfileDetailsUsingGeneric() async throws -> Data {
    guard let url = URL(string: "") else { throw ProfileError.urlCorruptedError }
    
    do {
        let (data, urlResponse) = try await URLSession.shared.data(from: url)
        guard let response = urlResponse as? HTTPURLResponse, (200...299).contains(response.statusCode) else { throw ProfileError.otherError(message: "") }
        return data
    } catch {
        throw ProfileError.otherError(message: "")
    }
}

func checkForLoop() {
    let array = ["sujeet", "Kumar", "Tiwary"]
    let itmes = [30, 40, 90]

    
    for item in array {
        print(array)
    }
    
    let dic = ["name": "Sujeet", "lastName": "Tiwary"]
    for (key, value) in dic {
        print("\(key)  \(value)")
    }
    
    for index in 1...3 {
        
    }
    for item in itmes {
        print("In the loop, the belwo items \(item)")
    }
    let length = itmes.count
    for index in 0..<length {
        print("The item at the index \(index) is \(itmes[index])")
    }
}

func reverseIntegerArray() -> [Int] {
    var intArray = [2,4,9,8,3]
    var left = 0
    var right = intArray.count - 1
    while left < right {
        intArray.swapAt(left, right)
        left += 1
        right -= 1
    }
    return intArray
}

func reverseIntegerArrayManually() -> [Int] {
    var intArray = [2,4,9,8,3]
    var left = 0
    var right = intArray.count - 1
    while left < right {
        let item = intArray[left]
        intArray[left] = intArray[right]
        intArray[right] = item
        //intArray.swapAt(left, right)
        left += 1
        right -= 1
    }
    return intArray
}
