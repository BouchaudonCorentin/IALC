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

tuple Salle{
	int numSalle;//pour simplifier ensuite lors des contraites
	string idSalle;
	int tailleSalle;
}
{Salle}salles;

tuple BesoinSpecifique{
	string idBesoinSpecifique;
	{string}besoinsSalles;
}
{BesoinSpecifique}besoinsSpecifiques;
{string}listBesoinsSpecifiques[0..10];

tuple Indemnite {
	int indemniteJournaliere;
	int indemniteDeplacement;
	int indemniteSejour;
	{string}personnels;
}
{Indemnite}indemnites;
{string} listPersonnelsIndemnites[0..30];


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
	getSalles(donnees,salles);
	getBesoins(donnees,besoinsSpecifiques,listBesoinsSpecifiques);
	getIndemnites(donnees,indemnites,listPersonnelsIndemnites);
}

/************************************************************************
* Prétraitement sur les données de l'instance (si besoin)
************************************************************************/
 
{string} codeDeSession = {s.idSession | s in sessions};
{string} codeDeBloc = {b.idBloc | b in blocs};
{string} codeDeSalle = {s.idSalle | s in salles};
int dureeMinimaleSession = min(s in sessions)s.duree;
int dureeMaximaleSession = max(s in sessions)s.duree;
int nbSalles = max (s in salles)s.numSalle;
int coutMaximal;


{string} intervenantsDuBloc[codeDeBloc];//recupere tout les intervenants interne au bloc
{string} blocDuBloc[codeDeBloc];//contient les blocs se situant dans le bloc
{string} temp1[codeDeBloc]; // permet la modification de intervenantsDuBloc

{string} intervenantsDeSession[codeDeSession];//recupere tout les intervenants à la session
{int} sessionIndisponibleClient[codeDeSession];//recupere pour chaque session ses indisponibilités en créneaux pour les intervenants
{string}intervenants;//recupere tout les intervenants de l'instance

{string} sessionIntervenant[intervenants];//donne toute les sessions auquel participe l'intervenant

string salleDeSession[codeDeSession];//donne pour chaque session la salle ou elle doit avoir lieu

int nbPersonnesSessions[codeDeSession];

{int} indisponibiliteSalle[codeDeSalle];//recupere pour chaque session ses indisponibilités en créneaux pour les salles
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
	// nombre de personne dans une session
	for (s in sessions){
		var cpt =0;
		for (i in intervenantsDeSession[s.idSession]){
			cpt++;
		}
		nbPersonnesSessions[s.idSession]=cpt;
	}
	
	//Indisponibilté des salles
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
	//calcul du max d'indemnité possible meme si avoir ce cout est impossible
	coutMaximal=0;
	for(s in sessions){
		for (i in intervenantsDeSession[s.idSession]){
			for (ind in indemnites){
				for(inter in ind.personnels){
					if(inter == i){
						if(ind.indemniteDeplacement>=ind.indemniteSejour){
							coutMaximal = (coutMaximal+ind.indemniteJournaliere+ind.indemniteDeplacement);
						}else{
							coutMaximal = (coutMaximal+ind.indemniteJournaliere+ind.indemniteSejour);
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

dvar int couttotal in 0..coutMaximal;
dvar int debutSession[codeDeSession] in 0..((nbJoursMax*nbCreneauxMaxParJour) - dureeMinimaleSession);
dvar int finSession[codeDeSession] in dureeMinimaleSession..nbJoursMax*nbCreneauxMaxParJour;
dvar int salleSession[codeDeSession] in 1..nbSalles; 
dvar int indemniteParSession[intervenants][codeDeSession] in 0..coutMaximal;
/************************************************************************
* Contraintes du modèle 					(NB : ne peut être mutualisé)
************************************************************************/
minimize 
	couttotal;
subject to {
	//////////////////////////// Gestion Employés et jours/créneaux//////////////////////////////////
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
	//un intervenant ne doit pas etre a deux endroits en même temps
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
	//Gestion des Indemnités
	couttotal == sum(i in intervenants, cds in codeDeSession) indemniteParSession[i][cds];
	
	//calcul des couts
	forall(i in intervenants){
		forall(s1 in sessionIntervenant[i],s2 in sessionIntervenant[i] :s1!=s2){
			forall (indem in indemnites){
				forall(i2 in indem.personnels){
					if(i==i2){
						((debutSession[s1]div nbCreneauxMaxParJour)-(debutSession[s2]div nbCreneauxMaxParJour)==1 &&  indemniteParSession[i][s1] >= indem.indemniteJournaliere+indem.indemniteSejour)
						||((debutSession[s1]div nbCreneauxMaxParJour)-(debutSession[s2]div nbCreneauxMaxParJour)>1 &&  indemniteParSession[i][s1] >= indem.indemniteJournaliere+indem.indemniteDeplacement)
						||((debutSession[s1]div nbCreneauxMaxParJour)-(debutSession[s2]div nbCreneauxMaxParJour)==0 && indemniteParSession[i][s1] >= indem.indemniteJournaliere)
						||((debutSession[s1]div nbCreneauxMaxParJour)-(debutSession[s2]div nbCreneauxMaxParJour)<0);
					}
				}
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
	writeln(couttotal);
	var resultat = new Array();
	resultat[resultat.length] = nom+"_planning3.res";
	for (s in codeDeSession){
		for(sa in salles ){ 
			if(sa.numSalle==salleSession[s]){
				resultat[resultat.length] = "planning <"+s+"> <"+parseInt(debutSession[s]/ nbCreneauxMaxParJour)+"> <"+(parseInt(debutSession[s])-(parseInt(debutSession[s]/ nbCreneauxMaxParJour)*nbCreneauxMaxParJour)+1)+"> <"+sa.idSalle+">" ;
			}
		}
	}	
	resultat[resultat.length]="couttotal"+couttotal
	for(var i =0; i<resultat.length;i++){
		writeln(resultat[i]);
	}
	
	ecrireResultat(resultat);
}

