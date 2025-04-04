import SwiftUI
import FirebaseAuth

struct SignUp: View {
    
    @State private var emailID: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Binding var showSignup: Bool
    @State var confirmPasswordIsChange = false
    @State private var passwordsMatch = true
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showHome = false
    @AppStorage("isFirstTime") private var isFirstTime = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer(minLength: 0)
            
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("Please create an account to continue")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            VStack(spacing: 25) {

                CustomTF(sfIcon: "person", hint: "Full Name", value: $fullName)
                
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                    .padding(.top, 5)
                
                CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $password)
                    .padding(.top, 5)
                
                CustomTF(sfIcon: "lock", hint: "Confirm Password", isPassword: true, value: $confirmPassword)
                    .padding(.top, 5)
                    .onChange(of: confirmPassword) { _, _ in
                        confirmPasswordIsChange = true
                    }
                
                if confirmPasswordIsChange {
                    if password != confirmPassword {
                        Text("Passwords do not match")
                            .font(.callout)
                            .foregroundStyle(.red)
                            .offset(x: 9)
                            .hSpacing(.leading)
                            .onAppear {
                                passwordsMatch.toggle()
                            }
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .offset(x: 9)
                            .hSpacing(.leading)
                    } else {
                        VStack {}
                            .frame(width: 0, height: 0)
                            .onAppear {
                                passwordsMatch.toggle()
                            }
                    }
                }
                
                GradientButton(title: "Continue", icon: "arrow.right") {
                    Auth.auth().createUser(withEmail: emailID, password: password) { _, error in
                        if error != nil {
                            showError.toggle()
                            errorMessage = error?.localizedDescription ?? ""
                        } else {
                            isFirstTime = true
                            self.showHome = true
                        }
                    }
                }
                .hSpacing(.trailing)
                .disableWithOpacity(emailID.isEmpty || password.isEmpty || fullName.isEmpty || confirmPassword.isEmpty || !passwordsMatch)

            }.padding(.top, 20)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 6) {
                Text("Already have an account?")
                    .foregroundStyle(.gray)
                
                Button("Log In.") {
                    showSignup = false
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
        .fullScreenCover(isPresented: $showHome) {
            ContentView()
        }
    }
}
