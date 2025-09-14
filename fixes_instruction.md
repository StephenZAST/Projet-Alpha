fixe instruction 

Pour toute question ou besoin de compréhension sur une feature du projet Alpha, réfère-toi aux fichiers suivants :

REFERENCE_FEATURES.md : Documentation progressive, cartographie complète des features principales (auth, user, order, address, etc.) avec liens backend/frontend, schémas d’interaction et conseils de navigation.
REFERENCE_ARTICLE_SERVICE.md : Référence détaillée pour les features Article, Service, Admin, OrderItem, Affiliate, Delivery, Notification, Subscription, Offer, avec explications sur la logique métier, les endpoints, et la structure des fichiers.
Lis la section correspondante à la feature recherchée dans ces fichiers pour obtenir une vue d’ensemble, la liste des fichiers impliqués, et les points d’attention pour naviguer rapidement dans le code.




n'hesite pas si tu n'a pas une certaine informaiton sur certaine implementation faite dans ma codebase a faire des recherche dans la code base afin de retrouver des information et avoir plus de context par exemple a faire des recherche de terme ou ficher  cible et les lire pour meiux comprend et faire des suggestion de code tres fin et precise



applique les effet de zebrage dans les differente tableau que tu va utiliser pour une meilleur lecture : 

L’effet d’alternance de couleur sur les lignes d’un tableau s’appelle : « zébrage » ou « row striping » (en anglais : striped rows). Il améliore la lisibilité en différenciant visuellement chaque ligne.

Dans ton code Flutter (users_table.dart), l’alternance est gérée ainsi :

color: index % 2 == 0
  ? (isDark ? AppColors.gray900 : AppColors.gray50)
  : Colors.transparent,


Si la ligne est paire (index % 2 == 0), elle prend une couleur de fond :
En dark theme : AppColors.gray900 (gris très foncé)
En light theme : AppColors.gray50 (gris très clair)
Si la ligne est impaire, le fond est transparent (donc couleur par défaut du conteneur).
Description des couleurs utilisées :

Dark theme : Gris très foncé (gray900) pour les lignes paires, fond par défaut (souvent gris foncé ou noir) pour les impaires.
Light theme : Gris très clair (gray50) pour les lignes paires, fond par défaut (blanc ou gris très pâle) pour les impaires.




2 pour la page services 

retire la collone prix car elle n'est pas necessaie les services on pas vraiment un prix une on un champ prix mais elle n'est pas consider c'est jsute une champ obselet que lon va supprimer putard mas pas maintenant donc ce n'est pas necessaire de le prendre en consideration tu peut lire le fichier backend\docs\pricing-system.md mieux comprendre l'architecture mis en place entre les services servicestype et articles et les couple articles services services types : 

pour une meilleure comprenhension tu peut lire le schema prisma et lire les fichier definie dans les documentation reference pour comprendre comment mettre en place les differente query pas type 

retire aussi le filtre par type toujours dans cette page services : 


enfin tu peut ajuster les button que tu a ajouter (type de services  et article services couple ) qui renvoie respectivement vers ces page car il ne semble pas etre sunchroniser avec notre menue abrre ajuste les pour permette leur bonne fonctionnement c'est a dire leur navigation vers ces page : 

quand je clique sur l'un oiu l'autre de ces button j'ai ceci comme log en console mais je n'acced pas au page en faite : 


[AuthMiddleware] isAuthenticated: true
js_primitives.dart:28 [AuthMiddleware] Access granted to route: /service-article-couples
js_primitives.dart:28 [Router] Redirect to null
js_primitives.dart:28 [Router] GOING TO ROUTE /service-article-couples
js_primitives.dart:28 [MyApp] Route changed: /service-article-couples
js_primitives.dart:28 [AdminBinding] Initializing bindings
js_primitives.dart:28 [AdminBinding] Dependencies initialization completed
js_primitives.dart:28 [AuthMiddleware] Page build starting
js_primitives.dart:28 [AdminSideMenu] Current selected index: 2
js_primitives.dart:28 [MenuAppController] getScreen called with index: 2



