//
//  ListView.swift
//  ios-literati
//
//  Created by Robert Norris on 29.06.23.
//

import SwiftUI



struct ListView: View {

    struct Person: Identifiable {
        let givenName: String
        let familyName: String
        let emailAddress: String
        let id = UUID()

        var fullName: String { givenName + " " + familyName }
    }
    
    @State private var people = [
        Person(givenName: "Juan", familyName: "Chavez", emailAddress: "juanchavez@icloud.com"),
        Person(givenName: "Mei", familyName: "Chen", emailAddress: "meichen@icloud.com"),
        Person(givenName: "Tom", familyName: "Clark", emailAddress: "tomclark@icloud.com"),
        Person(givenName: "Gita", familyName: "Kumar", emailAddress: "gitakumar@icloud.com")
    ]

    struct NestedView: View {

        @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
        @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
        @Environment(\.dynamicTypeSize) var typeSize
        @Binding var people: [Person]
        @State private var sortOrder = [KeyPathComparator(\Person.givenName, order: .reverse)
                                        , KeyPathComparator(\Person.familyName, order: .reverse)
                                        , KeyPathComparator(\Person.emailAddress, order: .reverse)]

        // Nota bene: Robert Norris - does not need to be a @ViewBuilder as it
        // is a single opaque type.
        private var list: some View {
            List(people) { person in
                VStack(alignment: .leading) {
                    HStack {
                        Text(person.givenName)
                        Text(person.familyName)
                    }
                    Text(person.emailAddress).font(.subheadline).foregroundColor(.blue)
                }
                .listRowBackground(Color.red)
            }
        }
        
        var body: some View {
            // Nota bene: Robert Norris - horizontalSizeClass == .compact covers all iPhone in portait,
            // excludes iPhone Plus in landscape, Both primary and secondary apps on iPad in split screen
            // and slide over in portrait, primary app on iPad and iPad mini in landscape, and secondary
            // app in all but iPad Pro in landscape. The use of typeSize further scopes the use.
            if horizontalSizeClass == .compact || typeSize > .large {
                if #available(iOS 16, *) {
                    NavigationStack {
                        list
                    }
                } else {
                    NavigationView {
                        list
                    }
                    .navigationViewStyle(.stack)
                }
            }
            else {
                if #available(iOS 16, *) {
                    HStack {
                        Table(people, sortOrder: $sortOrder) {
                            TableColumn("Given Name", value: \.givenName) { person in
                                VStack(alignment: .leading) {
                                    if verticalSizeClass == .compact {
                                        // Nota bane: Robert Norris - iPhone Plus in landscape; similar to a List.
                                        Text([person.givenName, person.familyName].joined(separator: " "))
                                        Text(person.emailAddress).foregroundStyle(.secondary)
                                    }
                                    else {
                                        Text(person.givenName)
                                    }
                                }
                            }
                            // Nota bene: Robert Norris - subsequent columns will be ignored when verticalSizeClass != .compact
                            // as such they will only display on iPad and macOS.
                            TableColumn("Family Name", value: \.familyName)
                            TableColumn("E-Mail Address", value: \.emailAddress)
                        }
                        .onChange(of: sortOrder) {
                            people.sort(using: $0)
                        }
                        //.background(Color.white)
                        //.padding()
                    }
                } else {
                    
                }
            }
        }
    }
    
    // @EnvironmentObject
    
    struct DataType: Identifiable {
        var id: Int
        let name: String
        let size: String
        let color: Color
    }
    @State var dataTypeList = [
        DataType(id: 0, name: "Integer", size: "4 bytes", color: .red),
        DataType(id: 1, name: "Character", size: "1 byte", color: .blue),
        DataType(id: 2, name: "Float", size: "4 bytes", color: .green),
        DataType(id: 3, name: "Double", size: "8 bytes", color: .yellow),
      ]
    let colors: [Color] =
        [.red, .orange, .yellow, .green, .blue, .purple]
    //let dataTypesArray = ["Integer", "String", "Float", "Double"]
    var body: some View {
        VStack {
//            ZStack {
//                ForEach(0..<colors.count) {
//                    Rectangle()
//                        .fill(colors[$0])
//                        .frame(width: 100, height: 100)
//                        .offset(x: CGFloat($0) * 10.0,
//                                y: CGFloat($0) * 10.0)
//                }
//            }
//            Grid {
//                GridRow {
//                    Text("Foo")
//                    Text("Bar")
//                }
//                GridRow {
//                    Text("1")
//                    Text("2")
//                    Text("3")
//                }
//            }
            List(dataTypeList) { dataType in
                HStack {
                    Text(dataType.name)
                    Text(dataType.size).foregroundColor(dataType.color)
                }
            }
            NestedView(people: $people)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListView()
                .previewDisplayName("Default")
            ListView()
                .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
                .previewDisplayName("iPad (10th generation)")
        }
    }
}
