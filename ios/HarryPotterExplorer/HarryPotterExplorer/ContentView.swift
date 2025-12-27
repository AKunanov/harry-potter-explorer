//
//  ContentView.swift
//  HarryPotterExplorer
//
//  Created by Арслан Кунанов on 27.12.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                HousesView()
            }
            .tabItem {
                Label("Houses", systemImage: "building.columns")
            }

            NavigationStack {
                CharactersView()
            }
            .tabItem {
                Label("Characters", systemImage: "person.3")
            }
        }
    }
}

#Preview {
    ContentView()
}
