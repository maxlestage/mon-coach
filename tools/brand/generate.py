# -*- coding: utf-8 -*-
"""Fabrique la marque de Mon Coach, une seule fois, pour tous les supports.

La marque est un « M » ascendant : les deux jambages montent, le second plus
haut que le premier, si bien que la lettre se lit aussi comme une courbe de
progression. Autour d'elle, l'arc n'est pas un cercle décoratif : il part
mince et sourd en bas à gauche, s'épaissit et s'éclaire en tournant, et
s'arrête net en bas à droite. C'est le bloc en cours — cinq semaines qui
montent, une coupure, puis on recommence un cran plus haut.

Tout est dérivé d'une seule géométrie, décrite ici et nulle part ailleurs :
le site la dessine en SVG à partir des mêmes coordonnées, et ce script en
tire les PNG dont la PWA et iOS ont besoin. Deux dessins entretenus
séparément finissent toujours par diverger.

    python3 tools/brand/generate.py
"""

from __future__ import annotations

import io
import math
import os
import re
from PIL import Image, ImageDraw

# --------------------------------------------------------------- géométrie

# Repère de 100 × 100, celui du viewBox du SVG.
M_POINTS = [(28, 73), (28, 43), (50, 60), (72, 32), (72, 73)]
M_STROKE = 10.0

# L'arc : centre, rayon, puis les segments qui le composent, du plus sourd au
# plus franc. Angles en degrés, 0° = est, sens horaire (l'axe des y descend).
# Le trou du bas laisse passer les jambages : la lettre et l'arc ne se
# touchent jamais, à aucune taille.
ARC_CENTER = (50, 50)
ARC_RADIUS = 43.0
# (début, fin, épaisseur, opacité)
ARC_SEGMENTS = [
    (128, 250, 2.6, 0.22),
    (250, 340, 3.6, 0.50),
    (340, 412, 4.8, 1.00),
]

# La lueur derrière la lettre : ce qui détache le dessin du fond au lieu de le
# poser dessus. Centre, rayon et opacité au centre.
GLOW_CENTER = (50, 42)
GLOW_RADIUS = 52.0
GLOW_ALPHA = 0.13

# ----------------------------------------------------------------- couleurs

BG_TOP = (21, 26, 35)
BG_BOTTOM = (11, 13, 18)
ACCENT_TOP = (124, 240, 168)
ACCENT_BOTTOM = (53, 196, 123)
HAIRLINE = (255, 255, 255, 26)

SUPERSAMPLE = 4


