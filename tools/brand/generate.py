# -*- coding: utf-8 -*-
"""Fabrique la marque de Mon Coach, une seule fois, pour tous les supports.

La marque n'est pas une initiale : c'est ce que l'application produit.

Au centre, une courbe de progression qui monte, redescend d'un cran, puis
repart — un bloc et sa semaine de décharge. Le trait naît fin et finit
épais, ce qui donne le sens de la lecture sans qu'il faille une flèche, et
se termine par un point plein : la séance du jour, celle qui reste à faire.

Autour, l'anneau est le bloc lui-même. Il part mince et sourd en bas à
gauche, s'épaissit et s'éclaire en tournant, et s'arrête net en bas à
droite. Le trou du bas est ce qui sépare deux blocs.

Tout est dérivé d'une seule géométrie, décrite ici et nulle part ailleurs :
le site la dessine en SVG à partir des mêmes coordonnées, et ce script en
tire les PNG dont la PWA et iOS ont besoin. Deux dessins entretenus
séparément finissent toujours par diverger — et l'écart ne se voit pas dans
le code, il se voit en posant les deux rendus côte à côte.

    python3 tools/brand/generate.py
"""

from __future__ import annotations

import io
import math
import os
import re
from PIL import Image, ImageDraw

# --------------------------------------------------------------- géométrie

# Repère de 100 × 100, celui du viewBox du SVG. Quatre points de contrôle,
# reliés par une courbe lisse : monter, marquer la décharge, repartir.
CURVE = [(28, 68), (45, 51), (56, 58), (70, 42)]
CURVE_WIDTH_START = 3.4
CURVE_WIDTH_END = 8.5
# L'épaisseur ne croît pas tout à fait linéairement : légèrement en retrait
# au départ, le trait reste fin plus longtemps et la fin paraît plus franche.
CURVE_WIDTH_EASE = 0.9
# Nombre d'échantillons par segment de courbe. Au-delà, la facette d'un
# polygone mesure moins d'un dixième de pixel : on paierait des octets pour
# une différence que personne ne voit.
CURVE_STEPS = 40

# Le point du bout, posé sur le dernier point de contrôle : il en est déduit
# plutôt que saisi, sinon déplacer la courbe le laisserait derrière.
DOT_RADIUS = 7.0

# L'anneau : centre, rayon, puis les segments qui le composent, du plus sourd
# au plus franc. Angles en degrés, 0° = est, sens horaire (l'axe des y
# descend). Le trou du bas laisse passer le départ de la courbe.
RING_CENTER = (50, 50)
RING_RADIUS = 43.0
# (début, fin, épaisseur, opacité)
RING_SEGMENTS = [
    (126, 250, 2.4, 0.18),
    (250, 340, 3.2, 0.42),
    (340, 410, 4.4, 0.90),
]

# La part du cadre occupée par le dessin. Partagée par le PNG et le SVG :
# sans elle, le SVG du site dessinait la marque bord à bord pendant que
# l'icône gardait sa marge, et les deux ne se ressemblaient plus.
CONTENT_RATIO = 0.70

# La lueur derrière le dessin : ce qui le détache du fond au lieu de le
# poser dessus. Centre, rayon et opacité au centre.
GLOW_CENTER = (50, 44)
GLOW_RADIUS = 52.0
GLOW_ALPHA = 0.13

# ----------------------------------------------------------------- couleurs

BG_TOP = (21, 26, 35)
BG_BOTTOM = (11, 13, 18)
ACCENT_TOP = (124, 240, 168)
ACCENT_BOTTOM = (53, 196, 123)
HAIRLINE = (255, 255, 255, 26)

SUPERSAMPLE = 4


def hex_color(color: tuple[int, int, int]) -> str:
    return "#%02x%02x%02x" % color


# ----------------------------------------------------------------- la courbe

