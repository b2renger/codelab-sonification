# codelab-sonification

http://b2renger.github.io/pages_codelab/index.html

This repo is about sonifying a twitter feed. It was created for the 2nd aniversary of the french creative coding forum codelab (29th februrary 2016).

Ce repo contient le code de la page web permettant la sonification d'un fil twitter. L'exemple se base sur la sonification du fil du forum codelab et a été fait à l'ocasion des deux ans du forum (29 février 2016).

J'ai laissé mes notes d'avancement telles quelles au fur et a mesure du projet (vous y comprendrez peut-être quelquechose !)




Remerciements :
Olivier : http://yamatierea.org/
Germain : http://www.mgsx.net/
Pierre : http://emoc.org/


Technos :
twitter
ruby
p5js 
webpd

Si il fallait aller plus loin :
- pouvoir interroger directement la base de do
=> sonification de threads en intégralité
=> sonification de catégories de concurence de catégories : "Pd" vs "Max/Msp"
=> sonification de recherches par mots clés, avec représentation des différents thread
=> Data-mining

////////////////////////////////////////////////////////////////////////////////////////////////////////////

Jour 1

récupération d'un script ruby écrit par Germain d'un ancien projet. 
Ce script permet de scrapper la timeline d'un utilisateur de manière itérative avec un temps entre chaque requête pour éviter d'en formuler trop et de se voir refuser des infos par twitter.
Il faut créer un app twitter et renseigner de tokens d'identifications.

observation des différents tweets, des mots publié dans les titres, réfléxions à des filtres de type "aide" / "au secours" 

chercher des mots clés :

"aide" / "help" / "problème"   
"apéro" / "codelab"
"windows" / "linux" / "mac" / "OSX" / "arduino"
spams : "Nike" "Adidas" "free" "sale" "discount" "tiffany" "sneakers" "shoes" "health" "low energy" "smart "
// "son" / "image" / "video" / "mapping"
// "Pd" / "Pure-Data" / "Proessing" / "Max/MSP"

easter egg : PPP , combinaisons "probleme / mac " , "dans le potage"

Dans les tweets récents il semble en fait manquer des infos, depuis le 15 septembre 2015 : plus de "posté par #pseudo" , "dans #catégorie" est-ce le cas dans tout l'historique ? jusqu'au bout ?

faudrait-il tronquer les data pour pouvoir filtrer par catégorie ? par pseudo ? pour pouvoir associer des sons à différents utlisateurs ? serait-il possible un jour de laisser chaque utilisateur choisir un son pour ses propres postes ?

Il va falloir analyser un peu les 22 000 et quelques tweets, et prévoir un peu de data-mining. Il faudra de toute manière recréer un fichier json avec les data qui sont intéressantes.

Erreur TooManyRequests ! il va falloir investiguer. Il devrait être possible de lancer une nouvelle recherche à partir d'un id précis. (#ajoutscreen)

Lecture et compréhension de l'algo dans le script et ajout de commentaires dans le fichier "timeline-scraper.rb": il faudra créer un nouvel objet tweet en utilisant :

```
tweet = Marshal.load(File.binread(file))
```
avec le dernier fichier crée depuis le dernier "scrap", il faudra ensuite initialiser la variable lastTweet avec cet objet.

Pour charger un fichier du disque
```
Dir.glob("data-scrap/tweet/*").sort
```
pourrait être utile.

Il faudra un sélecteur de date en js avec un calendrier ou autre :
http://jster.net/library/datetimepicker
http://jster.net/library/kalendae
cela pourra être utile pour choisir une date de début et une date de fin, mais aussi pour avoir un référence des mois à 30 vs 31 jours mais aussi des années bisextiles.

Il pourra être intéressant de marquer le premier anniversaire du site, et les nouvelles années par un repère sonore.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

Jour2

Il n'est a priori pas possible de surpasser la limite de 3200 tweets récupérés.
https://dev.twitter.com/rest/reference/get/statuses/user_timeline
https://twittercommunity.com/t/why-the-3200-tweet-user-timeline-limit-and-will-it-ever-change/


