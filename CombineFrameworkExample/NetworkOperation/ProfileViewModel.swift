//
//  ProfileViewModel.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 09/08/26.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    
    // Published states observed by UI
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Dependency Injection (allows easy mock testing)
    init(networkService: NetworkServiceProtocol?) {
        self.networkService = networkService ?? NetworkService()
    }
    
    func getUserProfile(for id: Int) {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchUserProfile(userID: id)
            // Ensure UI updates happen on the Main Thread
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] profile in
                    guard let self = self else { return }
                    self.userProfile = profile
                }
            )
            // Retain the subscription lifecycle inside cancellables Set
            .store(in: &cancellables)
    }
}
