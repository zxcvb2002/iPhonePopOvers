//
//  ContentView.swift
//  iPhonePopOvers
//
//  Created by 드즈 on 2023/01/23.
//

import SwiftUI

/*
 struct ContentView: View {
    var body: some View {
        Home()
    }
}
*/


 struct ContentView: View {
     var body: some View {
         NavigationStack {
             Home().navigationTitle("iOS Popovers")
         }
     }
 }
 

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
