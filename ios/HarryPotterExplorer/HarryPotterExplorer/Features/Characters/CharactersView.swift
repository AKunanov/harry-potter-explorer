import SwiftUI

struct CharactersView: View {
    @StateObject private var viewModel = CharactersViewModel()
    @ObservedObject private var favorites = FavoritesStore.shared
    @State private var showFavoritesOnly = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("Filter", selection: $showFavoritesOnly) {
                Text("All").tag(false)
                Text("Favorites").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)

            Group {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorText = viewModel.errorText, viewModel.items.isEmpty {
                    VStack(spacing: 12) {
                        Text(errorText)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.reload() }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredItems) { item in
                        NavigationLink {
                            CharacterDetailsView(characterId: item.id)
                        } label: {
                            HStack(spacing: 12) {
                                RemoteImage(
                                    urlString: item.image,
                                    size: 48,
                                    cornerRadius: 8,
                                    fallbackText: item.name,
                                    colorSeed: item.id
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nonEmpty(item.name, fallback: "Unknown name"))
                                        .font(.headline)
                                    Text("\(nonEmpty(item.house, fallback: "Unknown house")) • \(nonEmpty(item.patronus, fallback: "Unknown patronus"))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                favoriteButton(for: item)
                            }
                            .padding(.vertical, 4)
                        }
                        .onAppear {
                            Task { await viewModel.loadNextPageIfNeeded(currentItem: item) }
                        }
                    }
                }
            }
        }
        .navigationTitle("Characters")
        .searchable(
            text: Binding(
                get: { viewModel.query },
                set: { viewModel.onQueryChanged($0) }
            )
        )
        .task {
            await viewModel.reload()
        }
    }

    private var filteredItems: [CharacterPreview] {
        guard showFavoritesOnly else { return viewModel.items }
        let favoriteIds = favorites.all()
        return viewModel.items.filter { item in
            guard let id = item.id else { return false }
            return favoriteIds.contains(id)
        }
    }

    private func nonEmpty(_ value: String?, fallback: String) -> String {
        guard let value, !value.isEmpty else {
            return fallback
        }
        return value
    }

    private func favoriteButton(for item: CharacterPreview) -> some View {
        let isFavorite = item.id.map { favorites.isFavorite(id: $0) } ?? false
        return Button {
            guard let id = item.id else { return }
            favorites.toggle(id: id)
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : .secondary)
        }
        .buttonStyle(.borderless)
        .disabled(item.id == nil)
    }
}