def smoothed() -> list[tuple[float, float]]:
    """La courbe échantillonnée, en passant par tous les points de contrôle.

    Catmull-Rom plutôt que Bézier : les points de contrôle sont sur la courbe,
    donc les déplacer dit exactement ce qu'on veut voir. Les extrémités sont
    doublées pour que la courbe démarre et finisse dans la bonne direction.
    """
    padded = [CURVE[0]] + list(CURVE) + [CURVE[-1]]
    points: list[tuple[float, float]] = []
    for index in range(len(padded) - 3):
        p0, p1, p2, p3 = padded[index], padded[index + 1], padded[index + 2], padded[index + 3]
        for step in range(CURVE_STEPS):
            t = step / CURVE_STEPS
            t2, t3 = t * t, t * t * t
            points.append(
                (
                    0.5 * (2 * p1[0] + (-p0[0] + p2[0]) * t
                           + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2
                           + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3),
                    0.5 * (2 * p1[1] + (-p0[1] + p2[1]) * t
                           + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2
                           + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3),
                )
            )
    points.append(CURVE[-1])
    return points


def widths(count: int) -> list[float]:
    """L'épaisseur en chaque point, du départ fin à l'arrivée épaisse."""
    span = CURVE_WIDTH_END - CURVE_WIDTH_START
    return [
        CURVE_WIDTH_START + span * (index / (count - 1)) ** CURVE_WIDTH_EASE
        for index in range(count)
    ]


def outline() -> list[tuple[float, float]]:
    """Le contour du trait, un bord aller et l'autre retour.

    Ni Pillow ni SVG ne savent tracer une ligne dont l'épaisseur varie : on
    calcule les deux bords à la main et on remplit la forme obtenue. C'est
    aussi ce qui garantit que le PNG et le SVG sont le même dessin, aux
    mêmes coordonnées, et pas deux approximations voisines.
    """
    points = smoothed()
    thickness = widths(len(points))
    left: list[tuple[float, float]] = []
    right: list[tuple[float, float]] = []
    for index, (x, y) in enumerate(points):
        if index == 0:
            dx, dy = points[1][0] - x, points[1][1] - y
        elif index == len(points) - 1:
            dx, dy = x - points[-2][0], y - points[-2][1]
        else:
            dx = points[index + 1][0] - points[index - 1][0]
            dy = points[index + 1][1] - points[index - 1][1]
        length = math.hypot(dx, dy) or 1.0
        # La normale au chemin : c'est d'elle que dépendent les deux bords.
        nx, ny = -dy / length, dx / length
        half = thickness[index] / 2
        left.append((x + nx * half, y + ny * half))
        right.append((x - nx * half, y - ny * half))
    return left + right[::-1]


def discs() -> list[tuple[tuple[float, float], float]]:
    """Les disques à poser : les deux bouts arrondis, puis le point du bout.

    Le point est plus large que le trait ; il est listé en dernier pour être
    dessiné par-dessus, comme dans le SVG.
    """
    points = smoothed()
    thickness = widths(len(points))
    return [
        (points[0], thickness[0] / 2),
        (points[-1], thickness[-1] / 2),
        (CURVE[-1], DOT_RADIUS),
    ]


# ----------------------------------------------------------------- l'anneau

def ring_point(degrees: float) -> tuple[float, float]:
    angle = math.radians(degrees)
    return (
        RING_CENTER[0] + RING_RADIUS * math.cos(angle),
        RING_CENTER[1] + RING_RADIUS * math.sin(angle),
    )


def ring_free_ends() -> list[tuple[float, float, float, float]]:
    """Les deux extrémités libres de l'anneau : x, y, épaisseur, opacité.

    Seules celles-là sont arrondies. Entre deux segments, la coupure franche
    est précisément ce qui donne l'impression d'un trait qui s'épaissit — et
    deux bouts ronds superposés y feraient une bosse.
    """
    first, last = RING_SEGMENTS[0], RING_SEGMENTS[-1]
    start, end = ring_point(first[0]), ring_point(last[1])
    return [
        (start[0], start[1], first[2], first[3]),
        (end[0], end[1], last[2], last[3]),
    ]


# ---------------------------------------------------------------- rendu PNG

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
    """La lueur derrière le dessin, en niveaux de gris.

    Calculée petite puis agrandie : un dégradé radial pixel par pixel sur
    4096 × 4096 coûterait des minutes pour un résultat identique.
    """
    resolution = 192
    glow = Image.new("L", (resolution, resolution), 0)
    pixels = glow.load()
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


