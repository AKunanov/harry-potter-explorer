import SwiftUI

struct CharacterDetailsView: View {
    let characterId: String?

    @StateObject private var viewModel = CharacterDetailsViewModel()
    @ObservedObject private var favorites = FavoritesStore.shared
    @ObservedObject private var homeStore = HomeCharacterStore.shared
    @State private var didLoad = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.details == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.details == nil {
                Text(errorMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let details = viewModel.details {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerView(details: details)
                        sectionView(title: "Bio") {
                            detailRow(label: "Species", value: display(details.species))
                            detailRow(label: "Gender", value: display(details.gender))
                            detailRow(label: "Birth", value: birthText(date: details.dateOfBirth, year: details.yearOfBirth))
                        }
                        sectionView(title: "Appearance") {
                            detailRow(label: "Eye color", value: display(details.eyeColour))
                            detailRow(label: "Hair color", value: display(details.hairColour))
                        }
                        sectionView(title: "Actor") {
                            detailRow(label: "Name", value: display(details.actor))
                        }
                        sectionView(title: "Wand") {
                            detailRow(label: "Wood", value: display(details.wand?.wood))
                            detailRow(label: "Core", value: display(details.wand?.core))
                            detailRow(label: "Length", value: lengthText(details.wand?.length))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            } else {
                Text("—")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(display(viewModel.details?.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    guard let id = characterId, !id.isEmpty else { return }
                    favorites.toggle(id: id)
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .secondary)
                }
                .disabled(characterId == nil || characterId?.isEmpty == true)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Button {
                    guard let id = characterId, !id.isEmpty else { return }
                    homeStore.setSelected(id: id)
                } label: {
                    Text(homeButtonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 49)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
                .tint(homeButtonColor)
                .disabled(isHomeButtonDisabled)
            }
            .padding(.top, 10)
            .padding(.horizontal, 63)
            .padding(.bottom, 8)
        }
        .task {
            if didLoad { return }
            didLoad = true
            guard let id = characterId, !id.isEmpty else {
                viewModel.errorMessage = "Missing character id"
                return
            }
            await viewModel.load(id: id)
        }
    }

    private func headerView(details: CharacterDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                RemoteImage(
                    urlString: details.image,
                    size: 88,
                    cornerRadius: 8,
                    fallbackText: details.name,
                    colorSeed: details.id
                )
                VStack(alignment: .leading, spacing: 6) {
                    Text(display(details.name))
                        .font(.title2)
                        .bold()
                    Text("\(display(details.house)) • \(display(details.patronus))")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func sectionView(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label + ":")
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
        }
    }

    private func display(_ value: String?) -> String {
        guard let value, !value.isEmpty else {
            return "—"
        }
        return value
    }

    private func birthText(date: String?, year: Int?) -> String {
        let dateValue = (date?.isEmpty == false) ? date : nil
        let yearValue = year.map { String($0) }
        switch (dateValue, yearValue) {
        case (nil, nil):
            return "—"
        case let (date?, year?):
            return "\(date) (\(year))"
        case let (date?, nil):
            return date
        case let (nil, year?):
            return year
        }
    }

    private func lengthText(_ value: Double?) -> String {
        guard let value else { return "—" }
        let intValue = Int(value)
        if value == Double(intValue) {
            return String(intValue)
        }
        return String(value)
    }

    private var isFavorite: Bool {
        guard let id = characterId, !id.isEmpty else { return false }
        return favorites.isFavorite(id: id)
    }

    private var homeButtonTitle: String {
        isHomeCharacter ? "Shown on Home" : "Show on Home"
    }

    private var isHomeCharacter: Bool {
        guard let id = characterId, !id.isEmpty else { return false }
        return homeStore.selectedCharacterId == id
    }

    private var isHomeButtonDisabled: Bool {
        guard let id = characterId, !id.isEmpty else { return true }
        return homeStore.selectedCharacterId == id
    }

    private var homeButtonColor: Color {
        isHomeButtonDisabled ? Color.gray.opacity(0.4) : Color.accentColor
    }
}