3215 tweets :
521334560487784448 : 2014-10-12 16:20:19 +0000
696011996823552000 : 2016-02-11 11:14:12 +0000

soit un peut plus d'un an de tweets.

Il faudrait créer un script ruby permettant de charger les tweets (Marshal.load) et de générer un fichier json comprenant la date de chaque tweet.
A priori l'année, le mois, le jour, et l'heure suffisent (par précaution on peut prendre les minutes mais les secondes ne seront pas nécessaires a priori).

Potentiellement sur un an 365j x 24 h = 8760 h dans une année soit potentiellement 8760 pas dans notre step sequencer, 2190 mesures, 547.5 groupes de 4 mesures...er

Une clock midi va elle séprarer chaque noire en 24 'subticks' : en utilisant ce paradigme 1 journée = 1 temps. A 120 bpm : un an ~ 3 minutes de musique.

3215 tweets sur un an => 8.8 tweets par jour en moyenne. Cela risque de donner quelque chose d'assez dense. Il faudra utiliser des sons brefs voire étaler la base temporelle en diminuant le bpm.

Si une option est prise pour un tempo rapide et un rendu sonore de type 'texture' il pourra être amusant de jouer sur l'heure du tweet avec la spatialisation (0h et 12h centrés ?), l'amplitude (fort à 0h et 12h ?), permettre de comparer ces différents résultats par un paramètre ?

En tenant compte de cette limite il est peut-être intéressant de se limiter à la dernière année d'activité du compte twitter de codelab. 28 février 2015 => 29 février 2016 
Avec cette approche les possibilités de filtrage et de data-mining vont être réduites.

Ecriture des données dans un fichier json à l'aide d'un script ruby 'data2json.rb'.

Il est temps de tester le chargement du fichier json dans une page web :
http://p5js.org/reference/#/p5/loadJSON

Pour utiliser ce code il est nécessaire d'avoir un serveur de fichier qui tourne localement sur sa machine. Heureusement ruby a un 'gem' pour cela et la déclaration du serveur ne prend qu'une ligne :

- mettre tous les fichiers dans un dossier "public" et installer le gem
```
gem install sinatra
```
- créer un fichier ruby "server.rb" avec cette simple ligne de code
``` ruby
require 'sinatra'
```
- lancer le serveur
``` 
ruby server.rb
```
-sur un navigateur entrer l'adresse :
``` 
http://localhost:4567/index.html
```
et hop ! on a un serveur qui sert les fichiers présent dans public.

Le code p5js pour charger un fichier json adapté pour parcourir l'index du fichier de manière incrémentale :

``` javascript
var data;
var counter = 0;

function preload() {
  var file = "temp.json";
  data = loadJSON(file ,success, error, "json");
}

function setup() {
  //noLoop();
  frameRate(1);
}

function draw() {
  background(200);
  // get the humidity value out of the loaded JSON
  var id = data[counter].id;
  var count = data[counter].count;
  var date = data[counter].date;
  console.log(id,count,date);
  counter ++;
}

function success (){
	console.log("success loading json");
}

function error (){
	console.log("error loading json");
}
```

Il va maintenant falloir écrire un compteur qui compte tous les jours d'une année en prenant en compte la durée des mois (31 jours vs 30 jours, voire 28 ou 29). Ceci est assez simple normalement. J'avais écrit il y a quelques temps une classe java ...

C'est relativement rudimentaire et cela manque d'élégance mais cela fera l'affaire.

