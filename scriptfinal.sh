#!/bin/bash
######################################
# Nom du script : scriptfinal.sh
# Utilité: ce script sert à comparer deux arborescences 
# Usage: bash scriptfinal.sh $1 $2 (les premiers et deuxièmes paramètres sont les noms des dossiers contenant les fichiers qu'on veut comparer)
# Auteurs: BOUHENAF Irfan DUHAMEL Andréa TALBI Mohamed Lamine
# Mise à jour le: 15/12/2019
######################################
 
#------------------Déclarations variables--------------------#
rouge='\e[0;31m'
neutre='\e[0;m'
bleu='\e[0;36m'
vert='\e[0;32m'
jaune='\e[0;33m'
violet='\e[1;35m'
titre='\e[1;7m'
grasul='\e[1;4m'
arbo1=$1
arbo2=$2
#------------------Déclaration fonctions--------------------#
#Fonction qui calcule les empreintes md5 des dossiers
function md5dossier
{
	find $1 -type f -exec md5sum {} \; >> temp.txt
	while read ligne 
	do
		cheminfichier=`echo $ligne | cut -d" " -f2`
		md5fichier=`echo $ligne | cut -d" " -f1`
		nomfichier=`basename "$cheminfichier"`
		echo $md5fichier $nomfichier > temp2.txt
	done < temp.txt
	find $1 -type d -exec basename {} \; | sed "1d" >> temp2.txt
}
#Fonction qui compte les empreintes md5 des fichiers mais aussi des répertoires
function comptemd5
{
	empreintemd5=`cat md5 | cut -d ' ' -f1 | sort -u`
	compteempreintemd5=`cat md5 | cut -d ' ' -f1 | sort -u | wc -l`
    echo -e "\n""${jaune}Voici les empreintes md5 des fichiers présente dans les arborescences ${neutre}${violet}$arbo1${neutre} ${jaune}et${neutre} ${violet}$arbo2${neutre}"
	echo -e "\n""$empreintemd5"
    echo -e "\n""${jaune}Il y a donc ${neutre}$compteempreintemd5 ${jaune}empreintes md5 de fichiers différentes dans les arborescences${neutre} ${violet}$arbo1${neutre} ${jaune}et${neutre} ${violet}$arbo2${neutre} "   
	empreintemd52=`cat md5arbod | cut -d ' ' -f1 | sort -u`
	compteempreintemd52=`cat md5arbod | cut -d ' ' -f1 | sort -u | wc -l`
    echo -e "\n""${jaune}Voici les empreintes md5 des répertoires présente dans les arborescences ${neutre}${violet}$arbo1${neutre} ${jaune}et${neutre} ${violet}$arbo2${neutre}"
	echo -e "\n""$empreintemd52"
     echo -e "\n""${jaune}Il y a donc ${neutre}$compteempreintemd52 ${jaune}empreintes md5 de répertoires différentes dans les arborescences${neutre} ${violet}$arbo1${neutre} ${jaune}et${neutre} ${violet}$arbo2${neutre} "     
}
#Fonction qui affiche les arborescences + calcule empreinte md5 fichiers + définition md5dossier
function arbo
{
	find $1 | sed "1d" > temp
	while read ligne
	do
		if test -d $ligne
		then
			echo -e "$ligne est un ${bleu}répertoire${neutre}"
			chemin="$ligne"
			md5dossier $ligne
			md5d=`md5sum temp2.txt`
			md5seul=`echo $md5d | cut -d" " -f1`
			md5n=`basename $chemin`
			echo "$md5seul  $1/$md5n" >> md5arbod
			echo "$md5seul  $1/$md5n" | sort -n >> $3
		else
			echo -e "$ligne est un ${vert}fichier${neutre}"
			md5sum $ligne | sort -n >> $2
			md5sum $ligne >> md5
		fi
done < temp
rm -f temp
}
#Fonction qui affiche le decompte avant le début du script
function decompte
{
	z=5
	while [ $z -ge 0 ]
	do
		echo -e "\r""Lancement du programme dans ${violet}$z secondes ${neutre}""\c"
		sleep 1
		z=$(($z - 1))	
	done
	echo -e "\n""${rouge}C'est parti !${neutre}"
	sleep 1
	echo -e "\n"
}
#Fonction qui compare les lignes entre deux fichiers les répertoires uniques dans chaque arborescence
function diffligne
{
	fgrep -vf $1 $2 | sort -u > temp5
	while read ligne
	do
		compte=`echo $ligne | cut -d ' ' -f1`
		path=`echo $ligne | cut -d ' ' -f2`	
		while read ligne2 
		do
			if [ "$compte" == "$ligne2" ]
			then
				echo -e "\n"
				echo -e "${jaune}Son empreinte md5 :${neutre} $compte"
				echo -e "${jaune}Son chemin :${neutre} $path" 
				echo -e "${jaune}Son nom :${neutre} $(basename $path)"
				echo "$path" >> temp7
				compteligne2=`cat temp7 | wc -l`
			fi
		done < temp5
	done < $3
	if [[ $compteligne2 -eq 0 ]]
	then
		echo -e "\n""${jaune}Il y a ${neutre}0 ${jaune}$4 uniques dans cette arborescence${neutre}"
	else	
		echo -e "\n""${jaune}Il y a ${neutre}$compteligne2 ${jaune}$4 uniques dans cette arborescence${neutre}"
	fi
	rm -f temp5
	rm -f temp7
}
#Fonction qui compare les lignes entre deux fichiers les répertoires uniques dans chaque arborescence avec leur chemin absolu
function diffligne2
{
	fgrep -vf $1 $2 | sort -u > temp6
	while read ligne
	do
		compte=`echo $ligne | cut -d ' ' -f1`
		while read ligne2 
		do
			nomfichrep=`echo $ligne | cut -d ' ' -f2`
			absolu=`readlink -f $nomfichrep`
			if [ "$compte" == "$ligne2" ]
			then
				echo "$absolu"
				echo "$absolu" >> temp8
				compteligne3=`cat temp8 | wc -l`
			fi
		done < temp6
	done < $3
	if [[ $compteligne3 -eq 0 ]]
	then
		echo -e "\n""Il y a 0 $4 uniques dans cette arborescence"
	else
		echo -e "\n""Il y a $compteligne3 $4 uniques dans cette arborescence"
	fi
	rm -f temp6
	rm -f temp8
}
#Fonction qui définit deux autres fonctions et on rajoute du texte pour pouvoir afficher tout ça dans un fichier
function diffligneabsolu
{
	echo "Affichage des fichiers uniques de $arbo1"
	diffligne2 md5arbo2f md5arbo1f md5 fichiers
	echo "Affichage des fichiers uniques de $arbo2"
	diffligne2 md5arbo1f md5arbo2f md5 fichiers
	echo -e "\n"
	echo "Affichage des répertoires uniques de $arbo1" 
	diffligne2 md5arbo2df md5arbo1df md5arbod répertoires 
	echo "Affichage des répertoires uniques de $arbo2" 
	diffligne2 md5arbo1df md5arbo2df md5arbod répertoires
}
#Fonction qui permet d'utliser les bons paramètres
function conditionparam
{
		if ! test -r $arbo1 || ! test -r $arbo2
			then
				if ! test -r $arbo1
				then
					echo -e "L'arborescence ${violet}$arbo1${neutre} est invalide, voulez vous continuer ? (${jaune}O${neutre}ui ou ${jaune}N${neutre}on ?)"
					read reponse
				elif ! test -r $arbo2
				then
					echo -e "L'arborescence ${violet}$arbo2${neutre} est invalide, voulez vous continuer ? (${jaune}O${neutre}ui ou ${jaune}N${neutre}on ?)"
					read reponse
				fi	
				until [ "$reponse" == 'Oui' ] || [ "$reponse" == 'Non' ]
				do
					while [ "$reponse" == 'oui' ] || [ "$reponse" == 'non' ]
					do
						echo -e "Il faut mettre la première lettre en ${rouge}MAJUSCULES${neutre}!"
						read reponse
					done
					if [ "$reponse" != 'Oui' ] && [ "$reponse" != 'Non' ]
					then
						echo -e "Les réponses valides sont ${jaune}Oui${neutre} et ${jaune}Non${neutre}, recommencez s'il vous plaît"
						read reponse
					fi
				done
				if [ "$reponse" == 'Oui' ] && ! test -r $arbo1
				then
					echo "Rentrez l'arborecence n°1"
					read arbo1
				elif [ "$reponse" == 'Oui' ] && ! test -r $arbo2
				then
					echo "Rentrez l'arborecence n°2"
					read arbo2
				fi
				if [ "$reponse" == 'Non' ]
				then
					 echo -e "${rouge}FIN DU PROGRAMME${neutre}"
					exit
				fi
			
		fi
}
#-Début du script, on affiche l'heure, l'utilité de ce script, etc.#
echo -e "${titre}Bonjour, ce script sert a comparer deux arborescences${neutre}"
echo -e "Le script s'est lancé le ${grasul}$(date +"%d/%m/%Y à %Hh%M")${neutre}"
echo -e "le nom du système d'exploitation de la machine est ${grasul}$(uname)${neutre}"
echo -e "La version de la machine est ${grasul}$(lsb_release -ds)${neutre}"
echo -e "${rouge}Verification des paramètres${neutre}"
#--------------Verification-du-nombre-de-paramètres----------------#
#----------------+-regarde-si-ils-sont-identiques------------------#
if test $# -eq 2
	then
		echo -e "\n""Il y a deux paramètres"
		conditionparam
	else
		echo  "\n""Il n'y a pas deux paramètres"
		if test $# -eq 1
		then
			echo "Veuillez entrer le deuxième paramètre :"
			read arbo2
			conditionparam
			
		fi
		if test $# -eq 0
		then
			echo "Rentrez l'arborecence n°1"
			read arbo1
			echo "Rentrez l'arborecence n°2"
			read arbo2
			conditionparam
		fi
	
