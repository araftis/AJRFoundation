/*
 HTMLEntities.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRFoundation nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

/*
 Basically, if you're trying to parse an HTML file with XMLDocument, you'll find that HTML entities aren't handled very gracefully. To get around this, you can use HTMLEntities.htmlDocType to get a <!DOCTYPE> header that includes are the HTML entities.
 */
public struct HTMLEntities {
    
    private static var predefinedHTMLEntities : [(character:String, name: String)] {
        return [
            (character: "\u{00c0}", name: "Agrave"), // À
            (character: "\u{00c1}", name: "Aacute"), // Á
            (character: "\u{00c2}", name: "Acirc"), // Â
            (character: "\u{00c3}", name: "Atilde"), // Ã
            (character: "\u{00c4}", name: "Auml"), // Ä
            (character: "\u{00c5}", name: "Aring"), // Å
            (character: "\u{00c6}", name: "AElig"), // Æ
            (character: "\u{00c7}", name: "Ccedil"), // Ç
            (character: "\u{00c8}", name: "Egrave"), // È
            (character: "\u{00c9}", name: "Eacute"), // É
            (character: "\u{00ca}", name: "Ecirc"), // Ê
            (character: "\u{00cb}", name: "Euml"), // Ë
            (character: "\u{00cc}", name: "Igrave"), // Ì
            (character: "\u{00cd}", name: "Iacute"), // Í
            (character: "\u{00ce}", name: "Icirc"), // Î
            (character: "\u{00cf}", name: "Iuml"), // Ï
            (character: "\u{00d0}", name: "ETH"), // Ð
            (character: "\u{00d1}", name: "Ntilde"), // Ñ
            (character: "\u{00d2}", name: "Ograve"), // Ò
            (character: "\u{00d3}", name: "Oacute"), // Ó
            (character: "\u{00d4}", name: "Ocirc"), // Ô
            (character: "\u{00d5}", name: "Otilde"), // Õ
            (character: "\u{00d6}", name: "Ouml"), // Ö
            (character: "\u{00d8}", name: "Oslash"), // Ø
            (character: "\u{00d9}", name: "Ugrave"), // Ù
            (character: "\u{00da}", name: "Uacute"), // Ú
            (character: "\u{00db}", name: "Ucirc"), // Û
            (character: "\u{00dc}", name: "Uuml"), // Ü
            (character: "\u{00dd}", name: "Yacute"), // Ý
            (character: "\u{00de}", name: "THORN"), // Þ
            (character: "\u{00df}", name: "szlig"), // ß
            (character: "\u{00e0}", name: "agrave"), // à
            (character: "\u{00e1}", name: "aacute"), // á
            (character: "\u{00e2}", name: "acirc"), // â
            (character: "\u{00e3}", name: "atilde"), // ã
            (character: "\u{00e4}", name: "auml"), // ä
            (character: "\u{00e5}", name: "aring"), // å
            (character: "\u{00e6}", name: "aelig"), // æ
            (character: "\u{00e7}", name: "ccedil"), // ç
            (character: "\u{00e8}", name: "egrave"), // è
            (character: "\u{00e9}", name: "eacute"), // é
            (character: "\u{00ea}", name: "ecirc"), // ê
            (character: "\u{00eb}", name: "euml"), // ë
            (character: "\u{00ec}", name: "igrave"), // ì
            (character: "\u{00ed}", name: "iacute"), // í
            (character: "\u{00ee}", name: "icirc"), // î
            (character: "\u{00ef}", name: "iuml"), // ï
            (character: "\u{00f0}", name: "eth"), // ð
            (character: "\u{00f1}", name: "ntilde"), // ñ
            (character: "\u{00f2}", name: "ograve"), // ò
            (character: "\u{00f3}", name: "oacute"), // ó
            (character: "\u{00f4}", name: "ocirc"), // ô
            (character: "\u{00f5}", name: "otilde"), // õ
            (character: "\u{00f6}", name: "ouml"), // ö
            (character: "\u{00f8}", name: "oslash"), // ø
            (character: "\u{00f9}", name: "ugrave"), // ù
            (character: "\u{00fa}", name: "uacute"), // ú
            (character: "\u{00fb}", name: "ucirc"), // û
            (character: "\u{00fc}", name: "uuml"), // ü
            (character: "\u{00fd}", name: "yacute"), // ý
            (character: "\u{00fe}", name: "thorn"), // þ
            (character: "\u{00ff}", name: "yuml"), // ÿ
            (character: "\u{00a0}", name: "nbsp"), //
            (character: "\u{00a1}", name: "iexcl"), // ¡
            (character: "\u{00a2}", name: "cent"), // ¢
            (character: "\u{00a3}", name: "pound"), // £
            (character: "\u{00a4}", name: "curren"), // ¤
            (character: "\u{00a5}", name: "yen"), // ¥
            (character: "\u{00a6}", name: "brvbar"), // ¦
            (character: "\u{00a7}", name: "sect"), // §
            (character: "\u{00a8}", name: "uml"), // ¨
            (character: "\u{00a9}", name: "copy"), // ©
            (character: "\u{00aa}", name: "ordf"), // ª
            (character: "\u{00ab}", name: "laquo"), // «
            (character: "\u{00ac}", name: "not"), // ¬
            (character: "\u{00ad}", name: "shy"), //
            (character: "\u{00ae}", name: "reg"), // ®
            (character: "\u{00af}", name: "macr"), // ¯
            (character: "\u{00b0}", name: "deg"), // °
            (character: "\u{00b1}", name: "plusmn"), // ±
            (character: "\u{00b2}", name: "sup2"), // ²
            (character: "\u{00b3}", name: "sup3"), // ³
            (character: "\u{00b4}", name: "acute"), // ´
            (character: "\u{00b5}", name: "micro"), // µ
            (character: "\u{00b6}", name: "para"), // ¶
            (character: "\u{00b8}", name: "cedil"), // ¸
            (character: "\u{00b9}", name: "sup1"), // ¹
            (character: "\u{00ba}", name: "ordm"), // º
            (character: "\u{00bb}", name: "raquo"), // »
            (character: "\u{00bc}", name: "frac14"), // ¼
            (character: "\u{00bd}", name: "frac12"), // ½
            (character: "\u{00be}", name: "frac34"), // ¾
            (character: "\u{00bf}", name: "iquest"), // ¿
            (character: "\u{00d7}", name: "times"), // ×
            (character: "\u{00f7}", name: "divide"), // ÷
            (character: "\u{2200}", name: "forall"), // ∀
            (character: "\u{2202}", name: "part"), // ∂
            (character: "\u{2203}", name: "exist"), // ∃
            (character: "\u{2205}", name: "empty"), // ∅
            (character: "\u{2207}", name: "nabla"), // ∇
            (character: "\u{2208}", name: "isin"), // ∈
            (character: "\u{2209}", name: "notin"), // ∉
            (character: "\u{220b}", name: "ni"), // ∋
            (character: "\u{220f}", name: "prod"), // ∏
            (character: "\u{2211}", name: "sum"), // ∑
            (character: "\u{2212}", name: "minus"), // −
            (character: "\u{2217}", name: "lowast"), // ∗
            (character: "\u{221a}", name: "radic"), // √
            (character: "\u{221d}", name: "prop"), // ∝
            (character: "\u{221e}", name: "infin"), // ∞
            (character: "\u{2220}", name: "ang"), // ∠
            (character: "\u{2227}", name: "and"), // ∧
            (character: "\u{2228}", name: "or"), // ∨
            (character: "\u{2229}", name: "cap"), // ∩
            (character: "\u{222a}", name: "cup"), // ∪
            (character: "\u{222b}", name: "int"), // ∫
            (character: "\u{2234}", name: "there4"), // ∴
            (character: "\u{223c}", name: "sim"), // ∼
            (character: "\u{2245}", name: "cong"), // ≅
            (character: "\u{2248}", name: "asymp"), // ≈
            (character: "\u{2260}", name: "ne"), // ≠
            (character: "\u{2261}", name: "equiv"), // ≡
            (character: "\u{2264}", name: "le"), // ≤
            (character: "\u{2265}", name: "ge"), // ≥
            (character: "\u{2282}", name: "sub"), // ⊂
            (character: "\u{2283}", name: "sup"), // ⊃
            (character: "\u{2284}", name: "nsub"), // ⊄
            (character: "\u{2286}", name: "sube"), // ⊆
            (character: "\u{2287}", name: "supe"), // ⊇
            (character: "\u{2295}", name: "oplus"), // ⊕
            (character: "\u{2297}", name: "otimes"), // ⊗
            (character: "\u{22a5}", name: "perp"), // ⊥
            (character: "\u{22c5}", name: "sdot"), // ⋅
            (character: "\u{0391}", name: "Alpha"), // Α
            (character: "\u{0392}", name: "Beta"), // Β
            (character: "\u{0393}", name: "Gamma"), // Γ
            (character: "\u{0394}", name: "Delta"), // Δ
            (character: "\u{0395}", name: "Epsilon"), // Ε
            (character: "\u{0396}", name: "Zeta"), // Ζ
            (character: "\u{0397}", name: "Eta"), // Η
            (character: "\u{0398}", name: "Theta"), // Θ
            (character: "\u{0399}", name: "Iota"), // Ι
            (character: "\u{039a}", name: "Kappa"), // Κ
            (character: "\u{039b}", name: "Lambda"), // Λ
            (character: "\u{039c}", name: "Mu"), // Μ
            (character: "\u{039d}", name: "Nu"), // Ν
            (character: "\u{039e}", name: "Xi"), // Ξ
            (character: "\u{039f}", name: "Omicron"), // Ο
            (character: "\u{03a0}", name: "Pi"), // Π
            (character: "\u{03a1}", name: "Rho"), // Ρ
            (character: "\u{03a3}", name: "Sigma"), // Σ
            (character: "\u{03a4}", name: "Tau"), // Τ
            (character: "\u{03a5}", name: "Upsilon"), // Υ
            (character: "\u{03a6}", name: "Phi"), // Φ
            (character: "\u{03a7}", name: "Chi"), // Χ
            (character: "\u{03a8}", name: "Psi"), // Ψ
            (character: "\u{03a9}", name: "Omega"), // Ω
            (character: "\u{03b1}", name: "alpha"), // α
            (character: "\u{03b2}", name: "beta"), // β
            (character: "\u{03b3}", name: "gamma"), // γ
            (character: "\u{03b4}", name: "delta"), // δ
            (character: "\u{03b5}", name: "epsilon"), // ε
            (character: "\u{03b6}", name: "zeta"), // ζ
            (character: "\u{03b7}", name: "eta"), // η
            (character: "\u{03b8}", name: "theta"), // θ
            (character: "\u{03b9}", name: "iota"), // ι
            (character: "\u{03ba}", name: "kappa"), // κ
            (character: "\u{03bb}", name: "lambda"), // λ
            (character: "\u{03bc}", name: "mu"), // μ
            (character: "\u{03bd}", name: "nu"), // ν
            (character: "\u{03be}", name: "xi"), // ξ
            (character: "\u{03bf}", name: "omicron"), // ο
            (character: "\u{03c0}", name: "pi"), // π
            (character: "\u{03c1}", name: "rho"), // ρ
            (character: "\u{03c2}", name: "sigmaf"), // ς
            (character: "\u{03c3}", name: "sigma"), // σ
            (character: "\u{03c4}", name: "tau"), // τ
            (character: "\u{03c5}", name: "upsilon"), // υ
            (character: "\u{03c6}", name: "phi"), // φ
            (character: "\u{03c7}", name: "chi"), // χ
            (character: "\u{03c8}", name: "psi"), // ψ
            (character: "\u{03c9}", name: "omega"), // ω
            (character: "\u{03d1}", name: "thetasym"), // ϑ
            (character: "\u{03d2}", name: "upsih"), // ϒ
            (character: "\u{03d6}", name: "piv"), // ϖ
            (character: "\u{0152}", name: "OElig"), // Œ
            (character: "\u{0153}", name: "oelig"), // œ
            (character: "\u{0160}", name: "Scaron"), // Š
            (character: "\u{0161}", name: "scaron"), // š
            (character: "\u{0178}", name: "Yuml"), // Ÿ
            (character: "\u{0192}", name: "fnof"), // ƒ
            (character: "\u{02c6}", name: "circ"), // ˆ
            (character: "\u{02dc}", name: "tilde"), // ˜
            (character: "\u{2002}", name: "ensp"), //
            (character: "\u{2003}", name: "emsp"), //
            (character: "\u{2009}", name: "thinsp"), //
            (character: "\u{200c}", name: "zwnj"), // ‌
            (character: "\u{200d}", name: "zwj"), //
            (character: "\u{200e}", name: "lrm"), // ‎
            (character: "\u{200f}", name: "rlm"), // ‏
            (character: "\u{2013}", name: "ndash"), // –
            (character: "\u{2014}", name: "mdash"), // —
            (character: "\u{2018}", name: "lsquo"), // ‘
            (character: "\u{2019}", name: "rsquo"), // ’
            (character: "\u{201a}", name: "sbquo"), // ‚
            (character: "\u{201c}", name: "ldquo"), // “
            (character: "\u{201d}", name: "rdquo"), // ”
            (character: "\u{201e}", name: "bdquo"), // „
            (character: "\u{2020}", name: "dagger"), // †
            (character: "\u{2021}", name: "Dagger"), // ‡
            (character: "\u{2022}", name: "bull"), // •
            (character: "\u{2026}", name: "hellip"), // …
            (character: "\u{2030}", name: "permil"), // ‰
            (character: "\u{2032}", name: "prime"), // ′
            (character: "\u{2033}", name: "Prime"), // ″
            (character: "\u{2039}", name: "lsaquo"), // ‹
            (character: "\u{203a}", name: "rsaquo"), // ›
            (character: "\u{203e}", name: "oline"), // ‾
            (character: "\u{20ac}", name: "euro"), // €
            (character: "\u{2122}", name: "trade"), // ™
            (character: "\u{2190}", name: "larr"), // ←
            (character: "\u{2191}", name: "uarr"), // ↑
            (character: "\u{2192}", name: "rarr"), // →
            (character: "\u{2193}", name: "darr"), // ↓
            (character: "\u{2194}", name: "harr"), // ↔
            (character: "\u{21b5}", name: "crarr"), // ↵
            (character: "\u{2308}", name: "lceil"), // ⌈
            (character: "\u{2309}", name: "rceil"), // ⌉
            (character: "\u{230a}", name: "lfloor"), // ⌊
            (character: "\u{230b}", name: "rfloor"), // ⌋
            (character: "\u{25ca}", name: "loz"), // ◊
            (character: "\u{2660}", name: "spades"), // ♠
            (character: "\u{2663}", name: "clubs"), // ♣
            (character: "\u{2665}", name: "hearts"), // ♥
            (character: "\u{2666}", name: "diams"), // ♦
        ]
    }

    public static var htmlDocType : String {
        var string = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\" [\n"
        for entity in predefinedHTMLEntities {
            string += "<!ENTITY \(entity.name) \"\(entity.character)\">\n"
        }
        string += "]>\n"
        
        return string
    }

}