``` java 
// made to count from 1984 to 2014 day by day
class DateCounter {

  int year, month, day;
  int n_iteration = 0;
  PGraphics pg = createGraphics(160, 50);

  DateCounter(int year, int month, int day) {
    this.year = year ;
    this.month = month ;
    this.day = day;
  } 

  void printDate() {
    println(year+"-"+month+"-"+day);
  }

  PGraphics drawDate() {
    String year = nf(dc.year, 4, 0);
    String month = nf(dc.month, 2, 0);
    String day = nf(dc.day, 2, 0);
    String date = year+"-"+month+"-"+day ;
    pg.beginDraw();
    pg.background(255);
    pg.fill(0);
    pg.textSize(20);
    pg.text(date,20,30);
    pg.endDraw();
    return pg;
  }

  void update() {
    n_iteration += 1;

    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) {
      if (day == 31) {
        day = 1;
        month+=1;
      } else {
        day +=1;
      }
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      if ( day == 30) {
        day = 1;
        month+=1;
      } else {
        day +=1;
      }
    } else if (month == 2) {
      if (year == 2016 || year == 2012 || year == 2008 || year == 2004 || year == 2000 || year == 1996 || year == 1992 || year == 1988 || year == 1984) {
        if (day == 29) {
          day = 1;
          month+=1;
        } else {
          day +=1;
        }
      } else {
        if (day == 28) {
          day = 1;
          month+=1;
        } else {
          day +=1;
        }
      }
    } else if (month == 12) {
      if (day == 31) {
        day = 1;
        month = 1;
        year +=1;
      } else {
        day +=1;
      }
    }
  }
}

```

Il va falloir aussi construire un clock en javascript :
http://www.html5rocks.com/en/tutorials/audio/scheduling/


///////////////////////////////////////////////////////////////////////////////////////////////////////
Jour 3

Pour la représentation visuelle, sur fond noir on va commencer par dessiner une barre jaune d'1px lorsqu'il y a un tweet dans une période de temps.

On pourrait imaginer que ce dt pourrait être égal à : 
1h => nombre de pixels nécessaire : 365 * 24 = 8760 pixels
4h => nombre de pixels nécessaire : 365 * 6 = 2190 pixels
6h => nombre de pixels nécessaire : 365 * 4 = 1460 pixels

On peut prendre pour référence une image finale dans une 'petite' résolution assez habituelle 1366x768 pixels.
Si on veut s'approcher du visuel de codelab il faut que ces barres soient en diagonnale du coup le nombre de pixels sur la diagonale est : sqrt(1366*1366 + 768*768) ~ 1567 pixels. 

La diagonale d'un écran 1366*768 et un dt de 6h pourrait être une combinaison intéressante. 

Mais attention 3215 tweet sur un an cela signifie environ 8,8 tweets par jour, c'est à dire potentiellement 2 tweets par période de 6h. Il ne faut pas oublier que le silence est primordial pour la perception des patterns rythmiques, il faut donc si ce paradigme est conservé penser à peut-être compter le nombre de tweets dans une période pour dessiner un jaune plus ou moins marqué, un barre plus ou moins longue, un son plus ou moins fort ou un son plutôt qu'un autre.

Ecriture d'une "classe" DateCounter en javascript et dépillage du json en fonction de ce compter. Cette classe permet de compter les heures, jours, mois et années de manière incrémentale à chaque fois que l'on appelle sa fonction update().

Un premier visuel puis un second ont été obtenus, dans l'esthétique on est bien dans l'esprit codelab.

Pour le son deux pistes sont envisagés pour l'instant :
1- Webpd : glitch time ! le principe serait simplement d'utiliser toutes les sources dispos dans webpd (éventuellement différents noises avec des filtres) pour juste allumer/éteindre (sans line~ d'interpolation) des noeuds de gains.
2- p5.sound ou web audio api pure : granular universal happy birthday song ! trouver plusieurs versions (différentes langues/orchestrations de happy birthday) et essayer de récrer un happy birthday à partir d'échantillons de ces différentes versions !! attention !! il faudra très certainement que ces versions fassent la même durée et soient a des tempos similaires car il faut pouvoir reconnaitre que c'est happy birthday !! Montage et timestrech seront autorisés. Mais cette solution risue de demander trop de temps et le rendu sonore risque d'être difficile à maîtriser...


////////////////////////////////////////////////////////////////////////////////////////////////////////
Jour 4

Création d'un patch pd et intégration dans la page p5js avec webpd

