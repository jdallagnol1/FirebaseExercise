//
//  ContentView.swift
//  FirebaseExercise
//
//  Created by João Dall Agnol on 15/02/23.
//

// MARK: Notes
// Data() object could use a commom key agrement ( that patient and medic would both have in their local apps ) to be decrypted in each device to be shown onscreen with PDFKitRepresentedView

import SwiftUI
import Firebase
import FirebaseStorage

enum Destination: Hashable {
    case firebasePatients, defaultzinho
}

struct ContentView: View {
    // Firebase
    
    // Database -> key-value
    var dbRef = Database.database().reference() // pega o root do banco -> https://uploadfilesexercise-default-rtdb.firebaseio.com/
    var refObservers: [DatabaseHandle] = []
    
    // Database -> Data such as images or Data() object
    var storageRef = Storage.storage().reference()
    
    // End Firebase
    
    
    // For Navigation
    @State private var path: [Destination] = []
    
    @State var showFileChooser = false
    @State var fileURL: URL?
    @State var name: String = ""
    @State var dataSelectedExam: Data?
    
//    var localPatient: PatientLocalModel?
    
    
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                Text("Upload File Test")
                
                Spacer()
                
                Text("Name")
                TextField("Patient Name", text: $name)
                
                Group {
                    Button {
                        showFileChooser = true
                    } label: {
                        Text("File Picker")
                    }
                    
                    PDFKitRepresentedView(dataSelectedExam ?? Data())
                    
                    Button {
                        let patient = PatientLocalModel(id: UUID(), name: name, exam: self.dataSelectedExam ?? Data())
                        self.savePatient(patient: patient)
                    } label: {
                        Text("Save new patient")
                    }

                    Button {
                        path.append(.firebasePatients)
                    } label: {
                        Text("Firebase patients")
                    }
                }
                
                NavigationLink(value: Destination.firebasePatients) {
                    EmptyView()
                }
                .navigationDestination(for: Destination.self) {
                    switch $0 {
                    case .firebasePatients:
                        FirebasePatientsListView()
                    case .defaultzinho:
                        EmptyView()
                    }
                }
                
            }   // end navStack
        }   // end vstack
        .fileImporter(isPresented: $showFileChooser, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
            importFile(result)
        }
    }   // end varbody
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension ContentView {
    func importFile(_ res: Result<[URL], Error>) {
        do{
            let fileUrlArray = try res.get()
            let fileUrl = fileUrlArray[0]
            
            guard fileUrl.startAccessingSecurityScopedResource() else { return }
            
            let fileData = try Data(contentsOf: fileUrl)
            
            self.dataSelectedExam = fileData
            self.fileURL = fileUrl
            
            fileUrl.stopAccessingSecurityScopedResource()
            
        } catch {
            print ("error reading")
            print (error.localizedDescription)
        }
    }
    
    func savePatient(patient: PatientLocalModel) {
        let uuidPatient = patient.id?.uuidString ?? UUID().uuidString
        dbRef.child("Patients/\(uuidPatient)").setValue(["id": patient.id?.uuidString])
        dbRef.child("Patients/\(uuidPatient)").setValue(["name": patient.name])
        
        // preparing to upload
        let examReferenceInStorage = storageRef.child("\(uuidPatient)/examData.dat")
        guard let examData = patient.exam else {return}
        
        // upload task
        examReferenceInStorage.putData(examData, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error)
                return
            } else {
                print("salvou")
            }
        }
    }
    
    
    // MARK: Navigation Helper
    func tapFirebasePatients() {
        path.append(.firebasePatients)
    }
    
    func tapDefault() {
        path.append(.defaultzinho)
    }
}
