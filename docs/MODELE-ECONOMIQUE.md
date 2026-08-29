# Modèle économique — freemium

Ce document pose le raisonnement derrière la page Tarifs du site. Il est
versionné pour que le « pourquoi » survive aux ajustements de prix.

## Les contraintes qui décident de tout

**L'architecture ne coûte presque rien.** Pas de serveur applicatif, pas de
base de données, pas de compte : le moteur tourne sur l'appareil. Les coûts
récurrents se réduisent à l'hébergement du site (~5 $/mois), au compte
développeur Apple (99 $/an) et au temps de développement. Conséquence : pas
besoin de course au volume pour couvrir des coûts d'infrastructure — le
modèle peut se permettre d'être généreux.

**La promesse de confidentialité est un actif.** Aucun compte, aucune
donnée collectée : c'est l'argument différenciant du produit. Tout modèle
qui exigerait un compte (abonnement maison, licence serveur) détruirait cet
actif. D'où le choix de StoreKit : Apple gère le paiement, l'application ne
voit qu'un booléen local « formule active ». Commission de 15 % (Small
Business Program sous 1 M$/an) — le prix de la cohérence.

**La valeur du produit se révèle avec le temps.** Un générateur de
programme s'évalue en une séance ; un coach qui *s'adapte* s'évalue sur des
semaines. Le moment où l'utilisateur perçoit la vraie valeur est la fin du
premier bloc : il a un historique, une habitude, et le bilan hebdomadaire a
commencé à modifier son plan. C'est là — et pas avant — que se place la
frontière payante.

## La frontière gratuit / payant

**Gratuit, pour toujours :**

| Quoi | Pourquoi |
| --- | --- |
| Questionnaire et profil complets | c'est l'inscription, la friction doit être nulle |
| Le premier bloc entier (5–6 semaines), charges autorégulées comprises | le produit doit prouver qu'il est un coach, pas une démo |
| Check-in du jour et séance ajustée | c'est l'expérience quotidienne ; la brider fausserait l'évaluation |
| Enregistrement des séances et pesées, sans limite | les données appartiennent à l'utilisateur |
| Export JSON et effacement | **non négociable** : un export payant transformerait la promesse « tes données t'appartiennent » en mensonge |

**Stride+ :**

| Quoi | Pourquoi c'est la bonne frontière |
| --- | --- |
| Les blocs suivants (reconstruction adaptée) | c'est la continuité du coaching — la valeur qui se paie chez un coach humain aussi |
| Le bilan hebdomadaire complet | l'adaptation est le cœur différenciant ; elle n'a de sens qu'en continu |
| L'app Apple Watch | confort premium, coût de développement réel, n'ampute pas l'expérience de base |
| La Live Activity | idem |
| Les courbes de progression | la donnée reste exportable gratuitement ; c'est la *lecture* qui est premium |

Règle de tri, pour les débats futurs : **ce qui enregistre est gratuit, ce
qui continue ou visualise est payant.** Un utilisateur gratuit qui arrête de
payer garde tout son historique et peut toujours s'entraîner sur son dernier
bloc — il perd la suite, pas le passé.

## Les prix

| Formule | Prix | Raisonnement |
| --- | --- | --- |
| Mensuel | 14,99 € | positionnement premium assumé, aligné sur les leaders de la programmation adaptative (Fitbod, Juggernaut AI sont à 12–20 €/mois) — le produit se compare à un coach, pas à un carnet de séances |
| Annuel | 119,99 € | −33 % vs mensuel (« quatre mois offerts ») : l'annuel reste l'achat évident sans brader — au-delà de ~150 €, le montant d'un seul paiement freine plus que la remise n'attire |

**Pas de formule « à vie », par choix.** À ce niveau de prix, un à-vie
crédible coûterait ~200 € et convertirait surtout les meilleurs clients en
revenu unique : on préfère maximiser le revenu récurrent. La contrepartie
est réelle et il faut la regarder en face — l'argument anti-abonnement
disparaît, et un prix premium exige de la preuve : c'est le rôle du premier
bloc entièrement gratuit, qui fait la démonstration avant de demander quoi
que ce soit. Si la conversion à la fin du bloc 1 déçoit durablement
(< 3 % des finisseurs), les leviers dans l'ordre : offre de lancement App
Store (premier mois réduit), puis réexamen de la grille — jamais de rognage
du gratuit.

Le prix élevé rend deux garde-fous encore plus importants : le gratuit doit
rester un vrai coach (c'est lui qui justifie le prix), et l'export doit
rester gratuit (personne ne doit se sentir enfermé dans un abonnement à
180 €/an).

## Ce qu'on refuse d'emblée

- **La publicité** — incompatible avec « aucun traceur », et une app de
  séance pleine de bannières est une app désinstallée.
- **La vente de données** — il n'y a rien à vendre, par construction.
- **Les crédits/consommables** — un coach à la séance n'est pas un coach.
- **Le paywall sur l'export ou la suppression** — voir plus haut.

## Signaux à suivre après lancement

1. **Taux de complétion du premier bloc** — c'est l'entonnoir entier : si
   les gens ne finissent pas le bloc gratuit, le paywall est invisible.
2. **Conversion à la fin du bloc 1** (l'écran « construire le bloc
   suivant » est le point de vente naturel) — cible raisonnable : 5–10 %
   des finisseurs.
3. **Répartition mensuel / annuel** — l'annuel doit dominer ; un parc trop
   mensuel à 14,99 € signale des utilisateurs qui testent puis partent, donc
   un problème de valeur perçue, pas de prix.
4. **Rétention à J+7 du bloc 2** — vérifie que la valeur payée est perçue.

## Ce que ça implique dans le code, plus tard

Le jour où la formule est branchée : un `EntitlementStore` (StoreKit 2)
dans l'app, un booléen local, et des portes aux quatre endroits premium —
`startNextBlock`, bilan hebdomadaire, cibles montre/Live Activity, courbes.
Rien dans MonCoachKit ne change : le moteur ignore ce qu'est un abonnement,
et c'est très bien comme ça.
