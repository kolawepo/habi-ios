import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        Group {
            if let user = authManager.user {
                SignedInView(uid: user.uid, email: user.email ?? "", streak: authManager.streak) {
                    authManager.signOut()
                }
            } else {
                SignInView(authManager: authManager)
            }
        }
        .onAppear { authManager.observeAuthState() }
    }
}

struct SignInView: View {
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Habi")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = authManager.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                Task { await authManager.signIn(email: email, password: password) }
            } label: {
                if authManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
        }
        .padding(32)
    }
}

struct SignedInView: View {
    let uid: String
    let email: String
    let streak: Int
    let onSignOut: () -> Void

    @State private var showWrapped = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Signed in")
                .font(.title2)
                .bold()

            Text(email)
                .foregroundStyle(.secondary)

            Text("🔥 Day \(streak)")
                .font(.title)
                .padding(.top, 8)

            Text("Add the Habi widget to your Home Screen to see this at a glance.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            Button("View Weekly Wrapped") {
                showWrapped = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)

            Button("Sign Out", role: .destructive, action: onSignOut)
                .padding(.top, 8)
        }
        .padding(32)
        .sheet(isPresented: $showWrapped) {
            WeeklyWrappedView(uid: uid, streak: streak)
        }
    }
}
