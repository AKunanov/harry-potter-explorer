import SwiftUI

struct RemoteImage: View {
    let urlString: String?
    var size: CGFloat
    var cornerRadius: CGFloat
    var fallbackText: String?
    var colorSeed: String?

    @StateObject private var loader: ImageLoader

    init(
        urlString: String?,
        size: CGFloat,
        cornerRadius: CGFloat,
        fallbackText: String? = nil,
        colorSeed: String? = nil
    ) {
        self.urlString = urlString
        self.size = size
        self.cornerRadius = cornerRadius
        self.fallbackText = fallbackText
        self.colorSeed = colorSeed
        let url = URL(string: urlString ?? "")
        self._loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(placeholderColor)
                    if let initials = initialsText {
                        Text(initials)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .task(id: key) {
            let url = URL(string: urlString ?? "")
            loader.update(url: url)
            await loader.load()
        }
        .id(key)
    }

    private var initialsText: String? {
        guard let text = fallbackText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        let parts = text.split { $0.isWhitespace || $0 == "-" }
        var letters: [String] = []
        for part in parts {
            if let first = part.first {
                letters.append(String(first).uppercased())
            }
            if letters.count == 2 { break }
        }
        guard !letters.isEmpty else { return nil }
        return letters.joined()
    }

    private var placeholderColor: Color {
        placeholderColor(for: colorSeed ?? fallbackText)
    }

    private var key: String {
        (urlString ?? "") + "|" + (colorSeed ?? "") + "|" + (fallbackText ?? "")
    }

    private func placeholderColor(for seed: String?) -> Color {
        guard let seed, !seed.isEmpty else {
            return Color.gray.opacity(0.2)
        }
        let hash = fnv1a64(seed)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.35, brightness: 0.92)
    }

    private func fnv1a64(_ value: String) -> UInt64 {
        var hash: UInt64 = 14695981039346656037
        let prime: UInt64 = 1099511628211
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= prime
        }
        return hash
    }
}