def vertical_gradient(size: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    """Un dégradé vertical plein cadre."""
    gradient = Image.new("RGB", (1, size))
    pixels = gradient.load()
    for y in range(size):
        ratio = y / max(1, size - 1)
        pixels[0, y] = tuple(
            round(top[channel] + (bottom[channel] - top[channel]) * ratio) for channel in range(3)
        )
    return gradient.resize((size, size), Image.NEAREST)


def radial_glow(size: int, scale: float, offset: float) -> Image.Image:
    """La lueur derrière la lettre, en niveaux de gris.

    Calculée petite puis agrandie : un dégradé radial pixel par pixel sur
    4096 × 4096 coûterait des minutes pour un résultat identique.
    """
    resolution = 192
    glow = Image.new("L", (resolution, resolution), 0)
    pixels = glow.load()
    # Centre et rayon exprimés dans le repère de l'image basse résolution.
    center_x = (offset + GLOW_CENTER[0] * scale) * resolution / size
    center_y = (offset + GLOW_CENTER[1] * scale) * resolution / size
    radius = GLOW_RADIUS * scale * resolution / size
    peak = round(255 * GLOW_ALPHA)
    for y in range(resolution):
        for x in range(resolution):
            distance = math.hypot(x + 0.5 - center_x, y + 0.5 - center_y)
            if distance >= radius:
                continue
            # Décroissance quadratique : nette au centre, éteinte au bord,
            # sans le liseré qu'un dégradé linéaire laisse voir.
            falloff = 1 - distance / radius
            pixels[x, y] = round(peak * falloff * falloff)
    return glow.resize((size, size), Image.BICUBIC)


def arc_geometry(index: int) -> tuple[float, float, float, float]:
    """Un segment d'arc : début, fin, épaisseur, opacité."""
    return ARC_SEGMENTS[index]


def stroke_mask(size: int, scale: float, offset: float, *, with_arc: bool) -> Image.Image:
    """Le tracé de la marque, en niveaux de gris.

    Le tracé est dessiné dans un masque puis rempli d'un dégradé : Pillow ne
    sait pas peindre un trait dégradé, mais il sait très bien composer deux
    images à travers un masque.
    """
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)

    def place(point: tuple[float, float]) -> tuple[float, float]:
        return (offset + point[0] * scale, offset + point[1] * scale)

    if with_arc:
        center = place(ARC_CENTER)

        def on_arc(degrees: float) -> tuple[float, float]:
            angle = math.radians(degrees)
            return (
                center[0] + ARC_RADIUS * scale * math.cos(angle),
                center[1] + ARC_RADIUS * scale * math.sin(angle),
            )

        for position, (begin, finish, thickness, opacity) in enumerate(ARC_SEGMENTS):
            width = max(1, round(thickness * scale))
            # Pillow épaissit un arc vers l'intérieur de la boîte : on élargit
            # la boîte d'une demi-épaisseur pour que la ligne médiane reste
            # sur le rayon, quelle que soit l'épaisseur du segment.
            outer = (ARC_RADIUS * scale) + width / 2
            box = [
                center[0] - outer,
                center[1] - outer,
                center[0] + outer,
                center[1] + outer,
            ]
            draw.arc(box, begin, finish, fill=round(255 * opacity), width=width)
            # Seules les deux extrémités libres sont arrondies : entre deux
            # segments, la coupure franche est précisément ce qui donne
            # l'impression d'un trait qui s'épaissit.
            for degrees in (
                [begin] if position == 0 else []
            ) + ([finish] if position == len(ARC_SEGMENTS) - 1 else []):
                cap = on_arc(degrees)
                draw.ellipse(
                    [
                        cap[0] - width / 2,
                        cap[1] - width / 2,
                        cap[0] + width / 2,
                        cap[1] + width / 2,
                    ],
                    fill=round(255 * opacity),
                )

    width = round(M_STROKE * scale)
    points = [place(point) for point in M_POINTS]
    draw.line(points, fill=255, width=width, joint="curve")
    # Pillow ne fait pas de terminaisons rondes : on les pose à la main, aux
    # extrémités comme aux sommets, sinon la lettre a des coins coupés.
    for point in points:
        draw.ellipse(
            [point[0] - width / 2, point[1] - width / 2, point[0] + width / 2, point[1] + width / 2],
            fill=255,
        )
    return mask


