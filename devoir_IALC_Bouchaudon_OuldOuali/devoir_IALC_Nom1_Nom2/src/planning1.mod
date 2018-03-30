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
int jours;
int creneaux;
/************************************************************************
* Lecture du fichier d'instance
************************************************************************/

/* TODO 
Déclaration des structures de données utiles pour lire 
les fichiers décrivant l'instance.
*/

execute {  
	includeScript("lectureInstance.js");	// Permet d'inclure un fichier de script
	// TODO - appeler la fonction que vous aurez définie et 
	// permettant de lire le contenu des fichiers décrivant l'instance, 
	// pour alimenter les structures de données que vous jugez utiles	
	jours = getJours();
	creneaux = getCreneaux();
	writeln(jours);
	writeln(creneaux);
	
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

