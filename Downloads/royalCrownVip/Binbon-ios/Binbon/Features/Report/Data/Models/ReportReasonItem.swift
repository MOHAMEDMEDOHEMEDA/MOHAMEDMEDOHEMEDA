//
//  ReportReasonItem.swift
//  Binbon
//
//  Created by Aya Mashaly on 09/06/2026.
//

import Foundation

struct ReportDetailsData: Hashable {
    var reason: String
    var reasonDescription: String? = nil
    var bullets: [String]? = nil
}

struct ReportReasonItem: Hashable, Identifiable {
    var id: String { title }
    let title: String
    let destination: Destination
    
    enum Destination: Hashable {
        case details(ReportDetailsData)
        case subReasons([ReportReasonItem])
        case ipInfringement
    }
}

// MARK: - The whole report-reason tree
extension ReportReasonItem {
    static let topLevel: [ReportReasonItem] = [
        .init(title: "report_reason_spam",
              destination: .details(.init(reason: "report_reason_spam"))),
        
            .init(title: "report_reason_offensive", destination: .subReasons([
                .init(title: "report_reason_offensive_content",
                      destination: .details(.init(reason: "report_reason_offensive_content",
                                                  reasonDescription: "report_desc_offensive"))),
                .init(title: "report_reason_hate_speech",
                      destination: .details(.init(reason: "report_reason_hate_speech",
                                                  reasonDescription: "report_desc_offensive"))),
                .init(title: "report_reason_child_offensive",
                      destination: .details(.init(reason: "report_reason_child_offensive",
                                                  reasonDescription: "report_desc_sexual"))),
            ])),
        
            .init(title: "report_reason_sexually_inappropriate",
                  destination: .details(.init(reason: "report_reason_sexually_inappropriate",
                                              reasonDescription: "report_desc_sexual"))),
        
            .init(title: "report_reason_misleading", destination: .subReasons([
                .init(title: "report_reason_misleading_info",
                      destination: .details(.init(reason: "report_reason_misleading_info"))),
                .init(title: "report_reason_misleading_ai",
                      destination: .details(.init(reason: "report_reason_misleading_ai_full",
                                                  bullets: [
                                                    "report_bullet_crisis",
                                                    "report_bullet_elections",
                                                    "report_bullet_didnt_occur",
                                                    "report_bullet_under_18",
                                                    "report_bullet_deepfake",
                                                    "report_bullet_authoritative_source"
                                                  ]))),
            ])),
        
            .init(title: "report_reason_ip_violation", destination: .subReasons([
                .init(title: "report_reason_ip_holder",
                      destination: .ipInfringement),
                .init(title: "report_reason_ip_not_holder",
                      destination: .details(.init(reason: "report_reason_ip_violation"))),
            ])),
        
            .init(title: "report_reason_prohibited",
                  destination: .details(.init(reason: "report_reason_prohibited"))),
        .init(title: "report_reason_fraud",
              destination: .details(.init(reason: "report_reason_fraud"))),
        .init(title: "report_reason_political",
              destination: .details(.init(reason: "report_reason_political"))),
        .init(title: "report_reason_others",
              destination: .details(.init(reason: "report_reason_others"))),
    ]
}
