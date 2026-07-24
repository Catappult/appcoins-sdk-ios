//
//  Storefront.swift
//  AppCoinsSDK
//
//  Created by aptoide on 13/05/2025.
//

import Foundation

public struct Storefront {
    
    public let locale: Storefront.Locale?
    public let marketplace: Storefront.Marketplace?
    
    public struct Locale: Equatable {
        /// ISO 3166-1 alpha-3 country code
        public let code: String
        /// Country or region name
        public let region: String
        
        public static func fromRaw(raw: String) -> Locale? {
            return all.first { $0.code == raw }
        }
        
        public static func == (lhs: Locale, rhs: Locale) -> Bool {
            return lhs.code == rhs.code && lhs.region == rhs.region
        }
    }
    
    public enum Marketplace: String {
        case aptoide = "aptoide"
        case apple = "apple"
        
        public static func fromRaw(raw: String) -> Marketplace? {
            return Marketplace(rawValue: raw)
        }
    }
}

public extension Storefront.Locale {
    static let AFG = Storefront.Locale(code: "AFG", region: "Afghanistan")
    static let ALB = Storefront.Locale(code: "ALB", region: "Albania")
    static let DZA = Storefront.Locale(code: "DZA", region: "Algeria")
    static let AGO = Storefront.Locale(code: "AGO", region: "Angola")
    static let AIA = Storefront.Locale(code: "AIA", region: "Anguilla")
    static let ATG = Storefront.Locale(code: "ATG", region: "Antigua and Barbuda")
    static let ARG = Storefront.Locale(code: "ARG", region: "Argentina")
    static let ARM = Storefront.Locale(code: "ARM", region: "Armenia")
    static let AUS = Storefront.Locale(code: "AUS", region: "Australia")
    static let AUT = Storefront.Locale(code: "AUT", region: "Austria")
    static let AZE = Storefront.Locale(code: "AZE", region: "Azerbaijan")
    static let BHS = Storefront.Locale(code: "BHS", region: "Bahamas")
    static let BHR = Storefront.Locale(code: "BHR", region: "Bahrain")
    static let BRB = Storefront.Locale(code: "BRB", region: "Barbados")
    static let BLR = Storefront.Locale(code: "BLR", region: "Belarus")
    static let BEL = Storefront.Locale(code: "BEL", region: "Belgium")
    static let BLZ = Storefront.Locale(code: "BLZ", region: "Belize")
    static let BEN = Storefront.Locale(code: "BEN", region: "Benin")
    static let BMU = Storefront.Locale(code: "BMU", region: "Bermuda")
    static let BTN = Storefront.Locale(code: "BTN", region: "Bhutan")
    static let BOL = Storefront.Locale(code: "BOL", region: "Bolivia")
    static let BIH = Storefront.Locale(code: "BIH", region: "Bosnia and Herzegovina")
    static let BWA = Storefront.Locale(code: "BWA", region: "Botswana")
    static let BRA = Storefront.Locale(code: "BRA", region: "Brazil")
    static let VGB = Storefront.Locale(code: "VGB", region: "British Virgin Islands")
    static let BRN = Storefront.Locale(code: "BRN", region: "Brunei")
    static let BGR = Storefront.Locale(code: "BGR", region: "Bulgaria")
    static let BFA = Storefront.Locale(code: "BFA", region: "Burkina Faso")
    static let KHM = Storefront.Locale(code: "KHM", region: "Cambodia")
    static let CMR = Storefront.Locale(code: "CMR", region: "Cameroon")
    static let CAN = Storefront.Locale(code: "CAN", region: "Canada")
    static let CPV = Storefront.Locale(code: "CPV", region: "Cape Verde")
    static let CYM = Storefront.Locale(code: "CYM", region: "Cayman Islands")
    static let TCD = Storefront.Locale(code: "TCD", region: "Chad")
    static let CHL = Storefront.Locale(code: "CHL", region: "Chile")
    static let CHN = Storefront.Locale(code: "CHN", region: "China mainland")
    static let COL = Storefront.Locale(code: "COL", region: "Colombia")
    static let COD = Storefront.Locale(code: "COD", region: "Congo, Democratic Republic of the")
    static let COG = Storefront.Locale(code: "COG", region: "Congo, Republic of the")
    static let CRI = Storefront.Locale(code: "CRI", region: "Costa Rica")
    static let CIV = Storefront.Locale(code: "CIV", region: "Cote d’Ivoire")
    static let HRV = Storefront.Locale(code: "HRV", region: "Croatia")
    static let CYP = Storefront.Locale(code: "CYP", region: "Cyprus")
    static let CZE = Storefront.Locale(code: "CZE", region: "Czech Republic")
    static let DNK = Storefront.Locale(code: "DNK", region: "Denmark")
    static let DMA = Storefront.Locale(code: "DMA", region: "Dominica")
    static let DOM = Storefront.Locale(code: "DOM", region: "Dominican Republic")
    static let ECU = Storefront.Locale(code: "ECU", region: "Ecuador")
    static let EGY = Storefront.Locale(code: "EGY", region: "Egypt")
    static let SLV = Storefront.Locale(code: "SLV", region: "El Salvador")
    static let EST = Storefront.Locale(code: "EST", region: "Estonia")
    static let SWZ = Storefront.Locale(code: "SWZ", region: "Eswatini")
    static let FJI = Storefront.Locale(code: "FJI", region: "Fiji")
    static let FIN = Storefront.Locale(code: "FIN", region: "Finland")
    static let FRA = Storefront.Locale(code: "FRA", region: "France")
    static let GAB = Storefront.Locale(code: "GAB", region: "Gabon")
    static let GMB = Storefront.Locale(code: "GMB", region: "Gambia")
    static let GEO = Storefront.Locale(code: "GEO", region: "Georgia")
    static let DEU = Storefront.Locale(code: "DEU", region: "Germany")
    static let GHA = Storefront.Locale(code: "GHA", region: "Ghana")
    static let GRC = Storefront.Locale(code: "GRC", region: "Greece")
    static let GRD = Storefront.Locale(code: "GRD", region: "Grenada")
    static let GTM = Storefront.Locale(code: "GTM", region: "Guatemala")
    static let GNB = Storefront.Locale(code: "GNB", region: "Guinea-Bissau")
    static let GUY = Storefront.Locale(code: "GUY", region: "Guyana")
    static let HND = Storefront.Locale(code: "HND", region: "Honduras")
    static let HKG = Storefront.Locale(code: "HKG", region: "Hong Kong")
    static let HUN = Storefront.Locale(code: "HUN", region: "Hungary")
    static let ISL = Storefront.Locale(code: "ISL", region: "Iceland")
    static let IND = Storefront.Locale(code: "IND", region: "India")
    static let IDN = Storefront.Locale(code: "IDN", region: "Indonesia")
    static let IRQ = Storefront.Locale(code: "IRQ", region: "Iraq")
    static let IRL = Storefront.Locale(code: "IRL", region: "Ireland")
    static let ISR = Storefront.Locale(code: "ISR", region: "Israel")
    static let ITA = Storefront.Locale(code: "ITA", region: "Italy")
    static let JAM = Storefront.Locale(code: "JAM", region: "Jamaica")
    static let JPN = Storefront.Locale(code: "JPN", region: "Japan")
    static let JOR = Storefront.Locale(code: "JOR", region: "Jordan")
    static let KAZ = Storefront.Locale(code: "KAZ", region: "Kazakhstan")
    static let KEN = Storefront.Locale(code: "KEN", region: "Kenya")
    static let XKS = Storefront.Locale(code: "XKS", region: "Kosovo")
    static let KWT = Storefront.Locale(code: "KWT", region: "Kuwait")
    static let KGZ = Storefront.Locale(code: "KGZ", region: "Kyrgyzstan")
    static let LAO = Storefront.Locale(code: "LAO", region: "Laos")
    static let LVA = Storefront.Locale(code: "LVA", region: "Latvia")
    static let LBN = Storefront.Locale(code: "LBN", region: "Lebanon")
    static let LBR = Storefront.Locale(code: "LBR", region: "Liberia")
    static let LBY = Storefront.Locale(code: "LBY", region: "Libya")
    static let LTU = Storefront.Locale(code: "LTU", region: "Lithuania")
    static let LUX = Storefront.Locale(code: "LUX", region: "Luxembourg")
    static let MAC = Storefront.Locale(code: "MAC", region: "Macau")
    static let MDG = Storefront.Locale(code: "MDG", region: "Madagascar")
    static let MWI = Storefront.Locale(code: "MWI", region: "Malawi")
    static let MYS = Storefront.Locale(code: "MYS", region: "Malaysia")
    static let MDV = Storefront.Locale(code: "MDV", region: "Maldives")
    static let MLI = Storefront.Locale(code: "MLI", region: "Mali")
    static let MLT = Storefront.Locale(code: "MLT", region: "Malta")
    static let MRT = Storefront.Locale(code: "MRT", region: "Mauritania")
    static let MUS = Storefront.Locale(code: "MUS", region: "Mauritius")
    static let MEX = Storefront.Locale(code: "MEX", region: "Mexico")
    static let FSM = Storefront.Locale(code: "FSM", region: "Micronesia")
    static let MDA = Storefront.Locale(code: "MDA", region: "Moldova")
    static let MNG = Storefront.Locale(code: "MNG", region: "Mongolia")
    static let MNE = Storefront.Locale(code: "MNE", region: "Montenegro")
    static let MSR = Storefront.Locale(code: "MSR", region: "Montserrat")
    static let MAR = Storefront.Locale(code: "MAR", region: "Morocco")
    static let MOZ = Storefront.Locale(code: "MOZ", region: "Mozambique")
    static let MMR = Storefront.Locale(code: "MMR", region: "Myanmar")
    static let NAM = Storefront.Locale(code: "NAM", region: "Namibia")
    static let NRU = Storefront.Locale(code: "NRU", region: "Nauru")
    static let NPL = Storefront.Locale(code: "NPL", region: "Nepal")
    static let NLD = Storefront.Locale(code: "NLD", region: "Netherlands")
    static let NZL = Storefront.Locale(code: "NZL", region: "New Zealand")
    static let NIC = Storefront.Locale(code: "NIC", region: "Nicaragua")
    static let NER = Storefront.Locale(code: "NER", region: "Niger")
    static let NGA = Storefront.Locale(code: "NGA", region: "Nigeria")
    static let MKD = Storefront.Locale(code: "MKD", region: "North Macedonia")
    static let NOR = Storefront.Locale(code: "NOR", region: "Norway")
    static let OMN = Storefront.Locale(code: "OMN", region: "Oman")
    static let PAK = Storefront.Locale(code: "PAK", region: "Pakistan")
    static let PLW = Storefront.Locale(code: "PLW", region: "Palau")
    static let PAN = Storefront.Locale(code: "PAN", region: "Panama")
    static let PNG = Storefront.Locale(code: "PNG", region: "Papua New Guinea")
    static let PRY = Storefront.Locale(code: "PRY", region: "Paraguay")
    static let PER = Storefront.Locale(code: "PER", region: "Peru")
    static let PHL = Storefront.Locale(code: "PHL", region: "Philippines")
    static let POL = Storefront.Locale(code: "POL", region: "Poland")
    static let PRT = Storefront.Locale(code: "PRT", region: "Portugal")
    static let QAT = Storefront.Locale(code: "QAT", region: "Qatar")
    static let KOR = Storefront.Locale(code: "KOR", region: "Republic of Korea")
    static let ROU = Storefront.Locale(code: "ROU", region: "Romania")
    static let RUS = Storefront.Locale(code: "RUS", region: "Russia")
    static let RWA = Storefront.Locale(code: "RWA", region: "Rwanda")
    static let STP = Storefront.Locale(code: "STP", region: "Sao Tome and Principe")
    static let SAU = Storefront.Locale(code: "SAU", region: "Saudi Arabia")
    static let SEN = Storefront.Locale(code: "SEN", region: "Senegal")
    static let SRB = Storefront.Locale(code: "SRB", region: "Serbia")
    static let SYC = Storefront.Locale(code: "SYC", region: "Seychelles")
    static let SLE = Storefront.Locale(code: "SLE", region: "Sierra Leone")
    static let SGP = Storefront.Locale(code: "SGP", region: "Singapore")
    static let SVK = Storefront.Locale(code: "SVK", region: "Slovakia")
    static let SVN = Storefront.Locale(code: "SVN", region: "Slovenia")
    static let SLB = Storefront.Locale(code: "SLB", region: "Solomon Islands")
    static let ZAF = Storefront.Locale(code: "ZAF", region: "South Africa")
    static let ESP = Storefront.Locale(code: "ESP", region: "Spain")
    static let LKA = Storefront.Locale(code: "LKA", region: "Sri Lanka")
    static let KNA = Storefront.Locale(code: "KNA", region: "St. Kitts and Nevis")
    static let LCA = Storefront.Locale(code: "LCA", region: "St. Lucia")
    static let VCT = Storefront.Locale(code: "VCT", region: "St. Vincent and the Grenadines")
    static let SUR = Storefront.Locale(code: "SUR", region: "Suriname")
    static let SWE = Storefront.Locale(code: "SWE", region: "Sweden")
    static let CHE = Storefront.Locale(code: "CHE", region: "Switzerland")
    static let TWN = Storefront.Locale(code: "TWN", region: "Taiwan")
    static let TJK = Storefront.Locale(code: "TJK", region: "Tajikistan")
    static let TZA = Storefront.Locale(code: "TZA", region: "Tanzania")
    static let THA = Storefront.Locale(code: "THA", region: "Thailand")
    static let TON = Storefront.Locale(code: "TON", region: "Tonga")
    static let TTO = Storefront.Locale(code: "TTO", region: "Trinidad and Tobago")
    static let TUN = Storefront.Locale(code: "TUN", region: "Tunisia")
    static let TUR = Storefront.Locale(code: "TUR", region: "Türkiye")
    static let TKM = Storefront.Locale(code: "TKM", region: "Turkmenistan")
    static let TCA = Storefront.Locale(code: "TCA", region: "Turks and Caicos Islands")
    static let UGA = Storefront.Locale(code: "UGA", region: "Uganda")
    static let UKR = Storefront.Locale(code: "UKR", region: "Ukraine")
    static let ARE = Storefront.Locale(code: "ARE", region: "United Arab Emirates")
    static let GBR = Storefront.Locale(code: "GBR", region: "United Kingdom")
    static let USA = Storefront.Locale(code: "USA", region: "United States")
    static let URY = Storefront.Locale(code: "URY", region: "Uruguay")
    static let UZB = Storefront.Locale(code: "UZB", region: "Uzbekistan")
    static let VUT = Storefront.Locale(code: "VUT", region: "Vanuatu")
    static let VEN = Storefront.Locale(code: "VEN", region: "Venezuela")
    static let VNM = Storefront.Locale(code: "VNM", region: "Vietnam")
    static let YEM = Storefront.Locale(code: "YEM", region: "Yemen")
    static let ZMB = Storefront.Locale(code: "ZMB", region: "Zambia")
    static let ZWE = Storefront.Locale(code: "ZWE", region: "Zimbabwe")

