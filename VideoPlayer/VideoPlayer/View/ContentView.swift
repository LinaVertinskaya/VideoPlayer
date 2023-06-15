//
//  ContentView.swift
//  VideoPlayer
//
//  Created by Лина Вертинская on 13.06.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeArea = proxy.safeAreaInsets
            MainView(size: size, safeArea: safeArea)
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