def render(target: int, *, content_ratio: float, rounded: bool, with_arc: bool = True) -> Image.Image:
    """Dessine la marque à la taille demandée.

    `content_ratio` est la part du cadre occupée par le dessin : les icônes
    masquables d'Android sont rognées jusqu'à un cercle inscrit, donc leur
    contenu doit tenir bien à l'intérieur.
    """
    size = target * SUPERSAMPLE

    background = vertical_gradient(size, BG_TOP, BG_BOTTOM).convert("RGBA")
    if rounded:
        corner = Image.new("L", (size, size), 0)
        ImageDraw.Draw(corner).rounded_rectangle(
            [0, 0, size - 1, size - 1], radius=round(size * 0.225), fill=255
        )
        background.putalpha(corner)

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.alpha_composite(background)

    scale = size * content_ratio / 100
    offset = (size - 100 * scale) / 2

    # La lueur passe avant le dessin : elle éclaire le fond, elle ne voile pas
    # la lettre. Elle est rognée par le même masque que le fond, sinon elle
    # déborderait des coins arrondis.
    glow = Image.new("RGBA", (size, size), ACCENT_TOP + (0,))
    glow_mask = radial_glow(size, scale, offset)
    if rounded:
        glow_mask = Image.composite(glow_mask, Image.new("L", (size, size), 0), background.getchannel("A"))
    glow.putalpha(glow_mask)
    canvas.alpha_composite(glow)

    if rounded:
        # Un filet clair sur le bord : c'est ce qui détache l'icône d'un fond
        # sombre, sur un écran verrouillé comme dans un onglet.
        hairline = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        ImageDraw.Draw(hairline).rounded_rectangle(
            [1, 1, size - 2, size - 2],
            radius=round(size * 0.225),
            outline=HAIRLINE,
            width=max(1, round(size * 0.006)),
        )
        canvas.alpha_composite(hairline)

    mask = stroke_mask(size, scale, offset, with_arc=with_arc)
    accent = vertical_gradient(size, ACCENT_TOP, ACCENT_BOTTOM).convert("RGBA")
    accent.putalpha(mask)
    canvas.alpha_composite(accent)

    return canvas.resize((target, target), Image.LANCZOS)


def m_svg_path() -> str:
    """La lettre, en commandes de chemin SVG."""
    return " ".join(
        ("M" if index == 0 else "L") + f"{x},{y}"
        for index, (x, y) in enumerate(M_POINTS)
    )


def arc_svg_path(begin: float, finish: float) -> str:
    """Un segment d'arc, en commandes de chemin SVG."""
    def point(degrees: float) -> tuple[float, float]:
        angle = math.radians(degrees)
        return (
            ARC_CENTER[0] + ARC_RADIUS * math.cos(angle),
            ARC_CENTER[1] + ARC_RADIUS * math.sin(angle),
        )

    x1, y1 = point(begin)
    x2, y2 = point(finish)
    large = 1 if (finish - begin) % 360 > 180 else 0
    return f"M{x1:.2f},{y1:.2f} A{ARC_RADIUS},{ARC_RADIUS} 0 {large} 1 {x2:.2f},{y2:.2f}"


def svg(*, with_arc: bool = True, background: bool = True) -> str:
    """La même marque, en SVG, pour le site et les favicons."""
    path = m_svg_path()
    arc_path = arc_svg_path

    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" role="img">',
        "<defs>",
        '<linearGradient id="mc-mark" x1="0" y1="0" x2="0" y2="1">',
        f'<stop offset="0" stop-color="rgb{ACCENT_TOP}"/>',
        f'<stop offset="1" stop-color="rgb{ACCENT_BOTTOM}"/>',
        "</linearGradient>",
        '<linearGradient id="mc-bg" x1="0" y1="0" x2="0" y2="1">',
        f'<stop offset="0" stop-color="rgb{BG_TOP}"/>',
        f'<stop offset="1" stop-color="rgb{BG_BOTTOM}"/>',
        "</linearGradient>",
        f'<radialGradient id="mc-glow" cx="{GLOW_CENTER[0] / 100}" cy="{GLOW_CENTER[1] / 100}" '
        f'r="{GLOW_RADIUS / 100}">',
        f'<stop offset="0" stop-color="rgb{ACCENT_TOP}" stop-opacity="{GLOW_ALPHA}"/>',
        f'<stop offset="1" stop-color="rgb{ACCENT_TOP}" stop-opacity="0"/>',
        "</radialGradient>",
        "</defs>",
    ]
    if background:
        parts.append('<rect width="100" height="100" rx="22.5" fill="url(#mc-bg)"/>')
        parts.append('<rect width="100" height="100" rx="22.5" fill="url(#mc-glow)"/>')
    if with_arc:
        for begin, finish, thickness, opacity in ARC_SEGMENTS:
            parts.append(
                f'<path d="{arc_path(begin, finish)}" fill="none" stroke="url(#mc-mark)" '
                f'stroke-opacity="{opacity}" stroke-width="{thickness}" stroke-linecap="round"/>'
            )
    parts.append(
        f'<path d="{path}" fill="none" stroke="url(#mc-mark)" stroke-width="{M_STROKE}" '
        'stroke-linecap="round" stroke-linejoin="round"/>'
    )
    parts.append("</svg>")
    return "".join(parts)


