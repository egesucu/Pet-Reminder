//
//  FoundationExtensions.swift
//  Shared
//
//  Created by Sucu, Ege on 11.06.2025.
//

import Foundation

public extension AttributedString {
    /// Converts given Markdown text into AttributedString while making sure spacings & Headers are properly recognized.
    /// - Parameter url: URL of the markdown from local file
    static func convertMarkdown(url: URL) throws -> Self {
        let markdownString = try String(contentsOf: url, encoding: .utf8)
        var output = try AttributedString(
            markdown: markdownString,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        )

        for (intentBlock, intentRange) in output.runs[
            AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self
        ].reversed() {
            guard let intentBlock = intentBlock else { continue }
            for intent in intentBlock.components {
                switch intent.kind {
                case .header(level: let level):
                    switch level {
                    case 1:
                        output[intentRange].font = .system(.title).bold()
                    case 2:
                        output[intentRange].font = .system(.title2).bold()
                    case 3:
                        output[intentRange].font = .system(.title3).bold()
                    default:
                        break
                    }
                default:
                    break
                }
            }

            if intentRange.lowerBound != output.startIndex {
                output.characters.insert(contentsOf: "\n\n", at: intentRange.lowerBound)
            }
        }
        return output
    }
}

// MARK: - Constants Defined
public extension CGFloat {
    /// Extra-small spacing used for tight gaps between related elements.
    static let spacing4: Self = 4
    /// Small spacing used for compact layouts and inline content.
    static let spacing8: Self = 8
    /// Spacing used between closely grouped controls and labels.
    static let spacing12: Self = 12
    /// Default spacing used across standard content sections.
    static let spacing16: Self = 16
    /// Medium spacing used to separate distinct UI groups.
    static let spacing20: Self = 20
    /// Generous spacing used around cards and section content.
    static let spacing24: Self = 24
    /// Large spacing used for major separation between layout blocks.
    static let spacing32: Self = 32
    /// Extra-large spacing used for spacious vertical rhythm.
    static let spacing40: Self = 40
    /// Oversized spacing used for prominent section breaks.
    static let spacing60: Self = 60
    
    /// Tiny icon size for subtle indicators or accessory glyphs.
    static let icon8: Self = 8
    /// Small icon size for compact controls.
    static let icon16: Self = 16
    /// Standard small icon size used in lists and actions.
    static let icon20: Self = 20
    /// Default icon size for most interface elements.
    static let icon24: Self = 24
    /// Medium-large icon size for emphasized controls.
    static let icon28: Self = 28
    /// Large icon size for prominent actions or empty states.
    static let icon32: Self = 32
    /// Oversized icon size used for hero or illustration-like treatments.
    static let icon80: Self = 80
    
    /// Small corner radius for subtle rounding.
    static let radius10: Self = 10
    /// Default corner radius for cards and controls.
    static let radius16: Self = 16
    /// Large corner radius for softer surfaces.
    static let radius20: Self = 20
    /// Extra-large corner radius for highly rounded containers.
    static let radius24: Self = 24
    /// Large radius value used to create pill-shaped views.
    static let pill: Self = 999
    
    /// Minimum recommended tappable dimension for interactive elements.
    static let minimum: Self = 44
    
    /// Small avatar size for profile or pet thumbnails.
    static let avatar120: Self = 120
    /// Medium avatar size for detail headers.
    static let avatar150: Self = 150
    /// Large avatar size for prominent image presentation.
    static let avatar200: Self = 200
    /// Extra-large avatar size for full-width or hero imagery.
    static let avatar300: Self = 300
    /// Fixed height used by feed history cards.
    static let feedCardHeight100: Self = 100
    
    /// Compact sheet or panel height used in constrained presentations.
    static let compactHeight200: Self = 200
    /// Minimum height used by taller edit forms.
    static let editFormMinHeight500: Self = 500
    /// Fractional height used for compact sheet presentations.
    static let compactFraction: Self = 0.3
    
    /// Corner radius applied to bottom sheets.
    static let sheetCornerRadius25: Self = 25
    
    /// Horizontal offset amount used by the wiggle animation.
    static let wiggle: Self = 2
    /// Horizontal offset for delete badges overlaid on content.
    static let deleteBadgeX: Self = 15
    /// Horizontal offset for close button placement.
    static let closeButtonX: Self = -10
    /// Vertical offset for close button placement.
    static let closeButtonY: Self = 10
    /// Width of the event indicator stripe or marker.
    static let eventIndicatorWidth: Self = 6
}
