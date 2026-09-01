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
semaines. D'où un essai de **quatorze jours avec le produit entier**, sans
carte bancaire et sans rien à demander : deux semaines pleines, donc deux
fois toutes les séances de la semaine, et un week-end de plus pour ceux qui
ne s'entraînent que le samedi. Juger sur pièces, pas sur une démonstration
amputée.

**Ce qui reste gratuit après l'essai n'est pas une démo non plus.** Le bloc
commencé va jusqu'à sa dernière séance — laisser quelqu'un au milieu d'un
bloc sans ses séances serait lui retirer un entraînement déjà commencé, ce
qu'aucune frontière commerciale ne justifie. Le check-in, les repas du jour,
le mode guidé, l'enregistrement et l'export restent ouverts à vie.

## La frontière gratuit / payant

**Gratuit, pour toujours :**

| Quoi | Pourquoi |
| --- | --- |
| Questionnaire et profil complets | c'est l'inscription, la friction doit être nulle |
| Quatorze jours avec absolument tout, sans carte bancaire | le produit doit prouver qu'il est un coach, pas une démo |
| Le bloc commencé, jusqu'à sa dernière séance | on n'interrompt pas un entraînement en cours pour vendre |
| Le mode guidé sur les 92 mouvements | c'est ce qui rend le produit utilisable par un débutant ; le brider le rendrait dangereux |
| Les repas du jour et les cibles expliquées | l'alimentation quotidienne fait partie de l'expérience de base |
| Check-in du jour et séance ajustée | c'est l'expérience quotidienne ; la brider fausserait l'évaluation |
| Enregistrement des séances et pesées, sans limite | les données appartiennent à l'utilisateur |
| Export JSON et effacement | **non négociable** : un export payant transformerait la promesse « tes données t'appartiennent » en mensonge |

**Stride+ :**

| Quoi | Pourquoi c'est la bonne frontière |
| --- | --- |
| Les blocs suivants (reconstruction adaptée) | c'est la continuité du coaching — la valeur qui se paie chez un coach humain aussi |
| Le plan de course et la liste de courses de la semaine | enregistrer une sortie reste gratuit ; c'est le plan qui la prescrit qui est premium |
| Le bilan hebdomadaire complet | l'adaptation est le cœur différenciant ; elle n'a de sens qu'en continu |
| L'app Apple Watch | confort premium, coût de développement réel, n'ampute pas l'expérience de base |
| La Live Activity | idem |
| Les courbes de progression | la donnée reste exportable gratuitement ; c'est la *lecture* qui est premium |

Règle de tri, pour les débats futurs : **ce qui enregistre est gratuit, ce
qui continue ou visualise est payant.** Un utilisateur gratuit qui arrête de
payer garde tout son historique et peut toujours s'entraîner sur son dernier
bloc — il perd la suite, pas le passé.

La frontière est déclarée une fois, dans le moteur (`PlusFeature`,
`AlwaysFree`), et testée. Éparpillée dans les écrans, elle deviendrait
incohérente en trois semaines : un bouton oublié ici, une carte gratuite là,
et plus personne ne saurait dire ce qui est offert.

## Les prix

| Formule | Prix | Raisonnement |
| --- | --- | --- |
| Mensuel | 14,99 € | positionnement premium assumé, aligné sur les leaders de la programmation adaptative (Fitbod, Juggernaut AI sont à 12–20 €/mois) — le produit se compare à un coach, pas à un carnet de séances |
| Annuel | 119,99 € | −33 % vs mensuel (« quatre mois offerts ») : l'annuel reste l'achat évident sans brader — au-delà de ~150 €, le montant d'un seul paiement freine plus que la remise n'attire |

**Pas de formule « à vie », par choix.** À ce niveau de prix, un à-vie
crédible coûterait ~200 € et convertirait surtout les meilleurs clients en
revenu unique : on préfère maximiser le revenu récurrent. La contrepartie
est réelle et il faut la regarder en face — l'argument anti-abonnement
disparaît, et un prix premium exige de la preuve : c'est le rôle de l'essai
de quatorze jours, qui fait la démonstration avant de demander quoi que ce
soit. Si la conversion à la fin de l'essai déçoit durablement (< 3 % des
essais actifs), les leviers dans l'ordre : allonger l'essai, offre de
lancement App Store (premier mois réduit), puis réexamen de la grille —
jamais de rognage du socle gratuit.

Le prix élevé rend deux garde-fous encore plus importants : l'essai doit
montrer un vrai coach (c'est lui qui justifie le prix), et l'export doit
rester gratuit (personne ne doit se sentir enfermé dans un abonnement à
180 €/an).

**Le droit d'accès n'est jamais écrit sur le disque.** Il se constate auprès
de StoreKit à chaque lancement. Un booléen persisté serait un droit qu'on
peut s'accorder soi-même en modifiant un fichier — et l'application se vante
par ailleurs de laisser l'athlète maître de ses données : les deux ne
tiennent pas ensemble. Hors ligne, StoreKit rend le dernier état connu de
l'appareil, ce qui est exactement le comportement voulu.

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