fi

if [ "$arbo1" = "$arbo2" ] 
then
	echo "Les 2 arborescences sont identiques"
	echo "Rentrez l'arborecence n°1"
	read arbo1
	echo "Rentrez l'arborecence n°2"
	read arbo2
fi
#----------------Verification de la première arborescence-----------------#
arbo1valide=0
if test -d $arbo1
	then
		if test -r $arbo1
		then
			echo "La première arborescence est un dossier valide"
			arbo1valide=1
		else
			echo "La première arborescence n'est pas un dossier valide"
			arbo1valide=0
		fi
	else
		echo "La premiere arborescence n'est pas un dossier"
		arbo1valide=0
fi
#----------------Verification de la deuxième arborescence-----------------#
arbo2valide=0
if test -d $arbo2
	then
		if test -r $arbo2
		then
			echo "La deuxieme arborescence est un dossier valide"
			arbo2valide=1
		else
			echo "La deuxième arborescence n'est pas un dossier valide"
			arbo2valide=0
		fi
	else
		echo "La deuxieme arborescence n'est pas un dossier"
		arbo2valide=0
fi
#----------------Si une arborescence est invalide--> exit-----------------#
if  [ $arbo1valide -eq 0 ] || [ $arbo2valide -eq 0 ]
	then 
		echo -e "${rouge}FIN DU PROGRAMME${neutre}"
		exit
