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

function supprimerEspaces(information){
	var infosansEspace = new Array();
	var debutMot = 0;
	information += " ";
	var i = 0
	for (; i < information.length; i++){
		if(isEspace(information.charCodeAt(i))){
			infosansEspace[infosansEspace.length] = information.substring(debutMot, i);
			while(i < information.length && isEspace(information.charCodeAt(++i)));// a modifier
			debutMot = i;
		}
	}
	return infosansEspace;
}

function isEspace(chara){
	var espaces = new Array(9, 10, 11, 12, 13, 32, 133, 160);
	for(var i = 0; i < espaces.length; i++){
		if(chara == espaces[i]){
			return true;
		}
	}
	return false;
}

function getJours(donnees){
	for (var i = 0; i < donnees.length; i++){
		if(donnees[i][0] == "jours"){
			return donnees[i][1];
		}
	}
	return -1;	
}
function getCreneaux(donnees){
        for (var i = 0; i < donnees.length; i++){
                if(donnees[i][0] == "creneaux") { 
					return donnees[i][1];
				}
        }
        return -1;
}
function getBlocs(donnees, blocs, blocsIn){
	var cpt =0;
	for (var i = 0; i<donnees.length;i++){
			if(donnees[i][0] == "bloc") {
				for (j = 2; j<donnees[i].length;j++){
					if(donnees[i][j]!=null){
						blocsIn[cpt].add(donnees[i][j]);						
					}
				}
				blocs.add(donnees[i][1],blocsIn[cpt]);
				cpt ++
			}
	}
	
}
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
function getPrecedes(donnees, precedes){
	for (var i = 0; i<donnees.length;i++){
			if(donnees[i][0] == "precede") {
			  if(donnees[i].length>3){
			     precedes.add(donnees[i][1],donnees[i][2],parseInt(donnees[i][3]));			
			  }else{
			  	precedes.add(donnees[i][1],donnees[i][2],0);				
			  }
	    }
	
  }
}
function getIndisponibles(donnees, indisponibles, listJours, listCreneaux){//obliger de mettre list jours et list creneaux car sans je n'arrivais pas à retourner le tuple
	var cpt =0.
    for(var i = 0; i < donnees.length; i++){
		var joursindispo=new Array();;//recupere le split pour les jours indispo			
		if(donnees[i][0] == "indisponible"){		
			joursindispo = (donnees[i][2]).split(",");	
			for (var j=0; j<joursindispo.length;j++){ 
				var sanstiret = (joursindispo[j]).split("-");
				if (sanstiret.length!=1){
					for (k = parseInt(sanstiret[0]);k<=parseInt(sanstiret[1]);k++){
						listJours[cpt].add(k);		
					}
				}else{
					listJours[cpt].add(parseInt(sanstiret[0]));
				}
			}	
			if((donnees[i]).length>3){
				for (var j =3; j<(donnees[i]).length;j++){
					listCreneaux[cpt].add(parseInt(donnees[i][j]));
				}						
			}else{
				listCreneaux[cpt].add(0);
			}
			indisponibles.add(donnees[i][1],listJours[cpt],listCreneaux[cpt]);
			cpt++;
		}

	}	
}

function getIntervenants(blocs, listbloc, listIntervenants){
	for (b in blocs){
		for(b2 in listbloc){
				if(b2==b.idBloc){					
					getIntervenants(blocs, b.intervenants,listIntervenants);
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

function ecrireResultat(resultat){
	var fichier = new IloOplOutputFile("../resultats/" + resultat[0]);
	for (var i = 0; i < resultat.length; i++){
		fichier.writeln(resultat[i]);
	}
	fichier.close();	
}