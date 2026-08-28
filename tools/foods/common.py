# -*- coding: utf-8 -*-
"""Aides partagées par les tables d'aliments."""

ALL = ["omnivore", "vegetarian", "vegan", "pescatarian", "halal", "glutenFree"]


def vegan(gluten=False):
    """Convient à tous les régimes ; retirer glutenFree si gluten."""
    return [d for d in ALL if not (gluten and d == "glutenFree")]


def vegetarian(gluten=False):
    """Œufs ou laitages : tous sauf végétalien."""
    return [d for d in ALL if d != "vegan" and not (gluten and d == "glutenFree")]


def fish(gluten=False):
    return [d for d in ["omnivore", "pescatarian", "halal", "glutenFree"]
            if not (gluten and d == "glutenFree")]


def meat():
    """Viande hors porc : halal-compatible."""
    return ["omnivore", "halal", "glutenFree"]


def pork(gluten=False):
    return [d for d in ["omnivore", "glutenFree"] if not (gluten and d == "glutenFree")]


def alcohol(gluten=False):
    """La politique de la maison, celle de la bière déjà en rayon."""
    base = ["omnivore", "vegetarian", "vegan", "pescatarian", "halal"]
    return base + ([] if gluten else ["glutenFree"])
