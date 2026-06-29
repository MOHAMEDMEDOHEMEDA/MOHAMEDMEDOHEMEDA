//
//  AddPaymentCardAlert.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct AddPaymentCardAlertModifier: ViewModifier {

    @Binding var isPresented: Bool
    let onAdd: (PaymentCard) -> Void

    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var ccv = ""
    @State private var holderName = ""
    @State private var validationMessage: String?
    @State private var showValidationAlert = false

    func body(content: Content) -> some View {
        content
            .alert("add_payment_method_title".localized,
                   isPresented: $isPresented) {
                TextField("card_number".localized, text: $cardNumber)
                    .keyboardType(.numberPad)
                TextField("card_expiry_date".localized, text: $expiry)
                    .keyboardType(.numbersAndPunctuation)
                TextField("card_ccv".localized, text: $ccv)
                    .keyboardType(.numberPad)
                TextField("card_holder_name".localized, text: $holderName)
                    .textInputAutocapitalization(.words)

                Button("add".localized, action: handleAdd)
                Button("cancel".localized, role: .cancel, action: resetFields)
            }
            .alert("Error", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage ?? "")
            }
    }

    // MARK: - Logic
    private func handleAdd() {
        if let error = validate() {
            validationMessage = error
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showValidationAlert = true
            }
            return
        }
        onAdd(buildCard())
        resetFields()
    }

    private func validate() -> String? {
        let number = cardNumber.trimmingCharacters(in: .whitespaces)
        let exp    = expiry.trimmingCharacters(in: .whitespaces)
        let cvv    = ccv.trimmingCharacters(in: .whitespaces)
        let holder = holderName.trimmingCharacters(in: .whitespaces)

        if number.isEmpty || exp.isEmpty || cvv.isEmpty || holder.isEmpty {
            return "All fields are required"
        }

        let digits = number.filter(\.isNumber)
        if digits.count < 13 || digits.count > 19 {
            return "Invalid card number"
        }

        let expiryRegex = #"^(0[1-9]|1[0-2])\/\d{2}$"#
        if exp.range(of: expiryRegex, options: .regularExpression) == nil {
            return "Invalid expiry format (MM/YY)"
        }

        if cvv.filter(\.isNumber).count < 3 {
            return "Invalid CCV"
        }

        return nil
    }

    private func buildCard() -> PaymentCard {
        let digits = cardNumber.filter(\.isNumber)
        let masked = String(repeating: "*", count: max(0, digits.count - 4))
            + digits.suffix(4)
        let brand: String
        switch digits.first {
        case "4": brand = "visa"
        case "5": brand = "Mastercard"
        default:  brand = "visa"
        }
        return PaymentCard(
            brandImage: brand,
            maskedNumber: masked,
            expiry: expiry,
            ccv: String(repeating: "*", count: ccv.count),
            holderName: holderName
        )
    }

    private func resetFields() {
        cardNumber = ""
        expiry = ""
        ccv = ""
        holderName = ""
    }
}

extension View {
    func addPaymentCardAlert(
        isPresented: Binding<Bool>,
        onAdd: @escaping (PaymentCard) -> Void
    ) -> some View {
        modifier(AddPaymentCardAlertModifier(isPresented: isPresented, onAdd: onAdd))
    }
}
