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

/* TODO 
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

/* Représente une salle avec un ajout d'identifiant en int pour faciliter la gestion des dvar*/
tuple Salle{
	int numSalle; 			//pour simplifier ensuite lors des contraites
	string idSalle; 		// nom de la salle
	int tailleSalle;		//taille de la salle
}

/* Représente un besoin Spécifique */
tuple BesoinSpecifique{
	string idBesoinSpecifique;	//nom d'une salle
	{string}besoinsSalles;     	//list des noms de sessions devant se faire dans la salle
}


/* LES INSTANCES */
int nbJoursMax;
int nbCreneauxMaxParJour;

/* Déclaration de tableaux de Tuples qui recupereront les données de l'instance */
{Salle}salles;
{Indisponible}indisponibles;
{Precede} precedes;
{Session} sessions;
{Bloc} blocs;
{BesoinSpecifique}besoinsSpecifiques;

/*Déclarations de variable permettant de recuperer les tableaux de string des tuples*/
{string}blocsIn[0..100];		//100 est le nombre de bloc qu'il y a environ dans tout les fichiers
{string}listSessions[0..40];	//40 est le nombre de sessions qu'il y a environ dans tout les fichiers
{int}listCrenaux[0..24];		//24 est le nombre de creneaux qu'il y a environ dans tout les fichiers
{int}listJours[0..30];			//30 est le nombre de bloc qu'il y a environ dans tout les fichiers
{string}listBesoinsSpecifiques[0..10];// 10 est le nombre de besoins spécifique moyen dans tout les fichiers


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
	getSalles(donnees,salles);
	getBesoins(donnees,besoinsSpecifiques,listBesoinsSpecifiques);
}

/************************************************************************
********* Prétraitement sur les données de l'instance (si besoin)********
************************************************************************/
 
{string} codeDeSession = {s.idSession | s in sessions}; //Stocke dans un tableau de String les identifiants de toutes les sessions
{string} codeDeBloc = {b.idBloc | b in blocs};			//Stocke dans un tableau de String les identifiants de tous les blocs
{string} codeDeSalle = {s.idSalle | s in salles};		//stocke dans un tableau de String Les indentifiants des salles
int dureeMinimaleSession = min(s in sessions)s.duree;	//Stocke la durée minimale d'une session
int dureeMaximaleSession = max(s in sessions)s.duree;	//Stocke la durée maximale d'une session
int nbSalles = max (s in salles)s.numSalle;				//indique le nombre totale de salle dans l'instance
{string} intervenantsDuBloc[codeDeBloc];	//stocke tous les intervenants interne au bloc
{string} blocDuBloc[codeDeBloc];			//stocke tous les blocs se situant dans le bloc
{string} temp1[codeDeBloc]; 				//tableau temporaire qui permet la modification de intervenantsDuBloc
{string} intervenantsDeSession[codeDeSession];	//stocke tous les intervenants à la session
{int} sessionIndisponibleClient[codeDeSession]; //stock les indisponibilités d'une session (par rapport aux indispos des personnes)
{string}intervenants;							//stocke tous les noms des intervenants de l'instance
{string} sessionIntervenant[intervenants];      //stocke tous les noms des sessions auquel participe l'intervenant	
string salleDeSession[codeDeSession];			//stocke pour chaque session la salle ou elle doit avoir lieu
int nbPersonnesSessions[codeDeSession];			//stocke pour chaque session le nombe d'intervenant
{int} indisponibiliteSalle[codeDeSalle];		//recupere pour chaque salle ses indisponibilités en créneaux pour les salles


