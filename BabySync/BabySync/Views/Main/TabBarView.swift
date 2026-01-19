import SwiftUI

struct TabBarView: View {
    @StateObject private var babyViewModel = BabyViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: Constants.Icons.home)
                }
                .tag(0)

            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: Constants.Icons.timeline)
                }
                .tag(1)

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: Constants.Icons.analytics)
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: Constants.Icons.profile)
                }
                .tag(3)
        }
        .environmentObject(babyViewModel)
    }
}

#Preview {
    TabBarView()
        .environmentObject(AuthViewModel())
}
