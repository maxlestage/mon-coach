import Foundation

/// The compiled-in movement library the coach selects from.
///
/// Kept in code rather than in a bundled file so that a session can be built
/// with no network, no database migration and no decoding step.
public enum ExerciseCatalog {

    public static let all: [Exercise] = squatPattern
        + hingePattern
        + horizontalPush
        + verticalPush
        + horizontalPull
        + verticalPull
        + armIsolation
        + shoulderIsolation
        + legIsolation
        + coreWork

    private static let byID: [String: Exercise] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    public static func exercise(id: String) -> Exercise? { byID[id] }

    /// Every movement the athlete can perform without aggravating a flagged area.
    public static func available(for profile: UserProfile) -> [Exercise] {
        all.filter {
            $0.isAvailable(with: profile.equipment)
                && !$0.conflicts(with: profile.limitations)
                && !profile.dislikedExerciseIDs.contains($0.id)
        }
    }

    public static func exercises(training muscle: MuscleGroup) -> [Exercise] {
        all.filter { $0.primaryMuscle == muscle }
    }

    // MARK: - Squat pattern

    static let squatPattern: [Exercise] = [
        Exercise(
            id: "back-squat",
            name: LocalizedText(fr: "Squat barre", en: "Back squat", es: "Sentadilla trasera"),
            cue: LocalizedText(
                fr: "Descends jusqu'à ce que le pli de hanche passe sous le genou, buste gainé.",
                en: "Descend until the hip crease passes below the knee, trunk braced.",
                es: "Baja hasta que el pliegue de la cadera pase por debajo de la rodilla, con el tronco firme."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .hamstrings, .core],
            pattern: .squat,
            equipment: [.barbell],
            isCompound: true,
            stressedAreas: [.knee, .lowerBack],
            stimulusRating: 5,
            viableRepRange: 3...12,
            loadFactor: 1.0,
            baseRestSeconds: 180
        ),
        Exercise(
            id: "front-squat",
            name: LocalizedText(fr: "Squat avant", en: "Front squat", es: "Sentadilla frontal"),
            cue: LocalizedText(
                fr: "Coudes hauts en permanence : dès qu'ils tombent, la barre suit.",
                en: "Elbows high throughout: the moment they drop, the bar follows.",
                es: "Codos altos todo el tiempo: en cuanto caen, la barra los sigue."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .core],
            pattern: .squat,
            equipment: [.barbell],
            isCompound: true,
            stressedAreas: [.knee, .wrist],
            stimulusRating: 4,
            viableRepRange: 3...10,
            loadFactor: 0.8,
            baseRestSeconds: 180
        ),
        Exercise(
            id: "goblet-squat",
            name: LocalizedText(fr: "Goblet squat", en: "Goblet squat", es: "Sentadilla goblet"),
            cue: LocalizedText(
                fr: "Haltère collée au sternum, descends entre les pieds.",
                en: "Dumbbell against the sternum, descend between your feet.",
                es: "Mancuerna pegada al esternón, baja entre los pies."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .core],
            pattern: .squat,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.35,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "hack-squat",
            name: LocalizedText(fr: "Hack squat machine", en: "Hack squat machine", es: "Hack squat en máquina"),
            cue: LocalizedText(
                fr: "Dos plaqué, pieds au milieu du plateau, amplitude complète.",
                en: "Back flat against the pad, feet mid-platform, full range.",
                es: "Espalda pegada al respaldo, pies en el centro de la plataforma, recorrido completo."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes],
            pattern: .squat,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 5,
            viableRepRange: 6...15,
            loadFactor: 1.2,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "leg-press",
            name: LocalizedText(fr: "Presse à cuisses", en: "Leg press", es: "Prensa de piernas"),
            cue: LocalizedText(
                fr: "Ne verrouille jamais les genoux en fin de poussée.",
                en: "Never lock the knees at the end of the push.",
                es: "No bloquees nunca las rodillas al final del empuje."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .hamstrings],
            pattern: .squat,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...20,
            loadFactor: 1.8,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "bulgarian-split-squat",
            name: LocalizedText(fr: "Fente bulgare", en: "Bulgarian split squat", es: "Zancada búlgara"),
            cue: LocalizedText(
                fr: "Le pied arrière n'est qu'un appui : tout le poids reste sur la jambe avant.",
                en: "The back foot is only a support: all the weight stays on the front leg.",
                es: "El pie trasero solo es un apoyo: todo el peso queda en la pierna delantera."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .hamstrings],
            pattern: .lunge,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 5,
            viableRepRange: 6...15,
            loadFactor: 0.25,
            baseRestSeconds: 120,
            isUnilateral: true
        ),
        Exercise(
            id: "bodyweight-squat",
            name: LocalizedText(fr: "Squat au poids du corps", en: "Bodyweight squat", es: "Sentadilla con peso corporal"),
            cue: LocalizedText(
                fr: "Tempo lent à la descente, trois secondes.",
                en: "Slow on the way down, three seconds.",
                es: "Bajada lenta, tres segundos."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes],
            pattern: .squat,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 2,
            viableRepRange: 12...30,
            loadFactor: 0.0,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "walking-lunge",
            name: LocalizedText(fr: "Fentes marchées", en: "Walking lunges", es: "Zancadas caminando"),
            cue: LocalizedText(
                fr: "Grand pas, genou arrière qui frôle le sol.",
                en: "Long stride, back knee brushing the floor.",
                es: "Paso largo, rodilla trasera rozando el suelo."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.quads, .hamstrings],
            pattern: .lunge,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 4,
            viableRepRange: 8...16,
            loadFactor: 0.25,
            baseRestSeconds: 120,
            isUnilateral: true
        )
    ]