    /// All App Store Connect storefronts
    static let all: [Storefront.Locale] = [
        .AFG,
        .ALB,
        .DZA,
        .AGO,
        .AIA,
        .ATG,
        .ARG,
        .ARM,
        .AUS,
        .AUT,
        .AZE,
        .BHS,
        .BHR,
        .BRB,
        .BLR,
        .BEL,
        .BLZ,
        .BEN,
        .BMU,
        .BTN,
        .BOL,
        .BIH,
        .BWA,
        .BRA,
        .VGB,
        .BRN,
        .BGR,
        .BFA,
        .KHM,
        .CMR,
        .CAN,
        .CPV,
        .CYM,
        .TCD,
        .CHL,
        .CHN,
        .COL,
        .COD,
        .COG,
        .CRI,
        .CIV,
        .HRV,
        .CYP,
        .CZE,
        .DNK,
        .DMA,
        .DOM,
        .ECU,
        .EGY,
        .SLV,
        .EST,
        .SWZ,
        .FJI,
        .FIN,
        .FRA,
        .GAB,
        .GMB,
        .GEO,
        .DEU,
        .GHA,
        .GRC,
        .GRD,
        .GTM,
        .GNB,
        .GUY,
        .HND,
        .HKG,
        .HUN,
        .ISL,
        .IND,
        .IDN,
        .IRQ,
        .IRL,
        .ISR,
        .ITA,
        .JAM,
        .JPN,
        .JOR,
        .KAZ,
        .KEN,
        .XKS,
        .KWT,
        .KGZ,
        .LAO,
        .LVA,
        .LBN,
        .LBR,
        .LBY,
        .LTU,
        .LUX,
        .MAC,
        .MDG,
        .MWI,
        .MYS,
        .MDV,
        .MLI,
        .MLT,
        .MRT,
        .MUS,
        .MEX,
        .FSM,
        .MDA,
        .MNG,
        .MNE,
        .MSR,
        .MAR,
        .MOZ,
        .MMR,
        .NAM,
        .NRU,
        .NPL,
        .NLD,
        .NZL,
        .NIC,
        .NER,
        .NGA,
        .MKD,
        .NOR,
        .OMN,
        .PAK,
        .PLW,
        .PAN,
        .PNG,
        .PRY,
        .PER,
        .PHL,
        .POL,
        .PRT,
        .QAT,
        .KOR,
        .ROU,
        .RUS,
        .RWA,
        .STP,
        .SAU,
        .SEN,
        .SRB,
        .SYC,
        .SLE,
        .SGP,
        .SVK,
        .SVN,
        .SLB,
        .ZAF,
        .ESP,
        .LKA,
        .KNA,
        .LCA,
        .VCT,
        .SUR,
        .SWE,
        .CHE,
        .TWN,
        .TJK,
        .TZA,
        .THA,
        .TON,
        .TTO,
        .TUN,
        .TUR,
        .TKM,
        .TCA,
        .UGA,
        .UKR,
        .ARE,
        .GBR,
        .USA,
        .URY,
        .UZB,
        .VUT,
        .VEN,
        .VNM,
        .YEM,
        .ZMB,
        .ZWE
    ]
    
    /// All EU member-state storefronts (ISO 3166-1 alpha-3)
    static let EU: [Storefront.Locale] = [
        .AUT,
        .BEL,
        .BGR,
        .HRV,
        .CYP,
        .CZE,
        .DNK,
        .EST,
        .FIN,
        .FRA,
        .DEU,
        .GRC,
        .HUN,
        .IRL,
        .ITA,
        .LVA,
        .LTU,
        .LUX,
        .MLT,
        .NLD,
        .POL,
        .PRT,
        .ROU,
        .SVK,
        .SVN,
        .ESP,
        .SWE
    ]
}
