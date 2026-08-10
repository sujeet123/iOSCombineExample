//
//  ProfileView.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 09/08/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView("Fetching Profile...")
            } else if let profile = viewModel.userProfile {
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.name ?? "")
                        .font(.title)
                        .bold()
                    Text(profile.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("Tap below to load profile")
            }
            
            Button("Load User #1") {
                viewModel.getUserProfile(for: 1)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
