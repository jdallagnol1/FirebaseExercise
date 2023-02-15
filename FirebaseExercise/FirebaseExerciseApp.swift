//
//  FirebaseExerciseApp.swift
//  FirebaseExercise
//
//  Created by João Dall Agnol on 15/02/23.
//

import SwiftUI

@main
struct FirebaseExerciseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