def stroke_mask(size: int, scale: float, offset: float) -> Image.Image:
    """Le tracé de la marque, en niveaux de gris.

    Le tracé est dessiné dans un masque puis rempli d'un dégradé : Pillow ne
    sait pas peindre un trait dégradé, mais il sait très bien composer deux
    images à travers un masque. Le niveau de gris porte l'opacité, ce qui
    permet à l'anneau d'être plus sourd que la courbe sans changer de teinte.
    """
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)

    def place(point: tuple[float, float]) -> tuple[float, float]:
        return (offset + point[0] * scale, offset + point[1] * scale)

    def disc(center: tuple[float, float], radius: float, fill: int) -> None:
        x, y = place(center)
        r = radius * scale
        draw.ellipse([x - r, y - r, x + r, y + r], fill=fill)

    center = place(RING_CENTER)
    for begin, finish, thickness, opacity in RING_SEGMENTS:
        width = max(1, round(thickness * scale))
        # Pillow épaissit un arc vers l'intérieur de la boîte : on élargit la
        # boîte d'une demi-épaisseur pour que la ligne médiane reste sur le
        # rayon, quelle que soit l'épaisseur du segment.
        outer = RING_RADIUS * scale + width / 2
        draw.arc(
            [center[0] - outer, center[1] - outer, center[0] + outer, center[1] + outer],
            begin,
            finish,
            fill=round(255 * opacity),
            width=width,
        )
    for x, y, thickness, opacity in ring_free_ends():
        disc((x, y), thickness / 2, round(255 * opacity))

    draw.polygon([place(point) for point in outline()], fill=255)
    for point, radius in discs():
        disc(point, radius, 255)
    return mask


def render(target: int, *, content_ratio: float, rounded: bool) -> Image.Image:
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
    # le trait. Elle est rognée par le même masque que le fond, sinon elle
    # déborderait des coins arrondis.
    glow = Image.new("RGBA", (size, size), ACCENT_TOP + (0,))
    glow_mask = radial_glow(size, scale, offset)
    if rounded:
        glow_mask = Image.composite(
            glow_mask, Image.new("L", (size, size), 0), background.getchannel("A")
        )
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

    accent = vertical_gradient(size, ACCENT_TOP, ACCENT_BOTTOM).convert("RGBA")
    accent.putalpha(stroke_mask(size, scale, offset))
    canvas.alpha_composite(accent)

    return canvas.resize((target, target), Image.LANCZOS)


# ---------------------------------------------------------------- rendu SVG

def outline_path() -> str:
    """Le contour du trait, en commandes de chemin SVG."""
    points = outline()
    head = f"M{points[0][0]:.1f},{points[0][1]:.1f}"
    body = "".join(f"L{x:.1f},{y:.1f}" for x, y in points[1:])
    return head + body + "Z"


def centerline_path() -> str:
    """La ligne médiane, en trois cubiques exactes.

    Une courbe de Catmull-Rom se convertit sans perte en Bézier cubique : le
    favicon obtient le même tracé que le contour échantillonné, en trente
    fois moins d'octets. C'est ce qui permet de le glisser dans une URL de
    données sans alourdir chaque page.
    """
    padded = [CURVE[0]] + list(CURVE) + [CURVE[-1]]
    path = f"M{CURVE[0][0]:g},{CURVE[0][1]:g}"
    for index in range(len(padded) - 3):
        p0, p1, p2, p3 = padded[index], padded[index + 1], padded[index + 2], padded[index + 3]
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        path += f"C{c1[0]:.1f},{c1[1]:.1f} {c2[0]:.1f},{c2[1]:.1f} {p2[0]:g},{p2[1]:g}"
    return path


def ring_path(begin: float, finish: float) -> str:
    """Un segment d'anneau, en commandes de chemin SVG."""
    x1, y1 = ring_point(begin)
    x2, y2 = ring_point(finish)
    large = 1 if (finish - begin) % 360 > 180 else 0
    return f"M{x1:.2f},{y1:.2f} A{RING_RADIUS:g},{RING_RADIUS:g} 0 {large} 1 {x2:.2f},{y2:.2f}"


