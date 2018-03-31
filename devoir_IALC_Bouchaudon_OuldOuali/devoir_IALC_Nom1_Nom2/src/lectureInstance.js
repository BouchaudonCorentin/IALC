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

function isEspace(lettreOuSymbole){
	var espaces = new Array(9, 10, 11, 12, 13, 32, 133, 160);
	for(var i = 0; i < espaces.length; i++){
		if(lettreOuSymbole == espaces[i]){
			return true;
		}
	}
	return false;
}

	
