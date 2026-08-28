import SwiftUI

import MonCoachKit

/// Everything the athlete told the coach, editable, plus what the coach
/// derived from it.
struct ProfileView: View {
    @Environment(CoachStore.self) private var store

    @State private var showingEditor = false
    @State private var showingResetConfirmation = false
    @State private var exportedURL: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let profile = store.profile, let program = store.program {
                        identityCard(profile)
                        derivedCard(program)
                        trainingCard(profile)
                        constraintsCard(profile)
                        dataCard
                        creditFooter
                    } else {
                        Card(title: "Profil vide") { EmptyView() }
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modifier") { showingEditor = true }
                        .disabled(store.profile == nil)
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let profile = store.profile {
                    ProfileEditorView(profile: profile) { updated in
                        store.updateProfile(updated)
                    }
                }
            }
            .confirmationDialog(
                "Tout effacer ?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Effacer définitivement", role: .destructive) {
                    store.resetEverything()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ton profil, ton programme et l'intégralité de ton historique d'entraînement seront supprimés de cet appareil. C'est irréversible.")
            }
        }
        .tint(Theme.accent)
    }

    private func identityCard(_ profile: UserProfile) -> some View {
        Card(title: profile.firstName, subtitle: "\(profile.age()) ans · \(profile.sex.label)") {
            HStack(spacing: 12) {
                StatTile(value: Format.height(profile.heightCm, unit: profile.unit), label: "taille")
                StatTile(value: Format.weight(profile.weightKg, unit: profile.unit), label: "poids")
                if let fat = profile.bodyFatPercent {
                    StatTile(value: "\(Format.number(fat, decimals: 1)) %", label: "masse grasse")
                }
            }
        }
    }

    private func derivedCard(_ program: CoachingProgram) -> some View {
        Card(title: "Ce que le coach en déduit", subtitle: program.metrics.leanMassIsEstimated
            ? "Masse maigre estimée (formule de Boer) — renseigne ton taux de gras pour affiner"
            : "Calculs basés sur ta masse maigre mesurée") {
            HStack(spacing: 12) {
                StatTile(value: "\(Int(program.metrics.bmr))", label: "métabolisme de base")
                StatTile(value: "\(Int(program.metrics.tdee))", label: "dépense quotidienne")
                StatTile(value: Format.weight(program.metrics.leanBodyMassKg, unit: program.profile.unit, decimals: 1), label: "masse maigre")
                if let ffmi = program.metrics.ffmi {
                    StatTile(value: Format.number(ffmi, decimals: 1), label: "FFMI")
                }
            }
            Text("IMC \(Format.number(program.metrics.bmi, decimals: 1)) — \(program.metrics.bmiCategory). L'IMC ignore la composition corporelle : à masse musculaire élevée, il se trompe systématiquement.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func trainingCard(_ profile: UserProfile) -> some View {
        Card(title: "Entraînement") {
            LabeledRow(label: "Objectif", value: profile.goal.label)
            LabeledRow(label: "Niveau", value: profile.experience.label)
            LabeledRow(label: "Fréquence", value: "\(profile.daysPerWeek) séances / semaine")
            LabeledRow(label: "Durée", value: Format.duration(minutes: profile.sessionMinutes))
            LabeledRow(label: "Incrément", value: profile.loadIncrement.label)
            LabeledRow(label: "Sommeil", value: "\(Format.number(profile.averageSleepHours, decimals: 1)) h")
            LabeledRow(label: "Activité", value: profile.activityLevel.label)
        }
    }

    private func constraintsCard(_ profile: UserProfile) -> some View {
        Card(title: "Matériel et contraintes") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Matériel disponible")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                FlowLayout(spacing: 6) {
                    ForEach(Array(profile.equipment).sorted { $0.rawValue < $1.rawValue }, id: \.self) {
                        Pill(text: $0.label)
                    }
                }
                if !profile.limitations.isEmpty {
                    Text("Zones épargnées")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 4)
                    FlowLayout(spacing: 6) {
                        ForEach(Array(profile.limitations).sorted { $0.rawValue < $1.rawValue }, id: \.self) {
                            Pill(text: $0.label, tint: Theme.warning)
                        }
                    }
                }
            }
        }
    }

    private var dataCard: some View {
        Card(title: "Tes données", subtitle: "Tout est stocké sur cet appareil. Rien n'est envoyé nulle part.") {
            if let exportedURL {
                ShareLink(item: exportedURL) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Partager l'export")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.primaryText)
                }
            } else {
                GhostButton(title: "Exporter mes données (JSON)", systemImage: "square.and.arrow.up") {
                    exportedURL = writeExport()
                }
            }
            Button(role: .destructive) {
                showingResetConfirmation = true
            } label: {
                Text("Tout effacer")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.danger.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.danger)
            }
            .buttonStyle(.plain)

            if let error = store.saveError {
                Text(error)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.danger)
            }
        }
    }

    private var creditFooter: some View {
        Text("Mon Coach — créé et fait par Maxime Nathan Lestage")
            .font(Theme.captionFont)
            .foregroundStyle(Theme.secondaryText)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }

    private func writeExport() -> URL? {
        guard let data = try? store.exportJSON() else { return nil }
        let url = URL.temporaryDirectory.appending(path: "mon-coach-export.json")
        try? data.write(to: url, options: [.atomic])
        return url
    }
}

/// Label on the left, value on the right — the whole profile screen is these.
struct LabeledRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}
