//
//  AppTextField.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

struct AppTextField: View {
    
    // MARK: - Properties
    var title: String? = nil
    let placeholder: String
    var icon: String? = nil
    var isRequired: Bool = false
    var isLoading: Bool = false
    var isPassword: Bool = false
    var keyboard: UIKeyboardType = .default
    var limit: Int = .max
    
    @Binding var text: String
    var tint: Color = .appText
    var background: Color = .white
    var border: Color = .appText
    
    // MARK: - States
    @State private var isSecure: Bool = true
    @State private var isToggling: Bool = false
    @State private var shimmerOffset: CGFloat = -1
    @FocusState private var focusedField: FieldType?
    @ObservedObject private var localizer = Localizer.shared
    
    private enum FieldType { case secure, plain }
    
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                HStack(spacing: 1) {
                    Text(title)
                        .foregroundStyle(tint)
                    if isRequired {
                        Text("*")
                            .foregroundStyle(.red)
                    }
                }
                .font(.subheadline)
            }
            
            HStack(alignment: .center, spacing: 2) {
                
                ZStack(alignment: localizer.language.direction == .rightToLeft ? .trailing : .trailing) {
                    
                    /// Center — Placeholder
                    if text.isEmpty && focusedField == nil {
                        Text(placeholder)
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                            .allowsHitTesting(false)
                            .opacity(text.isEmpty ? 1 : 0)
                    }
                    
                    /// Center — Field
                    if isPassword {
                        SecureField(String(""), text: $text)
                            .font(.subheadline)
                            .foregroundStyle(background == .white ? .black : tint)
                            .focused($focusedField, equals: .secure)
                            .opacity(isSecure ? 1 : 0)
                            .allowsHitTesting(isSecure)
                    }
                    
                    TextField(String(""), text: $text)
                        .font(.subheadline)
                        .foregroundStyle(background == .white ? .black : tint)
                        .focused($focusedField, equals: .plain)
                        .opacity(!isPassword || !isSecure ? 1 : 0)
                        .allowsHitTesting(!isPassword || !isSecure)
                }
                .padding(.leading, 10)
                .padding(.vertical, icon == nil ? 11 : 10)
                .tint(.orange)
                .font(.callout)
                .lineLimit(1)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(keyboard)
                .multilineTextAlignment(localizer.language.direction == .rightToLeft ? .trailing : .leading)
                .environment(\.layoutDirection, localizer.language.direction == .rightToLeft ? .leftToRight : .rightToLeft)
                .onChange(of: text) {
                    if text.count > limit { text = String(text.prefix(limit)) }
                }
                
                /// Trailing — Password Toggle
                if isPassword {
                    Button(action: togglePassword) {
                        createImage(isSecure ? "eye.slash" : "eye", opacity: isSecure ? 0.5 : 1)
                    }
                    .buttonStyle(.plain)
                }
                
                /// Icon
                if let icon {
                    createImage(icon, opacity: focusedField == nil ? 0.5 : 1)
                }
            }
            .padding(4)
            .padding(.leading, 4)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(background)
                    .strokeBorder(border.opacity(focusedField != nil ? 1.0 : 0.2), lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onTapGesture { focusActiveField() }
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .overlay(shimmerOverlay)
            .onChange(of: isLoading) { startShimmer() }
            .animation(.easeInOut(duration: 0.2), value: focusedField != nil)
        }
    }
    
    // MARK: - Methods
    private func togglePassword() {
        guard !isToggling else { return }
        isToggling = true
        
        isSecure.toggle()
        focusActiveField()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isToggling = false }
    }
    
    private func focusActiveField() {
        if isPassword {
            focusedField = isSecure ? .secure : .plain
        } else {
            focusedField = .plain
        }
    }
    
    private func createImage(_ icon: String, opacity: Double) -> some View {
        Image(systemName: icon)
            .frame(width: 24, height: 24, alignment: .center)
            .font(.system(size: 16))
            .foregroundStyle(background == .white ? .black : tint)
            .contentShape(Rectangle())
            .opacity(opacity)
            .padding(10)
    }
    
    // MARK: - Shimmer
    @ViewBuilder
    private var shimmerOverlay: some View {
        if isLoading {
            GeometryReader { geo in
                LinearGradient(
                    stops: [.init(color: .clear, location: 0.0),
                            .init(color: .appText.opacity(0.12), location: 0.4),
                            .init(color: .appText.opacity(0.24), location: 0.5),
                            .init(color: .appText.opacity(0.12), location: 0.6),
                            .init(color: .clear, location: 1.0),],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geo.size.width * 3)
                .offset(x: shimmerOffset * geo.size.width * 3)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .allowsHitTesting(false)
        }
    }
    
    private func startShimmer() {
        guard isLoading else { return }
        shimmerOffset = -1
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) { shimmerOffset = 1 }
    }
}

#Preview {
    AppTextField(
        placeholder: "Enter your password",
        icon: "lock",
        isRequired: true,
        isLoading: true,
        isPassword: true,
        text: .constant(""))
    .background(.black)
}