fi
#-----------Affiche d'une phrase si les arbos sont corrects----------------#
if test -r $arbo1 && test -r $arbo2
then
	echo -e "${rouge}Vérification terminée${neutre}"
fi
#----------------------Définition fonctions + programme principal-------------------------------#
decompte
echo -e "${rouge}Lecture des contenus de ${violet}$arbo1${neutre} ${rouge}et${neutre} ${violet}$arbo2${neutre}${neutre}"
arbo $arbo1 md5arbo1 md5arbo1d  && arbo $arbo2 md5arbo2 md5arbo2d
echo -e "${rouge}Lecture terminée${neutre}"
#On enlève les chemins des fichiers pour garder que leurs empreintes
cat md5arbo1 | cut -d ' ' -f1 > md5arbo1f
cat md5arbo2 | cut -d ' ' -f1 > md5arbo2f	
cat md5 | cut -d ' ' -f1 | sort -u > md5arbo
cat md5arbod | cut -d ' ' -f1 | sort -u > md5rep
i=0
#Affiche les fichiers selon leur empreinte md5
for ligne in $(cat md5arbo)
do
	i=$(($i+1))
	lireligne=`head -$i md5arbo | tail -1 `
	liste=`grep $lireligne md5 | cut -d ' ' -f1` 
	truc=`grep $lireligne md5 | cut -d ' ' -f3-4`
	echo -e "\n"
	echo -e "${jaune}Les fichiers ayant l'empreinte md5 ${neutre}$(echo $liste | cut -d ' ' -f1) ${jaune} sont :${neutre} \n$truc"
