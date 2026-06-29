//
//  AnchorInformationFormView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

struct AnchorInformationFormView: View {

    @Environment(\.router) var router
    @StateObject private var viewModel = AnchorInformationFormViewModel()
    @ObservedObject private var localizer = Localizer.shared

    @State private var showAgePicker = false
    @State private var showCountrySheet = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                genderRow
                phoneRow
                ageRow
                countryRow
                nationalIdRow
                photoRow("copy_of_national_id", image: $viewModel.idCopyImage)
                photoRow("anchor_photo_1", image: $viewModel.anchorPhoto1)
                photoRow("anchor_photo_2", image: $viewModel.anchorPhoto2)

                GradientPillButton(title: "submit".localized) {
                    router.navigate(.agencyInformationForm)
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
                inlineField(text: $viewModel.phoneNumber,
                            placeholder: "phone_number".localized,
                            keyboard: .phonePad)
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
            pickerControl(value: viewModel.anchorCountry.map(countryName),
                          placeholder: "select_country".localized,
                          leadingFlag: viewModel.anchorCountry?.flag) { showCountrySheet = true }
        }
    }

    private var nationalIdRow: some View {
        FormRow(label: "national_id".localized, isRequired: true) {
            inlineField(text: $viewModel.nationalId,
                        placeholder: "enter_national_id".localized,
                        keyboard: .numberPad)
        }
    }

    private func photoRow(_ key: String, image: Binding<UIImage?>) -> some View {
        FormRow(label: key.localized, isRequired: true, axis: .vertical, labelBelow: true) {
            PhotoUploadTile(image: image)
        }
    }

    // MARK: - Shared controls

    private func inlineField(text: Binding<String>, placeholder: String, keyboard: UIKeyboardType) -> some View {
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(.appText.opacity(0.5)))
            .keyboardType(keyboard)
            .multilineTextAlignment(.trailing)
            .font(.subheadline)
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .trailing)
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

    private func countryName(_ c: Country) -> String {
        localizer.language == .arabic ? c.nameAr : c.nameEn
    }
}

#Preview {
    NavigationStack { AnchorInformationFormView() }
}
