import SwiftUI

struct HouseDetailsView: View {
    let house: House

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(house.name)
                    .font(.title)
                    .bold()
                Text("Founder: \(house.founder)")
                Text("Animal: \(house.animal)")
                Text("Colors: \(house.colors.joined(separator: ", "))")
                Text(house.description)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(house.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
