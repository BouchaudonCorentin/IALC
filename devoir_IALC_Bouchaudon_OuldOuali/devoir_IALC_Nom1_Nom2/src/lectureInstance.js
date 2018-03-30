/************************
* Devoir IALC 2017-18 - M1 Miage App 
* Binome : Nom1 Nom2 	(TODO)
*
* Fonctions de script utiles pour la lecture des fichiers d'instance
************************/

// NB comme pour n'importe quel langage de programmation, pour faciliter la 
// lisibilité de votre code, n'hésitez pas à le décomposer en plusieurs 
// fonctions

/* TODO */

function getJours(){
	var fin = new IloOplInputFile("../donneesInstances/bourgeois/cal-23-4.txt");
	if (fin.exists){
		var s;
		var jours;
		while (!fin.eof){
			s=fin.readline();
			coupe= s.split("	");
			if (coupe[0]=='jours'){			
				jours = parseInt(coupe[1]);				
			}
		}
		fin.close();
	}else {
		writeln("fichier n'existe pas");
	}
	return jours;
}
function getCreneaux(){
	var fin = new IloOplInputFile("../donneesInstances/bourgeois/cal-23-4.txt");
	if (fin.exists){
		var s;
		var creneaux;
		while (!fin.eof){
			s=fin.readline();
			coupe= s.split(" ");
			if (coupe[0]=='creneaux'){			
				creneaux = parseInt(coupe[1]);			
			}
		}
		fin.close();
	}else {
		writeln("fichier n'existe pas");
	}
	return creneaux;
}

