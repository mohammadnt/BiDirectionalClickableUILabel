import CoreText
import UIKit

protocol CustomLabelDelegate: class {
    
    func didSelect(_ text: String, type: ActiveType, style: MessageTextStyle?)
}

extension CustomLabelDelegate {
    func didSelect(_ text: String, type: ActiveType) {
        self.didSelect(text, type: type, style: nil)
    }
}

@IBDesignable @objc
class CustomLabel: UIView {
    var clickableColor = UIColor.blue
    
    var textDirection : NSTextAlignment = .right
    var writingDirection : NSWritingDirection = .rightToLeft
    var setWidthGreaterThan: Bool = false
    
    var UserInfo: Any!
    var onTouchUp: ((_ label: CustomLabel, _ text: String?) -> Void)!
    
    func AddOnTouchUp(onTouchUp: @escaping (_ label: CustomLabel, _ text: String?) -> Void) {
        self.onTouchUp = onTouchUp
    }
    
    var Center: Bool = false
    var MaxWidthInfinitive = false
    var maxwidth: CGFloat {
        if (MaxWidthInfinitive) {
            return (MaxPrefferedWidth != 0) ? MaxPrefferedWidth : 9999
        }
        if (CreateWidthCons == false) {
            return self.frame.width
        } else {
            return (MaxPrefferedWidth != 0) ? MaxPrefferedWidth : 9999
        }
    }
    @IBInspectable var MaxPrefferedWidth: CGFloat = 0
    @IBInspectable var CreateWidthCons: Bool = true
    var widthPriority: CGFloat = 1000
    @IBInspectable var CreateAttrStrAutomatically: Bool = true
    var font: UIFont = UIFont.systemFont(ofSize: 11)
    var paddings: UIEdgeInsets!
    @IBInspectable var textColor: UIColor = UIColor.black
    var text: String? {
        didSet {
            if (CreateAttrStrAutomatically) {
                self.actived.removeAll()
                CreateAtrStr(size: nil, addLineSpace: false)
            }
        }
    }
    
    func setText(_ text: String) {
        self.text = text
        self.actived.removeAll()
        CreateAtrStr(size: nil, addLineSpace: false)
    }
    
