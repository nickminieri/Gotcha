//
//  LoginView.swift
//  Gotcha
//
//  Created by Nicholas Minieri on 4/28/24.
//

import SwiftUI

// MARK: - Login Root
struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var page = 0

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.10)
                .ignoresSafeArea()

            AnimatedBlobs()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    OnboardingPage1(page: $page).tag(0)
                    OnboardingPage2(page: $page).tag(1)
                    LoginFormPage().tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Animated pill dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(page == i
                                  ? Color(red: 0.65, green: 0.45, blue: 1.0)
                                  : Color.white.opacity(0.2))
                            .frame(width: page == i ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: page)
                    }
                }
                .padding(.bottom, 36)
            }
        }
    }
}

// MARK: - Animated Background Blobs
struct AnimatedBlobs: View {
    @State private var animating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.50, green: 0.30, blue: 1.00).opacity(0.28))
                .frame(width: 340)
                .blur(radius: 90)
                .offset(x: animating ? -90 : -110, y: animating ? -260 : -220)

            Circle()
                .fill(Color(red: 0.90, green: 0.35, blue: 0.70).opacity(0.18))
                .frame(width: 270)
                .blur(radius: 80)
                .offset(x: animating ? 130 : 110, y: animating ? 240 : 280)

            Circle()
                .fill(Color(red: 0.20, green: 0.55, blue: 1.00).opacity(0.14))
                .frame(width: 200)
                .blur(radius: 65)
                .offset(x: animating ? -10 : 20, y: animating ? 80 : 40)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                animating = true
            }
        }
    }
}

// MARK: - Onboarding Page 1
struct OnboardingPage1: View {
    @Binding var page: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.50, green: 0.32, blue: 1.00).opacity(0.18))
                    .frame(width: 170, height: 170)
                Image(systemName: "bag.fill")
                    .font(.system(size: 68, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.60, green: 0.40, blue: 1.00),
                                     Color(red: 0.90, green: 0.62, blue: 1.00)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 52)

            Text("Gotcha.")
                .font(.system(size: 54, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)

            Text("Buy, sell, and trade with\nyour campus community.")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(5)
                .padding(.horizontal, 32)
                .padding(.top, 14)

            Spacer()
            Spacer()

            GotchaButton(label: "Let's go", icon: "arrow.right") {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    page = 1
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - Onboarding Page 2
struct OnboardingPage2: View {
    @Binding var page: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.10, green: 0.65, blue: 0.90).opacity(0.18))
                    .frame(width: 170, height: 170)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 68, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.10, green: 0.65, blue: 0.90),
                                     Color(red: 0.25, green: 0.90, blue: 0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 52)

            Text("Students\nonly.")
                .font(.system(size: 54, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)

            Text("Every account is verified through\na campus email. No strangers.")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(5)
                .padding(.horizontal, 32)
                .padding(.top, 14)

            Spacer()
            Spacer()

            GotchaButton(label: "Sign in", icon: "arrow.right", colors: [
                Color(red: 0.10, green: 0.65, blue: 0.90),
                Color(red: 0.25, green: 0.90, blue: 0.72)
            ]) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    page = 2
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - Login Form Page
struct LoginFormPage: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @FocusState private var focusedField: LoginField?

    private enum LoginField { case email, password }

    private var canSubmit: Bool { !email.isEmpty && !password.isEmpty && !isLoading }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 52)

                Text("Welcome\nback.")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)

                Text("Sign in to your campus account.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                VStack(spacing: 14) {
                    FloatingField(
                        label: "Campus Email",
                        placeholder: "you@university.edu",
                        text: $email,
                        isFocused: focusedField == .email
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)

                    // Password field (custom to support visibility toggle)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.leading, 4)
                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("", text: $password,
                                              prompt: Text("••••••••").foregroundColor(.white.opacity(0.22)))
                                } else {
                                    SecureField("", text: $password,
                                                prompt: Text("••••••••").foregroundColor(.white.opacity(0.22)))
                                }
                            }
                            .focused($focusedField, equals: .password)
                            .foregroundColor(.white)
                            .font(.system(size: 16, design: .rounded))

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.white.opacity(0.35))
                                    .font(.system(size: 16))
                                    .animation(.easeInOut(duration: 0.15), value: isPasswordVisible)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(focusedField == .password ? 0.11 : 0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(
                                            Color.white.opacity(focusedField == .password ? 0.22 : 0),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }

                    HStack {
                        Spacer()
                        Button("Forgot password?") { }
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.65, green: 0.48, blue: 1.00))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 36)

                // Sign in button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        appState.login()
                    }
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign in")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.50, green: 0.32, blue: 1.00),
                                     Color(red: 0.85, green: 0.55, blue: 1.00)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .opacity(canSubmit ? 1.0 : 0.45)
                    .animation(.easeInOut(duration: 0.2), value: canSubmit)
                }
                .disabled(!canSubmit)
                .padding(.horizontal, 32)
                .padding(.top, 28)

                // Divider
                HStack(spacing: 12) {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    Text("or")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.28))
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)

                VStack(spacing: 12) {
                    SocialAuthButton(label: "Continue with Apple", icon: "apple.logo")
                    SocialAuthButton(label: "Continue with Google", icon: "globe")
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)

                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.white.opacity(0.38))
                    Button("Sign up") { }
                        .foregroundColor(Color(red: 0.65, green: 0.48, blue: 1.00))
                }
                .font(.system(size: 14, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Floating Field
struct FloatingField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .padding(.leading, 4)
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundColor(.white.opacity(0.22))
            )
            .foregroundColor(.white)
            .font(.system(size: 16, design: .rounded))
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(isFocused ? 0.11 : 0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(isFocused ? 0.22 : 0), lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Social Auth Button
struct SocialAuthButton: View {
    let label: String
    let icon: String

    var body: some View {
        Button { } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Reusable Gradient Button
struct GotchaButton: View {
    let label: String
    let icon: String
    var colors: [Color] = [Color(red: 0.50, green: 0.32, blue: 1.00), Color(red: 0.85, green: 0.55, blue: 1.00)]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Spring Button Style
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
