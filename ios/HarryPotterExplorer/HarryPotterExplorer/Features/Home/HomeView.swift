import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Harry Potter Explorer")
                .font(.title2)
                .bold()
            Text("Pick a tab to get started.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Home")
    }
}
