#!/bin/bash
#COMANDO MENSAJE TIPO (INFO WAR ERR)

#Variables
tipoLog="INFO"
comandoLog="LOG"
cantParam=$#
userLog=$(who | grep 'pts' | cut -d ' ' -f 1)
fechaLog=$(date "+%d/%m/%Y_%T")

#Chequeo ambiente
if [ "$LOGDIR" != "" ]
then

	#Chequeo parametros
	if [ $cantParam -eq 2 ] || [ $cantParam -eq 3 ]
	then
		#Chequeo tercer parametro
		if [ $cantParam -eq 3 ]
		then
			#Chequeo parametro correcto
			if [ "$3" == "INFO" ] || [ "$3" == "WAR" ] || [ "$3" == "ERR" ]
			then
				tipoLog="$3"
			fi
		fi

		#armo direccion de archivo
		comandoLog="$1"

		chequeo=$(echo "$LOGDIR" | grep '/$')
		if [ "$chequeo" == "" ]
		then
			archivoLog="$LOGDIR"'/'"$comandoLog"'.'"$LOGEXT"
		else
			archivoLog="$LOGDIR""$comandoLog"'.'"$LOGEXT"
		fi

		#Armo mensaje a loguear
		mensajeLog="$fechaLog"'-'"$userLog"'-'"$comandoLog"'-'"$tipoLog"'-'"$2"

		#Corroboro existencia y tamaño
		if [ -e "$archivoLog" ]
		then
			tamanioArchivo=$(ls -o "$archivoLog" | cut -d ' ' -f 4)
			let tamanioArchivo="$tamanioArchivo"/1024
		
			#Chequeo el tamaño del archivo (si no es correcto se borra)
			if [ "$tamanioArchivo" -gt "$LOGSIZE" ]
			then
				echo "Log extendido" > "$archivoLog"
			fi

		fi

		#Grabo en el log
		echo "$mensajeLog" >> "$archivoLog"

		#Chequeo error
		if [ $? -eq 0 ]
		then
			exit 0
		else
			exit 1
		fi

	else
		echo "GraLog: cantidad de parametros incorrectos"
		exit 1
	fi

else
	echo "GraLog: No se puede iniciar si no esta inicializado el ambiente"
	exit 1
fi