ca ce sont les fixe a apporter dans la page services 

3 page categories : 

dans le tableau tu peut retirer le button radio ativer ou desactiver car ce n'est pas necessaire les categonie non pas la facuter active inactive c'est sut suppression pour les desctiver 

de plus je voudrais vraiment avoir la possiblite dans cette page categogie pour chaque ligne de categoy avoir une moyen de voir les different articels associer a cette categories tu comprend pour linstant je voit vial la collon article les nombre articles associer a chaque categories mais je voir voir aissi via un button ouvrant un dialog ou peut importe (uen implemebtatin en accord avec le design pattern et offrant une meilleur experience utilisateur ) de voir chaque article associer aux categories c'était lune des principade featureinteressance de cette page categories : 


les categories nom pas la possiblite d'etre active ou pas 

model article_categories {
  id          String     @id @default(dbgenerated("uuid_generate_v4()")) @db.Uuid
  name        String     @db.VarChar
  description String?
  createdAt   DateTime?  @default(now()) @db.Timestamptz(6)
  articles    articles[]
}

donc reitre le filtre de query par active ou inactive car elle ne fonctionnera pas : 
le filtre par date 'est pas fonctionnelle il faudras l'implementer : 

car pour linstant quand on clique sdessus il ne fonctionne pas : 

la aussi je remarque que quand kje clique sur le button article dans la page des categories il ya comme une page article qui s'ouvre ce qui n'est pas normal avec des log en boulble infinie en cosole : 

[   +7 ms] Context: while handling a pointer data packet
[   +1 ms] Library: gestures library
[   +1 ms] ===========================

