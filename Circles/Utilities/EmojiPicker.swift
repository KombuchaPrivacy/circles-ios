//
//  EmojiPicker.swift
//  Circles
//
//  Created by Charles Wright on 7/20/21.
//

import SwiftUI
import KeyboardKit

struct EmojiPicker: View {
    var message: MatrixMessage
    @Environment(\.presentationMode) var presentation

    //let categories: [EmojiCategory] = [.smileys, .animals, .foods, .activities, .travels, .objects, .symbols, .flags] // Everything but "recent" and "frequent"
    let categories = EmojiCategory.all

    @State var selectedCategory: EmojiCategory = .frequent

    var buttonBar: some View {
        HStack {
            Spacer()

            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            buttonBar
            Divider()

            Picker("Select Category: \(selectedCategory.title)", selection: $selectedCategory) {
                ForEach(categories) { category in
                    Text(category.title)
                        .tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())

            ScrollView {
                let columns: [GridItem] =
                        Array(repeating: .init(.flexible()), count: 6)


                LazyVGrid(columns: columns) {

                    let emojis: [Emoji] = selectedCategory.emojis
                    let reactions = emojis.map { $0.char }

                    ForEach(reactions, id: \.self) { reaction in
                        //let reaction: String = emoji.char
                        Button(action: {
                            self.message.addReaction(reaction: reaction) { response in
                                // Does it make any difference whether the request
                                // succeeded or failed?
                                // Can we do anything about it either way?

                                // Log that we've used this emoji
                                let provider = MostRecentEmojiProvider()
                                provider.registerEmoji(Emoji(reaction))

                                self.presentation.wrappedValue.dismiss()
                            }
                        }) {
                            Text(reaction)
                                .font(.title)
                                .padding(3)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

/*
struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPicker()
    }
}
*/
