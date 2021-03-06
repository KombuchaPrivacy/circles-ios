//  Copyright 2020, 2021 Kombucha Digital Privacy Systems LLC
//
//  CirclePicker.swift
//  Circles for iOS
//
//  Created by Charles Wright on 11/10/20.
//

import SwiftUI

struct CirclePicker: View {
    @ObservedObject var store: KSStore
    @Binding var selected: Set<SocialCircle>
    
    var body: some View {
        VStack {
            List {
                ForEach(store.circles) { circle in
                    Button(action: {
                        if selected.contains(circle) {
                            selected.remove(circle)
                        }
                        else {
                            selected.insert(circle)
                        }
                    }) {
                        VStack {
                            if selected.contains(circle) {
                                HStack {
                                    //Image(systemName: "checkmark.circle")
                                    Text(circle.name)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                            } else {
                                HStack {
                                    //Image(systemName: "circle")
                                    Text(circle.name)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .padding()
                            }
                        }

                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

/*
struct StreamPicker_Previews: PreviewProvider {
    static var previews: some View {
        StreamPicker()
    }
}
 */
