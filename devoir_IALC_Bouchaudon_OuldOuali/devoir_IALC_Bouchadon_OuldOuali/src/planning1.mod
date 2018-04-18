/************************
* Devoir IALC 2017-18 - M1 Miage  
* Binome : Bouchaudon Ould Ouali 
*
* Modèle 1
* Description : TODO
*
************************/
using CP;

/************************************************************************
* Lecture du fichier d'instance
************************************************************************/

string nom = ...;
{string} fichiersDonnees = ...;		/* ens des chemins vers les fichiers décrivant l'instance */

/*
Déclaration des structures de données utiles pour lire 
les fichiers décrivant l'instance.
*/

/* LES TUPLES */

/* Représente un bloc */
tuple Bloc {
	string idBloc;			//nom du bloc
	{string} intervenants;	//list des intervenants dans un bloc (intervenant peut etre un bloc lui meme)
}

/* Représente une session*/
tuple Session{
 	string idSession;		//nom de la session
	int duree;			 	//durée de la session
	{string} intervenants; 	//la liste des noms de tous les intervenant dans cette session
}

/* Représente l'organisation chronologique entre deux sessions */
tuple Precede{
	string idS1; 	//nom de la première session
	string idS2;	//nom de la deuxième session
	int duree;		//duree d'attente après la première session pour que la deuxième commence
}

/*  Formalise l'indiposinibilité d'un individu */
tuple Indisponible{
	string idIntervenant; 	//nom de l'intervenant qui n'est pas disponible
	{int} jours;			//le jour où l'intevenant ne sera pas disponible
	{int} creneaux;			//le créneau pendant lequel l'intevenant ne sera pas disponible (si 0, alors il est indisponible toute la journée)
}


/* LES INSTANCES */
int nbJoursMax;				//nombre de jours maximum sur lequel se déroule le planning 1
int nbCreneauxMaxParJour;  	//nombre de créneaux totaux maximum sur lequel se déroule le planning 1


/* Déclaration de tableaux de Tuples qui recupereront les données de l'instance */
{Bloc} blocs;
{Session} sessions;
{Precede} precedes;
{Indisponible}indisponibles;


/*Déclarations de variable permettant de recuperer les tableaux de string des tuples*/
{string}blocsIn[0..100];		//100 est le nombre de bloc qu'il y a environ dans tout les fichiers
{string}listSessions[0..40];	//40 est le nombre de sessions qu'il y a environ dans tout les fichiers
{int}listCrenaux[0..24];		//24 est le nombre de creneaux qu'il y a environ dans tout les fichiers
{int}listJours[0..30];			//30 est le nombre de bloc qu'il y a environ dans tout les fichiers


/* Recupération des données du fichier*/
execute {  
	includeScript("lectureInstance.js");
	
	//appel des fonctions de lectureInstances.js afin de d'extraire les données et de les traiter	
	var informationsraw = recupererDonnees(fichiersDonnees);
	var donnees = new Array();
	for (var i = 0;i<informationsraw.length;i++){// pour chaque ligne supprimer les espaces
		donnees[donnees.length++]=supprimerEspaces(informationsraw[i]);
	}
	
	// récupération des informations correspondant aux instances depuis l'extraction de données
	nbJoursMax = getJours(donnees);
	nbCreneauxMaxParJour=getCreneaux(donnees);
	getBlocs(donnees,blocs,blocsIn);
    getSessions(donnees, sessions,listSessions);
	getPrecedes(donnees, precedes);
	getIndisponibles(donnees, indisponibles,listJours,listCrenaux);	
}



/************************************************************************
********* Prétraitement sur les données de l'instance (si besoin)********
************************************************************************/
 
{string} codeDeSession = {s.idSession | s in sessions}; //Stocke dans un tableau de String les identifiants de toutes les sessions
{string} codeDeBloc = {b.idBloc | b in blocs};			//Stocke dans un tableau de String les identifiants de tous les blocs
int dureeMinimaleSession = min(s in sessions)s.duree;	//Stocke la durée minimale d'une session
int dureeMaximaleSession = max(s in sessions)s.duree;	//Stocke la durée maximale d'une session
{string} intervenantsDuBloc[codeDeBloc];	//stocke tous les intervenants interne au bloc
{string} blocDuBloc[codeDeBloc];			//stocke tous les blocs se situant dans le bloc
{string} temp1[codeDeBloc]; 				//tableau temporaire qui permet la modification de intervenantsDuBloc
{string} intervenantsDeSession[codeDeSession];	//stocke tous les intervenants à la session
{int} sessionIndisponible[codeDeSession];		//stock les indisponibilités d'une session (par rapport aux indispos des personnes)
{string}intervenants;							//stocke tous les noms des intervenants de l'instance
{string} sessionIntervenant[intervenants];		//stocke tous les noms des sessions auquel participe l'intervenant	