def ring_svg(stroke: str) -> str:
    """L'anneau complet : les segments, puis les deux bouts arrondis.

    Les segments sont tracés à bouts francs et les extrémités libres posées
    en disques, exactement comme les dessine Pillow. Des bouts ronds partout
    empièteraient sur le segment voisin et la marche d'épaisseur, qui est le
    sujet du dessin, deviendrait une bosse.
    """
    parts = [
        f'<path d="{ring_path(begin, finish)}" fill="none" stroke="{stroke}" '
        f'stroke-opacity="{opacity:g}" stroke-width="{thickness:g}" stroke-linecap="butt"/>'
        for begin, finish, thickness, opacity in RING_SEGMENTS
    ]
    parts += [
        f'<circle cx="{x:.2f}" cy="{y:.2f}" r="{thickness / 2:g}" fill="{stroke}" '
        f'fill-opacity="{opacity:g}"/>'
        for x, y, thickness, opacity in ring_free_ends()
    ]
    return "".join(parts)


def discs_svg(fill: str) -> str:
    return "".join(
        f'<circle cx="{point[0]:.1f}" cy="{point[1]:.1f}" r="{radius:.2f}" fill="{fill}"/>'
        for point, radius in discs()
    )


def content_transform() -> str:
    """La transformation qui donne au SVG la marge des PNG."""
    inset = (100 - 100 * CONTENT_RATIO) / 2
    return f'transform="translate({inset:g},{inset:g}) scale({CONTENT_RATIO:g})"'


def glow_stops(indent: str = "", jsx: bool = False) -> str:
    """Les paliers du dégradé de la lueur.

    Un `radialGradient` interpole linéairement, alors que le PNG décroît en
    carré : sans paliers intermédiaires, la lueur du site est plus large et
    plus verte que celle de l'icône. Cinq arrêts suffisent à rendre l'écart
    invisible.
    """
    close = " />" if jsx else "/>"
    opacity = "stopOpacity" if jsx else "stop-opacity"
    color = "stopColor" if jsx else "stop-color"
    tint = "rgb(" + ", ".join(str(c) for c in ACCENT_TOP) + ")" if jsx else f"rgb{ACCENT_TOP}"
    lines = [
        f'{indent}<stop offset="{step / 4:g}" {color}="{tint}" '
        f'{opacity}="{GLOW_ALPHA * (1 - step / 4) ** 2:.4f}"{close}'
        for step in range(5)
    ]
    return "\n".join(lines) if indent else "".join(lines)


def svg() -> str:
    """La marque complète, en SVG."""
    return "".join(
        [
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" role="img">',
            "<defs>",
            # En coordonnées absolues : sinon chaque forme reçoit le dégradé
            # ramené à sa propre boîte, et les petits disques ressortent
            # comme des pastilles plus claires que le trait.
            '<linearGradient id="mc-stroke" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="0" y2="100">',
            f'<stop offset="0" stop-color="rgb{ACCENT_TOP}"/>',
            f'<stop offset="1" stop-color="rgb{ACCENT_BOTTOM}"/>',
            "</linearGradient>",
            '<linearGradient id="mc-plate" x1="0" y1="0" x2="0" y2="1">',
            f'<stop offset="0" stop-color="rgb{BG_TOP}"/>',
            f'<stop offset="1" stop-color="rgb{BG_BOTTOM}"/>',
            "</linearGradient>",
            f'<radialGradient id="mc-glow" cx="{GLOW_CENTER[0] / 100:g}" '
            f'cy="{GLOW_CENTER[1] / 100:g}" r="{GLOW_RADIUS / 100:g}">',
            glow_stops(),
            "</radialGradient>",
            "</defs>",
            '<rect width="100" height="100" rx="22.5" fill="url(#mc-plate)"/>',
            '<rect width="100" height="100" rx="22.5" fill="url(#mc-glow)"/>',
            f"<g {content_transform()}>",
            ring_svg("url(#mc-stroke)"),
            f'<path d="{outline_path()}" fill="url(#mc-stroke)"/>',
            discs_svg("url(#mc-stroke)"),
            "</g>",
            "</svg>",
        ]
    )


