//
//  PatientModel.swift
//  UploadingFilesExercise
//
//  Created by João Dall Agnol on 08/02/23.
//

import Foundation

struct PatientLocalModel: Identifiable, Hashable {
    var id: UUID?
    var name: String?
    var exam: Data?
}
