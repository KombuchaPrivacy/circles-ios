//  Copyright 2020, 2021 Kombucha Digital Privacy Systems LLC
//
//  MessageCard.swift
//  Circles for iOS
//
//  Created by Charles Wright on 11/3/20.
//

import SwiftUI
import Foundation
//import MarkdownUI

enum MessageDisplayStyle {
    case timeline
    case photoGallery
}

struct MessageText: View {
    var text: String
    var paragraphs: [Substring]
    
    init(_ text: String) {
        self.text = text
        self.paragraphs = text.split(separator: "\n")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if paragraphs.count > 1 {
                ScrollView {
                    VStack(alignment: .leading) {
                        //ForEach(0 ..< self.paragraphs.count ) { index in
                        //  let para = self.paragraphs[index]
                        ForEach(self.paragraphs, id: \.self) { para in
                            Text(para)
                                .multilineTextAlignment(.leading)
                                .font(.body)
                                .padding(.bottom, 5)
                        }
                    }
                }
            }
            else {
                Text(self.text)
                    .font(.body)
            }
        }
    }
}

struct MessageThumbnail: View {
    @ObservedObject var message: MatrixMessage
    
    var thumbnail: Image {
        guard let img = message.thumbnailImage ?? message.blurhashImage else {
            return Image(systemName: "photo")
        }
        return Image(uiImage: img)
    }
    
    var body: some View {
        ZStack {
            thumbnail
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .foregroundColor(.gray)
            
            if message.thumbnailURL != nil && message.thumbnailImage == nil
            {
                ProgressView()
            }
        }
    }
    
    
}

struct MessageTimestamp: View {
    var message: MatrixMessage
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return Text(dateFormatter.string(from: message.timestamp))
            .font(.caption)
            .foregroundColor(Color.gray)
    }
}

struct MessageCard: View {
    @ObservedObject var message: MatrixMessage
    var displayStyle: MessageDisplayStyle
    @Environment(\.colorScheme) var colorScheme
    //@State var showReplyComposer = false
    @State var reporting = false
    private let debug = false
    @State var showDetailView = false
    @State var sheetType: MessageSheetType? = nil

    func getCaption(body: String) -> String? {
        // By default, Matrix sets the text body to be the filename
        // But we want to use it for an image caption
        // So we want to ignore the obvious filenames, and let through anything that was actually written by a human
        // This is the cheap, quick, and dirty version.
        // Whoever heard of a regex anyway???
        if body.starts(with: "ima_") && body.hasSuffix(".jpeg") && body.split(separator: " ").count == 1 {
            return nil
        }
        return body
    }
    
    var timestamp: some View {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return Text("\(message.timestamp, formatter: formatter)")
            .font(.footnote)
            .foregroundColor(.gray)
    }
    
    var relativeTimestamp: some View {
        // From https://noahgilmore.com/blog/swiftui-relativedatetimeformatter/
        let formatter = RelativeDateTimeFormatter()
        return Text("\(message.timestamp, formatter: formatter)")
            .font(.footnote)
            .foregroundColor(.gray)
    }
    
    var content: some View {
        VStack {
            switch(message.content) {
            case .text(let textContent):
                MessageText(textContent.body)
                //Markdown(Document(textContent.body))
                    //.frame(minHeight: 30, maxHeight:400)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 5)
            case .image(let imageContent):
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        MessageThumbnail(message: message)
                            .padding(1)

                        if let caption = getCaption(body: imageContent.body) {
                            //Markdown(Document(caption))
                            Text(caption)
                                .padding(.horizontal, 3)
                                .padding(.bottom, 5)
                        }
                    }
                    Spacer()
                }
            case .video(let videoContent):
                ZStack(alignment: .center) {
                    MessageThumbnail(message: message)
                    Image(systemName: "play.circle")
                }
                .frame(minWidth: 200, maxWidth: 400, minHeight: 200, maxHeight: 500, alignment: .center)
            default:
                Text("This version of Circles can't display this message yet")
            }
        }
    }
    
    var avatarImage: Image {
        message.avatarImage != nil
            ? Image(uiImage: message.avatarImage!)
            : Image(systemName: "person.fill")
        // FIXME We can do better here.
        //       Use the SF Symbols for the user's initial(s)
        //       e.g. Image(sysetmName: "a.circle.fill")
    }
    
    var shield: some View {
         message.isEncrypted
            ? Image(systemName: "lock.shield")
                .foregroundColor(Color.blue)
            : Image(systemName: "xmark.shield")
                .foregroundColor(Color.red)
    }
    
    var footer: some View {
        HStack(alignment: .center) {
            
            shield
            
            if self.displayStyle == .photoGallery {
                //profileImage
                //ProfileImageView(user: message.matrix.getUser(userId: message.sender)!)
                avatarImage.resizable()
                .frame(width: 20, height: 20)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Spacer()
            timestamp
            //relativeTimestamp
        }
        //.padding(.horizontal)
    }

    var details: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Type: \(message.type)")
            Text("Related: \(message.relatesToId ?? "none")")
            Text("BlurHash: \(message.blurhash ?? "none")")
            if let hash = message.blurhash {
                if let img = message.blurhashImage {
                    Text("BlurHash is \(Int(img.size.width))x\(Int(img.size.height))")
                }
            }
        }
    }
    
    var mainCard: some View {
        
        VStack(alignment: .leading, spacing: 2) {

            if displayStyle == .timeline {
                MessageAuthorHeader(user: message.matrix.getUser(userId: message.sender)!)
            }

            if KOMBUCHA_DEBUG && self.debug {
                Text(message.id)
                    .font(.caption)
            }

            content

            if KOMBUCHA_DEBUG {
                details
                    .font(.caption)
            }

            footer
        }
        .padding(.all, 3.0)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .shadow(color: .gray, radius: 2, x: 0, y: 1)
        )

    }
    
    var body: some View {

        mainCard
            .contextMenu {
                MessageContextMenu(message: message,
                                   sheetType: $sheetType)
            }
            .sheet(item: $sheetType) { st in
                switch(st) {

                case .composer:
                    MessageComposerSheet(room: message.room, parentMessage: message)

                case .detail:
                    MessageDetailSheet(message: message, displayStyle: .timeline)

                case .reporting:
                    MessageReportingSheet(message: message)

                }
            }

    }
}
