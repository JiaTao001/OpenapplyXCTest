//
//  PushActivityWidgetLiveActivity.swift
//  PushActivityWidget
//
//  Created by Tao.jia on 2024/3/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PushActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PushActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PushActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PushActivityWidgetAttributes {
    fileprivate static var preview: PushActivityWidgetAttributes {
        PushActivityWidgetAttributes(name: "World")
    }
}

extension PushActivityWidgetAttributes.ContentState {
    fileprivate static var smiley: PushActivityWidgetAttributes.ContentState {
        PushActivityWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PushActivityWidgetAttributes.ContentState {
         PushActivityWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PushActivityWidgetAttributes.preview) {
   PushActivityWidgetLiveActivity()
} contentStates: {
    PushActivityWidgetAttributes.ContentState.smiley
    PushActivityWidgetAttributes.ContentState.starEyes
}
