//
//  CustomRegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//
import CoreData
public enum ActiveType : Int {
    case mention = 0
    case hashtag = 1
    case url = 2
    case SlashCommand = 3
    case Custom = 4
    
    var pattern: String {
        switch self {
        case .mention: return CustomRegexParser.mentionPattern
        case .hashtag: return CustomRegexParser.hashtagPattern
        case .url: return CustomRegexParser.urlPattern
        case .SlashCommand: return CustomRegexParser.SlashCommandPattern
            case .Custom : return ""
        }
    }
}
enum ActiveElement {
    case mention(String)
    case hashtag(String)
    case url(String)
    case SlashCommand(String)
    case Custom(MessageTextStyle, String)
    static func create(with activeType: ActiveType, text: String) -> ActiveElement {
        switch activeType {
        case .mention: return mention(text)
        case .hashtag: return hashtag(text)
        case .url: return url(text)
        case .SlashCommand : return SlashCommand(text)
        case .Custom : return Custom(MessageTextStyle() , text)
        }
    }
    static func CreateCustom(with style: MessageTextStyle, text: String) -> ActiveElement {
        return Custom(style , text)
    }
}
typealias ElementTuple = (range: NSRange, element: ActiveElement, type: ActiveType)
struct CustomRegexParser {
    static func createElements(from text: String,
                                       for type: ActiveType,
                                       range: NSRange,
                                       minLength: Int = 2) -> [ElementTuple] {
        
        let matches = CustomRegexParser.getElements(from: text, with: type, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let element = ActiveElement.create(with: type, text: word)
            elements.append((match.range, element, type))
        }
        return elements
    }

    static let hashtagPattern = "(?:^|\\s|$|[.])#[\\p{L}0-9_]*"
    static let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
 
//    static let urlPattern = "(https?:\\/\\/)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"
        static let urlPattern = "((http|ftp|https):\\/\\/)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"

    static let SlashCommandPattern = "(?:^|\\s|$)/[\\p{L}0-9_*#]*"
    
    
    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]
    
    static func getElements(from text: String, with pattern: ActiveType, range: NSRange) -> [NSTextCheckingResult]{
//        if pattern == .url{
//            return replaceLinkifyUrl(text: text)
//        }
        //else if pattern == .mention{
        //            return replaceLinkifyMention(text: text)
        //        }
        //        return [StringMatch]()
        let x = pattern.pattern
        guard let elementRegex = regularExpression(for: x) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }
    //private
    static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }

