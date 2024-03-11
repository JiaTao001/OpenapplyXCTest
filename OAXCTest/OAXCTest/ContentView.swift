//
//  ContentView.swift
//  OAXCTest
//
//  Created by Tao.jia on 2024/3/1.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button("启动", role: .destructive) {
                startActivity()
            }
            Text("Hello, world!")
            Button("停止", role: .destructive) {
                stopActivity()
            }
            Text("Hello, world!")
            Button("更新", role: .destructive) {
                updateActivity()
            }
        }
        .padding()
    }
    
    // 启动 Live Activity
    func startActivity() {
        // 判断版本号
        guard #available(iOS 16.1, *) else {
            return
        }
        // 判断是否开启了 Live Activity 权限
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            // Live Activity 不可用，上报空 token 给服务端
//            uploadTokenToService(nil)
            return
        }
        
        // 创建数据
        let pizzaDeliveryAttributes = PushActivityWidgetAttributes(name: "World")
        let initialContentState = PushActivityWidgetAttributes.ContentState(emoji: "🤩")
                                                  
        do {
            // 请求启动 Live Activity
            let deliveryActivity = try Activity<PushActivityWidgetAttributes>.request(
                attributes: pizzaDeliveryAttributes, contentState: initialContentState,
                pushType: .token)   // Enable Push Notification Capability First (from pushType: nil)
            
            print("Requested a pizza delivery Live Activity \(deliveryActivity.id)")

            Task {
                // 监听 push token 更新
                for await pushToken in deliveryActivity.pushTokenUpdates {
                    let pushTokenString = pushToken.reduce("") { $0 + String(format: "%02x", $1) }
                    print(pushTokenString)
                    // 上传 push token 给服务端，用于推送更新 Live Activity
//                    uploadTokenToService(pushTokenString)
                }
            }
            Task {
                // 监听 state 数据内容变化
                for await state in deliveryActivity.contentStateUpdates {
                    print("1content state update: tip=\(state.emoji)")
                }
            }
            Task {
                // 监听 Activity 状态变化
                for await state in deliveryActivity.activityStateUpdates {
                    print("activity state update: tip=\(state) id:\(deliveryActivity.id)")
                    // 当 LiveActivity 结束时，使服务端的推送token失效
                    // LiveActivity 活动状态一共有 4 种
                    // .active 处于活动中
                    // .ended 已经终止且不会有任何更新，但依旧在锁屏界面展示
                    // .dismissed 结束且不再展示
                    // .stale 消息过时，等待最新的消息。(iOS 16.2 以上才支持)
                    if state == .ended || state == .dismissed {
//                        uploadTokenToService(nil)
                    }
                }
                
            }
        } catch (let error) {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
            // Live Activity 不可用，上报空 token 给服务端
//            uploadTokenToService(nil)
        }
    }
    
    
    // 结束 Live Activity
    func stopActivity() {
        // 判断版本号
        guard #available(iOS 16.1, *) else {
            return
        }
        Task {
            // dismissalPolicy 有三种
            // .default 会在锁屏屏幕上停留四个小时，以便用户查看最后一个消息，或用户主动移除
            // .immediate 立即结束，不会在屏幕上停留
            // .after() 指定时间结束，最长为当前时间+4小时
            for activity in Activity<PushActivityWidgetAttributes>.activities{
                // 用户可以在锁定屏幕上移除Live Activity 后，ActivityState会变为.dismissed。
                if activity.activityState == .dismissed {
                    continue
                }
                await activity.end(dismissalPolicy: .immediate)
            }

            print("Cancelled pizza delivery Live Activity")
        }
    }
    
    
    // 更新 Live Activity
    func updateActivity() {
        // 判断版本号
        guard #available(iOS 16.1, *) else {
            return
        }
        Task {
            // 获取数据
            let updateStatus = PushActivityWidgetAttributes.ContentState(emoji: "🍳")
            
            // 更新数据
            for activity in Activity<PushActivityWidgetAttributes>.activities{
                // 用户可以在锁定屏幕上移除Live Activity 后，ActivityState会变为.dismissed。
                if activity.activityState == .dismissed {
                    continue
                }
                await activity.update(using: updateStatus)
            }
        }
    }
    
    
    
}

#Preview {
    ContentView()
}
