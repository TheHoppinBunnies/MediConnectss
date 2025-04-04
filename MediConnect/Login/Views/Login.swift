import SwiftUI
import FirebaseAuth

struct Login: View {
    
    @State private var emailID: String = ""
    @State private var password: String = ""
    @Binding var showSignup: Bool
    @State private var showForgotPasswordView = false
    @State private var errorMessage = ""
    @State private var errorIsPresented = false
    @State var showHome = false
    @StateObject var loginModel: LoginViewModel = .init()
    @AppStorage("isFirstTime") private var isFirstTime = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer(minLength: 0)
            
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("Please sign in to continue")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            VStack(spacing: 25) {
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                
                CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $password)
                    .padding(.top, 5)
                
                Button("Forgot Password?") {
                    showForgotPasswordView.toggle()
                }
                .font(.callout)
                .fontWeight(.heavy)
                .tint(.appYellow)
                .hSpacing(.trailing)
                
                GradientButton(title: "Login", icon: "arrow.right") {
                    Auth.auth().signIn(withEmail: emailID, password: password) { (result, error) in
                        if error != nil {
                            errorMessage = error?.localizedDescription ?? ""
                        } else {
                            isFirstTime = true
                            self.showHome = true
                        }
                    }
                }
                .hSpacing(.trailing)
                .disableWithOpacity(emailID.isEmpty || password.isEmpty)

            }.padding(.top, 20)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                Text("Don't have an account?")
                    .foregroundStyle(.gray)
                
                Button("Sign Up Now.") {
                    showSignup.toggle()
                }
                .fontWeight(.bold)
                .tint(.appYellow)
            }
            .font(.callout)
            .hSpacing()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .toolbar(.hidden, for: .navigationBar)
        .alert(Text(errorMessage), isPresented: $errorIsPresented, actions: {
            Button("Dismiss") {
                errorIsPresented.toggle()
            }
        })
        .sheet(isPresented: $showForgotPasswordView, content: {
            if #available(iOS 16.4, *) {
                ForgotPassword()
                    .presentationDetents([.height(300)])
                    .presentationCornerRadius(30)
            } else {
                ForgotPassword()
                    .presentationDetents([.height(300)])
            }
        })
        .fullScreenCover(isPresented: $showHome) {
            ContentView()
        }
    }
}
