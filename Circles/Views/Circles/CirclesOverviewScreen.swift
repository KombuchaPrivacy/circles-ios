//  Copyright 2020, 2021 Kombucha Digital Privacy Systems LLC
//
//  CirclesOverviewScreen.swift
//  Circles for iOS
//
//  Created by Charles Wright on 11/5/20.
//

import SwiftUI

enum CirclesOverviewSheetType: String {
    case create
}
extension CirclesOverviewSheetType: Identifiable {
    var id: String { rawValue }
}

struct CirclesOverviewScreen: View {
    @ObservedObject var store: KSStore
    @State var selection: String = ""
    
    @State private var sheetType: CirclesOverviewSheetType? = nil
    
    var toolbarMenu: some View {
        Menu {
            Button(action: {self.sheetType = .create}) {
                Label("New Circle", systemImage: "plus")
            }
        }
        label: {
            Label("More", systemImage: "ellipsis.circle")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    ForEach(store.circles) { circle in
                        NavigationLink(destination: CircleTimelineScreen(circle: circle)) {
                            CircleOverviewCard(circle: circle)
                                //.padding(.top)
                        }
                        .onTapGesture {
                            print("DEBUGUI\tNavigationLink tapped for Circle \(circle.id)")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider()
                    }
                }
                
            }
            .padding(.top)
            .navigationBarTitle("My Circles", displayMode: .inline)
            .sheet(item: $sheetType) { st in
                switch(st) {
                case .create:
                    CircleCreationSheet(store: store)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    toolbarMenu
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CirclesOverviewScreen_Previews: PreviewProvider {
    static var previews: some View {
        CirclesOverviewScreen(store: KSStore())
    }
}
