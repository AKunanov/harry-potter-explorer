import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var store = HomeCharacterStore.shared

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.character == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.character == nil {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await viewModel.reload() }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let details = viewModel.character {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        NavigationLink {
                            CharacterDetailsView(characterId: details.id)
                        } label: {
                            characterCard(details: details)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Home")
        .task {
            await viewModel.load()
        }
        .onChange(of: store.selectedCharacterId) { _ in
            Task { await viewModel.onSelectedIdChanged() }
        }
    }

    private func characterCard(details: CharacterDetails) -> some View {
        let avatarSize: CGFloat = 96
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                RemoteImage(
                    urlString: details.image,
                    size: avatarSize,
                    cornerRadius: 16,
                    fallbackText: details.name,
                    colorSeed: details.id
                )
                .id(details.id ?? "")
                VStack(alignment: .leading, spacing: 6) {
                    Text(details.name ?? "—")
                        .font(.title3.bold())
                        .lineLimit(2)
                    Text("\(display(details.house)) \(display(details.patronus))")
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(height: avatarSize, alignment: .center)
                Spacer(minLength: 0)
            }
            Text(CharacterStoryGenerator.story(for: details))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func display(_ value: String?) -> String {
        guard let value, !value.isEmpty else {
            return "—"
        }
        return value
    }
}
