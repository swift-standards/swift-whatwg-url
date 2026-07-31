//
//  WHATWG_Form_URL_Encoded.SpaceEncoding.swift
//  swift-whatwg-url
//

extension WHATWG_Form_URL_Encoded {
    /// How the ASCII space character round-trips through percent-encoded form data.
    ///
    /// WHATWG `application/x-www-form-urlencoded` (URL Standard Section 5) encodes
    /// space as `+` by default; plain percent-encoding instead represents space as
    /// `%20` and leaves a literal `+` as itself.
    public enum SpaceEncoding: Sendable, Hashable {
        /// Space encodes to `+`, and `+` decodes to space — the WHATWG form default.
        case plus

        /// Space encodes to `%20`; a literal `+` decodes to `+`, not space.
        case percentEscaped
    }
}
