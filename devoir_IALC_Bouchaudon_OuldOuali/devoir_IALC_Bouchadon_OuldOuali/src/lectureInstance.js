/************************
* Devoir IALC 2017-18 - M1 Miage App 
* Binome : Bouchaudon OuldOuali 	
*
* Fonctions de script utiles pour la lecture des fichiers d'instance
************************/

// NB comme pour n'importe quel langage de programmation, pour faciliter la 
// lisibilité de votre code, n'hésitez pas à le décomposer en plusieurs 
// fonctions

/* TODO */
// Fconction qui récupère les données depuis le fichier de données
// les stocke dans un tableau de String
// et retourne ce tableau
function recupererDonnees(fichiersDonnees){
	var fichier = new IloOplInputFile();
	var informations = new Array();
	var i=0;
	for (donnee in fichiersDonnees){
		fichier.open(donnee);
		if(fichier.isOpen){
			while(!fichier.eof){
				informations[i++]=fichier.readline();
			}
		}else{
			writeln("problème avec un fichier");
		}
	}
	return informations;
	
}

//supprime les espaces qui se trouve dans une ligne et la sépare en plusieurs string contenant les informations
function supprimerEspaces(information){
	var infosansEspace = new Array();
	var debutMot = 0;
	information += " ";
	for (i = 0; i < information.length; i++){
		if(isEspace(information.charCodeAt(i))){//verifie si le caractere est un espace
			infosansEspace[infosansEspace.length] = information.substring(debutMot, i);
			while(i < information.length && isEspace(information.charCodeAt(++i)));
			debutMot = i;
		}
	}
	return infosansEspace;
}

//recherche les différents types d'espace
function isEspace(chara){
	var espaces = new Array(9, 11,32);//ensemble des caractere pertinents pour le projet, si le metteur en scene decide d'ajouter d'autre type d'espace ou de caractere
	                                  //il a juste a ajouter leurs codes ascii dans cet Array
	for(var i = 0; i < espaces.length; i++){
		if(chara == espaces[i]){
			return true;
		}
	}
	return false;
}

//retourne le nombre de jours dont dispose le metteur en scene
function getJours(donnees){
	for (var i = 0; i < donnees.length; i++){
		if(donnees[i][0] == "jours"){
			return donnees[i][1];
		}
	}
	return -1;	
}

//retourne le nombre de creneaux par jour.
function getCreneaux(donnees){
        for (var i = 0; i < donnees.length; i++){
                if(donnees[i][0] == "creneaux") { 
					return donnees[i][1];
				}
        }
        return -1;
}

//remplie le tableau de tuple passer en commentaire par les données recuperer dans donnees
function getBlocs(donnees, blocs, blocsIn){
	var cpt =0;
	for (var i = 0; i<donnees.length;i++){
			if(donnees[i][0] == "bloc") {//si la ligne commence par "bloc"" c'est qu'il s'agit d'un bloc
				for (j = 2; j<donnees[i].length;j++){
					if(donnees[i][j]!=null){
						blocsIn[cpt].add(donnees[i][j]);//remplie le tableau de string passer en commentaire						
					}
				}
				blocs.add(donnees[i][1],blocsIn[cpt]);//ajoute les valeurs de ce tuple dans le tableau de tuple
				cpt ++
			}
	}
	
}
//idem que get Bloc mais avec sessions
function getSessions(donnees, sessions, listSessions){ 
	var cpt=0;
	for (var i = 0; i<donnees.length;i++){	
			if(donnees[i][0] == "session") {
				for (j = 3; j<donnees.length;j++){
					if(donnees[i][j]!=null){
						listSessions[cpt].add(donnees[i][j]);
					}
				}
				sessions.add(donnees[i][1],donnees[i][2],listSessions[cpt]);
				cpt++;
			}
	}
	
}

//légèrement different que bloc et session
function getPrecedes(donnees, precedes){
	for (var i = 0; i<donnees.length;i++){
			if(donnees[i][0] == "precede") {
			  if(donnees[i].length>3){
			     precedes.add(donnees[i][1],donnees[i][2],parseInt(donnees[i][3]));// si le nombre de jours entre session1 et session2 est renseigné			
			  }else{
			  	precedes.add(donnees[i][1],donnees[i][2],0);//sinon
			  }
	    }
	
  }
}

