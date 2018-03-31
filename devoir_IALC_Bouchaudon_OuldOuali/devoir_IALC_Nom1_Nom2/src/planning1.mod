/************************
* Devoir IALC 2017-18 - M1 Miage App 
* Binome : Bouchaudon OuldOuali 
*
* Modèle 1
* Description : TODO
*
************************/
using CP;
string nom = ...;
{string} fichiersDonnees = ...;		/* ens des chemins vers les fichiers décrivant l'instance */

/************************************************************************
* Lecture du fichier d'instance
************************************************************************/

/* TODO 
Déclaration des structures de données utiles pour lire 
les fichiers décrivant l'instance.
*/
int nbJoursTotal;
int nbCreneauxMaxparJour;
int tailleListes = 99;//trouver avec quoi on peut le remplacer

{ string } listeBlocs[0..tailleListes];
tuple Bloc {
	string idBloc;
	{string} intervenants;
}
{Bloc} blocs;
{string} listeSessions[0..tailleListes];
tuple Session{
 	string idSession;
	int duree;
	{string} intervenants;
}
{Session} sessions;

tuple Precede{
	string idSession1;
	string idSession2;
	int duree;
}
{Precede} precedes;

{int} listeCreneaux[0..tailleListes];
{int} listeJours[0..tailleListes];
tuple Indisponible{
	string idIntervenant;
	{int} jours;
	{int} creneaux;
}
{Indisponible} indisponibles;
execute {  
	includeScript("lectureInstance.js");	// Permet d'inclure un fichier de script
	// TODO - appeler la fonction que vous aurez définie et 
	// permettant de lire le contenu des fichiers décrivant l'instance, 
	// pour alimenter les structures de données que vous jugez utiles	
	var informations = recupererDonnees(fichiersDonnees);
	var trueInformations = new Array();
	for (var i = 0;i<informations.length;i++){
		trueInformations[trueInformations.length++]=supprimerEspaces(informations[i]);
	}
}

/************************************************************************
* Prétraitement sur les données de l'instance (si besoin)
************************************************************************/

/* TODO 
Déclaration des structures de données utiles pour faciliter
l'expression du modèle
*/


/************************************************************************
* Variables de décision
************************************************************************/

/* TODO */

/************************************************************************
* Contraintes du modèle 					(NB : ne peut être mutualisé)
************************************************************************/

/* TODO */


/************************************************************************
* Contrôle de flux  (si besoin)
************************************************************************/

/* TODO */

/************************************************************************
* PostTraitement
************************************************************************/

/* TODO */