execute{	

	/*********************************************************
	//IntervenantsDuBloc récupere tout les intervenants par bloc 
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
	**IntervenantsParSession récupere tout les intervenants par session*
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
	*********Gestion de l'indisponibilité des personnes*******
	**********************************************************/ 	
	for (s in intervenantsDeSession){
		for (inter in intervenantsDeSession[s]){
			for(indi in indisponibles){
				if(indi.idIntervenant == inter){
					for(j in indi.jours){
						for(k in indi.creneaux){
							if(k==0){// pas de creneaux en particulier
								for (var creneau =0 ; creneau<nbCreneauxMaxParJour; creneau++){
									sessionIndisponibleClient[s].add(((j-1)*nbCreneauxMaxParJour)+creneau);
								}
							}else{
								sessionIndisponibleClient[s].add(((j-1)*nbCreneauxMaxParJour)+(k-1));
							}							
						}
					}
				}
			}
		}
	}

	/*********************************************************
	**Recupere tout les intervenants de l'instance************
	*********************************************************/
	for(s in intervenantsDeSession){
		for(i in intervenantsDeSession[s]){
			intervenants.add(i);
		}
	}
	
	/*********************************************************
	**Donne toute les sessions auquel participe l'intervenant*
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
	
	/**************************************************************
	**Remplit pour chaque session la salle ou elle doit avoir lieu*
	***************************************************************/
	//remplit pour chaque session la salle ou elle doit avoir lieu
	for (s in sessions){
		for (besoin in besoinsSpecifiques){
			for (sess in besoin.besoinsSalles){
				if(sess==s.idSession){
					salleDeSession[s.idSession] = besoin.idBesoinSpecifique;
				}
			}
		}
	}
	
	/**************************************************************
	****************Nombre de personne dans une session************
	***************************************************************/
	//
	for (s in sessions){
		var cpt =0;
		for (i in intervenantsDeSession[s.idSession]){
			cpt++;
		}
		nbPersonnesSessions[s.idSession]=cpt;
	}
	
	/**************************************************************
	****Donne pour chaque session les indisponibilitésdes salles***
	***************************************************************/	
	for(cds in codeDeSalle){
		for(i in indisponibles){
			if(cds == i.idIntervenant){
				for(j in i.jours){
						for(k in i.creneaux){
							if(k==0){// pas de creneaux en particulier
								for (var creneau =0 ; creneau<nbCreneauxMaxParJour; creneau++){
									indisponibiliteSalle[cds].add(((j-1)*nbCreneauxMaxParJour)+creneau);
								}
							}else{
								indisponibiliteSalle[cds].add(((j-1)*nbCreneauxMaxParJour)+(k-1));
							}							
						}
				}
			}
		}
	}
}	

/************************************************************************
* Variables de décision
************************************************************************/

// recuperera le plus grand creneaux de finSession
dvar int dureeTotaleInstance in dureeMaximaleSession..nbJoursMax*nbCreneauxMaxParJour;

//tableau indexé par les noms des sessions et contenant le créneau où commence la session
dvar int debutSession[codeDeSession] in 0..((nbJoursMax*nbCreneauxMaxParJour) - dureeMinimaleSession);

//tableau indexé par les noms des sessions et contenant le créneau où fini la session
dvar int finSession[codeDeSession] in dureeMinimaleSession..nbJoursMax*nbCreneauxMaxParJour;

//tableau indexé par les noms des sessions et contenant le numéro de la salle ou doit se situer la session
dvar int salleSession[codeDeSession] in 1..nbSalles; 


/************************************************************************
* Contraintes du modèle 					(NB : ne peut être mutualisé)
************************************************************************/

/* On optimise la durée totale grace à minimize meme si ce nest pas demandé */
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
		
	//gestion des indisponibilité de personnel
	forall (s in sessions){
		forall(i in sessionIndisponibleClient[s.idSession]){
			debutSession[s.idSession]>=i || finSession[s.idSession]<=i;
		}
	}
	
	//////////////////////////// Gestion des Salles//////////////////////////////////
	//une salle ne peux pas depasser un certain nombre d'intervenant
	forall(s in sessions){
		forall(sa in salles){
			if(nbPersonnesSessions[s.idSession]>sa.tailleSalle){
				salleSession[s.idSession]!= sa.numSalle;
			}
		}
	}	
	//session devant absolument se derouler dans une salle particuliere
	forall (besoin in besoinsSpecifiques){
		forall (sess in besoin.besoinsSalles){
				forall (sa in salles){
					if(sa.idSalle==besoin.idBesoinSpecifique){
						salleSession[sess] == sa.numSalle;
					}
				}
		}		
	}	
	//deux sessions ne peuvent pas se derouler dans la même piece en même temps
	forall(s1 in sessions,s2 in sessions :s1!=s2){
		(salleSession[s1.idSession]==salleSession[s2.idSession]&&(debutSession[s1.idSession]>=finSession[s2.idSession]|| debutSession[s2.idSession]>=finSession[s1.idSession]))
		||(salleSession[s1.idSession]!=salleSession[s2.idSession]);
	}
	
	//respect des indisponiilité des salles

	forall(se in sessions){
		forall (sa in salles){
			forall (i in indisponibiliteSalle[sa.idSalle]){
				(salleSession[se.idSession]==sa.numSalle && (debutSession[se.idSession]>i || finSession[se.idSession]<i))|| salleSession[se.idSession]!=sa.numSalle;
			}
		}
	}
	
	
	
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
execute{
	var resultat = new Array();
	resultat[resultat.length] = nom+"_planning2.res";
	for (s in codeDeSession){
		for(sa in salles ){ 
			if(sa.numSalle==salleSession[s]){
				resultat[resultat.length] = "planning <"+s+"> <"+parseInt(debutSession[s]/ nbCreneauxMaxParJour)+"> <"+(parseInt(debutSession[s])-(parseInt(debutSession[s]/ nbCreneauxMaxParJour)*nbCreneauxMaxParJour)+1)+"> <"+sa.idSalle+">" ;
			}
		}
	}	
	ecrireResultat(resultat);
}

