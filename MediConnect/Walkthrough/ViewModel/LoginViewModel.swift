import SwiftUI
import Firebase

class LoginViewModel: ObservableObject {
    @Published var mobileNumber: String = ""
    @Published var optCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
}
