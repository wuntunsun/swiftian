//
//  ContentView.swift
//  swiftian
//
//  Created by Robert Norris on 19.06.23.
//

import SwiftUI


/*
 
    Storing long-term data:
    @AppStorage reads and writes values from UserDefaults. This owns its data. More info.
    @SceneStorage lets us save and restore small amounts of data for state restoration. This owns its data. More info.
    @FetchRequest starts a Core Data fetch request for a particular entity. This owns its data. More info.
 
    @Environment lets us read data from the system, such as color scheme, accessibility options, and trait collections, but you can add your own keys here if you want. This does not own its data. More info.
    @EnvironmentObject reads a shared object that we placed into the environment. This does not own its data. More info.
    @NSApplicationDelegateAdaptor is used to create and register a class as the app delegate for a macOS app. This owns its data.
    @ScaledMetric reads the user’s Dynamic Type setting and scales numbers up or down based on an original value you provide. This owns its data. More info.
    @UIApplicationDelegateAdaptor is used to create and register a class as the app delegate for an iOS app. This owns its data. More info.

    Reference type related propery wrappers:
    @StateObject is used to store new instances of reference type data that conforms to the ObservableObject protocol. This owns its data. More info.
    ...you can also use @StateObject to store it wherever it was originally created. This is not required, though: putting an object into the environment is enough to keep it alive without further ownership.
    @ObservedObject refers to an instance of an external class that conforms to the ObservableObject protocol. This does not own its data. More info.
    @Published is attached to properties inside an ObservableObject, and tells SwiftUI that it should refresh any views that use this property when it is changed. This owns its data. More info.

    So, @State means simple value type data created and managed locally but perhaps shared elsewhere using @Binding, and @StateObject means reference type data created and managed locally, but perhaps shared elsewhere using something like @ObservedObject.
    when we use @State to declare a property, we hand control over it to SwiftUI so that it remains persistent in memory for as long as the view exists.
    ObservedObject property get destroyed once their containing view struct redraws whereas StateObject don’t get destroyed.
    
    Prefer @Observable with iOS 17 as it works for both reference and value types:
    Starting with iOS 17, iPadOS 17, macOS 14, tvOS 17, and watchOS 10, SwiftUI provides support for Observation, a Swift-specific implementation of the observer design pattern.
    Using existing data flow primitives like State and Environment instead of object-based equivalents such as StateObject and EnvironmentObject.
    properties that are accessible to an observer that you don’t want to track, apply the ObservationIgnored macro to the property
 
    Value type related propery wrappers:
    @Binding refers to value type data owned by a different view. Changing the binding locally changes the remote data too. This does not own its data. More info.
    @State lets us manipulate small amounts of value type data locally to a view. This owns its data. More info.

    UI related propery wrappers:
    @FocusedBinding is designed to watch for values in the key wind ow, such as a text field that is currently selected. This does not own its data.
    @FocusedValue is a simpler version of @FocusedBinding that doesn’t unwrap the bound value for you. This does not own its data.
    @GestureState stores values associated with a gesture that is currently in progress, such as how far you have swiped, except it will be reset to its default value when the gesture stops. This owns its data. More info.
    @Namespace creates an animation namespace to allow matched geometry effects, which can be shared by other views. This owns its data.
    @ViewBuilder is a @resultBuilder that allows for
 
    WindowGroup is a Scene
    the App protocol defines @SceneBuilder @MainActor var body: Self.Body { get }
    an App can have multiple Scene and/or a Scene can have multiple WindowGroup
 
    Cmd+Shift+L or ⌘+⇧+L to open Library
 
 */


// processing values over time
// Publichser -> Subscriber
// Publishers only emit values when explicitly requested to do so by subscribers
// Use URLSession as Publisher Input/Output/Failure
// TextField -> Notification -> NotificationCenter.Publisher -> Subscriber
// sink and assign are default Subscriber (unlimited number of elements) others must be defined
// sequence-modifying operators such as map, flatMap and reduce can modify the published type.
// further operations customize behaviour e.g. filter and debounce (wait until user stops typing):

//let sub = NotificationCenter.default
//    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
//    .map( { ($0.object as! NSTextField).stringValue } )
//    .filter( { $0.unicodeScalars.allSatisfy({CharacterSet.alphanumerics.contains($0)}) } )
//    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
//    .receive(on: RunLoop.main)
//    .assign(to:\MyViewModel.filterString, on: myViewModel)

import Combine

class Bar {
    
}

class Foo: ObservableObject { // AnyObject i.e. class
    
    // @Published on a reference will show mutation on the reference only...
    // @Published is class constrained...
    @Published var children = [Bar]() // $children gives projected value i.e. Publisher
    
    init() {
        
        
    }
}

struct ContentView: View {
    
    @ObservedObject var foo = Foo() // ObservableObject
    
    @State var seconds: Int = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().eraseToAnyPublisher()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Image("IMG_6841")
                .resizable()
                .scaledToFit()
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .overlay {
                    Circle().stroke(.white, lineWidth: 4)
                }
                .shadow(radius: 7)
            Text("Hello World!").font(.title)
            HStack {
                Text("Peak District").font(.subheadline)
                Spacer()
                Text(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/)
            }
            Text("\(#function)").font(.title)
            Spacer()
            Text("Seconds passed \(self.seconds)").onReceive(timer) { _ in
                self.seconds += 1
            }
            Spacer(minLength: 150)

        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