done
j=0
echo -e "\n"
#Affiche les répertoires selon leur empreinte md5
for ligne in $(cat md5rep)
do
	j=$(($j+1))
	lireligne2=`head -$j md5rep | tail -1 `
	liste2=`grep $lireligne2 md5arbod | cut -d ' ' -f1` 
	truc2=`grep $lireligne2 md5arbod | cut -d ' ' -f3-4`
	echo -e "\n"
	echo -e "${jaune}Les répertoires ayant l'empreinte md5 ${neutre}$(echo $liste2 | cut -d ' ' -f1)${neutre}${jaune} sont :${neutre} \n$truc2"
done
comptemd5
#On affiche les fichiers et répertoires de arbo A qui sont différents de arbo B et inversement
fgrep -vf md5arbo2f md5arbo1f > md5uniq
fgrep -vf md5arbo1f md5arbo2f >> md5uniq
cat md5arbo1d | cut -d ' ' -f1 > md5arbo1df
cat md5arbo2d | cut -d ' ' -f1 > md5arbo2df
fgrep -vf md5arbo2df md5arbo1df > md5arbouniq
fgrep -vf md5arbo1df md5arbo2df >> md5arbouniq
cat md5uniq | sort -u > md5uniqf && rm -f md5uniq
#On affiche les fichiers et répertoires de arbo A qui sont communs de arbo B et inversement
fgrep -f md5arbo2f md5arbo1f > md5uniq2
fgrep -f md5arbo1f md5arbo2f >> md5uniq2
cat md5uniq2 | sort -u > md5uniq2f && rm -f md5uniq2
fgrep -f md5arbo2df md5arbo1df > md5arbouniq2
fgrep -f md5arbo1df md5arbo2df >> md5arbouniq2
cat md5arbouniq2 | sort -u > md5arbouniq2f
#Condition si les arborescences sont différentes
if [ "$(md5sum md5arbo1f | cut -d ' ' -f1)" != "$(md5sum md5arbo2f | cut -d ' ' -f1)" ]
then
	#On affiche les fichiers et répertoires uniques pour chaque arborescence
	echo -e "\n""${rouge}Affichage des fichiers uniques de $arbo1${neutre}"
	diffligne md5arbo2f md5arbo1f md5 fichiers
	echo -e "\n""${rouge}Affichage des répertoires uniques de $arbo1${neutre}"
	diffligne md5arbo2df md5arbo1df md5arbod répertoires
	echo -e "${rouge}Affichage des fichiers uniques de $arbo2${neutre}"
	diffligne md5arbo1f md5arbo2f md5 fichiers
	echo -e "${rouge}Affichage des répertoires uniques de $arbo2${neutre}"
	diffligne md5arbo1df md5arbo2df md5arbod répertoires
	echo -e "${rouge}Affichage terminée${neutre}"
	#On crée un fichier texte où on affiche les fichiers et répertoires uniques pour chaque arborescence
	diffligneabsolu > ficdiffpath.txt
	#Boucles qui affiche les fichiers différents entre deux arborescences et on met ça dans un fichier
	#+ On affiche leur nombre
	while read ligne
	do
		compte2=`echo $ligne | cut -d ' ' -f1`
		while read ligne2 
		do
			if [ "$compte2" == "$ligne2" ]
			then
				echo $ligne >> differents
			fi
		done < md5uniqf
	done < md5
	cat differents | cut -d ' ' -f2 > differentsf
	echo -e "\n""${vert}Il y a ${neutre}$(cat differentsf | wc -l) ${vert}fichiers différents sur ${neutre}$(cat md5 | wc -l) ${vert}fichiers au total ${neutre}( voir fichier differentsf )"
	#Boucles qui affiche les répertoires différents entre deux arborescences et on met ça dans un fichier
	#+ On affiche leur nombre
	while read ligne
	do
		compte4=`echo $ligne | cut -d ' ' -f1`
		while read ligne2 
		do
			if [ "$compte4" == "$ligne2" ]
			then
				echo $ligne >> diffarbo
			fi
		done < md5arbouniq
	done < md5arbod
	cat diffarbo | cut -d ' ' -f2 > diffarbof && rm -f diffarbo
	echo -e "\n""${vert}Il y a ${neutre}$(cat md5arbouniq | wc -l) ${vert}répertoires différents sur ${neutre}$(cat md5arbod | wc -l) ${vert}répertoires au total ${neutre} ( voir fichier diffarbof )"
