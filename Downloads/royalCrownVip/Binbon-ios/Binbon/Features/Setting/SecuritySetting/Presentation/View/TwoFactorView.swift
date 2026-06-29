//
//  TwoFactorView.swift
//  Binbon
//
//  Created by Salah Khaled on 31/05/2026.
//

import SwiftUI

struct TwoFactorView: View {
    
    // MARK: - Enums
    enum TwoFactorStep: CaseIterable {
        case method
        case code
        
        var title: String {
            switch self {
            case .method: "send_code".localized
            case .code: "verify_and_enable".localized
            }
        }
    }
    
    enum TwoFactorMethod: String, CaseIterable {
        case email
        case phone
        
        var title: String {
            switch self {
            case .email: "email_address".localized
            case .phone: "mobile_phone".localized
            }
        }
    }
    
    // MARK: - Properties
    @Environment(\.router) var router
    @State var step: TwoFactorStep = .method
    @State var method: TwoFactorMethod = .email
    @State var otpCode: String = ""
    @State var isLoading: Bool = false
    @State var error: APIError?
    
    var userMethod: String {
        switch method {
        case .email: return Storage.shared.user?.userEmail ?? " "
            #warning("mobile code not country")
        case .phone: return (Storage.shared.user?.countryCode ?? " ") + (Storage.shared.user?.userMobileNo ?? "")
        }
    }
    
    let settingRepo: SettingRepoProtocol = SettingRepo()
    
    
    // MARK: - Body
    var body: some View {
        content
            .adaptiveContentWidth()
            .appBackground()
            .appNavigation(title: "two_factor_authentication".localized)
            .errorAlert(error: $error)
    }
    
    var content: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            switch step {
            case .method: methodStep
            case .code: codeStep
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Spacer()
                ForEach(TwoFactorStep.allCases, id: \.self) { currentStep in
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(step == currentStep ? Color.appGold : Color.appText)
                }
                Spacer()
            }
            
            
            AppButton(title: step.title, isLoading: $isLoading) {
                switch step {
                case .method: sendCode()
                case .code: verifyCode()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .padding(16)
    }
    
    
    // MARK: - Steps
    var methodStep: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("choose_method_for_otp".localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.appText)
                .lineLimit(nil)
            
            ForEach(TwoFactorMethod.allCases, id: \.self) { methodCase in
                Button {
                    method = methodCase
                } label: {
                    HStack {
                        Image(systemName: method == methodCase ? "smallcircle.filled.circle" : "circle")
                            .font(.headline.weight(.black))
                            .frame(width: 24, height: 24)
                            .foregroundStyle(method == methodCase ? .blue : .gray)
                        
                        Text(methodCase.title)
                            .font(.subheadline)
                            .foregroundStyle(.appText)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Spacer().frame(height: 10)
            
            HStack {
                Text(userMethod)
                    .font(.footnote.weight(.medium))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "lock")
                    .font(.subheadline)
            }
            .foregroundStyle(.appText.opacity(0.7))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.appText.opacity(0.2), lineWidth: 1.5)
            }
        }
    }
    
    var codeStep: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("enter_6_digit_otp".localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.appText)
                .lineLimit(nil)
            
            Text(userMethod)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.appText.opacity(0.7))
                .lineLimit(nil)
            
            OTPInputView(code: $otpCode)
        }
    }
    
    // MARK: - Network
    func sendCode() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }
            
            let response = await settingRepo.enable2FAuth(channel: method.rawValue)
            
            switch response {
            case .success(let response):
                if response.status == true {
                    step = .code
                } else {
                    self.error = APIError(type: .unknown, message: response.message)
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func verifyCode() {
        
        if let error = FormValidation.otp(otpCode) {
            self.error = APIError(type: .request, message: error)
            return
        }
        
        /// Network call
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }
            
            let response = await settingRepo.verify2FAuth(otp: otpCode)
            
            switch response {
            case .success(let response):
                if response.status == true {
                    router.back()
                } else {
                    self.error = APIError(type: .unknown, message: response.message)
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
}

#Preview {
    NavigationView {
        TwoFactorView()
    }
}
