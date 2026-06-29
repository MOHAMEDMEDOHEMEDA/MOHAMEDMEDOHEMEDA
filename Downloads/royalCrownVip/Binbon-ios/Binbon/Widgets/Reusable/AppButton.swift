//
//  AppButton.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct AppButton: View {
    
    // MARK: - Properties
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var maxWidth: Bool = true
    @Binding var isLoading: Bool
    
    // MARK: - Init
    init(title: String,
         isLoading: Binding<Bool> = .constant(false),
         isDisabled: Bool = false,
         maxWidth: Bool = true,
         action: @escaping () -> Void) {
        
        self.title = title
        self._isLoading = isLoading
        self.isDisabled = isDisabled
        self.maxWidth = maxWidth
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Text(title)
                    .font(.callout.bold())
                    .foregroundStyle(.appText)
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .tint(.appText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    if isLoading {
                        ProgressView()
                    }
                }
            }
                    .if(maxWidth) {
                        $0.frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 16)
                    .background(chromeBackground)
                    .overlay(chromeBorder)
            }
            .animation(.easeInOut(duration: 0.2), value: isLoading)
            .disabled(isLoading || isDisabled)
        }
    
    
    private var chromeBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                isDisabled
                ? AnyShapeStyle(Color.gray.opacity(0.38))
                : AnyShapeStyle(AppColor.chromeButtonGradient)
            )
            .shadow(
                color: AppColor.authListRowShadowColor,
                radius: isDisabled ? 0 : 6,
                x: 0,
                y: isDisabled ? 0 : 3
            )
    }
    
    private var chromeBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.appText.opacity(isDisabled ? 0.06 : 0.12), lineWidth: 1)
    }
}

#Preview {
    AppButton(title: "Title", isLoading: .constant(false), action: {})
}

