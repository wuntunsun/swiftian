//
//  RootView.swift
//  ios-literati
//
//  Created by Robert Norris on 03.07.23.
//

import SwiftUI


struct RootView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @available(iOS 16, *)
    private struct NavigationSplitView: View {
        
        @State private var columnVisibility = NavigationSplitViewVisibility.all
        
        var body: some View {
            
            SwiftUI.NavigationSplitView(columnVisibility: $columnVisibility) {
                ListView()
            } content: {
                ContentView()
            } detail: {
                MapView()
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
    
    var body: some View {
        if horizontalSizeClass == .compact {
            TabView {
                ContentView().tabItem { Label("Content", systemImage: "book.circle") }
                MapView().tabItem { Label("Map", systemImage: "map.circle") }
                ListView().tabItem { Label("List", systemImage: "list.bullet.circle") }
            }
        }
        else {
            if #available(iOS 16, *) {
                RootView.NavigationSplitView()
            }
            else {
                NavigationView {
                    ListView()
                    ContentView()
                    MapView()
                }
                .navigationViewStyle(.columns)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 8 (iOS 15.5)"))
                .previewDisplayName("iPhone 8 (iOS 15.5)")
            RootView()
                .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
                .previewDisplayName("iPad (10th generation)")
        }
    }
}
