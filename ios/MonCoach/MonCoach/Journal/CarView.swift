import SwiftUI
import MonCoachKit

/// La section voiture : où vont les trajets, une fois qu'ils ne comptent
/// plus comme du sport.
///
/// Pourquoi elle existe
/// ....................
/// Le mode conduite avait trop bien réussi. Un trajet ne coûte aucune
/// calorie, ne pèse sur aucune charge, n'entre dans aucun total « tous
/// sports » et ne compte pas comme une séance — à force, il n'entrait plus
/// nulle part. L'application enregistrait fidèlement une donnée qu'elle ne
/// montrait plus jamais, ce qui est le défaut symétrique de celui qu'on
/// venait de corriger.
///
/// Refuser d'additionner un trajet à du sport est juste. Le faire
/// disparaître ne l'est pas. Les trajets ont donc leur propre compte, ici,
/// séparé et complet.
///
/// Ce qu'elle ne fait pas
/// ......................
/// Elle ne prescrit rien et ne juge rien. Une application d'entraînement
/// n'a aucune raison d'avoir un avis sur les kilomètres qu'on fait en
/// voiture, et un « objectif » là-dessus serait une intrusion. Elle compte,
/// elle montre, elle se tait.
struct CarView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var trips: [ActivityLog] { TravelStats.trips(in: store.history.activities) }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if trips.isEmpty {
                    emptyCard
                } else {
                    totalsCard
                    monthsCard
                    tripsCard
                }
            }
            .padding(16)
        }
        .screenBackground()
    }

    // MARK: - Rien encore

    /// L'écran qu'on voit en premier, et longtemps.
    ///
    /// Le volet est là dès le départ, donc cet écran est ce que découvre
    /// quiconque le touche par curiosité. Il ne peut pas se contenter de
    /// dire « rien à afficher » : c'est lui qui doit apprendre que
    /// l'application sait tracer un trajet, où le démarrer, et — le point
    /// qui compte le plus — que ça ne viendra rien polluer.
    ///
    /// Cette dernière phrase n'est pas décorative. La crainte légitime, dans
    /// une application d'entraînement, est qu'un trajet en voiture aille
    /// gonfler les kilomètres de la semaine. Le dire ici, avant de
    /// commencer, coûte deux lignes ; le découvrir après coup coûterait la
    /// confiance dans tous les autres chiffres.
    private var emptyCard: some View {
        Card(
            title: LocalizedText(
                fr: "Les trajets en voiture",
                en: "Car trips",
                es: "Los trayectos en coche"
            )[language],
            subtitle: LocalizedText(
                fr: "Démarre une activité « Conduite », dans la famille Déplacements, et le trajet se trace comme une sortie.",
                en: "Start a “Driving” activity, in the Getting around family, and the trip is traced like an outing.",
                es: "Inicia una actividad «Conducción», en la familia Desplazamientos, y el trayecto se traza como una salida."
            )[language]
        ) {
            VStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                Text(
                    LocalizedText(
                        fr: "Il sera compté ici, et nulle part ailleurs : aucune calorie, aucune charge d'entraînement, aucune séance de la semaine. Tes chiffres sportifs ne bougent pas d'un mètre.",
                        en: "It gets counted here, and nowhere else: no calories, no training load, no session of the week. Your sports figures do not move by a single metre.",
                        es: "Se cuenta aquí, y en ningún otro sitio: ni calorías, ni carga de entrenamiento, ni sesión de la semana. Tus cifras deportivas no se mueven ni un metro."
                    )[language]
                )
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Les totaux

    private var totalsCard: some View {
        let now = Date()
        let calendar = Calendar.current
        let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
        let year = TravelStats.summary(of: store.history.activities, since: yearStart)
        let month = TravelStats.summary(of: store.history.activities, since: monthStart)
        let all = TravelStats.summary(of: store.history.activities)

        return Card(
            title: LocalizedText(fr: "Au volant", en: "Behind the wheel", es: "Al volante")[language],
            subtitle: LocalizedText(
                fr: "Ces kilomètres ne sont dans aucune statistique sportive, et c'est voulu.",
                en: "These kilometres are in no sports statistic, and that is deliberate.",
                es: "Estos kilómetros no están en ninguna estadística deportiva, y es a propósito."
            )[language]
        ) {
            VStack(spacing: 10) {
                figure(LocalizedText(fr: "Ce mois-ci", en: "This month", es: "Este mes"), month)
                Divider()
                figure(LocalizedText(fr: "Cette année", en: "This year", es: "Este año"), year)
                Divider()
                figure(LocalizedText(fr: "Depuis le début", en: "All time", es: "Desde el inicio"), all)
            }
        }
    }

    private func figure(_ label: LocalizedText, _ summary: TravelStats.Summary) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label[language])
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Format.distance(meters: summary.meters, unit: unit, language: language))
                    .font(.system(.title3, design: .rounded).weight(.bold))
                Text(detail(summary))
                    .font(.caption2)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    /// Le nombre de trajets, le temps passé, et la moyenne — trois chiffres
    /// qui tiennent sur une ligne et répondent à « combien de temps ça m'a
    /// pris », qui est la seule question qu'on se pose sur un trajet.
    private func detail(_ summary: TravelStats.Summary) -> String {
        guard !summary.isEmpty else {
            return LocalizedText(fr: "aucun trajet", en: "no trips", es: "sin trayectos")[language]
        }
        let trips = summary.tripCount
        let count = LocalizedText(
            fr: "\(trips) trajet\(trips > 1 ? "s" : "")",
            en: "\(trips) trip\(trips > 1 ? "s" : "")",
            es: "\(trips) trayecto\(trips > 1 ? "s" : "")"
        )[language]
        let speed = Format.speed(
            metersPerSecond: summary.seconds > 0 ? summary.meters / summary.seconds : 0,
            unit: unit,
            language: language
        )
        return "\(count) · \(Format.stopwatch(seconds: summary.seconds)) · \(speed)"
    }

    // MARK: - Les mois

    private var monthsCard: some View {
        let months = TravelStats.byMonth(of: store.history.activities)
        return Card(
            title: LocalizedText(fr: "Par mois", en: "By month", es: "Por mes")[language],
            subtitle: nil
        ) {
            VStack(spacing: 8) {
                ForEach(months.prefix(12)) { month in
                    HStack {
                        Text(monthLabel(month.start))
                            .font(.subheadline)
                        Spacer()
                        Text(Format.distance(
                            meters: month.summary.meters, unit: unit, language: language
                        ))
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    }
                }
            }
        }
    }

    private func monthLabel(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).year().locale(language.locale)).capitalized
    }

    // MARK: - Les trajets

    private var tripsCard: some View {
        Card(
            title: LocalizedText(fr: "Les trajets", en: "The trips", es: "Los trayectos")[language],
            subtitle: nil
        ) {
            VStack(spacing: 10) {
                ForEach(trips.prefix(40)) { trip in
                    NavigationLink {
                        ActivityDetailView(activity: trip)
                    } label: {
                        row(trip)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func row(_ trip: ActivityLog) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "car.fill")
                .font(.system(size: 14))
                .foregroundStyle(Theme.secondaryText)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 1) {
                Text(dayLabel(trip.startedAt))
                    .font(.subheadline)
                Text(Format.stopwatch(seconds: trip.duration))
                    .font(.caption2)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Text(Format.distance(meters: trip.meters, unit: unit, language: language))
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(Theme.secondaryText)
        }
    }

    private func dayLabel(_ date: Date) -> String {
        date.formatted(
            .dateTime.weekday(.wide).day().month(.wide).locale(language.locale)
        ).capitalized
    }
}