[  +21 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[        ]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +5 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[   +8 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +2 ms] 
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +4 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[   +9 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +1 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +4 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[   +8 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +3 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +4 ms] Context: while handling a pointer data packet
[   +1 ms] Library: gestures library
[   +2 ms] ===========================

[   +8 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +2 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_
           packages/flutter/src/rendering/box.dart 2729:11                                 <fn>

           lib/_engine/engine/pointer_binding.dart 1034:18                                 <fn>
           lib/_engine/engine/pointer_binding.dart 948:7                                   <fn>
           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +5 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[+1516 ms] Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12
[+2924 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +3 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_
           packages/flutter/src/rendering/box.dart 2729:11                                 <fn>

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +6 ms] Context: while handling a pointer data packet
[   +1 ms] Library: gestures library
[        ] ===========================

[   +8 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +2 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_
           packages/flutter/src/rendering/box.dart 2729:11                                 <fn>

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +9 ms] Context: while handling a pointer data packet
[   +1 ms] Library: gestures library
[        ] ===========================

[   +5 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +3 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +6 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[  +35 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +1 ms]
           === GlobalKey Error Details ===
[   +1 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +6 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[   +3 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +3 ms]
           === GlobalKey Error Details ===
[        ] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_

           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +2 ms] Context: while handling a pointer data packet
[   +1 ms] Library: gestures library
[   +2 ms] ===========================

[  +12 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[   +5 ms]
           === GlobalKey Error Details ===
[        ] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_
           packages/flutter/src/rendering/box.dart 2729:11                                 <fn>

           lib/_engine/engine/pointer_binding.dart 948:7                                   <fn>
           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[   +3 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[ +116 ms] Another exception was thrown: Cannot hit test a render box that has never been laid out.
[  +13 ms]
           === GlobalKey Error Details ===
[   +3 ms] Location: dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 288:3     throw_
           packages/flutter/src/rendering/box.dart 2729:11                                 <fn>

           lib/_engine/engine/pointer_binding.dart 948:7                                   <fn>
           lib/_engine/engine/pointer_binding.dart 541:9                                   loggedHandler
           dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 212:27  _callDartFunctionFast1

[  +13 ms] Context: while handling a pointer data packet
[        ] Library: gestures library
[        ] ===========================

[        ] Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12


il serait plutôt simple que quand on clique sur ce button article dans le header de la page categoies que on acces a la page articles permie par le menu draword et quil soit la aussi shynchroniser tu comprend  voila cela devrais conclure les fix a apporter dans la page categories : 

quand la page articles souvre par exemple mon application devient bizarre en console il ya toujours cett bouble infinie qui s'affiche et mon application n'est plus focntionnelle il faut la le relancer pour continuer a le manipuler : 

couples
13js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12
js_primitives.dart:28 [Router] "ArticleController" onDelete() called
263js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12
js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12
2js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12
js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/mouse_tracker.dart:203:12


4 pour les page articles les different ajustement a faire dans cette page sont les suivante 

dans le tableaux des articels il n'est pas necessaire les collone prix premium et prix basic car il sont la aussi obselete ce n'est pas eux qui sont utiliser pour le calcule de prix mais plutôt le prix dans couple articles services price c'est la que cela se passe tu peut les laisser ces prix des articles comme descorration du tableau si tu trouve pas autre chose a les remplace pour ne pas juste laisser un vide tu comprend mais cela ne devrait pas porter en confusion les utilisateur admin qui utiliseron l'application tu comprend ?

la aussi les filtre par prix n'est pas necessaire les autre filte eux tu uet les laisser car il sont fonctionnelle il sagis de filtre par categories et par nom croissant ou decroissant etc.. 



enfin dans cette page articles je constate la meme erreure quand je clique sur le button header categories qui est cencer me ramnner dans la page categories par raccourcie construit une nouvelle app et il ya beacoup d'ereur en console et mon application n'est plus fonctionnelle : 

[AuthMiddleware] isAuthenticated: true
js_primitives.dart:28 [AuthMiddleware] Access granted to route: /categories
js_primitives.dart:28 [Router] Redirect to null
js_primitives.dart:28 [Router] GOING TO ROUTE /categories
js_primitives.dart:28 [MyApp] Route changed: /categories
js_primitives.dart:28 [AdminBinding] Initializing bindings
js_primitives.dart:28 [AdminBinding] Dependencies initialization completed
js_primitives.dart:28 [AuthMiddleware] Page build starting
js_primitives.dart:28 [AdminSideMenu] Current selected index: 4
js_primitives.dart:28 [MenuAppController] getScreen called with index: 4
js_primitives.dart:28 Another exception was thrown: RenderFlex children have non-zero flex but incoming width constraints are unbounded.
js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/box.dart:2176:12
js_primitives.dart:28 Another exception was thrown: Assertion failed: file:///D:/Stephen/flutter/packages/flutter/lib/src/rendering/box.dart:2176:12
js_primitives.dart:28 Another exception was thrown: Assertion failed: 



5 page type de services 

malheureusmeent dans la page type de services services_type_screen il ya une probleme car le problme de botton overflowed n'a pas été corriger comme ce qui a été fait dans les autre page comme categories services notification etc... fautra refaire cette correction de overflower pour  corriger cel roblmee : 

6 pour la page article services price les differente probleme de overflowed la aussi n'a pas été corriger un peut comme pour la page precedente il non pas été ajuster 


7 la page abonnement je propose que lon revienne sur cette page a la fin car il ya beaucoup d'implementation a ajuster meme en backend pour que cela puisse fonctionneer comme tes implementation avec les donnee mocker utiliser dans la page onglet utilsateur abonnee cela serait une bonne manière de faire cette implementation mais pour linstant il faut faire des ajsutement tant des les controller les Endpoint et  meme peut etres dans la base de donnee pour quelle ajuste et fite avec la vision sde test donnee mocker on pourrat lire les fichier frotned et backend pour elaborer un plan d'implementation avec meme des exemple de plan a inserezr dans la base de donnee pour similuer des plan sd'abonnement et des utiliser qui serait abonner avec des differente variable des donnee mocker 

souvent la navigation dans la cette page me retourne cette erreure : 

*** Response ***
js_primitives.dart:28 uri: http://localhost:3001/api/admin/subscriptions
js_primitives.dart:28 statusCode: 404
js_primitives.dart:28 headers:
js_primitives.dart:28  content-length: 162
js_primitives.dart:28  content-type: text/html; charset=utf-8
js_primitives.dart:28 Response Text:
js_primitives.dart:28 <!DOCTYPE html>
js_primitives.dart:28 <html lang="en">
js_primitives.dart:28 <head>
js_primitives.dart:28 <meta charset="utf-8">
js_primitives.dart:28 <title>Error</title>
js_primitives.dart:28 </head>
js_primitives.dart:28 <body>
js_primitives.dart:28 <pre>Cannot GET /api/admin/subscriptions</pre>
js_primitives.dart:28 </body>
js_primitives.dart:28 </html>


errors.dart:288 Uncaught (in promise) DartError: setState() called after dispose(): _OffersScreenState#634b4(lifecycle state: defunct, not mounted, ticker inactive)
This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree (e.g., whose parent widget no longer includes the widget in its build). This error can occur when code calls setState() from a timer or an animation callback.
The preferred solution is to cancel the timer or stop listening to the animation in the dispose() callback. Another solution is to check the "mounted" property of this object before calling setState() to ensure the object is still in the tree.
This error might indicate a memory leak if setState() is being called because another object is retaining a reference to this State object after it has been removed from the tree. To avoid memory leaks, consider breaking the reference to this object during dispose().
    at Object.throw_ [as throw] (errors.dart:288:3)
    at framework.dart:1168:9
    at offers_screen._OffersScreenState.new.setState (framework.dart:1202:14)

de plus le disloge pour par exmeple la creation d'une articels services price ne charge pas les donne type ni services ni articles pour faitre une combinaison le chagmeent des donnee echoue faudra corriger cela aussi 


8 pour la page utilisateur ya pas vraiment grand chose a dire que l'effet zebrage qu'il faut utiliser et pour les button des avatard utiliser pluto un full rouded plutôt qu'un rectable pour les avatar des initial tu comprned ?



9 POUR LA PAGE AFFILIER LA AUSSI YA pas grand chose a dire que le fait d'applique l'effet de zebrage pour le tableau et aussi ajsuter pour eviter les probleme de botton overflowed car les donnee du tableau ne sont pas assez donc on ne sait pas quand les donneer seron assez pour necessiter un scrolle est ce que cela ne poserait pas un probleme de overflowed  analyse cela a cette page et ajsute si possible 



10 pour la page des livreur je propose de refaire une refonte du designe et de le refaire et de bien ajuster les Endpoint pour une bonne communication avec le bakcend car des utlisateur livreur ca existe dans le systemem mais je voit aucun utilisateur trouvé donc en te basant ssur les fichier reference tu peut analyser le backend et le frotnend pour comprendre les source d'erreure et les corriger adequamment evec toujours une implementation design suivant nitre patter et robuste et aussi en offrant une experience utilisateur efficace : 



11 pour la page des notification je voit qu'il sagie de notification donnee mocker mais le design est particuliairement plaisant tu peut faire en sorte que lon analuyse les differente fposssibilite ofder par le backend et la base de donnee de faire en sorte d'ajuster le système de notification pour quelle soit aussi fonctionnelle pour les feature action auqqqsuelle elle serait liee ain quelle puisse etre aussi informatif et gerable depuis le la page notification comme l'offre l'experience de notification 



12 POUR LA PAGE  mon profile on me dit que le chargment des donnee ont echouer faudrai la aussi ajuster les différentes api et services controller pour permette a lutilisateur admin connecter dee gere ses propre donneer utilisateur tu comprend 


les different page tableau de bord et commande eut il faudra refaire une refonte progressible de leur design pour les fit au designe patterne de notre application et etre sur que caque composant a été mise a jours et si possbile réfléchis sur les implementation pour les procecuse de commande etc... 


pour toutes ces fixe je propose un patche etape par etape que lon prenne le temps pour chaque partie de faire une implkementation entiere et complete fonctionnelle avant de passer au suivant tu compren 


