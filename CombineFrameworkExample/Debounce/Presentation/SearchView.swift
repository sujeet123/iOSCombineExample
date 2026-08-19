//
//  SearchView.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 18/08/26.
//

import Foundation
import SwiftUI

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                searchField
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.results) { result in
                        Text(result.title)
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationTitle("Search")
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search...", text: $viewModel.query)
                .textFieldStyle(.plain)
            if !viewModel.query.isEmpty {
                Button(action: { viewModel.query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
