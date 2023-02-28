//
//  FirebaseExerciseApp.swift
//  FirebaseExercise
//
//  Created by João Dall Agnol on 15/02/23.
//

import SwiftUI
import FirebaseCore


@main
struct FirebaseExerciseApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

