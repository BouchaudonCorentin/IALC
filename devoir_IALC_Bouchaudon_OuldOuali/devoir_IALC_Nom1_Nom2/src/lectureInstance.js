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
function getBlocs(donnees, blocs){
	var blocsIn; //blocs dans bloc
	var cpt =0;
	for (var i = 0; i<donnees.length;i++){
			blocsIn = new Array();
			if(donnees[i][0] == "bloc") {
				for (j = 2; j<donnees.length;j++){
					if(donnees[i][j]!=null){
						blocsIn[j-2]=donnees[i][j];
					}
				}
				blocs.add(donnees[i][1],blocsIn);
				cpt++;
			}
	}
	
}
function getSessions(donnees, sessions){
	var intervenants; //blocs dans bloc
	var cpt =0;
	for (var i = 0; i<donnees.length;i++){		
			intervenants = new Array();
			if(donnees[i][0] == "session") {
				for (j = 3; j<donnees.length;j++){
					if(donnees[i][j]!=null){
						intervenants[j-3]=donnees[i][j];
					}
				}
				sessions.add(donnees[i][1],donnees[i][2],intervenants);
				cpt++;
			}
	}
	
}
function getPrecedes(donnees, precedes){
	for (var i = 0; i<donnees.length;i++){	
			if(donnees[i][0] == "precedes") {
				sessions.add(donnees[i][1],donnees[i][2],parseInt(donnee[i][3]));				
			}
	}
	
}
function getIndisponibles(donnees, indisponibles){//a refaire fonction bidon 
    for(var i = 0; i < donnees.length; i++){
		var joursnondisponible = new Array();
		var intervallenondisponible =new Array();
		var creneauxnondisponible = new Array();
		var joursindispo = new Array();
		var sansvirgule =new Array()
		if(donnees[i][0] == "indisponible"){			
			joursindispo = sansvirgule(donnees[i][2]);								
			for (var j =0; j < joursindispo.length;j++){
				if(joursindispo[j].indexOf("-")!=-1){
					joursnondisponible.add(joursindispo[i]);
				}else{
					intervallenondisponible= joursindispo.split("-");
					for (k = parseInt(intervallenondisponible[0]);k<parseInt(intervallenondisponible[1]);k++){
						joursnondisponible.add(k);
					}
				}
			}					
			if(donnees[i].length>3){				
				for (var j =4; j<donnees.length;j++){
					writeln("test");
					creneauxnondisponible.add(parseInt(donnees[j]));
				}						
			}
			
		}
		//indisponibles.add((donnees[i][1]),joursnondisponible,creneauxnondisponible);
	}	
}
function sansvirgule(ligne){
	var lignesansvirgule = new Array();
	var cpt=0;
	for (var i = 0; i < ligne.length; i++){
		if(ligne[i] == ","){ 
			lignesansvirgule[lignesansvirgule.length] = ligne.substring(debutMot, i);
			debutMot = i + 1;
		}
	}
	return lignesansvirgule;
}