execute{	

	/*********************************************************
	//intervenantsDuBloc récupere tout les intervenants par bloc 
	**********************************************************/
	
	/* Sépare les intervenants et les blocs qui sont à l'interieur dun meme bloc*/
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
	
	/* Récupère les intervenants se trouvant dans les blocs du bloc et les met dans le tableau de sting intervenantsDuBloc*/
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
	
	/* On a les intervenants, on re tire donc les blocs du bloc */
	for (b in temp1){
		for(i in temp1[b]){
			for(cb in codeDeBloc){
				if(i==cb){
					intervenantsDuBloc[b].remove(i);
				}
			}
		}
	}
	
	
	/*******************************************************************
	**intervenantsParSession récupere tout les intervenants par session*
	********************************************************************/
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
	
	/*********************************************************
	*********gestion de l'indisponibilité des personnes*******
	**********************************************************/ 
	for (s in intervenantsDeSession){
		for (inter in intervenantsDeSession[s]){
			for(indi in indisponibles){
				if(indi.idIntervenant == inter){
					for(j in indi.jours){
						for(k in indi.creneaux){
							if(k==0){// pas de creneaux en particulier
								for (var creneau =0 ; creneau<nbCreneauxMaxParJour; creneau++){
									sessionIndisponible[s].add(((j-1)*nbCreneauxMaxParJour)+creneau);
								}
							}else{
								sessionIndisponible[s].add(((j-1)*nbCreneauxMaxParJour)+(k-1));
							}							
						}
					}
				}
			}
		}
	}
	
	/*********************************************************
	**recupere tout les intervenants de l'instance************
	*********************************************************/
	for(s in intervenantsDeSession){
		for(i in intervenantsDeSession[s]){
			intervenants.add(i);
		}
	}
	
	/*********************************************************
	**donne toute les sessions auquel participe l'intervenant*
	*********************************************************/
	for (s in intervenantsDeSession){
		for (i in intervenantsDeSession[s]){
			for (i2 in intervenants){
				if(i==i2){
					sessionIntervenant[i].add(s);
				}
			}
		}
	}
}	


/************************************************************************
********************* Variables de décision *****************************
************************************************************************/

// recuperera le plus grand creneaux de finSession
dvar int dureeTotaleInstance in dureeMaximaleSession..nbJoursMax*nbCreneauxMaxParJour;

//tableau indexé par les noms des sessions et contenant le créneau où commence la session
dvar int debutSession[codeDeSession] in 0..((nbJoursMax*nbCreneauxMaxParJour) - dureeMinimaleSession);

//tableau indexé par les noms des sessions et contenant le créneau où fini la session
dvar int finSession[codeDeSession] in dureeMinimaleSession..nbJoursMax*nbCreneauxMaxParJour;


/************************************************************************
* Contraintes du modèle 					(NB : ne peut être mutualisé)
************************************************************************/

/* On optimise la durée totale grace à minimise meme si ce nest pas demandé */
minimize 
	dureeTotaleInstance;
subject to {

	//la duree totale de l'instance est egal a la fin de la derniere session (calculé en creneaux)
	dureeTotaleInstance == max (cs in codeDeSession) finSession[cs];	
													
	//la fin d'une session est defini par le debut + la duree
	forall(s in sessions){
		finSession[s.idSession]==debutSession[s.idSession]+s.duree;
	}
	
	//session ne peux pas s'etendre sur plusieurs jours
	forall(s in sessions){
		(debutSession[s.idSession]div nbCreneauxMaxParJour) == (finSession[s.idSession]div nbCreneauxMaxParJour);
	}
	//gestion de session 1 precede session 2
	forall (p in precedes){
		debutSession[p.idS2]>=((((finSession[p.idS1]div nbCreneauxMaxParJour)+p.duree)*nbCreneauxMaxParJour));
	}
	//un intervenant ne peux pas participer à deux sessions en meme temps
	forall (i in intervenants){
		forall(s1 in sessionIntervenant[i],s2 in sessionIntervenant[i]: s1!=s2){
			debutSession[s1]>=finSession[s2] || debutSession[s2]>=finSession[s1];
		}
	}	
	//gestion des indisponibilité
	forall (s in sessions){
		forall(i in sessionIndisponible[s.idSession]){
			debutSession[s.idSession]>=i || finSession[s.idSession]<=i;
		}
	}
}


/************************************************************************
* ************** Contrôle de flux  (si besoin) **************************
************************************************************************/
execute{
	cp.param.searchType="DepthFirst";
	cp.param.workers=1;
	cp.param.logVerbosity="Quiet";
}

/************************************************************************
*******************  PostTraitement *************************************
************************************************************************/
execute{
	writeln(dureeTotaleInstance);
	var resultat = new Array();
	resultat[resultat.length] = nom+"_planning1.res";
	for (s in codeDeSession){
		resultat[resultat.length] = "planning <"+s+"> <"+parseInt(debutSession[s]/ nbCreneauxMaxParJour)+"> <"+(parseInt(debutSession[s])-(parseInt(debutSession[s]/ nbCreneauxMaxParJour)*nbCreneauxMaxParJour)+1)+"> ";
	}	
	ecrireResultat(resultat);
}

