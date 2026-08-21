extension WHATWG_URL.URL {

    enum State {
        case schemeStart
        case scheme
        case noScheme
        case specialAuthoritySlashes
        case pathOrAuthority
        case authority
        case host
        case port
        case pathStart
        case path
        case relativePath
        case opaquePath
        case query
        case fragment
    }
}
