#! /bin/bash

ERROR_COLOR='\033[0;31m'
NC='\033[0m' #no color
DIRECTORIO_COLOR='\e[93m'
ARCHIVO_COLOR='\e[93m'


printError () {
	echo -e "${ERROR_COLOR}ERROR: $1 ${NC}"
}



# Funcion que da 0 si el ambiente fue inicializado y 1 si no
ambienteInicializado () {

	if [ "$AMB_INI" ]; then return 0; fi
	
	return 1

}




# Compruebo si un archivo existe y si no: lo informo y detengo el proceso
comprobarArchivo () {
	if [ ! -f "$1" ]; then
		printError "No existe el archivo: $1"
		return 1
	fi

	return 0
} 



# Compruebo si un directorio existe y si no: lo informo y detengo el proceso
comprobarDirectorio () {

	if [ ! -d "$1" ]; then
		printError "No existe el directorio: $1"
		return 1
	fi

	return 0
}


#$1 tiene el contenido de la variable a chequear
#$2 tiene el nombre de la variable a chequear
comprobarVariable () {

	if [[ ! "$1" ]]; then 
		printError "El valor de la variable $2 no fue asignada correctamente"
		return 1
	fi

	return 0

}



#$1: Archivo de configuracion
comprobarInstalacion () {
		
	echo "Comprobando la instalacion..."

	# $1: config file -------------
	comprobarArchivo "$1"

	if [ "$?" = 1 ]; then 
		printError "El archivo de configuracion especificado es invalido: No existe el archivo" 
		return 2
	fi

	GRUPO_INST=true

	CONFDIR_INST=true
	BINDIR_INST=true
	MAEDIR_INST=true
	ACEPDIR_INST=true
	RECHDIR_INST=true
	PROCDIR_INST=true
	REPODIR_INST=true
	LOGDIR_INST=true
	NOVEDIR_INST=true

	LOGSIZE_INST=true
	DATASIZE_INST=true
	LOGEXT_INST=true


	#GRUPO
	VALOR=$( grep "^GRUPO.*$" "$1" | sed "s-\(^GRUPO=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $GRUPO_INST; then comprobarVariable "$VALOR" GRUPO; if [ "$?" = 1 ]; then GRUPO_INST=false; fi; fi
	
	if $GRUPO_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then GRUPO_INST=false; fi; fi


	#CONFDIR
	VALOR=$( grep "^CONFDIR.*$" "$1" | sed "s-\(^CONFDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $CONFDIR_INST; then comprobarVariable "$VALOR" CONFDIR; if [ "$?" = 1 ]; then CONFDIR_INST=false; fi; fi
	if $CONFDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then CONFDIR_INST=false; fi; fi

		
	#BINDIR
	VALOR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $BINDIR_INST; then comprobarVariable "$VALOR" BINDIR; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi

	if $BINDIR_INST; then comprobarArchivo "$VALOR/AFRARECI.bash"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/AFRAUMBR.bash"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/AFRALIST.pl"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi



	
	#MAEDIR
	VALOR=$( grep "^MAEDIR.*$" "$1" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $MAEDIR_INST; then comprobarVariable "$VALOR" MAEDIR; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/CdP.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/CdA.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/CdC.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/agentes.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/tllama.tab"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/umbral.tab"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi

			

	#ACEPDIR
	VALOR=$( grep "^ACEPDIR.*$" "$1" | sed "s-\(^ACEPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $ACEPDIR_INST; then comprobarVariable "$VALOR" ACEPDIR; if [ "$?" = 1 ]; then ACEPDIR_INST=false; fi; fi
	if $ACEPDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then ACEPDIR_INST=false; fi; fi
	
	

	#RECHDIR
	VALOR=$( grep "^RECHDIR.*$" "$1" | sed "s-\(^RECHDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $RECHDIR_INST; then comprobarVariable "$VALOR" RECHDIR; if [ "$?" = 1 ]; then RECHDIR_INST=false; fi; fi
	if $RECHDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then RECHDIR_INST=false; fi; fi
	


	#PROCDIR
	VALOR=$( grep "^PROCDIR.*$" "$1" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $PROCDIR_INST; then comprobarVariable "$VALOR" PROCDIR; if [ "$?" = 1 ]; then PROCDIR_INST=false; fi; fi 
	if $PROCDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then PROCDIR_INST=false; fi; fi 


	#REPODIR
	VALOR=$( grep "^REPODIR.*$" "$1" | sed "s-\(^REPODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $REPODIR_INST; then comprobarVariable "$VALOR" REPODIR; if [ "$?" = 1 ]; then REPODIR_INST=false; fi; fi 
	if $REPODIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then REPODIR_INST=false; fi; fi 
	
	
	#LOGDIR
	VALOR=$( grep "^LOGDIR.*$" "$1" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $LOGDIR_INST; then comprobarVariable "$VALOR" LOGDIR; if [ "$?" = 1 ]; then LOGDIR_INST=false; fi; fi 
	if $LOGDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then LOGDIR_INST=false; fi; fi 
	
	#NOVEDIR
	VALOR=$( grep "^NOVEDIR.*$" "$1" | sed "s-\(^NOVEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $NOVEDIR_INST; then comprobarVariable "$VALOR" NOVEDIR; if [ "$?" = 1 ]; then NOVEDIR_INST=false; fi; fi
	if $NOVEDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then NOVEDIR_INST=false; fi; fi 






	#Variables
	
	#LOGSIZE 
	VALOR=$( grep "^LOGSIZE.*$" "$1" | sed "s-\(^LOGSIZE=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $LOGSIZE_INST; then comprobarVariable "$VALOR" LOGSIZE; if [ "$?" = 1 ]; then LOGDSIZE_INST=false; fi; fi 


	#DATASIZE
	VALOR=$( grep "^DATASIZE.*$" "$1" | sed "s-\(^DATASIZE=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $DATASIZE_INST; then comprobarVariable "$VALOR" DATASIZE; if [ "$?" = 1 ]; then DATASIZE_INST=false; fi; fi 


	#LOGEXT
	VALOR=$( grep "^LOGEXT.*$" "$1" | sed "s-\(^LOGEXT=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $LOGEXT_INST; then comprobarVariable "$VALOR" "LOGEXT"; if [ "$?" = 1 ]; then LOGEXT_INST=false; fi; fi
					
				

	if $GRUPO_INST && $CONFDIR_INST && $BINDIR_INST && $MAEDIR_INST && $ACEPDIR_INST && $RECHDIR_INST && $PROCDIR_INST && $REPODIR_INST && $LOGDIR_INST && $NOVEDIR_INST && $LOGSIZE_INST && $DATASIZE_INST && $LOGEXT_INST; then 
		return 0
	 fi

	return 1

}






#$1: Archivo al cual le quiero cambiar los permisos
#$2: Permisos por ejemplo "+x"
setearPermiso () {


	{ chmod "$2" "$1" 
	} || { 
	printError "No se pudieron setear los permisos de \"$1\" correctamente"
	return 1 
	}


}


#$1: Directorio al cual le quiero cambiar los permisos a todos sus archivos
#$2: Permisos por ejemplo "+x"
setearPermisosDeUnDirectorio () {

	{ chmod "$2" -R "$1" 
	} || { 
	printError "No se pudieron setear los permisos de \"$1\" correctamente"
	return 1 
	}
		


}





seteoDePermisos () {

	#Seteo permiso de lectura al archivo de configuracion
	setearPermiso "$1" "+r"
		
	#BINDIR: Agrego permisos de ejecucion a todos los archivos del directorio.
	VALOR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+x"


	
	#MAEDIR: Agrego permisos de lectura a todos los archivos de MAEDIR 
	VALOR=$( grep "^MAEDIR.*$" "$1" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"
			




	#EN TODOS LOS DEMAS SI HAY ARCHIVOS LES DOY PERMISOS DE LECTURA

	#ACEPDIR
	VALOR=$( grep "^ACEPDIR.*$" "$1" | sed "s-\(^ACEPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#RECHDIR
	VALOR=$( grep "^RECHDIR.*$" "$1" | sed "s-\(^RECHDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#PROCDIR
	VALOR=$( grep "^PROCDIR.*$" "$1" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"


	#REPODIR
	VALOR=$( grep "^REPODIR.*$" "$1" | sed "s-\(^REPODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"
	
	
	#LOGDIR
	VALOR=$( grep "^LOGDIR.*$" "$1" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"
	setearPermisosDeUnDirectorio "$VALOR" "+w"
	
	#NOVEDIR
	VALOR=$( grep "^NOVEDIR.*$" "$1" | sed "s-\(^NOVEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"
	
	return 0


}








# Funcion que levanta las variables GRUPO, CONFDIR, BINDIR, MAEDIR , DATASIZE,
# ACEPDIR, RECHDIR, PROCDIR, REPODIR, LOGDIR, LOGSIZE ademas levanta el usuario y la fecha
# en variables: GRUPO_USER, GRUPO_DATE, CONFDIR_USER, CONFDIR_DATE... etc

levantarVariablesDesdeElArchivo () {


	echo "Levantando variables de ambiente desde el archivo de configuracion..."

	#GRUPO
	GRUPO=$( grep "^GRUPO.*$" "$1" | sed "s-\(^GRUPO=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )

	export GRUPO

	#CONFDIR
	CONFDIR=$( grep "^CONFDIR.*$" "$1" | sed "s-\(^CONFDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export CONFDIR
		
	#BINDIR
	BINDIR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export BINDIR

	#PATH
	PATH="$PATH:$BINDIR"
	
	export PATH

	#MAEDIR
	MAEDIR=$( grep "^MAEDIR.*$" "$1" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export MAEDIR	

	#ACEPDIR
	ACEPDIR=$( grep "^ACEPDIR.*$" "$1" | sed "s-\(^ACEPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export ACEPDIR

	#RECHDIR
	RECHDIR=$( grep "^RECHDIR.*$" "$1" | sed "s-\(^RECHDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export RECHDIR

	#PROCDIR
	PROCDIR=$( grep "^PROCDIR.*$" "$1" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export PROCDIR

	#REPODIR
	REPODIR=$( grep "^REPODIR.*$" "$1" | sed "s-\(^REPODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export REPODIR	
		
	#LOGDIR
	LOGDIR=$( grep "^LOGDIR.*$" "$1" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export LOGDIR

	#NOVEDIR
	NOVEDIR=$( grep "^NOVEDIR.*$" "$1" | sed "s-\(^NOVEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )

	export NOVEDIR


	#Variables
	
	#LOGSIZE 
	LOGSIZE=$( grep "^LOGSIZE.*$" "$1" | sed "s-\(^LOGSIZE=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export LOGSIZE

	#DATASIZE
	DATASIZE=$( grep "^DATASIZE.*$" "$1" | sed "s-\(^DATASIZE=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	
	export DATASIZE

	#LOGEXT
	LOGEXT=$( grep "^LOGEXT.*$" "$1" | sed "s-\(^LOGEXT=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )

	export LOGEXT

	SECUENCIA=1

	export SECUENCIA

	return 0

}














#Funcion que muestra y loguea Directorio y los archivos contenidos en el mismo, el directorio se encuentra en una variable
#Entrada: parametro1 DIRECTORIO
#	  parametro2 Mensaje ej: "Directorio de configuracion:"

muestraYlogueoIndividual () {	

	CONTENIDO=$(ls "$1")
	MSG="$2 ${DIRECTORIO_COLOR} $1 ${NC}"
	
	echo -e "$MSG"
	GraLog.bash AFRAINIC "$2 $1" INFO

	if [ -n "$CONTENIDO" ]; then 
		echo "Archivos:"
		GraLog.bash AFRAINIC "Archivos:" INFO
		
		for archivo in $CONTENIDO
		do
			echo -e "${ARCHIVO_COLOR} $archivo ${NC}"
			GraLog.bash AFRAINIC "$archivo" INFO
		done
	fi
		
	
	return 0
}


mostrarYloguearVariables () {

	#Muestra y logueo de CONFDIR

	muestraYlogueoIndividual "$CONFDIR" "Directorio de Configuracion:" "CONFDIR"

	
	#BINDIR
	muestraYlogueoIndividual "$BINDIR" "Directorio de Ejecutables:" "BINDIR"



	#MAEDIR
	muestraYlogueoIndividual "$MAEDIR" "Directorio de Maestros y Tablas:" "MAEDIR"

	#NOVEDIR
	muestraYlogueoIndividual "$NOVEDIR" "Directorio de recepcion de archivos de llamadas:" "NOVEDIR"
 
	
	#ACEPDIR
	muestraYlogueoIndividual "$ACEPDIR" "Directorio de Archivos de llamadas Aceptados:" ACEPDIR


	#PROCDIR
	muestraYlogueoIndividual "$PROCDIR" "Directorio de Archivos de llamadas Sospechosas:" PROCDIR



	#REPODIR
	muestraYlogueoIndividual "$REPODIR" "Directorio de Archivos de Reportes de llamadas:" REPODIR


	#LOGDIR
	muestraYlogueoIndividual "$LOGDIR" "Directorio de Archivos de Log:" LOGDIR

	#RECHDIR
	muestraYlogueoIndividual "$RECHDIR" "Directorio de Archivos Rechazados:" RECHDIR


	echo "Estado del Sistema: INICIALIZADO"
	GraLog.bash AFRAINIC "Estado del Sistema: INICIALIZADO" INFO


}







arranqueAfrareci () {
	
	echo "¿Desea efectuar la activación de AFRARECI? ( ingrese 1 o 2 )"
	
	select respuesta in Si No
	do
		case $respuesta in
	
			Si)	PROCESO=$( ps -A | grep "AFRARECI.bash" )
				if [ -n "$PROCESO" ]; then
					echo "Ya existe un proceso AFRARECI corriendo"
					return 0				
				fi

				Arrancar.bash -i AFRAINIC

				SAVEIFS=$IFS
				IFS=" "
				AFRARECI_ID=$( ps -A | grep "AFRARECI" )
				AFRARECI_ID=( $AFRARECI_ID )
				AFRARECI_ID=${AFRARECI_ID[0]}

				IFS=$SAVEIFS

				MSJ="AFRARECI corriendo bajo el no.: <$AFRARECI_ID>"
				echo $MSJ
				echo "Para detenerlo invocar el siguiente comando:"
				echo "Detener.bash"
				GraLog.bash AFRAINIC "$MSJ" "INFO"

				return 0 ;;

			No)	echo "El proceso AFRARECI no se iniciara"
				echo "Puede iniciarlo manualmente a traves del comando:"
				echo "Arrancar.bash"
				echo "y para luego detenerlo invocar el siguiente comando:"
				echo "Detener.bash"	
				return 0 ;;
			
			*) echo "La respuesta solicitada no es valida por favor ingrese nuevamente: Recuerde que las opciones son 1 o 2 respectivamente"
		esac

	done

}











#$1: Contiene el archivo de configuracion con su path ej:"/home/.../AFRAINST.conf"

#-------------------- CODIGO PRINCIPAL ----------------------------------------


clear



# Funcion que devuelve 0 si no fue inicializado u otro numero si lo fue
ambienteInicializado 



# Veo cual fue el resultado de la funcion anterior
if [ "$?" =  1 ]; then
	
	#Input
	if [[ ! "$1" ]]; then 
		printError "Los parametros de entrada no fueron introducidos correctamente"
		echo -e "Recuerde que el comando debe ejecutarse de la siguiente manera:"
		echo -e "AFRAINIC.bash \"/home/.../AFRAINST.conf\" \n"
		return 1
	fi

	CONFIG_FILE=$1


	
	# Ambiente no inicializado

	comprobarInstalacion "$CONFIG_FILE"


	VALOR_RETORNO="$?"


	if [ "$VALOR_RETORNO" = 1 ]; then 
		printError "La instalacion no fue realizada correctamente faltan variables en el archivo de configuracion o estan mal definidas"
		echo -e "Por favor realice nuevamente la instalacion invocando a \"/path/AFRAINST.bash\" por ejemplo \"/home/user/program/AFRAINST.bash\"\n"	
		return 1

	elif [ "$VALOR_RETORNO" = 2 ]; then
		return 1
	fi


	seteoDePermisos "$CONFIG_FILE"

	if [ "$?" = 1 ]; then
		return 1
	fi

	levantarVariablesDesdeElArchivo "$CONFIG_FILE"

	

	mostrarYloguearVariables

	#Inicio AFRARECI
	arranqueAfrareci

	
	AMB_INI=true


else # -------------------------------------------




	# Ambiente inicializado

	MSJ="Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"

	echo -e $MSJ"\n"
	
	# Log del mensaje y sus respectivos datos.
	GraLog.bash AFRAINIC "$MSJ" "INFO"




fi


