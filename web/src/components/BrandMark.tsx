import { useId } from "react";

/**
 * La marque de Mon Coach.
 *
 * Fichier produit par `tools/brand/generate.py` — ne pas modifier à la main :
 * la prochaine exécution du script écraserait la retouche, et le SVG du site
 * ne correspondrait plus aux icônes de l'application.
 *
 * Le « M » monte, son second jambage plus haut que le premier. L'arc autour
 * part mince en bas à gauche, s'épaissit en tournant et s'arrête net en bas à
 * droite : c'est le bloc en cours, cinq semaines qui montent puis une coupure.
 */
export function BrandMark({
  size = 30,
  withPlate = true,
  className,
}: {
  size?: number;
  /** Le fond sombre arrondi. Faux pour poser la marque sur une surface claire. */
  withPlate?: boolean;
  className?: string;
}) {
  // Deux marques sur la même page partageraient leurs dégradés si les
  // identifiants étaient écrits en dur : la seconde effacerait la première.
  const id = useId().replace(/:/g, "");

  return (
    <svg
      className={className}
      width={size}
      height={size}
      viewBox="0 0 100 100"
      role="img"
      aria-hidden="true"
      focusable="false"
    >
      <defs>
        <linearGradient id={`${id}-stroke`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="rgb(124, 240, 168)" />
          <stop offset="1" stopColor="rgb(53, 196, 123)" />
        </linearGradient>
        <linearGradient id={`${id}-plate`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="rgb(21, 26, 35)" />
          <stop offset="1" stopColor="rgb(11, 13, 18)" />
        </linearGradient>
        <radialGradient id={`${id}-glow`} cx="0.5" cy="0.42" r="0.52">
          <stop offset="0" stopColor="rgb(124, 240, 168)" stopOpacity="0.13" />
          <stop offset="1" stopColor="rgb(124, 240, 168)" stopOpacity="0" />
        </radialGradient>
      </defs>
      {withPlate && (
        <>
          <rect width="100" height="100" rx="22.5" fill={`url(#${id}-plate)`} />
          <rect width="100" height="100" rx="22.5" fill={`url(#${id}-glow)`} />
        </>
      )}
      <path
        d="M23.53,83.88 A43.0,43.0 0 0 1 35.29,9.59"
        fill="none"
        stroke={`url(#${id}-stroke)`}
        strokeOpacity={0.22}
        strokeWidth={2.6}
        strokeLinecap="round"
      />
      <path
        d="M35.29,9.59 A43.0,43.0 0 0 1 90.41,35.29"
        fill="none"
        stroke={`url(#${id}-stroke)`}
        strokeOpacity={0.5}
        strokeWidth={3.6}
        strokeLinecap="round"
      />
      <path
        d="M90.41,35.29 A43.0,43.0 0 0 1 76.47,83.88"
        fill="none"
        stroke={`url(#${id}-stroke)`}
        strokeOpacity={1}
        strokeWidth={4.8}
        strokeLinecap="round"
      />
      <path
        d="M28,73 L28,43 L50,60 L72,32 L72,73"
        fill="none"
        stroke={`url(#${id}-stroke)`}
        strokeWidth={10}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
