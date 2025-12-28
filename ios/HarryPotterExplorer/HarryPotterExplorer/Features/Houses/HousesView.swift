import SwiftUI

struct HousesView: View {
    @StateObject private var viewModel = HousesViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorText = viewModel.errorText {
                Text(errorText)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.houses.isEmpty {
                Text("No houses")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.houses) { house in
                    NavigationLink {
                        HouseDetailsView(house: house)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(house.name)
                                .font(.headline)
                            Text(house.colors.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(house.animal)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Houses")
        .task {
            await viewModel.load()
        }
    }
}
