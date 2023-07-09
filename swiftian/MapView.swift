//
//  MapView.swift
//  ios-literati
//
//  Created by Robert Norris on 29.06.23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.535152, longitude: 13.390206),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    var body: some View {
        Map(coordinateRegion: self.$region)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