//    static func replaceLinkifyMention(text nullableText: String?) -> [StringMatch] {
//        guard let text = nullableText else {
//            return [StringMatch]()
//        }
//        if(text.isEmpty){
//            return [StringMatch]()
//        }
//        var strBuilder = [StringMatch]()
//
//        var i = 0
//        while (i < text.length) {
//            let ch : String = text[i]
//            if (ch == "@") {
//                i = findAndSetUsernameIfNeeded(result: &strBuilder, text: text, i: i)
//            }
////            else if (ch == ".") {
////                i = findAndSetUrlIfNeeded(result: &strBuilder, text: text, i: i)
////            }
//            i += 1
//
//        }
//
//        return strBuilder
//    }
//    static func replaceLinkifyUrl(text nullableText: String?) -> [StringMatch] {
//        guard let text = nullableText else {
//            return [StringMatch]()
//        }
//        if(text.isEmpty){
//            return [StringMatch]()
//        }
//        var strBuilder = [StringMatch]()
//
//        var i = 0
//        while (i < text.length) {
//            let ch : String = text[i]
////            if (ch == "@") {
////                i = findAndSetUsernameIfNeeded(result: &strBuilder, text: text, i: i)
////            }
//            //else
//            if (ch == ".") {
//                i = findAndSetUrlIfNeeded(result: &strBuilder, text: text, i: i)
//            }
//            i += 1
//
//        }
//
//        return strBuilder
//    }
//    static func replaceLinkify(text nullableText: String?) -> [StringMatch] {
//        guard let text = nullableText else {
//            return [StringMatch]()
//        }
//        if(text.isEmpty){
//            return [StringMatch]()
//        }
//        var strBuilder = [StringMatch]()
//
//        var i = 0
//        while (i < text.length) {
//            let ch : String = text[i]
//            if (ch == "@") {
//                i = findAndSetUsernameIfNeeded(result: &strBuilder, text: text, i: i)
//            } else if (ch == ".") {
//                i = findAndSetUrlIfNeeded(result: &strBuilder, text: text, i: i)
//            }
//            i += 1
//
//        }
//
//        return strBuilder
//    }
//
//
//    static func findAndSetUsernameIfNeeded(result: inout [StringMatch], text: String, i: Int) -> Int {
//
//        //        int startIndex = i + 1;
//
//        var endIndex = -1
//        for j in (i + 1)...(text.length - 1) {
//            let endChar = text[j]
//            if (endChar == " " || endChar == "\n") {
//                endIndex = j
//                break
//            } else if !(endChar.ascii == 95 || (endChar.ascii > 64 && endChar.ascii < 91) || (endChar.ascii > 47 && endChar.ascii < 58) || (endChar.ascii > 96 && endChar.ascii < 123) ) {
//                return j
//            }
//        }
//
//        if (endIndex == -1) {
//            endIndex = text.length
//        }
//
//        if (endIndex - i < 6) {
//            return endIndex - 1
//        }
//        //let hyperText = String(text[text.index(text.startIndex, offsetBy: i)...text.index(text.startIndex, offsetBy: endIndex)])
//
//        //strBuilder.setSpan(clickableSpan, i, endIndex, 0)
//        let q = StringMatch.init(location: i, EndIndex: endIndex)
//        result.append(q)
//        return endIndex - 1
//    }
//
//
//    static private func findAndSetUrlIfNeeded(result: inout [StringMatch], text: String, i: Int) -> Int {
//        var mChar: String
//        var startIndex = 0
//        var endIndex = text.length - 1
//        var fqdnIndex = -1
//        var j = i - 1
//        while j >= 0{
//            mChar = text[j]
//            if (mChar == " " || mChar == "\n") {
//                startIndex = j + 1
//                break
//            }
//            j -= 1
//        }
//
//        if (startIndex == i) {
//            return i
//        }
//
//        if (endIndex < i + 1) {
//            return i
//        }
//        for j in (i + 1)...(text.length - 1) {
//            mChar = text[j]
//            if (mChar == " " || mChar == "\n") {
//                endIndex = j - 1
//                break
//            } else if (fqdnIndex == -1 && (mChar == "/" || mChar == ":")) {
//                fqdnIndex = j - 1
//            }
//        }
//
//
//        //        if (endIndex == -1) endIndex = text.length();
//        if (fqdnIndex == -1) {fqdnIndex = endIndex}
//
//        if (fqdnIndex - startIndex < 3) {
//            return endIndex
//        }
//
//        //val hyperText = text.substring(startIndex, endIndex + 1)
//        if (isWebUrl(text.substring(start: startIndex, location: fqdnIndex))) {
//
////            val clickableSpan = object : ClickableSpan() {
////                override fun onClick(widget: View) {
////                    interactionListener.handleHyperText(hyperText)
////                }
////            }
//            //strBuilder.setSpan(clickableSpan, startIndex, endIndex + 1, 0)
//            let q = StringMatch.init(location: startIndex, EndIndex: endIndex + 1)
//            result.append(q)
//        }
//        return endIndex
//    }
//    static func isUserName(text: String)-> Bool {
//        return text.starts(with: "@")
//
//    }
//
//    static func isWebUrl(_ webUrl: String) -> Bool {
//        let text = webUrl.uppercased()
//        //            text = text.toUpperCase()
//        if let i = text.lastIndexOf(".")?.lowerBound.encodedOffset{
//            if(i + 1 >= webUrl.endIndex.encodedOffset - 1){
//                return false
//            }
//            let mtld = text.substring(start: i + 1, location: webUrl.endIndex.encodedOffset - 1)
//            return tlds.contains(mtld)
//        }
//        return false
//    }
//
//    static private var tlds :[String]{
//        return ["COM", "IR", "ME", "LY", "AAA", "AARP", "ABARTH", "ABB", "ABBOTT", "ABBVIE", "ABC", "ABLE", "ABOGADO", "ABUDHABI", "AC", "ACADEMY", "ACCENTURE", "ACCOUNTANT", "ACCOUNTANTS", "ACO", "ACTIVE", "ACTOR", "AD", "ADAC", "ADS", "ADULT", "AE", "AEG", "AERO", "AETNA", "AF", "AFAMILYCOMPANY", "AFL", "AFRICA", "AG", "AGAKHAN", "AGENCY", "AI", "AIG", "AIGO", "AIRBUS", "AIRFORCE", "AIRTEL", "AKDN", "AL", "ALFAROMEO", "ALIBABA", "ALIPAY", "ALLFINANZ", "ALLSTATE", "ALLY", "ALSACE", "ALSTOM", "AM", "AMERICANEXPRESS", "AMERICANFAMILY", "AMEX", "AMFAM", "AMICA", "AMSTERDAM", "ANALYTICS", "ANDROID", "ANQUAN", "ANZ", "AO", "AOL", "APARTMENTS", "APP", "APPLE", "AQ", "AQUARELLE", "AR", "ARAB", "ARAMCO", "ARCHI", "ARMY", "ARPA", "ART", "ARTE", "AS", "ASDA", "ASIA", "ASSOCIATES", "AT", "ATHLETA", "ATTORNEY", "AU", "AUCTION", "AUDI", "AUDIBLE", "AUDIO", "AUSPOST", "AUTHOR", "AUTO", "AUTOS", "AVIANCA", "AW", "AWS", "AX", "AXA", "AZ", "AZURE", "BA", "BABY", "BAIDU", "BANAMEX", "BANANAREPUBLIC", "BAND", "BANK", "BAR", "BARCELONA", "BARCLAYCARD", "BARCLAYS", "BAREFOOT", "BARGAINS", "BASEBALL", "BASKETBALL", "BAUHAUS", "BAYERN", "BB", "BBC", "BBT", "BBVA", "BCG", "BCN", "BD", "BE", "BEATS", "BEAUTY", "BEER", "BENTLEY", "BERLIN", "BEST", "BESTBUY", "BET", "BF", "BG", "BH", "BHARTI", "BI", "BIBLE", "BID", "BIKE", "BING", "BINGO", "BIO", "BIZ", "BJ", "BLACK", "BLACKFRIDAY", "BLANCO", "BLOCKBUSTER", "BLOG", "BLOOMBERG", "BLUE", "BM", "BMS", "BMW", "BN", "BNL", "BNPPARIBAS", "BO", "BOATS", "BOEHRINGER", "BOFA", "BOM", "BOND", "BOO", "BOOK", "BOOKING", "BOOTS", "BOSCH", "BOSTIK", "BOSTON", "BOT", "BOUTIQUE", "BOX", "BR", "BRADESCO", "BRIDGESTONE", "BROADWAY", "BROKER", "BROTHER", "BRUSSELS", "BS", "BT", "BUDAPEST", "BUGATTI", "BUILD", "BUILDERS", "BUSINESS", "BUY", "BUZZ", "BV", "BW", "BY", "BZ", "BZH", "CA", "CAB", "CAFE", "CAL", "CALL", "CALVINKLEIN", "CAM", "CAMERA", "CAMP", "CANCERRESEARCH", "CANON", "CAPETOWN", "CAPITAL", "CAPITALONE", "CAR", "CARAVAN", "CARDS", "CARE", "CAREER", "CAREERS", "CARS", "CARTIER", "CASA", "CASE", "CASEIH", "CASH", "CASINO", "CAT", "CATERING", "CATHOLIC", "CBA", "CBN", "CBRE", "CBS", "CC", "CD", "CEB", "CENTER", "CEO", "CERN", "CF", "CFA", "CFD", "CG", "CH", "CHANEL", "CHANNEL", "CHASE", "CHAT", "CHEAP", "CHINTAI", "CHLOE", "CHRISTMAS", "CHROME", "CHRYSLER", "CHURCH", "CI", "CIPRIANI", "CIRCLE", "CISCO", "CITADEL", "CITI", "CITIC", "CITY", "CITYEATS", "CK", "CL", "CLAIMS", "CLEANING", "CLICK", "CLINIC", "CLINIQUE", "CLOTHING", "CLOUD", "CLUB", "CLUBMED", "CM", "CN", "CO", "COACH", "CODES", "COFFEE", "COLLEGE", "COLOGNE", "COMCAST", "COMMBANK", "COMMUNITY", "COMPANY", "COMPARE", "COMPUTER", "COMSEC", "CONDOS", "CONSTRUCTION", "CONSULTING", "CONTACT", "CONTRACTORS", "COOKING", "COOKINGCHANNEL", "COOL", "COOP", "CORSICA", "COUNTRY", "COUPON", "COUPONS", "COURSES", "CR", "CREDIT", "CREDITCARD", "CREDITUNION", "CRICKET", "CROWN", "CRS", "CRUISE", "CRUISES", "CSC", "CU", "CUISINELLA", "CV", "CW", "CX", "CY", "CYMRU", "CYOU", "CZ", "DABUR", "DAD", "DANCE", "DATA", "DATE", "DATING", "DATSUN", "DAY", "DCLK", "DDS", "DE", "DEAL", "DEALER", "DEALS", "DEGREE", "DELIVERY", "DELL", "DELOITTE", "DELTA", "DEMOCRAT", "DENTAL", "DENTIST", "DESI", "DESIGN", "DEV", "DHL", "DIAMONDS", "DIET", "DIGITAL", "DIRECT", "DIRECTORY", "DISCOUNT", "DISCOVER", "DISH", "DIY", "DJ", "DK", "DM", "DNP", "DO", "DOCS", "DOCTOR", "DODGE", "DOG", "DOHA", "DOMAINS", "DOT", "DOWNLOAD", "DRIVE", "DTV", "DUBAI", "DUCK", "DUNLOP", "DUNS", "DUPONT", "DURBAN", "DVAG", "DVR", "DZ", "EARTH", "EAT", "EC", "ECO", "EDEKA", "EDU", "EDUCATION", "EE", "EG", "EMAIL", "EMERCK", "ENERGY", "ENGINEER", "ENGINEERING", "ENTERPRISES", "EPOST", "EPSON", "EQUIPMENT", "ER", "ERICSSON", "ERNI", "ES", "ESQ", "ESTATE", "ESURANCE", "ET", "ETISALAT", "EU","EUROVISION", "EUS", "EVENTS", "EVERBANK", "EXCHANGE", "EXPERT", "EXPOSED", "EXPRESS", "EXTRASPACE", "FAGE", "FAIL", "FAIRWINDS", "FAITH", "FAMILY", "FAN", "FANS", "FARM", "FARMERS", "FASHION", "FAST", "FEDEX", "FEEDBACK", "FERRARI", "FERRERO", "FI", "FIAT", "FIDELITY", "FIDO", "FILM", "FINAL", "FINANCE", "FINANCIAL", "FIRE", "FIRESTONE", "FIRMDALE", "FISH", "FISHING", "FIT", "FITNESS", "FJ", "FK", "FLICKR", "FLIGHTS", "FLIR", "FLORIST", "FLOWERS", "FLY", "FM", "FO", "FOO", "FOOD", "FOODNETWORK", "FOOTBALL", "FORD", "FOREX", "FORSALE", "FORUM", "FOUNDATION", "FOX", "FR", "FREE", "FRESENIUS", "FRL", "FROGANS", "FRONTDOOR", "FRONTIER", "FTR", "FUJITSU", "FUJIXEROX", "FUN", "FUND", "FURNITURE", "FUTBOL", "FYI", "GA", "GAL", "GALLERY", "GALLO", "GALLUP", "GAME", "GAMES", "GAP", "GARDEN", "GB", "GBIZ", "GD", "GDN", "GE", "GEA", "GENT", "GENTING", "GEORGE", "GF", "GG", "GGEE", "GH", "GI", "GIFT", "GIFTS", "GIVES", "GIVING", "GL", "GLADE", "GLASS", "GLE", "GLOBAL", "GLOBO", "GM", "GMAIL", "GMBH", "GMO", "GMX", "GN", "GODADDY", "GOLD", "GOLDPOINT", "GOLF", "GOO", "GOODHANDS", "GOODYEAR", "GOOG", "GOOGLE", "GOP", "GOT", "GOV", "GP", "GQ", "GR", "GRAINGER", "GRAPHICS", "GRATIS", "GREEN", "GRIPE", "GROCERY", "GROUP", "GS", "GT", "GU", "GUARDIAN", "GUCCI", "GUGE", "GUIDE", "GUITARS", "GURU", "GW", "GY", "HAIR", "HAMBURG", "HANGOUT", "HAUS", "HBO", "HDFC", "HDFCBANK", "HEALTH", "HEALTHCARE", "HELP", "HELSINKI", "HERE", "HERMES", "HGTV", "HIPHOP", "HISAMITSU", "HITACHI", "HIV", "HK", "HKT", "HM", "HN", "HOCKEY", "HOLDINGS", "HOLIDAY", "HOMEDEPOT", "HOMEGOODS", "HOMES", "HOMESENSE", "HONDA", "HONEYWELL", "HORSE", "HOSPITAL", "HOST", "HOSTING", "HOT", "HOTELES", "HOTELS", "HOTMAIL", "HOUSE", "HOW", "HR", "HSBC", "HT", "HTC", "HU", "HUGHES", "HYATT", "HYUNDAI", "IBM", "ICBC", "ICE", "ICU", "ID", "IE", "IEEE", "IFM", "IKANO", "IL", "IM", "IMAMAT", "IMDB", "IMMO", "IMMOBILIEN", "IN", "INDUSTRIES", "INFINITI", "INFO", "ING", "INK", "INSTITUTE", "INSURANCE", "INSURE", "INT", "INTEL", "INTERNATIONAL", "INTUIT", "INVESTMENTS", "IO", "IPIRANGA", "IQ", "IRISH", "IS", "ISELECT", "ISMAILI", "IST", "ISTANBUL", "IT", "ITAU", "ITV", "IVECO", "IWC", "JAGUAR", "JAVA", "JCB", "JCP", "JE", "JEEP", "JETZT", "JEWELRY", "JIO", "JLC", "JLL", "JM", "JMP", "JNJ", "JO", "JOBS", "JOBURG", "JOT", "JOY", "JP", "JPMORGAN", "JPRS", "JUEGOS", "JUNIPER", "KAUFEN", "KDDI", "KE", "KERRYHOTELS", "KERRYLOGISTICS", "KERRYPROPERTIES", "KFH", "KG", "KH", "KI", "KIA", "KIM", "KINDER", "KINDLE", "KITCHEN", "KIWI", "KM", "KN", "KOELN", "KOMATSU", "KOSHER", "KP", "KPMG", "KPN", "KR", "KRD", "KRED", "KUOKGROUP", "KW", "KY", "KYOTO", "KZ", "LA", "LACAIXA", "LADBROKES", "LAMBORGHINI", "LAMER", "LANCASTER", "LANCIA", "LANCOME", "LAND", "LANDROVER", "LANXESS", "LASALLE", "LAT", "LATINO", "LATROBE", "LAW", "LAWYER", "LB", "LC", "LDS", "LEASE", "LECLERC", "LEFRAK", "LEGAL", "LEGO", "LEXUS", "LGBT", "LI", "LIAISON", "LIDL", "LIFE", "LIFEINSURANCE", "LIFESTYLE", "LIGHTING", "LIKE", "LILLY", "LIMITED", "LIMO", "LINCOLN", "LINDE", "LINK", "LIPSY", "LIVE", "LIVING", "LIXIL", "LK", "LOAN", "LOANS", "LOCKER", "LOCUS", "LOFT", "LOL", "LONDON", "LOTTE", "LOTTO", "LOVE", "LPL", "LPLFINANCIAL", "LR", "LS", "LT", "LTD", "LTDA", "LU", "LUNDBECK", "LUPIN", "LUXE", "LUXURY", "LV", "MA", "MACYS", "MADRID", "MAIF", "MAISON", "MAKEUP", "MAN", "MANAGEMENT", "MANGO", "MAP", "MARKET", "MARKETING", "MARKETS", "MARRIOTT", "MARSHALLS", "MASERATI", "MATTEL", "MBA", "MC", "MCD", "MCDONALDS", "MCKINSEY", "MD", "MED", "MEDIA", "MEET", "MELBOURNE", "MEME", "MEMORIAL", "MEN", "MENU", "MEO", "MERCKMSD", "METLIFE", "MG", "MH", "MIAMI", "MICROSOFT", "MIL", "MINI", "MINT", "MIT", "MITSUBISHI", "MK", "ML", "MLB", "MLS", "MM", "MMA", "MN", "MO", "MOBI", "MOBILE", "MOBILY", "MODA", "MOE", "MOI", "MOM", "MONASH", "MONEY", "MONSTER", "MONTBLANC", "MOPAR", "MORMON", "MORTGAGE", "MOSCOW", "MOTO", "MOTORCYCLES", "MOV", "MOVIE", "MOVISTAR", "MP", "MQ", "MR", "MS", "MSD", "MT", "MTN", "MTR", "MU", "MUSEUM", "MUTUAL", "MV", "MW", "MX", "MY", "MZ", "NA", "NAB", "NADEX", "NAGOYA", "NAME", "NATIONWIDE", "NATURA", "NAVY", "NBA","NC", "NE", "NEC", "NET", "NETBANK", "NETFLIX", "NETWORK", "NEUSTAR", "NEW", "NEWHOLLAND", "NEWS", "NEXT", "NEXTDIRECT", "NEXUS", "NF", "NFL", "NG", "NGO", "NHK", "NI", "NICO", "NIKE", "NIKON", "NINJA", "NISSAN", "NISSAY", "NL", "NO", "NOKIA", "NORTHWESTERNMUTUAL", "NORTON", "NOW", "NOWRUZ", "NOWTV", "NP", "NR", "NRA", "NRW", "NTT", "NU", "NYC", "NZ", "OBI", "OBSERVER", "OFF", "OFFICE", "OKINAWA", "OLAYAN", "OLAYANGROUP", "OLDNAVY", "OLLO", "OM", "OMEGA", "ONE", "ONG", "ONL", "ONLINE", "ONYOURSIDE", "OOO", "OPEN", "ORACLE", "ORANGE", "ORG", "ORGANIC", "ORIGINS", "OSAKA", "OTSUKA", "OTT", "OVH", "PA", "PAGE", "PAMPEREDCHEF", "PANASONIC", "PANERAI", "PARIS", "PARS", "PARTNERS", "PARTS", "PARTY", "PASSAGENS", "PAY", "PCCW", "PE", "PET", "PF", "PFIZER", "PG", "PH", "PHARMACY", "PHD", "PHILIPS", "PHONE", "PHOTO", "PHOTOGRAPHY", "PHOTOS", "PHYSIO", "PIAGET", "PICS", "PICTET", "PICTURES", "PID", "PIN", "PING", "PINK", "PIONEER", "PIZZA", "PK", "PL", "PLACE", "PLAY", "PLAYSTATION", "PLUMBING", "PLUS", "PM", "PN", "PNC", "POHL", "POKER", "POLITIE", "PORN", "POST", "PR", "PRAMERICA", "PRAXI", "PRESS", "PRIME", "PRO", "PROD", "PRODUCTIONS", "PROF", "PROGRESSIVE", "PROMO", "PROPERTIES", "PROPERTY", "PROTECTION", "PRU", "PRUDENTIAL", "PS", "PT", "PUB", "PW", "PWC", "PY", "QA", "QPON", "QUEBEC", "QUEST", "QVC", "RACING", "RADIO", "RAID", "RE", "READ", "REALESTATE", "REALTOR", "REALTY", "RECIPES", "RED", "REDSTONE", "REDUMBRELLA", "REHAB", "REISE", "REISEN", "REIT", "RELIANCE", "REN", "RENT", "RENTALS", "REPAIR", "REPORT", "REPUBLICAN", "REST", "RESTAURANT", "REVIEW", "REVIEWS", "REXROTH", "RICH", "RICHARDLI", "RICOH", "RIGHTATHOME", "RIL", "RIO", "RIP", "RMIT", "RO", "ROCHER", "ROCKS", "RODEO", "ROGERS", "ROOM", "RS", "RSVP", "RU", "RUGBY", "RUHR", "RUN", "RW", "RWE", "RYUKYU", "SA", "SAARLAND", "SAFE", "SAFETY", "SAKURA", "SALE", "SALON", "SAMSCLUB", "SAMSUNG", "SANDVIK", "SANDVIKCOROMANT", "SANOFI", "SAP", "SAPO", "SARL", "SAS", "SAVE", "SAXO", "SB", "SBI", "SBS", "SC", "SCA", "SCB", "SCHAEFFLER", "SCHMIDT", "SCHOLARSHIPS", "SCHOOL", "SCHULE", "SCHWARZ", "SCIENCE", "SCJOHNSON", "SCOR", "SCOT", "SD", "SE", "SEARCH", "SEAT", "SECURE", "SECURITY", "SEEK", "SELECT", "SENER", "SERVICES", "SES", "SEVEN", "SEW", "SEX", "SEXY", "SFR", "SG", "SH", "SHANGRILA", "SHARP", "SHAW", "SHELL", "SHIA", "SHIKSHA", "SHOES", "SHOP", "SHOPPING", "SHOUJI", "SHOW", "SHOWTIME", "SHRIRAM", "SI", "SILK", "SINA", "SINGLES", "SITE", "SJ", "SK", "SKI", "SKIN", "SKY", "SKYPE", "SL", "SLING", "SM", "SMART", "SMILE", "SN", "SNCF", "SO", "SOCCER", "SOCIAL", "SOFTBANK", "SOFTWARE", "SOHU", "SOLAR", "SOLUTIONS", "SONG", "SONY", "SOY", "SPACE", "SPIEGEL", "SPOT", "SPREADBETTING", "SR", "SRL", "SRT", "ST", "STADA", "STAPLES", "STAR", "STARHUB", "STATEBANK", "STATEFARM", "STATOIL", "STC", "STCGROUP", "STOCKHOLM", "STORAGE", "STORE", "STREAM", "STUDIO", "STUDY", "STYLE", "SU", "SUCKS", "SUPPLIES", "SUPPLY", "SUPPORT", "SURF", "SURGERY", "SUZUKI", "SV", "SWATCH", "SWIFTCOVER", "SWISS", "SX", "SY", "SYDNEY", "SYMANTEC", "SYSTEMS", "SZ", "TAB", "TAIPEI", "TALK", "TAOBAO", "TARGET", "TATAMOTORS", "TATAR", "TATTOO", "TAX", "TAXI", "TC", "TCI", "TD", "TDK", "TEAM", "TECH", "TECHNOLOGY", "TEL", "TELECITY", "TELEFONICA", "TEMASEK", "TENNIS", "TEVA", "TF", "TG", "TH", "THD", "THEATER", "THEATRE", "TIAA", "TICKETS", "TIENDA", "TIFFANY", "TIPS", "TIRES", "TIROL", "TJ", "TJMAXX", "TJX", "TK", "TKMAXX", "TL", "TM", "TMALL", "TN", "TO", "TODAY", "TOKYO", "TOOLS", "TOP", "TORAY", "TOSHIBA", "TOTAL", "TOURS", "TOWN", "TOYOTA", "TOYS", "TR", "TRADE", "TRADING", "TRAINING", "TRAVEL", "TRAVELCHANNEL", "TRAVELERS", "TRAVELERSINSURANCE", "TRUST", "TRV", "TT", "TUBE", "TUI", "TUNES", "TUSHU", "TV", "TVS", "TW", "TZ", "UA", "UBANK", "UBS", "UCONNECT", "UG", "UK", "UNICOM", "UNIVERSITY", "UNO", "UOL", "UPS", "US", "UY", "UZ", "VA", "VACATIONS", "VANA", "VANGUARD", "VC", "VE", "VEGAS", "VENTURES", "VERISIGN", "VERSICHERUNG", "VET", "VG", "VI", "VIAJES", "VIDEO", "VIG", "VIKING", "VILLAS", "VIN", "VIP", "VIRGIN", "VISA",    "VODKA", "VOLKSWAGEN", "VOLVO", "VOTE", "VOTING", "VOTO", "VOYAGE", "VU", "VUELOS", "WALES", "WALMART", "WALTER", "WANG", "WANGGOU", "WARMAN", "WATCH", "WATCHES", "WEATHER", "WEATHERCHANNEL", "WEBCAM", "WEBER", "WEBSITE", "WED", "WEDDING", "WEIBO", "WEIR", "WF", "WHOSWHO", "WIEN", "WIKI", "WILLIAMHILL", "WIN", "WINDOWS", "WINE", "WINNERS", "WME", "WOLTERSKLUWER", "WOODSIDE", "WORK", "WORKS", "WORLD", "WOW", "WS", "WTC", "WTF", "XBOX", "XEROX", "XFINITY", "XIHUAN", "XIN"]
//    }
}


extension String {
    var ascii: UInt32 {
        return unicodeScalars.first!.value
    }
}
extension String {

    private subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
//    func substring(start : Int , endIndex : String.Index) -> String{
//        return String(self[self.index(self.startIndex, offsetBy: start)...endIndex])
//    }
    func substring(start : Int , location : Int) -> String{
        return String(self[self.index(self.startIndex, offsetBy: start)...self.index(self.startIndex, offsetBy: location)])
    }
    func lastIndexOf(_ char : String) -> Range<String.Index>?{

        return self.range(of: char, options: .backwards)
    }
}


class StringMatch{
    let location : Int
    let length : Int
    let EndIndex : Int
    let range : NSRange
    init(location : Int , length : Int) {
        self.location = location
        self.length = length
        self.EndIndex = location + length
        self.range =  NSRange.init(location: location, length: length)
    }
    init(location : Int , EndIndex : Int) {
        self.location = location
        self.EndIndex = EndIndex
        
        self.length = EndIndex - location
        self.range =  NSRange.init(location: location, length: length)
    }
}
