//
//  PhoneFieldWithDropdown.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct PhoneFieldWithDropdown: View {

    enum FieldStyle {
        /// White card — auth / create account.
        case phone
        /// Clear bordered field — language & region nationality row (Figma).
        case nationality
    }

    @Binding var dialCode: String
    @Binding var country: Country
    @Binding var phoneNumber: String

    var fieldStyle: FieldStyle = .phone
    var placeholder: String = "enter_your_phone".localized
    var keyboard: UIKeyboardType = .phonePad
    /// Notifies when the dropdown opens or closes so the parent can raise `zIndex` above sibling fields.
    var onCountryPickerVisibilityChange: ((Bool) -> Void)? = nil

    @State private var showCountryPicker = false

    /// When the available width is below this, country code and phone field stack vertically.
    private static let collapsedLayoutMinWidth: CGFloat = 312

    private var countryDropdownTopInset: CGFloat {
        fieldStyle == .phone ? 58 : 52
    }

    private var countryDropdownLeadingInset: CGFloat {
        fieldStyle == .phone ? 10 : 0
    }

    private var countryDropdownWidth: CGFloat? {
        fieldStyle == .phone ? 280 : nil
    }

    var body: some View {
        inputRow
            .overlay(alignment: .topLeading) {
                if showCountryPicker {
                    countryPickerDropdown
                        .frame(maxWidth: fieldStyle == .nationality ? .infinity : nil)
                        .frame(width: countryDropdownWidth)
                        .padding(.leading, countryDropdownLeadingInset)
                        .padding(.top, countryDropdownTopInset)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showCountryPicker)
            .onChange(of: showCountryPicker) { _, isOpen in
                onCountryPickerVisibilityChange?(isOpen)
            }
    }

    // MARK: - Input row

    @ViewBuilder
    private var inputRow: some View {
        switch fieldStyle {
        case .phone:
            phoneInputRow
        case .nationality:
            nationalityInputRow
        }
    }

    private var phoneInputRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                countryCodeButton
                textField
            }
            .frame(minWidth: Self.collapsedLayoutMinWidth, alignment: .leading)
            VStack(alignment: .leading, spacing: 8) {
                countryCodeButton
                textField
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        )
        .zIndex(1)
    }

    private var nationalityInputRow: some View {
        HStack(alignment: .center, spacing: 10) {
            nationalityPickerButton
            textField
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 48)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.clear)
                .strokeBorder(.appText.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .zIndex(1)
    }

    private var nationalityPickerButton: some View {
        Button(action: { showCountryPicker.toggle() }) {
            Group {
                if phoneNumber.isEmpty, country.key == Country.default.key {
                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.blue)
                } else {
                    Text(country.flag)
                        .font(.system(size: 22))
                }
            }
            .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }

    private var countryCodeButton: some View {
        Button(action: { showCountryPicker.toggle() }) {
            HStack(spacing: 6) {
                Text(dialCode)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appText)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.appText)
                    .rotationEffect(.degrees(showCountryPicker ? 180 : 0))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(countryCodeBackground)
        }
        .buttonStyle(.plain)
        .zIndex(1)
    }

    private var textField: some View {
        ZStack(alignment: .leading) {
            if phoneNumber.isEmpty {
                Text(placeholder)
                    .font(fieldStyle == .phone ? .callout : .subheadline)
                    .foregroundStyle(fieldStyle == .phone ? Color.gray : Color.appText.opacity(0.45))
            }
            TextField("", text: $phoneNumber)
                .font(fieldStyle == .phone ? .callout : .subheadline)
                .foregroundStyle(fieldStyle == .phone ? Color.black : Color.appText)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(fieldStyle == .nationality ? .words : .never)
        }
        .frame(maxWidth: fieldStyle == .nationality ? .infinity : nil, alignment: .leading)
    }

    /// Visible height of the dropdown — drives the wheel scale/fade math.
    private static let dropdownHeight: CGFloat = 340

    // MARK: - Country Picker Dropdown
    private var countryPickerDropdown: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(Country.all) { country in
                        countryRow(country)
                            .id(country.key)
                            .visualEffect { content, geo in
                                let center = Self.dropdownHeight / 2
                                let midY = geo.frame(in: .named("countryWheel")).midY
                                let t = min(abs(midY - center) / center, 1)
                                return content
                                    .scaleEffect(1 - t * 0.32)
                                    .opacity(1.0 - Double(t) * 0.78)
                            }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
            }
            .scrollContentBackground(.hidden)
            .coordinateSpace(name: "countryWheel")
            .frame(height: Self.dropdownHeight)
            .background(dropdownOpaqueBackground)
            .compositingGroup()
            .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            .onAppear { proxy.scrollTo(country.key, anchor: .center) }
        }
    }

    /// Opaque themed panel so sibling views never show through.
    private var dropdownOpaqueBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(AppColor.appBarFill)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.appText.opacity(0.15), lineWidth: 1.5)
            )
    }

    // MARK: - Country Row
    private func countryRow(_ country: Country) -> some View {
        
        let isSelected = self.country.key == country.key
        
        return Button(action: {
            
            self.dialCode = country.dialCode
            self.country = country
            
            withAnimation { showCountryPicker = false }
        }) {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.system(size: isSelected ? 26 : 20))
                    .lineLimit(1)

                Text(Localizer.shared.language == .arabic ? country.nameAr : country.nameEn)
                    .font(.system(size: isSelected ? 17 : 14, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(.appText.opacity(isSelected ? 1 : 0.7))
                    .lineLimit(1)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(.appText.opacity(isSelected ? 0 : 0.5), lineWidth: 2)
                    if isSelected {
                        Circle().fill(.green)
                    }
                }
                .frame(width: 18, height: 18)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, isSelected ? 16 : 11)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected
                            ? AppColor.gold.opacity(0.18)
                            : Color.appText.opacity(0.06)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? AppColor.gold : Color.clear,
                                lineWidth: 2
                            ))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Country Code Button Background
    private var countryCodeBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(AppColor.chromeButtonGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appText.opacity(0.12), lineWidth: 1)
            )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var dialCode = "+20"
        @State private var country = Country.default
        @State private var phoneNumber = ""
        var body: some View {
            ZStack {
                Color(red: 0.55, green: 0.1, blue: 0.55)
                    .ignoresSafeArea()
                PhoneFieldWithDropdown(
                    dialCode: $dialCode,
                    country: $country,
                    phoneNumber: $phoneNumber
                )
                .padding(24)
            }
        }
    }
    return PreviewWrapper()
}
