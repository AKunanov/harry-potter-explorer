import SwiftUI

struct CharactersView: View {
    @StateObject private var viewModel = CharactersViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("Characters")
                .font(.title2)
                .bold()
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text("Coming soon.")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Characters")
    }
}
