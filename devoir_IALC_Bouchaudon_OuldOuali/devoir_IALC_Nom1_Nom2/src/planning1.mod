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
int nbJoursMax;
int nbCreneauxMaxParJour;

tuple Bloc {
	string idBloc;
	{string} intervenants;
}
{Bloc} blocs;
{string}blocsIn[0..100];//100 est le nombre de bloc qu'il y a environ dans tout les fichiers

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

tuple Indisponible{
	string idIntervenant;
	{int} jours;
	{int} creneaux;
}
{Indisponible}indisponibles;
{int}listCrenaux[0..24];
{int}listJours[0..30];
execute {  
	includeScript("lectureInstance.js");	// Permet d'inclure un fichier de script
	// TODO - appeler la fonction que vous aurez définie et 
	// permettant de lire le contenu des fichiers décrivant l'instance, 
	// pour alimenter les structures de données que vous jugez utiles	
	var informationsraw = recupererDonnees(fichiersDonnees);
	var donnees = new Array();
	for (var i = 0;i<informationsraw.length;i++){
		donnees[donnees.length++]=supprimerEspaces(informationsraw[i]);
	}
	nbJoursMax = getJours(donnees);
	nbCreneauxMaxParJour=getCreneaux(donnees);
	getBlocs(donnees,blocs,blocsIn);
    getSessions(donnees, sessions);
	getPrecedes(donnees, precedes);
	getIndisponibles(donnees, indisponibles,listJours,listCrenaux);
}

/************************************************************************
* Prétraitement sur les données de l'instance (si besoin)
************************************************************************/
 
{string} codeDeSession = {s.idSession | s in sessions};
{string} codeDeBloc = {b.idBloc | b in blocs};
int dureeMinimaleSession = min(s in sessions)s.duree;
int dureeMaximaleSession = max(s in sessions)s.duree;


{string} intervenantDuBloc[codeDeBloc];//recupere tout les intervenants mais interne au bloc
{string} blocDuBloc[codeDeBloc];
{string} temp1[codeDeBloc];
execute{
	//intervenantsParBloc récupere tout les intervenants 
	var isbloc;
	for (b in blocs){		
		for (i in b.intervenants){
			isbloc =false;
			for(cb in codeDeBloc){				
				if(i==cb){
					blocDuBloc[b.idBloc].add(i);
					isbloc =true;
				}
			}
			if(isbloc ==false){
				for(i2 in b.intervenants){
					if(i==i2){						
						intervenantDuBloc[b.idBloc].add(i2);
						temp1[b.idBloc].add(i2);
					}
				}
			}
			
		}	
	}
	for (b in blocs){
		for(b2 in blocDuBloc){
			for(i in blocDuBloc[b2]){
				if(b2==b.idBloc){
					getIntervenants(blocs,b.intervenants,intervenantDuBloc[b.idBloc]);
					getIntervenants(blocs,b.intervenants,temp1[b.idBloc]);
				}
			}
		}
	}
	for (b in temp1){
		for(i in temp1[b]){
			for(cb in codeDeBloc){
				if(i==cb){
					intervenantDuBloc[b].remove(i);
				}
			}
		}
	}
	for (b in intervenantDuBloc){
		writeln("////",b);		
		for(i in intervenantDuBloc[b]){
			writeln(i);
		}	
		writeln("******");
	}

}
/*Déclaration des structures de données utiles pour faciliter
l'expression du modèle
*/


/************************************************************************
* Variables de décision
************************************************************************/

/*dvar int debutSession[codeSession] in 0..(nbJoursMax*nbCreneauxMaxParJour) - dureeMinimaleSession;
dvar int finSession[codeSession] in dureeMinimaleSession..nbJoursMax*nbCreneauxMaxParJour;
dvar int dureeTotaleSession in dureeMaximaleSession..nbJoursMax*nbCreneauxMaxParJour;*/

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

