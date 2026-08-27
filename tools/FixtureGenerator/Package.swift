// swift-tools-version: 6.2
import PackageDescription

/// Outil de développement, hors application : il produit les valeurs de
/// référence du moteur Swift que le portage TypeScript du site doit
/// reproduire. Paquet séparé pour ne rien ajouter aux dépendances de l'app.
let package = Package(
    name: "FixtureGenerator",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "../../ios/MonCoachKit")
    ],
    targets: [
        .executableTarget(
            name: "FixtureGenerator",
            dependencies: [.product(name: "MonCoachKit", package: "MonCoachKit")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