fi
#C'est pareil que précédemment sauf qu'on affiche les fichiers puis répertoires communs
#+ Cela s'affiche que si il y a des fichiers ou  répertoires communs
if [ $(cat md5uniq2f | wc -l) -ne 0 ]
then
	while read ligne
	do
		compte3=`echo $ligne | cut -d ' ' -f1`
		while read ligne2 
		do
			if [ "$compte3" == "$ligne2" ]
			then
				echo $ligne >> unique
			fi
		done < md5uniq2f
	done < md5
	cat unique | cut -d ' ' -f2 > uniquef
	echo -e "\n""${vert}Il y a ${neutre}$(cat uniquef | wc -l) ${vert}fichiers communs sur ${neutre} $(cat md5 | wc -l) ${vert}fichiers au total ${neutre} ( voir fichier uniquef )"
else
	rm -f uniqf 2>dev/null
fi
if [ $(cat md5arbouniq2f | wc -l) -ne 0 ]
then
	while read ligne
	do
		compte5=`echo $ligne | cut -d ' ' -f1`
		while read ligne2 
		do
			if [ "$compte5" == "$ligne2" ]
			then
				echo $ligne >> communarbo
			fi
		done < md5arbouniq2f
	done < md5arbod
	cat communarbo | cut -d ' ' -f2 > communarbof
	echo -e "\n""${vert}Il y a ${neutre}$(cat md5arbouniq2 | wc -l) ${vert}répertoires communs sur ${neutre} $(cat md5arbod | wc -l) ${vert}répertoires au total ${neutre} ( voir fichier communarbof )"
else
	rm -f communarbof 2>dev/null
fi
#On affiche si les arborescences sont identiques ou différentes
if [ "$(md5sum md5arbo1f | cut -d ' ' -f1)" == "$(md5sum md5arbo2f | cut -d ' ' -f1)" ]
then
	echo -e "\n""Les arborescences sont ${rouge}IDENTIQUES${neutre}"
	#Si on a déjà fait d'autres tests, on supprime les fichiers sans qu'on affiche les erreurs dans le terminal
	rm -f differentsf 2>/dev/null
	rm -f diffarbof 2>/dev/null
	rm -f ficdiffpath.txt 2>/dev/null
	rm -f projet.html 2>/dev/null
	rm -f projet.css 2>/dev/null