def favicon_svg() -> str:
    """La marque en version favicon : plate, sans dégradé ni lueur.

    À seize pixels un dégradé ne se voit pas, mais il pèse : cette version
    tient dans une URL de données trois fois plus courte, pour un dessin que
    l'œil ne distingue pas de l'autre.
    """
    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">',
        f'<rect width="100" height="100" rx="22.5" fill="{hex_color(BG_BOTTOM)}"/>',
    ]
    for begin, finish, thickness, opacity in ARC_SEGMENTS:
        parts.append(
            f'<path d="{arc_svg_path(begin, finish)}" fill="none" '
            f'stroke="{hex_color(ACCENT_BOTTOM)}" stroke-opacity="{opacity:g}" '
            f'stroke-width="{thickness:g}" stroke-linecap="round"/>'
        )
    parts.append(
        f'<path d="{m_svg_path()}" fill="none" stroke="{hex_color(ACCENT_TOP)}" '
        f'stroke-width="{M_STROKE:g}" stroke-linecap="round" stroke-linejoin="round"/>'
    )
    parts.append("</svg>")
    return "".join(parts)


def favicon_data_uri() -> str:
    """L'URL de données du favicon, encodée au strict nécessaire.

    Encoder tout le SVG en base64 le rendrait illisible et plus lourd d'un
    tiers : seuls les caractères qui casseraient l'attribut sont échappés.
    """
    encoded = favicon_svg()
    for character, escape in [
        ("%", "%25"),
        ("<", "%3C"),
        (">", "%3E"),
        ("#", "%23"),
        ('"', "'"),
    ]:
        encoded = encoded.replace(character, escape)
    return "data:image/svg+xml," + encoded


def hex_color(color: tuple[int, int, int]) -> str:
    return "#%02x%02x%02x" % color


def tsx() -> str:
    """Le composant React du site, dérivé de la même géométrie.

    Écrit par ce script plutôt que tenu à la main : le SVG du site et les PNG
    des icônes doivent rester le même dessin, et la seule façon de s'en
    assurer est qu'un seul fichier les décrive tous les deux.
    """
    def numbers(values: tuple[float, ...]) -> str:
        return ", ".join(f"{value:g}" for value in values)

    arcs = []
    for begin, finish, thickness, opacity in ARC_SEGMENTS:
        arcs.append(
            "      <path\n"
            f'        d="{arc_svg_path(begin, finish)}"\n'
            '        fill="none"\n'
            "        stroke={`url(#${id}-stroke)`}\n"
            f'        strokeOpacity={{{opacity:g}}}\n'
            f'        strokeWidth={{{thickness:g}}}\n'
            '        strokeLinecap="round"\n'
            "      />"
        )

    return f'''import {{ useId }} from "react";

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
export function BrandMark({{
  size = 30,
  withPlate = true,
  className,
}}: {{
  size?: number;
  /** Le fond sombre arrondi. Faux pour poser la marque sur une surface claire. */
  withPlate?: boolean;
  className?: string;
}}) {{
  // Deux marques sur la même page partageraient leurs dégradés si les
  // identifiants étaient écrits en dur : la seconde effacerait la première.
  const id = useId().replace(/:/g, "");

  return (
    <svg
      className={{className}}
      width={{size}}
      height={{size}}
      viewBox="0 0 100 100"
      role="img"
      aria-hidden="true"
      focusable="false"
    >
      <defs>
        <linearGradient id={{`${{id}}-stroke`}} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="rgb({numbers(ACCENT_TOP)})" />
          <stop offset="1" stopColor="rgb({numbers(ACCENT_BOTTOM)})" />
        </linearGradient>
        <linearGradient id={{`${{id}}-plate`}} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="rgb({numbers(BG_TOP)})" />
          <stop offset="1" stopColor="rgb({numbers(BG_BOTTOM)})" />
        </linearGradient>
        <radialGradient id={{`${{id}}-glow`}} cx="{GLOW_CENTER[0] / 100:g}" cy="{GLOW_CENTER[1] / 100:g}" r="{GLOW_RADIUS / 100:g}">
          <stop offset="0" stopColor="rgb({numbers(ACCENT_TOP)})" stopOpacity="{GLOW_ALPHA:g}" />
          <stop offset="1" stopColor="rgb({numbers(ACCENT_TOP)})" stopOpacity="0" />
        </radialGradient>
      </defs>
      {{withPlate && (
        <>
          <rect width="100" height="100" rx="22.5" fill={{`url(#${{id}}-plate)`}} />
          <rect width="100" height="100" rx="22.5" fill={{`url(#${{id}}-glow)`}} />
        </>
      )}}
{chr(10).join(arcs)}
      <path
        d="{m_svg_path()}"
        fill="none"
        stroke={{`url(#${{id}}-stroke)`}}
        strokeWidth={{{M_STROKE:g}}}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}}
'''


