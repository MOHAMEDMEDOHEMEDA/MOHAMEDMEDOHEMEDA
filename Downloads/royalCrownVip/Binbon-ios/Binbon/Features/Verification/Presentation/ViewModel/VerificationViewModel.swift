//
//  VerificationViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI
import Combine
import StripePaymentSheet

// MARK: - State

/// Status of the payment-intent setup that runs when the flow opens.
enum VerificationStartState {
    case idle
    case loading
    case ready
    case failed(APIError)
}

/// Status of the final KYC submission.
enum VerificationSubmitState {
    case idle
    case loading
    case success
    case failed(APIError)
}

@MainActor
class VerificationViewModel: ObservableObject {

    // MARK: - Published
    @Published var currentStep: Int = 0
    @Published var goingForward: Bool = true
    @Published var startState: VerificationStartState = .idle
    @Published var submitState: VerificationSubmitState = .idle

    // MARK: - State projections (kept for the views)
    var startLoading: Bool {
        get { if case .loading = startState { return true }; return false }
        set { startState = newValue ? .loading : .idle }
    }
    var startError: APIError? {
        get { if case .failed(let error) = startState { return error }; return nil }
        set {
            if let newValue { startState = .failed(newValue) }
            else if case .failed = startState { startState = .idle }
        }
    }
    var isLoading: Bool {
        get { if case .loading = submitState { return true }; return false }
        set { submitState = newValue ? .loading : .idle }
    }
    var error: APIError? {
        get { if case .failed(let error) = submitState { return error }; return nil }
        set {
            if let newValue { submitState = .failed(newValue) }
            else if case .failed = submitState { submitState = .idle }
        }
    }

    /// Step 1
    @Published var fullName = ""
    @Published var idNumber = ""
    @Published var address = ""
    @Published var dateOfBirth = ""
    @Published var phoneNumber = ""
    @Published var dialCode = "+20"
    @Published var country = Country.default
    @Published var city = ""
    @Published var village = ""
    @Published var whatsApp = ""
    @Published var state = ""
    @Published var accountType: AccountType = .personal
    @Published var isShowingDatePicker = false
    @Published var isPhoneCountryPickerOpen = false
    
    /// Step 2
    @Published var selectedDocumentType: documentType = .nationalId
    @Published var frontSideImage: UIImage? = nil
    @Published var backSideImage: UIImage? = nil
    
    /// Step 3
    @Published var selfieImage: UIImage? = nil
    
    /// Payment
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    
    /// Enum
    enum AccountType: String { case personal, company }
    enum documentType: String, CaseIterable {
        case nationalId = "National ID"
        case passport = "Passport"
        case driverLicense = "Driver's License"
    }
    
    
    /// Properties
    var router: AppRouter?
    var request = SubmitVerificationRequest()
    var paymentIntentResponse: PaymentIntentResponse?

    // MARK: - Use cases
    private let createPaymentIntentUseCase: CreateVerificationPaymentIntentUseCase
    private let submitVerificationUseCase: SubmitVerificationUseCase

    init(
        createPaymentIntentUseCase: CreateVerificationPaymentIntentUseCase,
        submitVerificationUseCase: SubmitVerificationUseCase
    ) {
        self.createPaymentIntentUseCase = createPaymentIntentUseCase
        self.submitVerificationUseCase = submitVerificationUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            createPaymentIntentUseCase: container.makeCreateVerificationPaymentIntentUseCase(),
            submitVerificationUseCase: container.makeSubmitVerificationUseCase()
        )
    }
    
    // MARK: - UI
    func onBack() {
        navigate(to: currentStep - 1)
    }
    
    func onNext() {
        checkValidation()
    }
    
    private func navigate(to step: Int) {
        goingForward = step > currentStep
        withAnimation(.easeInOut(duration: 0.4)) {
            currentStep = step
        }
    }
    
    var stepTransition: AnyTransition {
        let insertEdge: Edge = goingForward ? .trailing : .leading
        let removeEdge: Edge = goingForward ? .leading : .trailing
        return .asymmetric(
            insertion: .move(edge: insertEdge).combined(with: .opacity),
            removal: .move(edge: removeEdge).combined(with: .opacity)
        )
    }
    
    // MARK: - Logic
    private func checkValidation() {
        switch currentStep {
        case 0: firstStepValidation()
        case 1: secondStepValidation()
        case 2: thirdStepValidation()
        default: return
        }
    }
    
    private func firstStepValidation() {
        
        if let error = FormValidation.fullName(fullName) {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.idNumber(idNumber) {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.check(address, title: "Address") {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.dateOfBirth(dateOfBirth) {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.phoneDigits(phoneNumber) {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.check(city, title: "City") {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.check(village, title: "Village") {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.check(whatsApp, title: "WhatsApp") {
            self.error = APIError(type: .request, message: error)
            return
        }
        if let error = FormValidation.check(state, title: "State") {
            self.error = APIError(type: .request, message: error)
            return
        }
        
        error = nil
        request.fullName = fullName
        request.idNumber = idNumber
        request.address = address
        request.dateOfBirth = dateOfBirth
        request.phone = dialCode + phoneNumber
        request.region = city
        request.village = village
        request.state = state
        request.country = country.key
        request.whatsappUser = whatsApp
        request.accountType = accountType.rawValue
        
        navigate(to: currentStep + 1)
    }
    
    func secondStepValidation() {
        
        request.idCardFront = frontSideImage
        request.idCardBack  = backSideImage
        
        if request.idCardFront == nil {
            error = APIError(type: .request, message: "upload_front_side_image".localized)
            return
        }
        
        if request.idCardBack == nil {
            error = APIError(type: .request, message: "upload_back_side_image".localized)
            return
        }
        
        navigate(to: currentStep + 1)
    }
    
    func thirdStepValidation() {
        
        request.idCardSelfie = selfieImage
        
        if request.idCardSelfie == nil {
            error = APIError(type: .request, message: "upload_selfie_image".localized)
            return
        }
        
        submitVerification()
    }
    
    
    // MARK: - Network
    func submitVerification() {

        request.idCardSelfie = selfieImage

        Task {
            submitState = .loading
            do {
                try await submitVerificationUseCase.execute(request: request)
                submitState = .success
                router?.navigate(.verificationSuccess(status: true, message: nil))
            } catch {
                submitState = .failed(asAPIError(error))
            }
        }
    }

    func createVerificationIntent() {
        Task {
            startState = .loading
            do {
                let data = try await createPaymentIntentUseCase.execute()
                paymentIntentResponse = data
                request.paymentIntentId = data.paymentIntentId
                preparePaymentSheet(from: data)
                startState = .ready
            } catch {
                startState = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Helpers
    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}

// MARK: - Payment
extension VerificationViewModel {
    func preparePaymentSheet(from data: PaymentIntentResponse) {
        StripeAPI.defaultPublishableKey = data.publishableKey
        
        var config = PaymentSheet.Configuration()
        config.merchantDisplayName = "Binbon"
        
        paymentSheet = PaymentSheet(
            paymentIntentClientSecret: data.clientSecret ?? "",
            configuration: config
        )
    }
    
    func handlePaymentResult(_ result: PaymentSheetResult) {
        self.paymentResult = result
        switch result {
        case .completed:
            submitVerification()
        case .canceled:
            self.error = APIError(type: .server, message: "payment_canceled".localized)
        case .failed(let error):
            self.error = APIError(type: .server, message: error.localizedDescription)
        }
    }
}
