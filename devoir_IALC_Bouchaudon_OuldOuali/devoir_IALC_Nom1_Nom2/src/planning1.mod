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
{string}listSessions[0..40];

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
    getSessions(donnees, sessions,listSessions);
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
int sommeDureeSessions = sum(s in sessions)s.duree;//duree maximale du Projet
int duree[codeDeSession] =[s.idSession : s.duree  | s in sessions];



{string} intervenantsDuBloc[codeDeBloc];//recupere tout les intervenants interne au bloc
{string} blocDuBloc[codeDeBloc];//contient les blocs se situant dans le bloc
{string} temp1[codeDeBloc]; // permet la modification de intervenantsDuBloc
{string} intervenantsDeSession[codeDeSession];//recupere tout les intervenants à la session
execute{
	/*********************************************************
	//intervenantsDuBloc récupere tout les intervenants par bloc 
	**********************************************************/
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
						intervenantsDuBloc[b.idBloc].add(i2);
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
					getIntervenants(blocs,b.intervenants,intervenantsDuBloc[b.idBloc]);
					getIntervenants(blocs,b.intervenants,temp1[b.idBloc]);
				}
			}
		}
	}
	for (b in temp1){
		for(i in temp1[b]){
			for(cb in codeDeBloc){
				if(i==cb){
					intervenantsDuBloc[b].remove(i);
				}
			}
		}
	}
	/*********************************************************
	//intervenantsParSession récupere tout les intervenants par session 
	**********************************************************/
	for(s in sessions){
		isbloc=false;
		for (i in s.intervenants){
			for(b in intervenantsDuBloc){
				if(i==b){
					isbloc=true;					
					for(i2 in intervenantsDuBloc[b]){
						intervenantsDeSession[s.idSession].add(i2);;
					}
				}
			}
			if(isbloc==false){
				intervenantsDeSession[s.idSession].add(i)
			}
		}
	}
}	

/************************************************************************
* Variables de décision
************************************************************************/

dvar int dureeTotaleInstance in dureeMaximaleSession..nbJoursMax*nbCreneauxMaxParJour;
dvar interval s[cs in codeDeSession] in 0..sommeDureeSessions size duree[cs];
/************************************************************************
* Contraintes du modèle 					(NB : ne peut être mutualisé)
************************************************************************/

minimize 
	dureeTotaleInstance;
	
subject to {

	dureeTotaleInstance == max (cds in codeDeSession) endOf(s[cds]);
	
	//gestion du fait qu'une session doi se derouler apres une autre avec un ecart de donnée
	forall (p in precedes){
		endBeforeStart(s[p.idSession1],s[p.idSession2]);
	}	
	
	/*//un intervenant ne peux pas participer à deux sessions en meme temps
	forall(s1 in sessions,s2 in sessions : s1.idSession!=s2.idSession){
		forall(i1 in intervenantsDeSession[s1.idSession]){
			forall(i2 in intervenantsDeSession[s2.idSession]){
				if(i1==i2){
					finSession[s1.idSession]<debutSession[s2.idSession] || finSession[s2.idSession]<debutSession[s1.idSession];
				}
			}
		}
	
	}*/

}


/************************************************************************
* Contrôle de flux  (si besoin)
************************************************************************/
execute{
	cp.param.searchType="DepthFirst";
	cp.param.workers=1;
	cp.param.logVerbosity="Quiet";
}

/************************************************************************
* PostTraitement
************************************************************************/

/* TODO */

