//
//  AppcStorefront.swift
//  AppCoinsSDK
//
//  Created by aptoide on 13/05/2025.
//

import Foundation

public struct AppcStorefront {
    
    public let locale: AppcStorefront.Locale?
    public let marketplace: AppcStorefront.Marketplace?
    
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

public extension AppcStorefront.Locale {
    static let AFG = AppcStorefront.Locale(code: "AFG", region: "Afghanistan")
    static let ALB = AppcStorefront.Locale(code: "ALB", region: "Albania")
    static let DZA = AppcStorefront.Locale(code: "DZA", region: "Algeria")
    static let AGO = AppcStorefront.Locale(code: "AGO", region: "Angola")
    static let AIA = AppcStorefront.Locale(code: "AIA", region: "Anguilla")
    static let ATG = AppcStorefront.Locale(code: "ATG", region: "Antigua and Barbuda")
    static let ARG = AppcStorefront.Locale(code: "ARG", region: "Argentina")
    static let ARM = AppcStorefront.Locale(code: "ARM", region: "Armenia")
    static let AUS = AppcStorefront.Locale(code: "AUS", region: "Australia")
    static let AUT = AppcStorefront.Locale(code: "AUT", region: "Austria")
    static let AZE = AppcStorefront.Locale(code: "AZE", region: "Azerbaijan")
    static let BHS = AppcStorefront.Locale(code: "BHS", region: "Bahamas")
    static let BHR = AppcStorefront.Locale(code: "BHR", region: "Bahrain")
    static let BRB = AppcStorefront.Locale(code: "BRB", region: "Barbados")
    static let BLR = AppcStorefront.Locale(code: "BLR", region: "Belarus")
    static let BEL = AppcStorefront.Locale(code: "BEL", region: "Belgium")
    static let BLZ = AppcStorefront.Locale(code: "BLZ", region: "Belize")
    static let BEN = AppcStorefront.Locale(code: "BEN", region: "Benin")
    static let BMU = AppcStorefront.Locale(code: "BMU", region: "Bermuda")
    static let BTN = AppcStorefront.Locale(code: "BTN", region: "Bhutan")
    static let BOL = AppcStorefront.Locale(code: "BOL", region: "Bolivia")
    static let BIH = AppcStorefront.Locale(code: "BIH", region: "Bosnia and Herzegovina")
    static let BWA = AppcStorefront.Locale(code: "BWA", region: "Botswana")
    static let BRA = AppcStorefront.Locale(code: "BRA", region: "Brazil")
    static let VGB = AppcStorefront.Locale(code: "VGB", region: "British Virgin Islands")
    static let BRN = AppcStorefront.Locale(code: "BRN", region: "Brunei")
    static let BGR = AppcStorefront.Locale(code: "BGR", region: "Bulgaria")
    static let BFA = AppcStorefront.Locale(code: "BFA", region: "Burkina Faso")
    static let KHM = AppcStorefront.Locale(code: "KHM", region: "Cambodia")
    static let CMR = AppcStorefront.Locale(code: "CMR", region: "Cameroon")
    static let CAN = AppcStorefront.Locale(code: "CAN", region: "Canada")
    static let CPV = AppcStorefront.Locale(code: "CPV", region: "Cape Verde")
    static let CYM = AppcStorefront.Locale(code: "CYM", region: "Cayman Islands")
    static let TCD = AppcStorefront.Locale(code: "TCD", region: "Chad")
    static let CHL = AppcStorefront.Locale(code: "CHL", region: "Chile")
    static let CHN = AppcStorefront.Locale(code: "CHN", region: "China mainland")
    static let COL = AppcStorefront.Locale(code: "COL", region: "Colombia")
    static let COD = AppcStorefront.Locale(code: "COD", region: "Congo, Democratic Republic of the")
    static let COG = AppcStorefront.Locale(code: "COG", region: "Congo, Republic of the")
    static let CRI = AppcStorefront.Locale(code: "CRI", region: "Costa Rica")
    static let CIV = AppcStorefront.Locale(code: "CIV", region: "Cote d’Ivoire")
    static let HRV = AppcStorefront.Locale(code: "HRV", region: "Croatia")
    static let CYP = AppcStorefront.Locale(code: "CYP", region: "Cyprus")
    static let CZE = AppcStorefront.Locale(code: "CZE", region: "Czech Republic")
    static let DNK = AppcStorefront.Locale(code: "DNK", region: "Denmark")
    static let DMA = AppcStorefront.Locale(code: "DMA", region: "Dominica")
    static let DOM = AppcStorefront.Locale(code: "DOM", region: "Dominican Republic")
    static let ECU = AppcStorefront.Locale(code: "ECU", region: "Ecuador")
    static let EGY = AppcStorefront.Locale(code: "EGY", region: "Egypt")
    static let SLV = AppcStorefront.Locale(code: "SLV", region: "El Salvador")
    static let EST = AppcStorefront.Locale(code: "EST", region: "Estonia")
    static let SWZ = AppcStorefront.Locale(code: "SWZ", region: "Eswatini")
    static let FJI = AppcStorefront.Locale(code: "FJI", region: "Fiji")
    static let FIN = AppcStorefront.Locale(code: "FIN", region: "Finland")
    static let FRA = AppcStorefront.Locale(code: "FRA", region: "France")
    static let GAB = AppcStorefront.Locale(code: "GAB", region: "Gabon")
    static let GMB = AppcStorefront.Locale(code: "GMB", region: "Gambia")
    static let GEO = AppcStorefront.Locale(code: "GEO", region: "Georgia")
    static let DEU = AppcStorefront.Locale(code: "DEU", region: "Germany")
    static let GHA = AppcStorefront.Locale(code: "GHA", region: "Ghana")
    static let GRC = AppcStorefront.Locale(code: "GRC", region: "Greece")
    static let GRD = AppcStorefront.Locale(code: "GRD", region: "Grenada")
    static let GTM = AppcStorefront.Locale(code: "GTM", region: "Guatemala")
    static let GNB = AppcStorefront.Locale(code: "GNB", region: "Guinea-Bissau")
    static let GUY = AppcStorefront.Locale(code: "GUY", region: "Guyana")
    static let HND = AppcStorefront.Locale(code: "HND", region: "Honduras")
    static let HKG = AppcStorefront.Locale(code: "HKG", region: "Hong Kong")
    static let HUN = AppcStorefront.Locale(code: "HUN", region: "Hungary")
    static let ISL = AppcStorefront.Locale(code: "ISL", region: "Iceland")
    static let IND = AppcStorefront.Locale(code: "IND", region: "India")
    static let IDN = AppcStorefront.Locale(code: "IDN", region: "Indonesia")
    static let IRQ = AppcStorefront.Locale(code: "IRQ", region: "Iraq")
    static let IRL = AppcStorefront.Locale(code: "IRL", region: "Ireland")
    static let ISR = AppcStorefront.Locale(code: "ISR", region: "Israel")
    static let ITA = AppcStorefront.Locale(code: "ITA", region: "Italy")
    static let JAM = AppcStorefront.Locale(code: "JAM", region: "Jamaica")
    static let JPN = AppcStorefront.Locale(code: "JPN", region: "Japan")
    static let JOR = AppcStorefront.Locale(code: "JOR", region: "Jordan")
    static let KAZ = AppcStorefront.Locale(code: "KAZ", region: "Kazakhstan")
    static let KEN = AppcStorefront.Locale(code: "KEN", region: "Kenya")
    static let XKS = AppcStorefront.Locale(code: "XKS", region: "Kosovo")
    static let KWT = AppcStorefront.Locale(code: "KWT", region: "Kuwait")
    static let KGZ = AppcStorefront.Locale(code: "KGZ", region: "Kyrgyzstan")
    static let LAO = AppcStorefront.Locale(code: "LAO", region: "Laos")
    static let LVA = AppcStorefront.Locale(code: "LVA", region: "Latvia")
    static let LBN = AppcStorefront.Locale(code: "LBN", region: "Lebanon")
    static let LBR = AppcStorefront.Locale(code: "LBR", region: "Liberia")
    static let LBY = AppcStorefront.Locale(code: "LBY", region: "Libya")
    static let LTU = AppcStorefront.Locale(code: "LTU", region: "Lithuania")
    static let LUX = AppcStorefront.Locale(code: "LUX", region: "Luxembourg")
    static let MAC = AppcStorefront.Locale(code: "MAC", region: "Macau")
    static let MDG = AppcStorefront.Locale(code: "MDG", region: "Madagascar")
    static let MWI = AppcStorefront.Locale(code: "MWI", region: "Malawi")
    static let MYS = AppcStorefront.Locale(code: "MYS", region: "Malaysia")
    static let MDV = AppcStorefront.Locale(code: "MDV", region: "Maldives")
    static let MLI = AppcStorefront.Locale(code: "MLI", region: "Mali")
    static let MLT = AppcStorefront.Locale(code: "MLT", region: "Malta")
    static let MRT = AppcStorefront.Locale(code: "MRT", region: "Mauritania")
    static let MUS = AppcStorefront.Locale(code: "MUS", region: "Mauritius")
    static let MEX = AppcStorefront.Locale(code: "MEX", region: "Mexico")
    static let FSM = AppcStorefront.Locale(code: "FSM", region: "Micronesia")
    static let MDA = AppcStorefront.Locale(code: "MDA", region: "Moldova")
    static let MNG = AppcStorefront.Locale(code: "MNG", region: "Mongolia")
    static let MNE = AppcStorefront.Locale(code: "MNE", region: "Montenegro")
    static let MSR = AppcStorefront.Locale(code: "MSR", region: "Montserrat")
    static let MAR = AppcStorefront.Locale(code: "MAR", region: "Morocco")
    static let MOZ = AppcStorefront.Locale(code: "MOZ", region: "Mozambique")
    static let MMR = AppcStorefront.Locale(code: "MMR", region: "Myanmar")
    static let NAM = AppcStorefront.Locale(code: "NAM", region: "Namibia")
    static let NRU = AppcStorefront.Locale(code: "NRU", region: "Nauru")
    static let NPL = AppcStorefront.Locale(code: "NPL", region: "Nepal")
    static let NLD = AppcStorefront.Locale(code: "NLD", region: "Netherlands")
    static let NZL = AppcStorefront.Locale(code: "NZL", region: "New Zealand")
    static let NIC = AppcStorefront.Locale(code: "NIC", region: "Nicaragua")
    static let NER = AppcStorefront.Locale(code: "NER", region: "Niger")
    static let NGA = AppcStorefront.Locale(code: "NGA", region: "Nigeria")
    static let MKD = AppcStorefront.Locale(code: "MKD", region: "North Macedonia")
    static let NOR = AppcStorefront.Locale(code: "NOR", region: "Norway")
    static let OMN = AppcStorefront.Locale(code: "OMN", region: "Oman")
    static let PAK = AppcStorefront.Locale(code: "PAK", region: "Pakistan")
    static let PLW = AppcStorefront.Locale(code: "PLW", region: "Palau")
    static let PAN = AppcStorefront.Locale(code: "PAN", region: "Panama")
    static let PNG = AppcStorefront.Locale(code: "PNG", region: "Papua New Guinea")
    static let PRY = AppcStorefront.Locale(code: "PRY", region: "Paraguay")
    static let PER = AppcStorefront.Locale(code: "PER", region: "Peru")
    static let PHL = AppcStorefront.Locale(code: "PHL", region: "Philippines")
    static let POL = AppcStorefront.Locale(code: "POL", region: "Poland")
    static let PRT = AppcStorefront.Locale(code: "PRT", region: "Portugal")
    static let QAT = AppcStorefront.Locale(code: "QAT", region: "Qatar")
    static let KOR = AppcStorefront.Locale(code: "KOR", region: "Republic of Korea")
    static let ROU = AppcStorefront.Locale(code: "ROU", region: "Romania")
    static let RUS = AppcStorefront.Locale(code: "RUS", region: "Russia")
    static let RWA = AppcStorefront.Locale(code: "RWA", region: "Rwanda")
    static let STP = AppcStorefront.Locale(code: "STP", region: "Sao Tome and Principe")
    static let SAU = AppcStorefront.Locale(code: "SAU", region: "Saudi Arabia")
    static let SEN = AppcStorefront.Locale(code: "SEN", region: "Senegal")
    static let SRB = AppcStorefront.Locale(code: "SRB", region: "Serbia")
    static let SYC = AppcStorefront.Locale(code: "SYC", region: "Seychelles")
    static let SLE = AppcStorefront.Locale(code: "SLE", region: "Sierra Leone")
    static let SGP = AppcStorefront.Locale(code: "SGP", region: "Singapore")
    static let SVK = AppcStorefront.Locale(code: "SVK", region: "Slovakia")
    static let SVN = AppcStorefront.Locale(code: "SVN", region: "Slovenia")
    static let SLB = AppcStorefront.Locale(code: "SLB", region: "Solomon Islands")
    static let ZAF = AppcStorefront.Locale(code: "ZAF", region: "South Africa")
    static let ESP = AppcStorefront.Locale(code: "ESP", region: "Spain")
    static let LKA = AppcStorefront.Locale(code: "LKA", region: "Sri Lanka")
    static let KNA = AppcStorefront.Locale(code: "KNA", region: "St. Kitts and Nevis")
    static let LCA = AppcStorefront.Locale(code: "LCA", region: "St. Lucia")
    static let VCT = AppcStorefront.Locale(code: "VCT", region: "St. Vincent and the Grenadines")
    static let SUR = AppcStorefront.Locale(code: "SUR", region: "Suriname")
    static let SWE = AppcStorefront.Locale(code: "SWE", region: "Sweden")
    static let CHE = AppcStorefront.Locale(code: "CHE", region: "Switzerland")
    static let TWN = AppcStorefront.Locale(code: "TWN", region: "Taiwan")
    static let TJK = AppcStorefront.Locale(code: "TJK", region: "Tajikistan")
    static let TZA = AppcStorefront.Locale(code: "TZA", region: "Tanzania")
    static let THA = AppcStorefront.Locale(code: "THA", region: "Thailand")
    static let TON = AppcStorefront.Locale(code: "TON", region: "Tonga")
    static let TTO = AppcStorefront.Locale(code: "TTO", region: "Trinidad and Tobago")
    static let TUN = AppcStorefront.Locale(code: "TUN", region: "Tunisia")
    static let TUR = AppcStorefront.Locale(code: "TUR", region: "Türkiye")
    static let TKM = AppcStorefront.Locale(code: "TKM", region: "Turkmenistan")
    static let TCA = AppcStorefront.Locale(code: "TCA", region: "Turks and Caicos Islands")
    static let UGA = AppcStorefront.Locale(code: "UGA", region: "Uganda")
    static let UKR = AppcStorefront.Locale(code: "UKR", region: "Ukraine")
    static let ARE = AppcStorefront.Locale(code: "ARE", region: "United Arab Emirates")
    static let GBR = AppcStorefront.Locale(code: "GBR", region: "United Kingdom")
    static let USA = AppcStorefront.Locale(code: "USA", region: "United States")
    static let URY = AppcStorefront.Locale(code: "URY", region: "Uruguay")
    static let UZB = AppcStorefront.Locale(code: "UZB", region: "Uzbekistan")
    static let VUT = AppcStorefront.Locale(code: "VUT", region: "Vanuatu")
    static let VEN = AppcStorefront.Locale(code: "VEN", region: "Venezuela")
    static let VNM = AppcStorefront.Locale(code: "VNM", region: "Vietnam")
    static let YEM = AppcStorefront.Locale(code: "YEM", region: "Yemen")
    static let ZMB = AppcStorefront.Locale(code: "ZMB", region: "Zambia")
    static let ZWE = AppcStorefront.Locale(code: "ZWE", region: "Zimbabwe")

    /// All App Store Connect storefronts
    static let all: [AppcStorefront.Locale] = [
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
    static let EU: [AppcStorefront.Locale] = [
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
