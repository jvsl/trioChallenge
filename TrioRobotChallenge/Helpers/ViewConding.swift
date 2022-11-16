protocol ViewCoding {
    func addSubviews()
    func addConstraints()
    func additionalConfig()
    func buildView()
}

extension ViewCoding {
    func buildView() {
        addSubviews()
        addConstraints()
        additionalConfig()
    }
}