def favicon_svg() -> str:
    """La marque en version favicon : plate, sans dégradé, sans épaississement.

    À seize pixels, ni le dégradé ni la variation d'épaisseur ne se voient,
    mais ils pèsent — le contour échantillonné à lui seul fait deux kilos
    d'octets, répétés dans les quatre pages. L'anneau, lui, ne coûte rien :
    il est identique à celui de la marque complète.
    """
    thickness = (CURVE_WIDTH_START + CURVE_WIDTH_END) / 2
    accent = hex_color(ACCENT_TOP)
    return "".join(
        [
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">',
            f'<rect width="100" height="100" rx="22.5" fill="{hex_color(BG_BOTTOM)}"/>',
            f"<g {content_transform()}>",
            ring_svg(accent),
            f'<path d="{centerline_path()}" fill="none" stroke="{accent}" '
            f'stroke-width="{thickness:g}" stroke-linecap="round"/>',
            f'<circle cx="{CURVE[-1][0]:g}" cy="{CURVE[-1][1]:g}" r="{DOT_RADIUS:g}" fill="{accent}"/>',
            "</g>",
            "</svg>",
        ]
    )


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


def tsx() -> str:
    """Le composant React du site, dérivé de la même géométrie.

    Écrit par ce script plutôt que tenu à la main : le SVG du site et les PNG
    des icônes doivent rester le même dessin, et la seule façon de s'en
    assurer est qu'un seul fichier les décrive tous les deux.
    """
    def rgb(color: tuple[int, int, int]) -> str:
        return "rgb(" + ", ".join(str(channel) for channel in color) + ")"

    def indented(markup: str) -> str:
        """Les fragments SVG partagés, remis à l'indentation du composant."""
        pieces = markup.replace("/><", "/>\n<").split("\n")
        return "\n".join("        " + piece.replace("/>", " />") for piece in pieces)

    stroke = "{`url(#${id}-stroke)`}"
    body = indented(ring_svg("STROKE") + f'<path d="{outline_path()}" fill="STROKE"/>' + discs_svg("STROKE"))
    body = body.replace('"STROKE"', stroke)

    return f'''import {{ useId }} from "react";

/**
 * La marque de Mon Coach.
 *
 * Fichier produit par `tools/brand/generate.py` — ne pas modifier à la main :
 * la prochaine exécution du script écraserait la retouche, et le SVG du site
 * ne correspondrait plus aux icônes de l'application.
 *
 * Ce n'est pas une initiale, c'est ce que l'application produit. La courbe
 * monte, redescend d'un cran — la semaine de décharge — puis repart, et
 * finit sur un point plein : la séance du jour. L'anneau autour est le bloc,
 * mince et sourd à son début, franc à sa fin.
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
        <linearGradient id={{`${{id}}-stroke`}} gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="0" y2="100">
          <stop offset="0" stopColor="{rgb(ACCENT_TOP)}" />
          <stop offset="1" stopColor="{rgb(ACCENT_BOTTOM)}" />
        </linearGradient>
        <linearGradient id={{`${{id}}-plate`}} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="{rgb(BG_TOP)}" />
          <stop offset="1" stopColor="{rgb(BG_BOTTOM)}" />
        </linearGradient>
        <radialGradient id={{`${{id}}-glow`}} cx="{GLOW_CENTER[0] / 100:g}" cy="{GLOW_CENTER[1] / 100:g}" r="{GLOW_RADIUS / 100:g}">
{glow_stops(indent="          ", jsx=True)}
        </radialGradient>
      </defs>
      {{withPlate && (
        <>
          <rect width="100" height="100" rx="22.5" fill={{`url(#${{id}}-plate)`}} />
          <rect width="100" height="100" rx="22.5" fill={{`url(#${{id}}-glow)`}} />
        </>
      )}}
      <g {content_transform()}>
{body}
      </g>
    </svg>
  );
}}
'''


# Le catalogue de la montre, écrit ici plutôt que posé à la main : la marque a
# une source unique, et un fichier oublié se voit alors en régénérant.
WATCH_APPICON_CONTENTS = '''{
  "images" : [
    {
      "filename" : "icon-1024.png",
      "idiom" : "universal",
      "platform" : "watchos",
      "size" : "1024x1024"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
'''

