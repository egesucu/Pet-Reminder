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
        
        for (intentBlock, intentRange) in output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed() {
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