//retourne les indisponibilités intervenants et salles
function getIndisponibles(donnees, indisponibles, listJours, listCreneaux){
    var cpt =0;
    for(var i = 0; i < donnees.length; i++){
		var joursindispo=new Array();;//recupere le split pour les jours indispo			
		if(donnees[i][0] == "indisponible"){		
			joursindispo = (donnees[i][2]).split(",");	//split la string contenant les jours 
			for (var j=0; j<joursindispo.length;j++){ //pour le nombre de string créé par le spit
				var sanstiret = (joursindispo[j]).split("-");
				if (sanstiret.length!=1){// s'il s'agissait d'un intervalle
					for (k = parseInt(sanstiret[0]);k<=parseInt(sanstiret[1]);k++){
						listJours[cpt].add(k);		
					}
				}else{//sinon
					listJours[cpt].add(parseInt(sanstiret[0]));
				}
			}	
			if((donnees[i]).length>3){//si on indique les créneaux qui sont indisponible par jour
				for (var j =3; j<(donnees[i]).length;j++){
					listCreneaux[cpt].add(parseInt(donnees[i][j]));
				}						
			}else{
				listCreneaux[cpt].add(0);//sinon
			}
			indisponibles.add(donnees[i][1],listJours[cpt],listCreneaux[cpt]);
			cpt++;
		}

	}	
}

//retourne les intervenants participant au bloc. Si le participant est un bloc alors recursivité
function getIntervenants(blocs, listbloc, listIntervenants){
	for (b in blocs){
		for(b2 in listbloc){
				if(b2==b.idBloc){					
					getIntervenants(blocs, b.intervenants,listIntervenants);//si intervenant est un bloc
				}else{		
					for(i2 in b.intervenants){
						if(b2==i2){
							listIntervenants.add(i2);
						}
					}
				}
		}
	}	
}


//permet d'écrire les résultats dans un fichier se trouvant dans le repertoire resultats du projet
function ecrireResultat(resultat){
	var fichier = new IloOplOutputFile("../resultats/" + resultat[0]);//nom du fichier X(mod)_Y(dat).res
	for (var i = 0; i < resultat.length; i++){
		fichier.writeln(resultat[i]);
	}
	fichier.close();	
}

//retourne les salles du projet
function getSalles(donnees, salles){
	var cpt =0;
	for (var i = 0; i<donnees.length;i++){
		if(donnees[i][0] == "salle") {//si la ligne commence par salle alors 
			salles.add(cpt+1,donnees[i][1],parseInt(donnees[i][2]));//on ajoute a salles
			cpt++;
	    }	
	}	
}

//retourne les besoins spécifiques des sessions (en salle);
function getBesoins(donnees,besoinsSpecifiques,listBesoinsSpecifiques){
	var cpt=0;
	for (var i = 0; i<donnees.length;i++){	
		if(donnees[i][0] == "besoinSpecifique") {// si la session à un besoin spécifique
			for (j = 2; j<donnees.length;j++){
				if(donnees[i][j]!=null){
					listBesoinsSpecifiques[cpt].add(donnees[i][j]);
				}
			}
			besoinsSpecifiques.add(donnees[i][1],listBesoinsSpecifiques[cpt]);
			cpt++;
		}
	}
	
}


//retourne les indemnites des intervenants
function getIndemnites(donnees, indemnites, listPersonnelsIndemnites){
	var cpt =0;
	for(var i=0;i<donnees.length;i++){
		if(donnees[i][0]=="indemnite"){// si ligne commence par indemnité
			for(var j =4;j <donnees[i].length;j++){
				if(donnees[i][j]!=null){
					listPersonnelsIndemnites[cpt].add(donnees[i][j]);
				}
			}
			indemnites.add(donnees[i][1],donnees[i][2],donnees[i][3],listPersonnelsIndemnites[cpt]);
			cpt++			
		}		
	}	
}