def main() -> None:
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    web_icons = os.path.join(root, "web", "src", "icons")
    ios_icons = os.path.join(
        root, "ios", "MonCoach", "MonCoach", "Resources", "Assets.xcassets", "AppIcon.appiconset"
    )
    os.makedirs(web_icons, exist_ok=True)

    written = []
    for name, target, ratio, rounded, arc in [
        ("icon-180.png", 180, 0.70, True, True),
        ("icon-192.png", 192, 0.70, True, True),
        ("icon-512.png", 512, 0.70, True, True),
        # Masquable : le système rogne jusqu'au cercle inscrit, donc le
        # dessin est plus petit et le fond va jusqu'aux bords.
        ("icon-512-maskable.png", 512, 0.52, False, True),
    ]:
        path = os.path.join(web_icons, name)
        render(target, content_ratio=ratio, rounded=rounded, with_arc=arc).save(path)
        written.append(path)

    app_icon = os.path.join(ios_icons, "icon-1024.png")
    # iOS applique lui-même le masque arrondi : l'icône livrée est carrée et
    # pleine, sinon les coins apparaissent deux fois.
    render(1024, content_ratio=0.66, rounded=False, with_arc=True).convert("RGB").save(app_icon)
    written.append(app_icon)

    component = os.path.join(root, "web", "src", "components", "BrandMark.tsx")
    with io.open(component, "w", encoding="utf-8") as handle:
        handle.write(tsx())
    written.append(component)

    # Le favicon est réécrit dans les pages : le bundler refuse de résoudre un
    # href statique vers un fichier copié tel quel, et un favicon injecté en
    # JavaScript arriverait après que l'onglet a déjà affiché son icône par
    # défaut. Une URL de données ne demande rien à personne.
    pattern = re.compile(
        r'(<link\s+\n?\s*rel="icon"[^>]*?href=")[^"]*(")', re.MULTILINE
    )
    for page in ["index.html", "mentions-legales.html", "confidentialite.html", "conditions.html"]:
        path = os.path.join(root, "web", "src", page)
        with io.open(path, encoding="utf-8") as handle:
            source = handle.read()
        patched, count = pattern.subn(
            lambda match: match.group(1) + favicon_data_uri() + match.group(2), source
        )
        if count != 1:
            raise SystemExit(f"{page}: {count} balise(s) favicon trouvée(s), une attendue")
        if patched != source:
            with io.open(path, "w", encoding="utf-8") as handle:
                handle.write(patched)
        written.append(path)

    marks = os.path.join(root, "web", "src", "icons", "mark.svg")
    with io.open(marks, "w", encoding="utf-8") as handle:
        handle.write(svg())
    written.append(marks)

    for path in written:
        print(os.path.relpath(path, root))


if __name__ == "__main__":
    main()
