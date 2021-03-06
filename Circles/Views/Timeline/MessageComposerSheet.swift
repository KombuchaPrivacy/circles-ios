//
//  MessageComposerSheet.swift
//  Circles
//
//  Created by Charles Wright on 7/6/21.
//

import SwiftUI

struct MessageComposerSheet: View {
    var room: MatrixRoom
    var parentMessage: MatrixMessage?
    @State var isPresented = true

    var body: some View {
        VStack {
            Text("New Post")
                .font(.title2)
                .fontWeight(.bold)
            
            if let parent = parentMessage {
                MessageCard(message: parent, displayStyle: .timeline)
                    .padding(3)
            }
            let pad: CGFloat = parentMessage == nil ? 0 : 10
            RoomMessageComposer(room: room, inReplyTo: parentMessage)
                .padding(.horizontal, 3)
                .padding(.leading, pad)
        }
    }
}

/*
struct MessageComposerSheet_Previews: PreviewProvider {
    static var previews: some View {
        MessageComposerSheet()
    }
}
*/
