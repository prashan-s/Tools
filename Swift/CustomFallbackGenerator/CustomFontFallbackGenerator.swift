//
//  CustomFallbackGenerator.swift
//
//  Created by Prashan Samarathunge on 2023-08-10.
//  Copyright © 2023 MPCS. All rights reserved.
//
enum FontFallback {
    case regular(primary: String, secondary: String)
    case bold(primary: String, secondary: String)
    case italic(primary: String, secondary: String)
}

class CustomFallbackGenerator {
    private var fonts: [FontFallback: UIFont] = [:]
    
    init() {
        let fallbackOptions: [FontFallback] = [
            .regular(primary: "Helvetica", secondary: "Arial"),
            .bold(primary: "Helvetica-Bold", secondary: "Arial-BoldMT"),
            .italic(primary: "Helvetica-Italic", secondary: "Arial-ItalicMT")
        ]
        
        for option in fallbackOptions {
            if let primaryFont = UIFont(name: option.primary, size: 12) {
                fonts[option] = primaryFont
            } else if let secondaryFont = UIFont(name: option.secondary, size: 12) {
                fonts[option] = secondaryFont
            }
        }
    }
    
    func font(forFallback fallback: FontFallback, size: CGFloat) -> UIFont? {
        if let font = fonts[fallback] {
            return UIFont(descriptor: font.fontDescriptor, size: size)
        }
        return nil
    }
}