    // MARK: - Hinge pattern

    static let hingePattern: [Exercise] = [
        Exercise(
            id: "conventional-deadlift",
            name: LocalizedText(fr: "Soulevé de terre", en: "Deadlift", es: "Peso muerto"),
            cue: LocalizedText(
                fr: "Barre collée aux tibias, dos neutre du premier au dernier centimètre.",
                en: "Bar against the shins, neutral back from the first centimetre to the last.",
                es: "Barra pegada a las espinillas, espalda neutra del primer al último centímetro."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes, .back, .traps, .core],
            pattern: .hinge,
            equipment: [.barbell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 5,
            viableRepRange: 3...8,
            loadFactor: 1.0,
            baseRestSeconds: 210
        ),
        Exercise(
            id: "romanian-deadlift",
            name: LocalizedText(fr: "Soulevé de terre roumain", en: "Romanian deadlift", es: "Peso muerto rumano"),
            cue: LocalizedText(
                fr: "Pousse les hanches loin en arrière, genoux quasi fixes.",
                en: "Push the hips far back, knees almost fixed.",
                es: "Lleva la cadera bien atrás, con las rodillas casi fijas."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes, .back],
            pattern: .hinge,
            equipment: [.barbell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 5,
            viableRepRange: 6...12,
            loadFactor: 0.7,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "dumbbell-rdl",
            name: LocalizedText(fr: "Soulevé roumain haltères", en: "Dumbbell Romanian deadlift", es: "Peso muerto rumano con mancuernas"),
            cue: LocalizedText(
                fr: "Haltères qui glissent le long des cuisses, poitrine ouverte.",
                en: "Dumbbells sliding down the thighs, chest open.",
                es: "Mancuernas deslizándose por los muslos, pecho abierto."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes],
            pattern: .hinge,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.30,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "hip-thrust",
            name: LocalizedText(fr: "Hip thrust", en: "Hip thrust", es: "Hip thrust"),
            cue: LocalizedText(
                fr: "Menton rentré, verrouille les fessiers une seconde en haut.",
                en: "Chin tucked, squeeze the glutes for a second at the top.",
                es: "Barbilla metida, aprieta los glúteos un segundo arriba."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings],
            pattern: .hinge,
            equipment: [.barbell, .bench],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 8...15,
            loadFactor: 0.9,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "glute-bridge",
            name: LocalizedText(fr: "Pont fessier au sol", en: "Floor glute bridge", es: "Puente de glúteo en suelo"),
            cue: LocalizedText(
                fr: "Talons proches des fessiers, pousse dans les talons.",
                en: "Heels close to your backside, drive through the heels.",
                es: "Talones cerca de los glúteos, empuja con los talones."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings],
            pattern: .hinge,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 2,
            viableRepRange: 12...25,
            loadFactor: 0.0,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "back-extension",
            name: LocalizedText(fr: "Extension lombaire", en: "Back extension", es: "Extensión lumbar"),
            cue: LocalizedText(
                fr: "Monte jusqu'à l'alignement, jamais au-delà.",
                en: "Rise to alignment, never past it.",
                es: "Sube hasta la alineación, nunca más allá."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes, .back],
            pattern: .hinge,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.2,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "kettlebell-swing",
            name: LocalizedText(fr: "Kettlebell swing", en: "Kettlebell swing", es: "Swing con pesa rusa"),
            cue: LocalizedText(
                fr: "C'est une charnière de hanche explosive, pas un squat.",
                en: "This is an explosive hip hinge, not a squat.",
                es: "Es una bisagra de cadera explosiva, no una sentadilla."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings, .core],
            pattern: .hinge,
            equipment: [.kettlebell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 12...25,
            loadFactor: 0.2,
            baseRestSeconds: 90
        )
    ]

    // MARK: - Horizontal push

    static let horizontalPush: [Exercise] = [
        Exercise(
            id: "bench-press",
            name: LocalizedText(fr: "Développé couché", en: "Bench press", es: "Press de banca"),
            cue: LocalizedText(
                fr: "Omoplates serrées et basses, la barre touche le bas des pectoraux.",
                en: "Shoulder blades pinned and down, the bar touches the lower chest.",
                es: "Escápulas juntas y bajas, la barra toca la parte baja del pecho."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.barbell, .bench],
            isCompound: true,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 5,
            viableRepRange: 3...12,
            loadFactor: 1.0,
            baseRestSeconds: 180
        ),
        Exercise(
            id: "incline-bench-press",
            name: LocalizedText(fr: "Développé incliné barre", en: "Incline barbell press", es: "Press inclinado con barra"),
            cue: LocalizedText(
                fr: "Banc à 30°, pas plus : au-delà, ce sont les épaules qui travaillent.",
                en: "Bench at 30°, no more: past that it is the shoulders doing the work.",
                es: "Banco a 30°, no más: por encima trabajan los hombros."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.shoulders, .triceps],
            pattern: .horizontalPush,
            equipment: [.barbell, .bench],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 5,
            viableRepRange: 5...12,
            loadFactor: 0.85,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "dumbbell-bench-press",
            name: LocalizedText(fr: "Développé couché haltères", en: "Dumbbell bench press", es: "Press de banca con mancuernas"),
            cue: LocalizedText(
                fr: "Descends jusqu'à sentir l'étirement, sans forcer sur l'épaule.",
                en: "Lower until you feel the stretch, without forcing the shoulder.",
                es: "Baja hasta notar el estiramiento, sin forzar el hombro."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 5,
            viableRepRange: 6...15,
            loadFactor: 0.40,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "incline-dumbbell-press",
            name: LocalizedText(fr: "Développé incliné haltères", en: "Incline dumbbell press", es: "Press inclinado con mancuernas"),
            cue: LocalizedText(
                fr: "Trajectoire légèrement convergente en haut.",
                en: "A slightly converging path at the top.",
                es: "Trayectoria ligeramente convergente arriba."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.shoulders, .triceps],
            pattern: .horizontalPush,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 5,
            viableRepRange: 6...15,
            loadFactor: 0.35,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "machine-chest-press",
            name: LocalizedText(fr: "Développé machine", en: "Machine chest press", es: "Press de pecho en máquina"),
            cue: LocalizedText(
                fr: "Poignées à hauteur de pectoraux, pas d'épaules qui décollent.",
                en: "Handles at chest height, shoulders staying down.",
                es: "Agarres a la altura del pecho, sin despegar los hombros."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps],
            pattern: .horizontalPush,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.9,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "push-up",
            name: LocalizedText(fr: "Pompes", en: "Push-ups", es: "Flexiones"),
            cue: LocalizedText(
                fr: "Corps gainé comme une planche, coudes à 45°.",
                en: "Body braced like a plank, elbows at 45°.",
                es: "Cuerpo firme como una tabla, codos a 45°."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .core, .shoulders],
            pattern: .horizontalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.wrist],
            stimulusRating: 3,
            viableRepRange: 8...30,
            loadFactor: 0.0,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "dip",
            name: LocalizedText(fr: "Dips", en: "Dips", es: "Fondos"),
            cue: LocalizedText(
                fr: "Buste penché en avant pour cibler les pectoraux.",
                en: "Lean the torso forward to target the chest.",
                es: "Inclina el torso hacia delante para incidir en el pecho."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.dipStation],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 5,
            viableRepRange: 5...15,
            loadFactor: 0.0,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "cable-fly",
            name: LocalizedText(fr: "Écarté à la poulie", en: "Cable fly", es: "Aperturas en polea"),
            cue: LocalizedText(
                fr: "Coudes fixes, tu ne fais que rapprocher les mains.",
                en: "Elbows fixed — all you do is bring the hands together.",
                es: "Codos fijos: solo acercas las manos."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.25,
            baseRestSeconds: 90
        )
    ]

    // MARK: - Vertical push

    static let verticalPush: [Exercise] = [
        Exercise(
            id: "overhead-press",
            name: LocalizedText(fr: "Développé militaire", en: "Overhead press", es: "Press militar"),
            cue: LocalizedText(
                fr: "Fessiers et abdos serrés, la tête passe sous la barre en haut.",
                en: "Glutes and abs tight, the head passes under the bar at the top.",
                es: "Glúteos y abdomen apretados, la cabeza pasa bajo la barra arriba."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps, .core],
            pattern: .verticalPush,
            equipment: [.barbell],
            isCompound: true,
            stressedAreas: [.shoulder, .lowerBack],
            stimulusRating: 5,
            viableRepRange: 4...10,
            loadFactor: 1.0,
            baseRestSeconds: 180
        ),
        Exercise(
            id: "seated-dumbbell-press",
            name: LocalizedText(fr: "Développé épaules haltères", en: "Seated dumbbell press", es: "Press de hombro con mancuernas"),
            cue: LocalizedText(
                fr: "Dossier bien droit, descends jusqu'aux oreilles.",
                en: "Back rest upright, lower to ear height.",
                es: "Respaldo recto, baja hasta la altura de las orejas."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.32,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "machine-shoulder-press",
            name: LocalizedText(fr: "Développé épaules machine", en: "Machine shoulder press", es: "Press de hombro en máquina"),
            cue: LocalizedText(
                fr: "Amplitude complète, sans à-coups en bas.",
                en: "Full range, no bouncing at the bottom.",
                es: "Recorrido completo, sin rebotes abajo."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.6,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "pike-push-up",
            name: LocalizedText(fr: "Pompes piquées", en: "Pike push-ups", es: "Flexiones en pica"),
            cue: LocalizedText(
                fr: "Hanches hautes, le sommet du crâne vise le sol.",
                en: "Hips high, the crown of the head aiming at the floor.",
                es: "Caderas altas, la coronilla apuntando al suelo."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 3,
            viableRepRange: 6...20,
            loadFactor: 0.0,
            baseRestSeconds: 90
        )
    ]

    // MARK: - Horizontal pull

    static let horizontalPull: [Exercise] = [
        Exercise(
            id: "barbell-row",
            name: LocalizedText(fr: "Rowing barre", en: "Barbell row", es: "Remo con barra"),
            cue: LocalizedText(
                fr: "Buste à 45°, tire vers le nombril, pas vers la poitrine.",
                en: "Torso at 45°, pull to the navel, not to the chest.",
                es: "Torso a 45°, tira hacia el ombligo, no hacia el pecho."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps, .rearDelts],
            pattern: .horizontalPull,
            equipment: [.barbell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 5,
            viableRepRange: 5...12,
            loadFactor: 1.0,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "chest-supported-row",
            name: LocalizedText(fr: "Rowing buste calé", en: "Chest-supported row", es: "Remo con apoyo en banco"),
            cue: LocalizedText(
                fr: "Poitrine collée au banc : plus aucune triche possible.",
                en: "Chest glued to the bench: cheating becomes impossible.",
                es: "Pecho pegado al banco: hacer trampa deja de ser posible."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .rearDelts, .biceps],
            pattern: .horizontalPull,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 8...15,
            loadFactor: 0.35,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "seated-cable-row",
            name: LocalizedText(fr: "Rowing à la poulie basse", en: "Seated cable row", es: "Remo en polea baja"),
            cue: LocalizedText(
                fr: "Serre les omoplates avant de plier les bras.",
                en: "Squeeze the shoulder blades before the arms bend.",
                es: "Junta las escápulas antes de doblar los brazos."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps],
            pattern: .horizontalPull,
            equipment: [.cable],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.8,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "one-arm-dumbbell-row",
            name: LocalizedText(fr: "Rowing haltère un bras", en: "One-arm dumbbell row", es: "Remo a una mano con mancuerna"),
            cue: LocalizedText(
                fr: "Tire avec le coude, le bras n'est qu'un crochet.",
                en: "Pull with the elbow; the arm is only a hook.",
                es: "Tira con el codo: el brazo solo es un gancho."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps],
            pattern: .horizontalPull,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.35,
            baseRestSeconds: 120,
            isUnilateral: true
        ),
        Exercise(
            id: "inverted-row",
            name: LocalizedText(fr: "Rowing australien", en: "Inverted row", es: "Remo invertido"),
            cue: LocalizedText(
                fr: "Corps rigide, la poitrine touche la barre.",
                en: "Body rigid, chest touching the bar.",
                es: "Cuerpo rígido, el pecho toca la barra."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps, .core],
            pattern: .horizontalPull,
            equipment: [.pullUpBar],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "band-row",
            name: LocalizedText(fr: "Tirage élastique", en: "Band row", es: "Remo con banda"),
            cue: LocalizedText(
                fr: "Recule d'un pas pour garder de la tension en position basse.",
                en: "Step back so there is still tension in the bottom position.",
                es: "Da un paso atrás para mantener tensión en la posición baja."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps],
            pattern: .horizontalPull,
            equipment: [.band],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 2,
            viableRepRange: 12...25,
            loadFactor: 0.0,
            baseRestSeconds: 75
        )
    ]

    // MARK: - Vertical pull

    static let verticalPull: [Exercise] = [
        Exercise(
            id: "pull-up",
            name: LocalizedText(fr: "Traction pronation", en: "Pull-up", es: "Dominada prona"),
            cue: LocalizedText(
                fr: "Pars épaules basses, monte jusqu'au menton au-dessus de la barre.",
                en: "Start with the shoulders down, rise until the chin clears the bar.",
                es: "Empieza con los hombros bajos y sube hasta pasar la barbilla sobre la barra."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps],
            pattern: .verticalPull,
            equipment: [.pullUpBar],
            isCompound: true,
            stressedAreas: [.shoulder, .elbow],
            stimulusRating: 5,
            viableRepRange: 4...15,
            loadFactor: 0.0,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "chin-up",
            name: LocalizedText(fr: "Traction supination", en: "Chin-up", es: "Dominada supina"),
            cue: LocalizedText(
                fr: "Prise supination : plus de biceps, souvent plus de répétitions.",
                en: "Supinated grip: more biceps, and usually more reps.",
                es: "Agarre supino: más bíceps y, normalmente, más repeticiones."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.biceps, .back],
            pattern: .verticalPull,
            equipment: [.pullUpBar],
            isCompound: true,
            stressedAreas: [.elbow],
            stimulusRating: 5,
            viableRepRange: 4...15,
            loadFactor: 0.0,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "lat-pulldown",
            name: LocalizedText(fr: "Tirage vertical poulie", en: "Lat pulldown", es: "Jalón al pecho"),
            cue: LocalizedText(
                fr: "Amène la barre au sternum, coudes vers le bas.",
                en: "Bring the bar to the sternum, elbows driving down.",
                es: "Lleva la barra al esternón, con los codos hacia abajo."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps],
            pattern: .verticalPull,
            equipment: [.cable],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.8,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "straight-arm-pulldown",
            name: LocalizedText(fr: "Pull-over à la poulie", en: "Straight-arm pulldown", es: "Pullover en polea"),
            cue: LocalizedText(
                fr: "Bras tendus, seuls les dorsaux travaillent.",
                en: "Arms straight — only the lats are working.",
                es: "Brazos extendidos: solo trabajan los dorsales."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.3,
            baseRestSeconds: 90
        )
    ]

    // MARK: - Arms

    static let armIsolation: [Exercise] = [
        Exercise(
            id: "barbell-curl",
            name: LocalizedText(fr: "Curl barre", en: "Barbell curl", es: "Curl con barra"),
            cue: LocalizedText(
                fr: "Coudes collés au buste, pas d'élan de hanches.",
                en: "Elbows pinned to the torso, no hip swing.",
                es: "Codos pegados al torso, sin impulso de cadera."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.barbell],
            isCompound: false,
            stressedAreas: [.wrist, .elbow],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.35,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "incline-dumbbell-curl",
            name: LocalizedText(fr: "Curl incliné haltères", en: "Incline dumbbell curl", es: "Curl inclinado con mancuernas"),
            cue: LocalizedText(
                fr: "Bras derrière le corps : c'est l'étirement qui fait le travail.",
                en: "Arms behind the body: the stretch is what does the work.",
                es: "Brazos por detrás del cuerpo: el estiramiento hace el trabajo."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.dumbbell, .bench],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 5,
            viableRepRange: 8...15,
            loadFactor: 0.14,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "hammer-curl",
            name: LocalizedText(fr: "Curl marteau", en: "Hammer curl", es: "Curl martillo"),
            cue: LocalizedText(
                fr: "Prise neutre, monte sans balancer.",
                en: "Neutral grip, lift without swinging.",
                es: "Agarre neutro, sube sin balanceo."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.16,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "cable-curl",
            name: LocalizedText(fr: "Curl à la poulie", en: "Cable curl", es: "Curl en polea"),
            cue: LocalizedText(
                fr: "Tension constante du début à la fin.",
                en: "Constant tension from start to finish.",
                es: "Tensión constante de principio a fin."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.3,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "overhead-cable-extension",
            name: LocalizedText(fr: "Extension triceps poulie haute", en: "Overhead cable extension", es: "Extensión de tríceps en polea alta"),
            cue: LocalizedText(
                fr: "Bras au-dessus de la tête pour étirer la longue portion.",
                en: "Arms overhead to stretch the long head.",
                es: "Brazos por encima de la cabeza para estirar la porción larga."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 5,
            viableRepRange: 10...20,
            loadFactor: 0.3,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "skull-crusher",
            name: LocalizedText(fr: "Barre au front", en: "Skull crusher", es: "Press francés"),
            cue: LocalizedText(
                fr: "Coudes fixes, la barre descend derrière la tête.",
                en: "Elbows fixed, the bar travels behind the head.",
                es: "Codos fijos, la barra baja por detrás de la cabeza."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.barbell, .bench],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.3,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "triceps-pushdown",
            name: LocalizedText(fr: "Extension triceps à la poulie", en: "Triceps pushdown", es: "Extensión de tríceps en polea"),
            cue: LocalizedText(
                fr: "Coudes verrouillés le long du corps.",
                en: "Elbows locked against your sides.",
                es: "Codos fijos pegados al cuerpo."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.35,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "close-grip-push-up",
            name: LocalizedText(fr: "Pompes prise serrée", en: "Close-grip push-ups", es: "Flexiones con agarre cerrado"),
            cue: LocalizedText(
                fr: "Mains sous les épaules, coudes le long du corps.",
                en: "Hands under the shoulders, elbows tight to the body.",
                es: "Manos bajo los hombros, codos pegados al cuerpo."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [.chest],
            pattern: .horizontalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.wrist, .elbow],
            stimulusRating: 3,
            viableRepRange: 8...25,
            loadFactor: 0.0,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "wrist-curl",
            name: LocalizedText(fr: "Curl poignets", en: "Wrist curl", es: "Curl de muñeca"),
            cue: LocalizedText(
                fr: "Amplitude complète, charge légère.",
                en: "Full range, light load.",
                es: "Recorrido completo, carga ligera."
            ),
            primaryMuscle: .forearms,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [.wrist],
            stimulusRating: 2,
            viableRepRange: 12...25,
            loadFactor: 0.1,
            baseRestSeconds: 60
        )
    ]

    // MARK: - Shoulders

    static let shoulderIsolation: [Exercise] = [
        Exercise(
            id: "lateral-raise",
            name: LocalizedText(fr: "Élévations latérales", en: "Lateral raises", es: "Elevaciones laterales"),
            cue: LocalizedText(
                fr: "Monte à hauteur d'épaule, pas plus haut, sans hausser les trapèzes.",
                en: "Raise to shoulder height, no higher, without shrugging.",
                es: "Sube a la altura del hombro, no más, sin encoger el trapecio."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 10...20,
            loadFactor: 0.08,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "cable-lateral-raise",
            name: LocalizedText(fr: "Élévation latérale poulie", en: "Cable lateral raise", es: "Elevación lateral en polea"),
            cue: LocalizedText(
                fr: "Poulie basse derrière toi : tension même en bas.",
                en: "Low pulley behind you: tension even at the bottom.",
                es: "Polea baja detrás de ti: tensión incluso abajo."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 12...20,
            loadFactor: 0.12,
            baseRestSeconds: 75,
            isUnilateral: true
        ),
        Exercise(
            id: "face-pull",
            name: LocalizedText(fr: "Face pull", en: "Face pull", es: "Face pull"),
            cue: LocalizedText(
                fr: "Tire vers le front, coudes hauts, rotation externe en fin de mouvement.",
                en: "Pull to the forehead, elbows high, external rotation at the end.",
                es: "Tira hacia la frente, codos altos, rotación externa al final."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.traps, .back],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 12...20,
            loadFactor: 0.25,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "reverse-fly",
            name: LocalizedText(fr: "Oiseau haltères", en: "Reverse fly", es: "Pájaro con mancuernas"),
            cue: LocalizedText(
                fr: "Buste penché, coudes légèrement fléchis et fixes.",
                en: "Torso bent over, elbows slightly bent and fixed.",
                es: "Torso inclinado, codos algo flexionados y fijos."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.traps],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 12...20,
            loadFactor: 0.08,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "band-pull-apart",
            name: LocalizedText(fr: "Écarté élastique", en: "Band pull-apart", es: "Aperturas con banda"),
            cue: LocalizedText(
                fr: "Bras tendus, écarte jusqu'à toucher la poitrine.",
                en: "Arms straight, pull apart until the band touches your chest.",
                es: "Brazos extendidos, abre hasta que la banda toque el pecho."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.traps],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 15...30,
            loadFactor: 0.0,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "shrug",
            name: LocalizedText(fr: "Shrugs", en: "Shrugs", es: "Encogimientos"),
            cue: LocalizedText(
                fr: "Monte les épaules vers les oreilles, marque une pause en haut.",
                en: "Lift the shoulders towards the ears, pause at the top.",
                es: "Sube los hombros hacia las orejas y haz una pausa arriba."
            ),
            primaryMuscle: .traps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [.neck],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.4,
            baseRestSeconds: 75
        )
    ]

    // MARK: - Legs, isolation

    static let legIsolation: [Exercise] = [
        Exercise(
            id: "leg-curl",
            name: LocalizedText(fr: "Leg curl", en: "Leg curl", es: "Curl femoral"),
            cue: LocalizedText(
                fr: "Contrôle la phase de retour sur trois secondes.",
                en: "Control the return over three seconds.",
                es: "Controla la vuelta durante tres segundos."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 8...20,
            loadFactor: 0.4,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "leg-extension",
            name: LocalizedText(fr: "Leg extension", en: "Leg extension", es: "Extensión de cuádriceps"),
            cue: LocalizedText(
                fr: "Verrouille une seconde en haut, sans à-coup.",
                en: "Lock for one second at the top, smoothly.",
                es: "Bloquea un segundo arriba, sin tirones."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.5,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "nordic-curl",
            name: LocalizedText(fr: "Nordic curl", en: "Nordic curl", es: "Curl nórdico"),
            cue: LocalizedText(
                fr: "Descends aussi lentement que possible, rattrape aux mains.",
                en: "Lower as slowly as you can and catch yourself with your hands.",
                es: "Baja lo más lento posible y amortigua con las manos."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 5,
            viableRepRange: 4...10,
            loadFactor: 0.0,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "hip-abduction",
            name: LocalizedText(fr: "Abduction hanches", en: "Hip abduction", es: "Abducción de cadera"),
            cue: LocalizedText(
                fr: "Buste légèrement penché en avant pour cibler le moyen fessier.",
                en: "Lean the torso slightly forward to target the gluteus medius.",
                es: "Inclina un poco el torso hacia delante para incidir en el glúteo medio."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...25,
            loadFactor: 0.5,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "standing-calf-raise",
            name: LocalizedText(fr: "Mollets debout", en: "Standing calf raise", es: "Elevación de gemelos de pie"),
            cue: LocalizedText(
                fr: "Amplitude maximale, deux secondes d'étirement en bas.",
                en: "Maximum range, two seconds of stretch at the bottom.",
                es: "Recorrido máximo, dos segundos de estiramiento abajo."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.8,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "bodyweight-calf-raise",
            name: LocalizedText(fr: "Mollets au poids du corps", en: "Bodyweight calf raise", es: "Elevación de gemelos sin peso"),
            cue: LocalizedText(
                fr: "Sur une marche, une jambe à la fois si c'est trop facile.",
                en: "On a step, one leg at a time if it is too easy.",
                es: "En un escalón, a una pierna si te resulta demasiado fácil."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 2,
            viableRepRange: 15...30,
            loadFactor: 0.0,
            baseRestSeconds: 60
        )
    ]

    // MARK: - Core

    static let coreWork: [Exercise] = [
        Exercise(
            id: "hanging-leg-raise",
            name: LocalizedText(fr: "Relevés de jambes suspendu", en: "Hanging leg raise", es: "Elevación de piernas colgado"),
            cue: LocalizedText(
                fr: "Enroule le bassin, ne te contente pas de lever les jambes.",
                en: "Curl the pelvis; do not just lift the legs.",
                es: "Enrolla la pelvis, no te limites a levantar las piernas."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [.forearms],
            pattern: .coreBrace,
            equipment: [.pullUpBar],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 5,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "cable-crunch",
            name: LocalizedText(fr: "Crunch à la poulie", en: "Cable crunch", es: "Crunch en polea"),
            cue: LocalizedText(
                fr: "Enroule la colonne vertèbre après vertèbre.",
                en: "Roll the spine down one vertebra at a time.",
                es: "Enrolla la columna vértebra a vértebra."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [],
            pattern: .coreBrace,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.4,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "plank",
            name: LocalizedText(fr: "Gainage planche", en: "Plank", es: "Plancha"),
            cue: LocalizedText(
                fr: "Bassin en rétroversion, fessiers serrés.",
                en: "Pelvis tucked, glutes squeezed.",
                es: "Pelvis en retroversión, glúteos apretados."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [],
            pattern: .coreBrace,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 20...60,
            loadFactor: 0.0,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "dead-bug",
            name: LocalizedText(fr: "Dead bug", en: "Dead bug", es: "Dead bug"),
            cue: LocalizedText(
                fr: "Le bas du dos reste collé au sol du début à la fin.",
                en: "The low back stays flat on the floor from start to finish.",
                es: "La zona lumbar permanece pegada al suelo de principio a fin."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [],
            pattern: .coreBrace,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.0,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "farmer-carry",
            name: LocalizedText(fr: "Marche du fermier", en: "Farmer's carry", es: "Paseo del granjero"),
            cue: LocalizedText(
                fr: "Épaules basses, pas courts, respiration régulière.",
                en: "Shoulders down, short steps, steady breathing.",
                es: "Hombros bajos, pasos cortos, respiración constante."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [.traps, .forearms],
            pattern: .carry,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 20...60,
            loadFactor: 0.5,
            baseRestSeconds: 90
        )
    ]
}
