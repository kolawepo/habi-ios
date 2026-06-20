import Foundation
import FirebaseAuth
import FirebaseFirestore
import WidgetKit

@MainActor
final class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var streak: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var userDocListener: ListenerRegistration?

    func observeAuthState() {
        guard authListenerHandle == nil else { return }
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            if let user {
                self?.startObservingUserDoc(uid: user.uid)
            } else {
                self?.userDocListener?.remove()
                self?.userDocListener = nil
                LiveActivityManager.endAll()
            }
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

    // A live listener (not a one-shot fetch) so that if the user posts via the
    // web app while this app is open, the Live Activity flips from "counting
    // down" to "secured for today" without needing to reopen the app.
    private func startObservingUserDoc(uid: String) {
        userDocListener?.remove()
        let username = Auth.auth().currentUser?.email ?? ""
        userDocListener = Firestore.firestore().collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let data = snapshot?.data() else { return }

                let streakValue = data["streak"] as? Int ?? 0
                let lastPostDate = data["lastPostDate"] as? String

                self.streak = streakValue
                SharedStore.write(streak: streakValue)
                WidgetCenter.shared.reloadAllTimelines()

                let deadline = StreakDeadline.computeDeadline(lastPostDate: lastPostDate)
                let postedToday = StreakDeadline.postedToday(lastPostDate: lastPostDate)
                LiveActivityManager.startOrUpdate(
                    username: username,
                    streak: streakValue,
                    deadline: deadline,
                    postedToday: postedToday
                )
            }
    }
}