Attention l'objet [lop~] dans webpd ne peut pas accepter d'entier en entrée (comme dans pd), il lui faut lui un signal et uniquement un signal.

La communication entre p5js et webpd il faut notament faire attention au type de messages ! et bien suivre la documentation. Pour envoyer la variable 'ntweet_hour' il faut utiliser des crochets.

```
Pd.send('play', [ntweet_hour]);
```
Le rendu est un peu répétitif ... et le patch n'est pas très propre, il va falloir nettoyer et commenter tout ça ! Il faut probablement retravailler le panner pour qu'il marque la durée de la journée grâce au compteur d'heures. Et donner des signaux sonores au passages de jours, et des mois.

Pour l'instant le rythme est dépendant du frameRate du patch puisqu'à chaque calcul d'image la fonction update de notre dateCounter est appelée. Ainsi on avance heure par heure dans l'année.
Nombre de frame dans la totalité de l'animation = 365 * 24 = 8760 frames
Le framerate est d'environ 25 : il faut donc 8760 / 25 = 350.4 secondes pour lire l'ensemble soit ~ 6 minutes ! c'est un peu long !? 

Il faut noter que quand plusieurs tweets ont lieu dans une heure plusieures frames sont calculées et donc l'heure est plus longue dans le temps du programme (si il y a 6 tweets dans une heure elle durera 6 frames).
Il faut d'ailleurs avoir une idée précise 

Il faut afficher la date à laquelle on est dans l'animation, il faut peut-être ajouter un claque désactivable de repères temporels, il faut aussi peut-être envisager de rendre celle ci un peu plus dynamique ? par exemple calculer l'image dans le setup, puis déplacer un curseur avec des carrés jaunes transparents qui se déplacent jusqu'à l'endroit où ils sont censés arriver.

Il faut re-penser aussi à eventuellement intégrer des filtres (de spam par exemple) avec des sons spécifiques (son de notification). Un nouvelle passe sur le script ruby permettant de transcrire les données brutes en json pourrait être utile. Il s'agirait cette fois de préciser le nombre de tweet par heure quand plusieurs tweets sont émis en un heure.

////////////////////////////////////////////////////////////////////////////////////////////////////////////
Jour 5

TODO :
RUBY
//- script ruby avec compte du nombre de tweet par heure
PD
//- correction de l'utilisation du panner (soit un cycle sur 24h, soit passage de     //gauche à droite sur 24h , cognitivement la seconde option marquera une transition   //plus tranchée entre deux jours).
//- signaux de passage de jours et de mois.
P5JS
//- afficher la date
(- afficher un calque ammovible représentant les échélles de temps (en orange pour )  (respecter la charte codelab, peut-être faudra-t-il reprendre la police d'ailleurs).)
(- permettre de se déplacer à des moments précis en pointant à la souris.)
//- travailler l'animation d'apparition.
- ajouter des boutons play/stop/reset

//- Déplacer l'émission de son sur l'apparition des barres.

(- marquer les jours par l'émision d'un élément à la animated lines.)

// - faire en sorte que les éléments animés aient des tailles différentes et/ou       
// opacitées différentes en fonction du nombre de tweets dans la journée.

//- charger la police de codelab pour le compteur de date, travailler l'animation (rotatif ?)
//=> En réalité la police des titres de catégories n'est pas une police mais une image !!

//- rendre moins agressif le son de passage de journée.
//=> enlever le son de passage de journée, et faire un bip tous les lundi plutôt. (peut-être que des choses se //passent les week ends ?)

(- possible de tenter une autre représentation : 
	-> une journée = 1 barre noire assez épaisse, puis dessin d'une barre jaune par journée avec des teintes de jaune
	-> pour essayer de mieux coller spatialement au visuel du background de codelab.)


//- faire un menu d'info

// - rescrapper le compte twitter à partir du 28 février 2015 jsq au 28 février 2016
//- faire un datecounter => emitter et un datecounter => player
- vérifier les niveaux des sons
- ajouter une mention sur el son "use headphones"
- jouer joyeux anniversaire à la fin.

=> publier




