//
//  Extension.swift
//  BiDirectionalUILabel
//
//  Created by zigzag on 26/4/2022.
//
import UIKit
import Foundation
extension NSMutableAttributedString {
    
    func MakeParagraph(_ text : String) -> NSMutableParagraphStyle{
        let paragraph = NSMutableParagraphStyle()
        //paragraph.lineSpacing = 0.4
        paragraph.lineSpacing = 2
        paragraph.paragraphSpacing = 0
        //paragraph.paragraphSpacingBefore = 0
        if (text == ""){
            paragraph.alignment = .right
            return paragraph
        }
//        let tagschemes = NSArray(objects: NSLinguisticTagScheme.language) as! [NSLinguisticTagScheme]
//        let tagger = NSLinguisticTagger(tagSchemes: tagschemes, options: 0)
//        tagger.string = text
    
        var language : String
//        if #available(iOS 11.0, *) {
//            if let lng = NSLinguisticTagger.dominantLanguage(for: text) {
//                language = lng
//            } else {
//                language = "fa"
//            }
//        } else {
//
//                let lng  : NSString? = CFStringTokenizerCopyBestStringLanguage(text as CFString, CFRangeMake(0, min(100, text.count)))
//            language = (lng ?? "fa") as String
//        }
            let lng = text.language()
         language = (lng ?? "fa") as String
        if(language == "fa" || language == "ar" || language == "he" || language == "ur" || language == "mr" || language == "ur"){
            paragraph.alignment = .right
        }else{
            paragraph.alignment = .left
        }
        return paragraph
    }
    func SetText(_ text : String){
        let fullNameArr : [String] = text.replace(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var k = 0
        for item in fullNameArr{
          
            let paragraphStyle = MakeParagraph(item)
            let NSitem = item as NSString
            self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: k, length: NSitem.length))
            
            k += NSitem.length + 1
        }
    }
    
}

extension NSMutableAttributedString {
    
    func MakeParagraphForSize(_ text : String) -> NSMutableParagraphStyle{
        let paragraph = NSMutableParagraphStyle()
        //paragraph.lineSpacing = 0.4
        paragraph.lineSpacing = 2
        paragraph.paragraphSpacing = 0
        //paragraph.paragraphSpacingBefore = 0
         paragraph.alignment = .left
//        if (text == ""){
//            paragraph.alignment = .right
//            return paragraph
//        }
//        let tagschemes = NSArray(objects: NSLinguisticTagScheme.language) as! [NSLinguisticTagScheme]
//        let tagger = NSLinguisticTagger(tagSchemes: tagschemes, options: 0)
//        tagger.string = text
//        let language  : NSString? = CFStringTokenizerCopyBestStringLanguage(text as CFString, CFRangeMake(0, min(100, text.count)))
//
//        if(language == "fa" || language == "ar" || language == "he" || language == "ur" || language == "mr"){
//            paragraph.alignment = .right
//        }else{
//            paragraph.alignment = .left
//        }
        
        return paragraph
    }
    func SetTextForSize(_ text : String){
        let fullNameArr : [String] = text.replace(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var k = 0
        for item in fullNameArr{
            let paragraphStyle = MakeParagraphForSize(item)
            let NSitem = item as NSString
            self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: k, length: NSitem.length))
            
            k += NSitem.length + 1
        }
    }
    
}
extension String {
    func language() -> String? {
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.language], options: 0)
        tagger.string = self
        return tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil).map { $0.rawValue }
    }
}
extension String{
    func replace( of replaceText: String ,  with newText: String) -> String{
        return self.replacingOccurrences(of: replaceText, with: newText, options: .literal, range: nil)
    }
}
