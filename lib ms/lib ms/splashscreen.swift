import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image("AnyBookLogo") // Replace with your logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(isActive ? 360 : 0))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 1.2)) {
                    scale = 1.3
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            OnboardingScreen()
        }
    }
}

struct OnboardingScreen: View {
    @State private var currentPage = 0
    let pages = [
        ("Welcome to AnyBook", "Discover a seamless way to manage your books with cutting-edge features.", "book"),
        ("Manage Employee Payments", "Simplify payments with our intuitive and secure tools.", "creditcard"),
        ("Start Exploring", "Embark on a personalized journey tailored just for you!", "magnifyingglass")
    ]
    @State private var offset: CGFloat = 0
    @State private var isAnimating = false
    @State private var navigateToLogin = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].2)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                                .offset(y: offset)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .onAppear {
                                    isAnimating = true
                                    withAnimation(.easeInOut(duration: 0.7).repeatCount(1, autoreverses: true)) {
                                        offset = -30
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        withAnimation(.easeInOut(duration: 0.7)) {
                                            offset = 0
                                            isAnimating = false
                                        }
                                    }
                                }
                            Text(pages[index].0)
                                .font(.largeTitle)
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                                .bold()
                            Text(pages[index].1)
                                .font(.title3)
                                .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
                
                Button(action: {
                    withAnimation {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            navigateToLogin = true
                        }
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                }
                .padding(.bottom, 60)
                .fullScreenCover(isPresented: $navigateToLogin) {
                    LoginScreen()
                }
            }
        }
        .transition(.opacity.combined(with: .slide))
    }
}

struct ContentView: View {
    var body: some View {
        SplashScreen()
    }
}

#Preview {
    ContentView()
}
