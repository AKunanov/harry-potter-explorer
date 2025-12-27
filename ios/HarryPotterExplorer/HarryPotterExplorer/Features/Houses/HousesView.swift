import SwiftUI

struct HousesView: View {
    @StateObject private var viewModel = HousesViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("Houses")
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
        .navigationTitle("Houses")
    }
}
