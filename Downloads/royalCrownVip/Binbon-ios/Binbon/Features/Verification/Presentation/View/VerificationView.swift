//
//  VerificationView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI
import StripePaymentSheet

struct VerificationView: View {
    
    // MARK: - Properties
    @Environment(\.router) private var router
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VerificationViewModel()
    
    // MARK: - Body
    var body: some View {
        
        VStack(spacing: 0) {
            AppNavbar(title: "account_verification".localized) {
                if viewModel.currentStep > 0 {
                    viewModel.onBack()
                } else {
                    dismiss()
                }
            }
            
            if viewModel.startLoading {
                Spacer()
                ProgressView().tint(.appText)
                Spacer()
            } else if let error = viewModel.startError {
                Spacer()
                VStack {
                    Text(error.localizedMessage())
                        .font(.footnote)
                        .foregroundStyle(.appText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Button("retry".localized) {
                        viewModel.createVerificationIntent()
                    }
                    .tint(.orange)
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                content
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .appNavigation(title: "account_verification".localized)
        .onTapDismissKeyboard()
        .appBackground()
        .onAppear {
            viewModel.router = router
            viewModel.createVerificationIntent()
        }
    }
    
    // MARK: - Content
    private var content: some View {
        VStack(spacing: 0) {
            /// Message
            AppMessage("fill_personal_details_exactly".localized)
                .padding(.bottom, 24)
            
            /// Step Indicator
            StepIndicatorView(currentStep: viewModel.currentStep)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            
            /// Step Content
            Group {
                switch viewModel.currentStep {
                case 0: Step1PersonalInfoView(viewModel: viewModel)
                case 1: Step2DocumentView(viewModel: viewModel)
                case 2: Step3SelfieView(viewModel: viewModel)
                default: EmptyView()
                }
            }
            .transition(viewModel.stepTransition)
            
            
            /// Button
            Group {
                if let paymentSheet = viewModel.paymentSheet,
                   viewModel.currentStep == 2,
                   viewModel.paymentIntentResponse?.paymentRequired == true {
                    
                    PaymentSheet.PaymentButton(paymentSheet: paymentSheet,
                                               onCompletion: viewModel.handlePaymentResult) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.appText)
                            } else {
                                Label("pay_now".localized, systemImage: "lock.fill")
                                    .font(.callout.bold())
                                    .foregroundStyle(.appText)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 12)
                            .fill(AnyShapeStyle(AppColor.chromeButtonGradient))
                            .shadow(color: AppColor.authListRowShadowColor,
                                    radius: 6,
                                    x: 0,
                                    y: 3))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appText.opacity(0.3), lineWidth: 2))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                    }
                    .disabled(viewModel.isLoading || viewModel.selfieImage == nil)
                    .opacity(viewModel.selfieImage == nil ? 0.5 : 1)
                } else {
                    AppButton(title: "next".localized, isLoading: $viewModel.isLoading, action: viewModel.onNext)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
        .adaptiveContentWidth()
    }
}

#Preview {
    NavigationView {
        VerificationView()
    }
}

// MARK: - Step Indicator
struct StepIndicatorView: View {
    let currentStep: Int
    
    private let icons = ["info.circle.fill", "person.text.rectangle.fill", "camera.fill"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                
                ZStack {
                    Circle()
                        .fill(index <= currentStep
                              ? AppColor.authListFollowingRowGradient
                              : AnyShapeStyle(LinearGradient(colors: [Color.appText.opacity(0.15), Color.appText.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)))
                        .stroke(index <= currentStep ? .white : .clear, lineWidth: 2)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icons[index])
                        .font(.system(size: 18))
                        .foregroundColor(.appText)
                }
                
                if index < 2 {
                    StepConnector(active: index < currentStep)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 6)
                }
            }
        }
    }
}

// MARK: - Step Connector
/// Dashed line with a trailing arrowhead linking two steps.
private struct StepConnector: View {
    let active: Bool

    private var color: Color { active ? .white : .appText.opacity(0.3) }

    var body: some View {
        HStack(spacing: 3) {
            DashedLine()
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 4]))
                .frame(height: 2)
                .frame(maxWidth: .infinity)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