    weak var delegate: CustomLabelDelegate?
    var actived = [ElementTuple]()
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        associateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        associateConstraints()
    }
    
    var attributedText: NSMutableAttributedString? {
        didSet {
        }
    }
    
    
    func associateConstraints() {
        for constraint in constraints {
            if (constraint.firstAttribute == .height) {
                if (constraint.relation == .equal) {
                    heightConstraint = constraint;
                }
            } else if (constraint.firstAttribute == .width) {
                if (constraint.relation == .equal) {
                    widthConstraint = constraint;
                }
            }
        }
    }
    
    var textContainer: NSTextContainer!
    var layoutManager: NSLayoutManager!
    var CalculatedSize: CGSize!
    
    func CreateAtrStr(size: CGSize?, addLineSpace: Bool) {
        if text == nil || text?.isEmpty == true {
            MakeConstraints(size: CGSize.init(width: 0, height: 0))
            return;
        }
        let attrStr = NSMutableAttributedString.init(string: text!, attributes: [.font: font, .foregroundColor: textColor])
        if (addLineSpace) {
            attrStr.SetText(text!)
        }
        for item in actived {
            
            attrStr.addAttribute(.foregroundColor, value: clickableColor, range: item.range)
            if (item.type == .url) {
                
                //attrStr.addAttribute(.underlineColor, value: UIColor.red, range: item.range)
                attrStr.addAttribute(.underlineStyle, value: NSUnderlineStyle.double.rawValue, range: item.range)
            }
        }
        
        self.attributedText = attrStr
        
        
            MakeConstraints(size: size)
        
    }
    
    func MakeConstraints(size: CGSize?) {
        
        
        self.setNeedsDisplay()
        var height: CGFloat
        var width: CGFloat
        if let size = size {
            height = size.height
            width = size.width
        } else {
            
            let constraintRect = CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude)
            let calculatedSize = self.attributedText!.boundingRect(with: constraintRect, options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.RawValue(
                UInt8(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue) | UInt8(NSStringDrawingOptions.usesFontLeading.rawValue) |
                UInt8(NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)))
                                                            , context: nil)
            height = calculatedSize.height
            width = calculatedSize.width
            
        }
        if (heightConstraint == nil) {
            associateConstraints()
            if (heightConstraint == nil) {
                heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
                addConstraint(heightConstraint!)
            }
        }
        if (paddings != nil) {
            if (height == 0) {
                
            } else {
                height += paddings.top + paddings.bottom
            }
        }
        heightConstraint!.constant = height == 0 ? 0 : ceil(height + 0.5)
        if (CreateWidthCons) {
            
            if (widthConstraint == nil) {
                associateConstraints()
                if (widthConstraint == nil) {
                    
                    if (setWidthGreaterThan) {
                        widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
                    } else {
                        widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
                    }
                    
                    widthConstraint?.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(widthPriority))
                    addConstraint(widthConstraint!)
                }
            }
            if (paddings != nil) {
                if (width == 0) {
                    
                } else {
                    width += paddings.left + paddings.right
                }
            }
            widthConstraint!.constant = ceil(width)
        }
        self.CalculatedSize = CGSize.init(width: ceil(width), height: ceil(height))
    }
    
    func getSize1(width: CGFloat) -> CGSize {
        
        //let maxwidth = (MaxPrefferedWidth != 0) ? MaxPrefferedWidth : 9999
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return self.attributedText!.boundingRect(with: constraintRect, options:
                                                    NSStringDrawingOptions(rawValue: NSStringDrawingOptions.RawValue(
                                                        UInt8(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue) | UInt8(NSStringDrawingOptions.usesFontLeading.rawValue) |
                                                        UInt8(NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)))
                                                 , context: nil).size
    }
    
    var BiDirectionalText: String? {
        
        
        set {
            if newValue == nil || newValue?.isEmpty == true {
                MakeConstraints(size: CGSize.init(width: 0, height: 0))
                return;
            }
            self.text = newValue
            let attrStr = NSMutableAttributedString(string: newValue!, attributes: [.font: font, .foregroundColor: textColor])
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = textDirection
            paragraph.lineBreakMode = .byTruncatingTail
            paragraph.baseWritingDirection = writingDirection
            attrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange.init(location: 0, length: (newValue! as NSString).length))
            self.attributedText = attrStr
            //TextView.textAlignment = .justified
            MakeConstraints(size: nil)
        }
        get {
            return self.text
        }
    }
    
    func SetDirectionalLanguage(_ text: String?, aligment: NSTextAlignment) {
        if text == nil || text?.isEmpty == true {
            MakeConstraints(size: CGSize.init(width: 0, height: 0))
            return;
        }
        self.text = text
        let attrStr = NSMutableAttributedString(string: text!, attributes: [.font: font, .foregroundColor: textColor])
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = aligment//LanguageInfo.isRTL ? .right : .left
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.baseWritingDirection = aligment == NSTextAlignment.right ? .rightToLeft : .leftToRight //LanguageInfo.isRTL ? .rightToLeft : .leftToRight
        attrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange.init(location: 0, length: (text! as NSString).length))
        self.attributedText = attrStr
        //TextView.textAlignment = .justified
        MakeConstraints(size: nil)
    }
    
    func SetRtlCenterText(newValue: String?, size: CGSize?) {
        if newValue == nil || newValue?.isEmpty == true {
            MakeConstraints(size: CGSize.init(width: 0, height: 0))
            return;
        }
        self.text = newValue
        let attrStr = NSMutableAttributedString(string: newValue!, attributes: [.font: font, .foregroundColor: textColor])
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.baseWritingDirection = writingDirection
        attrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange.init(location: 0, length: (newValue! as NSString).length))
        self.attributedText = attrStr
        MakeConstraints(size: size)
    }
    
    func Hide() {
        if (heightConstraint == nil) {
            associateConstraints()
            if (heightConstraint == nil) {
                heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
                addConstraint(heightConstraint!)
            }
        }
        heightConstraint!.constant = 0
    }
    
    func FindElements() {
        guard let tex = text else {
            return;
        }
        actived.removeAll()
        let q = tex as NSString
        let range = NSRange.init(location: 0, length: q.length)
        let mentions = CustomRegexParser.createElements(from: tex, for: .mention, range: range, minLength: 0)
        actived.append(contentsOf: mentions)
        let hashtags = CustomRegexParser.createElements(from: tex, for: .hashtag, range: range, minLength: 0)
        actived.append(contentsOf: hashtags)
        let urls = CustomRegexParser.createElements(from: tex, for: .url, range: range, minLength: 0)
        actived.append(contentsOf: urls)
    }
    
    func manuallyAddElement(data: [ElementTuple]) {
        self.actived.append(data)
    }
    
    func manuallyAddElement(styles: [MessageTextStyle]) {
        for item in styles {
            let nstext = self.text! as NSString
            if(item.offset + item.length > nstext.length){
                continue;
            }
            
            let range = NSRange.init(location: item.offset, length: item.length)
            
            //            let f : Int  = item.Offset
            //            let l : Int = item.Offset + item.Length
            let word = nstext.substring(with: range)
            
            
            if (item.type == 1) {
                let element = ActiveElement.CreateCustom(with: item, text: word)
                self.actived.append((range, element, ActiveType.Custom))
            }
        }
    }
    
    static func FindURLS(text: String) -> [ElementTuple]? {
        
        
        let q = text as NSString
        let range = NSRange.init(location: 0, length: q.length)
        //        let mentions = CustomRegexParser.createElements(from: tex, for: .mention, range: range, minLength: 0)
        //        actived.append(contentsOf: mentions)
        //        let hashtags = CustomRegexParser.createElements(from: tex, for: .hashtag, range: range, minLength: 0)
        //        actived.append(contentsOf: hashtags)
        let urls = CustomRegexParser.createElements(from: text, for: .url, range: range, minLength: 0)
        
        //        actived.append(contentsOf: urls)
        return urls
    }
    
    func FineSlashCommandsClickable() {
        guard let tex = text else {
            return;
        }
        let q = tex as NSString
        let range = NSRange.init(location: 0, length: q.length)
        let slashs = CustomRegexParser.createElements(from: tex, for: .SlashCommand, range: range, minLength: 1)
        actived.append(contentsOf: slashs)
    }
    
    func AddElement(range: NSRange, element: ActiveElement, type: ActiveType) {
        let q: ElementTuple = (range: range, element: element, type: type)
        actived.append(q)
    }
    
    var rect: CGRect!
    
    override func draw(_ rect: CGRect) {
        
        var finalRect: CGRect
        if (paddings == nil) {
            self.rect = rect
            finalRect = rect
        } else {
            finalRect = CGRect.init(x: paddings.left, y: paddings.top, width: rect.width - paddings.left - paddings.right, height: rect.height - paddings.top - paddings.bottom)
        }
        if (self.Center) {
            var x, y, width, height: CGFloat
            if (finalRect.width < CalculatedSize.width) {
                x = finalRect.origin.x
                width = finalRect.width
            } else {
                x = finalRect.origin.x + (finalRect.size.width - CalculatedSize.width) / 2
                width = CalculatedSize.width
            }
            if (finalRect.height < CalculatedSize.height) {
                y = finalRect.origin.y
                height = finalRect.height
            } else {
                y = finalRect.origin.y + (finalRect.size.height - CalculatedSize.height) / 2
                height = CalculatedSize.height
            }
            let r = CGRect.init(x: x, y: y, width: width, height: height)
            attributedText?.draw(with: r, options:
                                    [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.truncatesLastVisibleLine]
                                 , context: nil)
            return;
        } else {
            
        }
        //attributedText?.draw(in: finalRect)
        
        attributedText?.draw(with: finalRect, options:
                                
                                [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.truncatesLastVisibleLine]
                             
                             , context: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    var time: Date!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        time = Date()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let time = self.time, Date().timeIntervalSince(time) >= 0.3 {
            return;
        }
        onTouchUp?(self, self.text);
        super.touchesEnded(touches, with: event)
        let touch = touches.first!
        let location = touch.location(in: self)
        _ = indexOfAttributedTextCharacterAtPoint(point: location)
    }
    
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer(size: CGSize.init(width: self.bounds.size.width, height: self.bounds.size.height + 100))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        for item in actived {
            if (item.range.location <= index && index <= item.range.location + item.range.length) {
                
                switch item.element {
                case .mention(let userHandle):
                    delegate?.didSelect(userHandle, type: item.type)
                case .hashtag(let hashtag):
                    delegate?.didSelect(hashtag, type: item.type)
                case .url(let originalURL):
                    delegate?.didSelect(originalURL, type: item.type)
                case .SlashCommand(let slashword):
                    delegate?.didSelect(slashword, type: item.type)
                case .Custom(let style, let word):
                    delegate?.didSelect(word, type: item.type, style: style)
                }
                break;
            }
        }
        return index
    }
}


