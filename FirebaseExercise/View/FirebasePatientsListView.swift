//
//  FirebasePatientsListView.swift
//  FirebaseExercise
//
//  Created by João Dall Agnol on 23/02/23.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct FirebasePatientsListView: View {
    // Firebase
    
    // Database -> key-value
    var dbRef = Database.database().reference() // pega o root do banco -> https://uploadfilesexercise-default-rtdb.firebaseio.com/
    var refObservers: [DatabaseHandle] = []
    
    // Database -> Data such as images or Data() object
//    var storageRef = Storage.storage().reference(forURL: "gs://uploadfilesexercise.appspot.com")
    var storageRef = Storage.storage().reference()
    
    // End Firebase
    
    @State var patients: [PatientLocalModel] = []
    @State var selectedPatient: PatientLocalModel?
    @State var selectedExam: Data?
    @State var showPDF = false
    @State var localUrlToExam: URL?
    
    var body: some View {
        Text("Patients stored on Firebase")
        
        List(patients) { patient in
            Text(patient.name ?? "no name registered")
                        .onTapGesture {
                            self.showPDF = true
                            self.selectedPatient = patient // patient.name ?? "no name registered"
                            self.fetchStorageExams()
                        }
                }
                .sheet(isPresented: $showPDF) {
                    Text("PDF File:")
                    if self.selectedExam == nil {
                        Text("Loading")
                    } else {
                        
                        PDFKitRepresentedView(self.selectedExam)
                    }
                }
        
        Button {
            //            tapDeletePatientsButton()
            print("tap Delete patients")
        } label: {
            Text("Delete patients")
        }
        .onAppear {
            self.fetchFirebasePatients()
        }
        
    } // end var body
}

extension FirebasePatientsListView {
//    func getPDFFile(patient: PatientLocalModel) -> Data {
//        return
//    }
    
    func fetchFirebasePatients() {
        let patientsPath = dbRef.child("Patients")
        
        patientsPath.getData { err, data in
            guard let data = data else  { return }
            if let result = data.children.allObjects as? [DataSnapshot] {
                
                for child in result {
                    let patientRef = patientsPath.child(child.key)
        
                    patientRef.observe(.value) { snapshot in
                        
                        if let value = snapshot.value as? [String : Any] {
                            
                            let uuid = UUID(uuidString: child.key)
                            let name = value["name"] as? String ?? ""
//                            let exam = value["exam"] as? Data ?? Data()
                            
                            let localPatient = PatientLocalModel(id: uuid, name: name)
                            self.patients.append(localPatient)
                        }
                    } // end observe
                } // end for child in result
            } // end if let
        } // end getData { }
        
    } // end func
    
    func fetchStorageExams()  {
        let uuidString = self.selectedPatient?.id?.uuidString ?? ""
        let examReferenceInStorage = storageRef.child("\(uuidString)/examData.dat")
        
        examReferenceInStorage.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
            if error != nil {
                    print("Error: could not download!")
                } else {
                    self.selectedExam = data
                }
        }
        
        // filePath gs://uploadfilesexercise.appspot.com/CCF70B72-430C-4B64-9819-872F2322C32B/examData.dat
        // debug gs://uploadfilesexercise.appspot.com/CCF70B72-430C-4B64-9819-872F2322C32B/examData.dat

    } // end func
    
}
//struct FirebasePatientsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FirebasePatientsListView()
//    }
//}
