//
//  AgencyInformationFormView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//
//

import SwiftUI

struct AgencyInformationFormView: View {

    @Environment(\.router) var router
    @StateObject private var viewModel = AgencyInformationFormViewModel()
    @ObservedObject private var localizer = Localizer.shared

    @State private var showAgePicker = false
    @State private var showCountrySheet = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                CheckboxButton(title: "is_host_voice".localized, isOn: viewModel.isHostVoice) {
                    viewModel.isHostVoice.toggle()
                }
                .padding(.bottom, 2)

                textRow("agency_code", placeholder: "enter_agency_code", text: $viewModel.agencyCode, required: true)
                textRow("agency_name", placeholder: "enter_agency_name", text: $viewModel.agencyName)
                textRow("broker_id", placeholder: "enter_broker_id", text: $viewModel.brokerId, required: true)
                textRow("mico_id", placeholder: "enter_mico_id", text: $viewModel.micoId, required: true)

                genderRow
                phoneRow
                ageRow
                countryRow
                textRow("national_id", placeholder: "enter_national_id", text: $viewModel.nationalId, required: true, keyboard: .numberPad)

                GradientPillButton(title: "submit".localized) {
                    router.navigate(.hostIncome)
                }
                .padding(.top, 14)
            }
            .padding(20)
            .adaptiveContentWidth()
        }
        .appBackground()
        .appNavigation(title: "information_form".localized)
        .sheet(isPresented: $showAgePicker) {
            AgeWheelSheet(age: $viewModel.age, range: viewModel.ageRange)
        }
        .sheet(isPresented: $showCountrySheet) {
            CountryListSheet(country: $viewModel.anchorCountry)
        }
    }

    // MARK: - Rows

    private func textRow(_ key: String, placeholder: String, text: Binding<String>,
                         required: Bool = false, keyboard: UIKeyboardType = .default) -> some View {
        FormRow(label: key.localized, isRequired: required) {
            TextField("", text: text, prompt: Text(placeholder.localized).foregroundColor(.appText.opacity(0.5)))
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var genderRow: some View {
        FormRow(label: "anchor_gender".localized, isRequired: true, axis: .vertical) {
            HStack(spacing: 28) {
                InlineRadio(title: "male".localized, isSelected: viewModel.gender == .male) {
                    viewModel.gender = .male
                }
                InlineRadio(title: "female".localized, isSelected: viewModel.gender == .female) {
                    viewModel.gender = .female
                }
            }
        }
    }

    private var phoneRow: some View {
        FormRow(label: "phone".localized, isRequired: true) {
            HStack(spacing: 8) {
                DialCodeBox(country: $viewModel.phoneCountry)
                TextField("", text: $viewModel.phoneNumber,
                          prompt: Text("phone_number".localized).foregroundColor(.appText.opacity(0.5)))
                    .keyboardType(.phonePad)
                    .multilineTextAlignment(.trailing)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var ageRow: some View {
        FormRow(label: "age".localized, isRequired: true) {
            pickerControl(value: viewModel.age.map(String.init),
                          placeholder: "select_age".localized) { showAgePicker = true }
        }
    }

    private var countryRow: some View {
        FormRow(label: "anchor_country".localized, isRequired: true) {
            pickerControl(value: viewModel.anchorCountry.map { localizer.language == .arabic ? $0.nameAr : $0.nameEn },
                          placeholder: "select_country".localized,
                          leadingFlag: viewModel.anchorCountry?.flag) { showCountrySheet = true }
        }
    }

    private func pickerControl(value: String?, placeholder: String, leadingFlag: String? = nil,
                               onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                if let leadingFlag { Text(leadingFlag) }
                Text(value ?? placeholder)
                    .font(.subheadline)
                    .foregroundStyle(value == nil ? .appText.opacity(0.5) : .appText)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.appText.opacity(0.7))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { AgencyInformationFormView() }
}