CATALOG_CONTENTS = '''{
  "info" : { "author" : "xcode", "version" : 1 }
}
'''


def main() -> None:
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    web_icons = os.path.join(root, "web", "src", "icons")
    ios_icons = os.path.join(
        root, "ios", "MonCoach", "MonCoach", "Resources", "Assets.xcassets", "AppIcon.appiconset"
    )
    os.makedirs(web_icons, exist_ok=True)

    written = []
    for name, target, ratio, rounded in [
        ("icon-180.png", 180, CONTENT_RATIO, True),
        ("icon-192.png", 192, CONTENT_RATIO, True),
        ("icon-512.png", 512, CONTENT_RATIO, True),
        # Masquable : le système rogne jusqu'au cercle inscrit, donc le
        # dessin est plus petit et le fond va jusqu'aux bords.
        ("icon-512-maskable.png", 512, 0.52, False),
    ]:
        path = os.path.join(web_icons, name)
        render(target, content_ratio=ratio, rounded=rounded).save(path)
        written.append(path)

    app_icon = os.path.join(ios_icons, "icon-1024.png")
    # iOS applique lui-même le masque arrondi : l'icône livrée est carrée et
    # pleine, sans couche alpha, sinon l'App Store la refuse. Le dessin est
    # un peu plus serré que sur le web, pour ne pas frôler ce masque.
    render(1024, content_ratio=0.66, rounded=False).convert("RGB").save(app_icon)
    written.append(app_icon)

    # La montre a son propre catalogue, et son absence ne se voit pas à la
    # compilation : c'est Apple qui refuse la livraison, tout à la fin, sur un
    # « Missing Icons » qui ne dit pas quelle cible manque.
    #
    # watchOS masque en cercle, pas en carré arrondi. Le cercle inscrit dans un
    # carré en rogne les angles bien plus qu'un squircle : le dessin est donc
    # resserré d'autant, sans quoi la courbe frôlerait le bord.
    watch_icons = os.path.join(
        root, "ios", "MonCoach", "MonCoachWatch", "Assets.xcassets", "AppIcon.appiconset"
    )
    os.makedirs(watch_icons, exist_ok=True)
    watch_icon = os.path.join(watch_icons, "icon-1024.png")
    render(1024, content_ratio=0.56, rounded=False).convert("RGB").save(watch_icon)
    written.append(watch_icon)

    for path, payload in [
        (os.path.join(watch_icons, "Contents.json"), WATCH_APPICON_CONTENTS),
        (
            os.path.join(os.path.dirname(watch_icons), "Contents.json"),
            CATALOG_CONTENTS,
        ),
    ]:
        with io.open(path, "w", encoding="utf-8") as handle:
            handle.write(payload)
        written.append(path)

    component = os.path.join(root, "web", "src", "components", "BrandMark.tsx")
    with io.open(component, "w", encoding="utf-8") as handle:
        handle.write(tsx())
    written.append(component)

    # Le favicon est réécrit dans les pages : le bundler refuse de résoudre un
    # href statique vers un fichier copié tel quel, et un favicon injecté en
    # JavaScript arriverait après que l'onglet a déjà affiché son icône par
    # défaut. Une URL de données ne demande rien à personne.
    pattern = re.compile(r'(<link rel="icon" type="image/svg\+xml" href=")[^"]*(")')
    for page in ["index.html", "mentions-legales.html", "confidentialite.html", "conditions.html"]:
        path = os.path.join(root, "web", "src", page)
        with io.open(path, encoding="utf-8") as handle:
            source = handle.read()
        patched, count = pattern.subn(
            lambda match: match.group(1) + favicon_data_uri() + match.group(2), source
        )
        if count != 1:
            raise SystemExit(f"{page} : {count} balise(s) favicon trouvée(s), une attendue")
        if patched != source:
            with io.open(path, "w", encoding="utf-8") as handle:
                handle.write(patched)
        written.append(path)

    mark = os.path.join(web_icons, "mark.svg")
    with io.open(mark, "w", encoding="utf-8") as handle:
        handle.write(svg())
    written.append(mark)

    for path in written:
        print(os.path.relpath(path, root))


if __name__ == "__main__":
    main()
