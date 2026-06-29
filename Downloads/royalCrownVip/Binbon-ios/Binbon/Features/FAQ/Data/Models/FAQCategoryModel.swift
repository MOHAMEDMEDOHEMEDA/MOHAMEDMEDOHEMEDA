//
//  FAQCategoryModel.swift
//  Binbon
//
//  Created by Heba Elcc on 08/06/2026.
//

import Foundation

struct FAQCategory: Identifiable, Codable {
    let id: Int
    let title: String
    let faqs: [FAQItem]

    enum CodingKeys: String, CodingKey {
        case id, title
        case faqs = "faq_items"
    }
}

struct FAQItem: Identifiable, Codable {
    let id: Int
    let question: String?
    let answer: String?

    enum CodingKeys: String, CodingKey {
        case id, question
        case answer = "answer"
    }

    var displayAnswer: String {
        answer ?? "This is a helpful answer to your question. Please let us know if this resolved your issue."
    }
}
