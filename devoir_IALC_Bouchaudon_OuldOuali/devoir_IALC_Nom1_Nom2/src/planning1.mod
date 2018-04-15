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



{string} intervenantsDuBloc[codeDeBloc];//recupere tout les intervenants interne au bloc
{string} blocDuBloc[codeDeBloc];//contient les blocs se situant dans le bloc
{string} temp1[codeDeBloc]; // permet la modification de intervenantsDuBloc
{string} intervenantsDeSession[codeDeSession];//recupere tout les intervenants à la session
{int} sessionIndisponible[codeDeSession];
{string}intervenants;
{string} sessionIntervenant[intervenants];
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
	
	/*********************************************************
	//gestion de l'indisponibilité des personnes
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
	//recupere tout les intervenants de l'instance
	for(s in intervenantsDeSession){
		for(i in intervenantsDeSession[s]){
			intervenants.add(i);
		}
	}
	
	//donne toute les sessions auquel participe l'intervenant	
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
* Variables de décision
************************************************************************/

dvar int dureeTotaleInstance in dureeMaximaleSession..nbJoursMax*nbCreneauxMaxParJour;
dvar int debutSession[codeDeSession] in 0..((nbJoursMax*nbCreneauxMaxParJour) - dureeMinimaleSession);
dvar int finSession[codeDeSession] in dureeMinimaleSession..nbJoursMax*nbCreneauxMaxParJour;
/************************************************************************
* Contraintes du modèle 					(NB : ne peut être mutualisé)
************************************************************************/
minimize 
	dureeTotaleInstance;
subject to {

	dureeTotaleInstance == max (cs in codeDeSession) finSession[cs];//la duree totale de l'instance est egal a la fin
																	//de la derniere session
	
	//fin == duree +debut 
	forall(s in sessions){
		finSession[s.idSession]==debutSession[s.idSession]+s.duree;//la fin d'une session est defini par le debut + la duree
	}
	//session ne peux pas s'etendre sur plusieurs jours
	forall(s in sessions){
		(debutSession[s.idSession]div nbCreneauxMaxParJour) == (finSession[s.idSession]div nbCreneauxMaxParJour);
	}
	//gestion de session 1 precede session 2
	forall (p in precedes){
		debutSession[p.idSession2]>=((((finSession[p.idSession1]div nbCreneauxMaxParJour)+p.duree)*nbCreneauxMaxParJour));
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
	writeln(dureeTotaleInstance);
	var resultat = new Array();
	resultat[resultat.length] = nom+"_planning1.res";
	for (s in codeDeSession){
		resultat[resultat.length] = "planning <"+s+"> <"+parseInt(debutSession[s]/ nbCreneauxMaxParJour)+"> <"+(parseInt(debutSession[s])-(parseInt(debutSession[s]/ nbCreneauxMaxParJour)*nbCreneauxMaxParJour)+1)+"> ";
	}	
	for(var i =0; i<resultat.length;i++){
		writeln(resultat[i]);
	}
	
	ecrireResultat(resultat);
}