else
	echo -e "\n""Les arborescences sont ${rouge}DIFFERENTES${neutre}"
	echo -e "\n""${vert}Les fichiers et répertoires différents pour chaque arborescence avec leur chemin absolu sont présents dans le fichier ${neutre}ficdiffpath.txt"
	#Création fichier HTML
	echo "<!DOCTYPE html>
	<html lang=""fr"">
		<head>
			<meta charset=""utf-8"" />
			<link rel=""stylesheet"" href=""projet.css"" />
			<title> Résultat script bash </title>
		</head>
		<body>
		<div id=""page"">
			<h1> Les résultats du script bash </h1>
			<h2> Les nombre de fichiers différents </h2>
			<div class=""article"">
				<p> ""Il y a $(cat differentsf | wc -l) fichiers différents"" </p>
			</div>
			<h2> Les nombre de répertoires différents </h2>
			<div class=""article"">
				<p> ""Il y a $(cat md5arbouniq | wc -l) répertoires différents"" </p>
			</div>
			<h2> Les fichiers différents </h2>
			<div class=""article"">
			<a href="differentsf" target="_blank"><p>""On peut les voir en cliquant sur ce lien""</p></a>
			</div>
			<h2> Les répertoires différents </h2>
			<div class=""article"" >
			<a href="diffarbof" target="_blank"><p>""On peut les voir en cliquant sur ce lien""</p></a>
			</div>
			<h2> Les fichiers et répertoires différents avec leurs chemin absolus </h2>
			<div class=""article"" >
			<a href="ficdiffpath.txt" target="_blank"><p>""On peut les voir en cliquant sur ce lien""</p></a>
			</div>
		</div>
		<footer>
			&copy; Copyright 2019 Irfan BOUHENAF, Andréa DUHAMEL, Mohamed Lamine TALBI - Tous droits réservés
		</footer>
			
			
		</body>
	</html>" > projet.html
	#Création fichier CSS
	echo "*
	{
		font-family : Tahoma
	}
	body
	{
		background-color:grey;	
	}
	#page
	{
		width:800px;
		margin:auto;
	}
	h1
	{
		font-size:300%;
		color:orange;
		margin-bottom: 0px;
	}
	h2
	{
		font-size:120%;
		color:white;
		margin-top: 0px;
	}
	.article
	{
		color:black;
		background-color: orange;
		text-justify:auto;
		margin-bottom :1em;
		padding:1em;
		border-radius: 10px 10px 10px 10px
	}
	.article p{
		font-weight: bold;
		color: white;
	}
	.article a{
		font-weight: bold;
		color: white;
		text-underline: white;
	}
	footer
	{
		color:white;
		font-size:0.8em;
		text-align:center;
		background-color: rgba(0, 0, 0, 0.5);
		padding:20px;
		margin-top:50px;
		position:relative;
		top:100px;
	}
" > projet.css
	echo -e "\n""Un fichier ${vert}HTML${neutre} et un fichier ${vert}CSS${neutre} ont été crées"
fi
#On supprime la quasi-totalité des fichiers temporaires
rm -f md5
rm -f differents
rm -f temp3
rm -f temp4
rm -f md5fic
rm -f md5uniq
rm -f md5uniq2
rm -f unique
rm -f md5arbo1
rm -f md5arbo2
rm -f md5arbo1f
rm -f md5arbo2f
rm -f md5uniqf
rm -f md5uniq2f
rm -f temp2.txt
#rm -f temp.txt
rm -f md5arbo1d
rm -f md5arbo2d
rm -f md5arbod
rm -f md5arbo
rm -f md5arbouniq
rm -f md5arbouniq2
rm -f diffarbo
rm -f md5arbo1df
rm -f md5arbo2df
rm -f md5arbouniq2f
rm -f md5rep
rm -f communarbo
#Fin du programme
echo -e "${rouge}FIN DU PROGRAMME${neutre}"


 
    
