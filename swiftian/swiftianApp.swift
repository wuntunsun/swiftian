//
//  swiftianApp.swift
//  swiftian
//
//  Created by Robert Norris on 11.06.23.
//

import SwiftUI

@main
struct swiftianApp: App {
    
    @Environment(\.openURL) var openURL
    
    // .compact is e.g. iPhone/Landscape so height limited, everything else is .regular
    // some larger devices may still count as regular
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    // .compact is e.g. iPhone/Portrait so width limited, everything else is .regular
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    // https://www.hackingwithswift.com/books/ios-swiftui/changing-a-views-layout-in-response-to-size-classes
    @Environment(\.dynamicTypeSize) var typeSize
    // https://developer.apple.com/documentation/swiftui/viewthatfits provide variants...
    
    
//    In the horizontal case, regular applies to all iPads in full screen as well as some iPhones in landscape,
//    compact applies to all iPhones in portrait and most iPhones in landscape along with some iPad multitasking configurations,
//    and unspecified is the case where it is not yet determined.
//    For a better and more detailed explanation of size classes, check out this great article: https://useyourloaf.com/blog/size-classes/
    //
    // a Table in a .compact horizontalSizeClass will only display the first column
    // SwiftUI does not use constraints, uses modifiers instead...
    
    // https://developer.apple.com/documentation/swiftui/reducing-view-modifier-maintenance
    // create ViewModifier and apply with .modifier to apply it
    // its body function is also a @ViewBuilder but body(content: Content) rather than @ViewBuilder @MainActor var body: Self.Body { get }
    // an EmptyModifier() is a placeholder that can be switched at compile time...
    // an EnvironmentalModifier() will be resolved from the environment before use.
    // EquatableView compares itself against its previous value and prevents its child updating if its new value is the same as its old value (efficiency?)
    // SubscriptionView subscribes to a publisher with an action (cut out boiletplate code)
    // TupleView created from a swift tuple of View values
    // There are View styles... appropriate style for a particular presentation context. For example, a Label might appear as an icon, a string title, or both, depending on factors like the platform, whether the view appears in a toolbar, and so on
    // There are LazyHStack and LazyVStack whereby their contents are created lazily. Wrap in ScrollView to make scrollable.
    // PinnedScrollableViews set of view types that may be pinned to the bounds of a scroll view.
    // There are LazyVGrid and LazyHGrid which perform better than Grid with larger data sets. Uses GridItem...
    // List includes implicit vertical scrolling
    // Table includes implicit vertical scrolling, Narrow displays may adapt to show only the first column of the table
    //  slide-over on iPad and Mac is supported by Table... i.e. .compact horizontalSizeClass shows first column...
    // Group and GroupBox, Form is for data-entry, ControlGroup provide an optional label to this view that describes its children - SwiftUI uses the label when the group is moved to the toolbar’s overflow menu
    // NavigationStack and NavigationSplitView replaced NavigationView in iOS 16, they devolve to a 'stack' on .compact horizontalSizeClass
    //
    
    var body: some Scene { // @SceneBuilder, see also @CommandsBuilder, @ViewBuilder
        WindowGroup {
            RootView()
        }
        #if !os(iOS)
        .commands {
            CommandMenu("Menu") {
                Button("Settings") {
                    openURL(URL(string: UIApplication.openSettingsURLString)!)
                }.keyboardShortcut("s")
            }
        }
        #endif
    }
}
