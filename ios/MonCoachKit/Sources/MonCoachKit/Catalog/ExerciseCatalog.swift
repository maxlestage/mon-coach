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
            name: "Squat barre",
            cue: "Descends jusqu'à ce que le pli de hanche passe sous le genou, buste gainé.",
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
            name: "Squat avant",
            cue: "Coudes hauts en permanence : dès qu'ils tombent, la barre suit.",
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
            name: "Goblet squat",
            cue: "Haltère collée au sternum, descends entre les pieds.",
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
            name: "Hack squat machine",
            cue: "Dos plaqué, pieds au milieu du plateau, amplitude complète.",
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
            name: "Presse à cuisses",
            cue: "Ne verrouille jamais les genoux en fin de poussée.",
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
            name: "Fente bulgare",
            cue: "Le pied arrière n'est qu'un appui : tout le poids reste sur la jambe avant.",
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
            name: "Squat au poids du corps",
            cue: "Tempo lent à la descente, trois secondes.",
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
            name: "Fentes marchées",
            cue: "Grand pas, genou arrière qui frôle le sol.",
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
            name: "Soulevé de terre",
            cue: "Barre collée aux tibias, dos neutre du premier au dernier centimètre.",
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
            name: "Soulevé de terre roumain",
            cue: "Pousse les hanches loin en arrière, genoux quasi fixes.",
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
            name: "Soulevé roumain haltères",
            cue: "Haltères qui glissent le long des cuisses, poitrine ouverte.",
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
            name: "Hip thrust",
            cue: "Menton rentré, verrouille les fessiers une seconde en haut.",
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
            name: "Pont fessier au sol",
            cue: "Talons proches des fessiers, pousse dans les talons.",
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
            name: "Extension lombaire",
            cue: "Monte jusqu'à l'alignement, jamais au-delà.",
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
            name: "Kettlebell swing",
            cue: "C'est une charnière de hanche explosive, pas un squat.",
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
            name: "Développé couché",
            cue: "Omoplates serrées et basses, la barre touche le bas des pectoraux.",
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
            name: "Développé incliné barre",
            cue: "Banc à 30°, pas plus : au-delà, ce sont les épaules qui travaillent.",
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
            name: "Développé couché haltères",
            cue: "Descends jusqu'à sentir l'étirement, sans forcer sur l'épaule.",
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
            name: "Développé incliné haltères",
            cue: "Trajectoire légèrement convergente en haut.",
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
            name: "Développé machine",
            cue: "Poignées à hauteur de pectoraux, pas d'épaules qui décollent.",
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
            name: "Pompes",
            cue: "Corps gainé comme une planche, coudes à 45°.",
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
            name: "Dips",
            cue: "Buste penché en avant pour cibler les pectoraux.",
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
            name: "Écarté à la poulie",
            cue: "Coudes fixes, tu ne fais que rapprocher les mains.",
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
            name: "Développé militaire",
            cue: "Fessiers et abdos serrés, la tête passe sous la barre en haut.",
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
            name: "Développé épaules haltères",
            cue: "Dossier bien droit, descends jusqu'aux oreilles.",
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
            name: "Développé épaules machine",
            cue: "Amplitude complète, sans à-coups en bas.",
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
            name: "Pompes piquées",
            cue: "Hanches hautes, le sommet du crâne vise le sol.",
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
            name: "Rowing barre",
            cue: "Buste à 45°, tire vers le nombril, pas vers la poitrine.",
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
            name: "Rowing buste calé",
            cue: "Poitrine collée au banc : plus aucune triche possible.",
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
            name: "Rowing à la poulie basse",
            cue: "Serre les omoplates avant de plier les bras.",
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
            name: "Rowing haltère un bras",
            cue: "Tire avec le coude, le bras n'est qu'un crochet.",
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
            name: "Rowing australien",
            cue: "Corps rigide, la poitrine touche la barre.",
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
            name: "Tirage élastique",
            cue: "Recule d'un pas pour garder de la tension en position basse.",
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
            name: "Traction pronation",
            cue: "Pars épaules basses, monte jusqu'au menton au-dessus de la barre.",
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
            name: "Traction supination",
            cue: "Prise supination : plus de biceps, souvent plus de répétitions.",
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
            name: "Tirage vertical poulie",
            cue: "Amène la barre au sternum, coudes vers le bas.",
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
            name: "Pull-over à la poulie",
            cue: "Bras tendus, seuls les dorsaux travaillent.",
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
            name: "Curl barre",
            cue: "Coudes collés au buste, pas d'élan de hanches.",
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
            name: "Curl incliné haltères",
            cue: "Bras derrière le corps : c'est l'étirement qui fait le travail.",
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
            name: "Curl marteau",
            cue: "Prise neutre, monte sans balancer.",
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
            name: "Curl à la poulie",
            cue: "Tension constante du début à la fin.",
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
            name: "Extension triceps poulie haute",
            cue: "Bras au-dessus de la tête pour étirer la longue portion.",
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
            name: "Barre au front",
            cue: "Coudes fixes, la barre descend derrière la tête.",
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
            name: "Extension triceps à la poulie",
            cue: "Coudes verrouillés le long du corps.",
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
            name: "Pompes prise serrée",
            cue: "Mains sous les épaules, coudes le long du corps.",
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
            name: "Curl poignets",
            cue: "Amplitude complète, charge légère.",
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
            name: "Élévations latérales",
            cue: "Monte à hauteur d'épaule, pas plus haut, sans hausser les trapèzes.",
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
            name: "Élévation latérale poulie",
            cue: "Poulie basse derrière toi : tension même en bas.",
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
            name: "Face pull",
            cue: "Tire vers le front, coudes hauts, rotation externe en fin de mouvement.",
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
            name: "Oiseau haltères",
            cue: "Buste penché, coudes légèrement fléchis et fixes.",
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
            name: "Écarté élastique",
            cue: "Bras tendus, écarte jusqu'à toucher la poitrine.",
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
            name: "Shrugs",
            cue: "Monte les épaules vers les oreilles, marque une pause en haut.",
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
            name: "Leg curl",
            cue: "Contrôle la phase de retour sur trois secondes.",
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
            name: "Leg extension",
            cue: "Verrouille une seconde en haut, sans à-coup.",
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
            name: "Nordic curl",
            cue: "Descends aussi lentement que possible, rattrape aux mains.",
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
            name: "Abduction hanches",
            cue: "Buste légèrement penché en avant pour cibler le moyen fessier.",
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
            name: "Mollets debout",
            cue: "Amplitude maximale, deux secondes d'étirement en bas.",
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
            name: "Mollets au poids du corps",
            cue: "Sur une marche, une jambe à la fois si c'est trop facile.",
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
            name: "Relevés de jambes suspendu",
            cue: "Enroule le bassin, ne te contente pas de lever les jambes.",
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
            name: "Crunch à la poulie",
            cue: "Enroule la colonne vertèbre après vertèbre.",
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
            name: "Gainage planche",
            cue: "Bassin en rétroversion, fessiers serrés.",
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
            name: "Dead bug",
            cue: "Le bas du dos reste collé au sol du début à la fin.",
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
            name: "Marche du fermier",
            cue: "Épaules basses, pas courts, respiration régulière.",
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
