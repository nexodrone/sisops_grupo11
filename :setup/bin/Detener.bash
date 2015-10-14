#!/bin/bash

cantParam=$#
hayFuncion=0

#Chequeo ambiente
if [ "$BINDIR" != "" ]
then

	#Chequeo cantidad de parametros
	if [ "$cantParam" -eq 0 ] || [ "$cantParam" -eq 2 ] || [ "$cantParam" -eq 4 ]
	then
		#Chequeo / en BINDIR
		chequeo=$(echo "$BINDIR" | grep '/$')
		if [ "$chequeo" == "" ]
		then
			binPath="$BINDIR"'/'
		else
			binPath="$BINDIR"
		fi

		#Seteo demonio por default
		funcionParametro='AFRARECI'
		funcionDetener="$binPath"'AFRARECI.bash'

		#Armo GraLog
		logDetener="$binPath"'GraLog.bash'

		#Chequeo que exista GraLog
		if [ -e "$logDetener" ]
		then

			#Chequeo parametros
			if [ "$2" != "" ] || [ "$4" != "" ]
			then

				#Chequeo comando que invoca
				if [ "$1" == "-i" ]
				then
					funcionInvoca="$2"
					hayFuncion=1
				else
					if [ "$3" == "-i" ]
					then
						funcionInvoca="$4"
						hayFuncion=1
					fi
				fi
	
				#Chequeo comando a ejecutar			
				if [ "$1" == "-c" ] 
				then
					funcionParametro="$2"
					#Chequeo extension de la funcion
					chequeo=$(echo "$funcionParametro" | grep '.bash$')
					if [ "$chequeo" == "" ]
					then
						funcionDetener="$binPath""$funcionParametro"'.bash'
					else
						funcionDetener="$binPath""$funcionParametro"			
					fi

				else
					if [ "$3" == "-c" ]
					then
						funcionParametro="$4"
						#Chequeo extension de la funcion
						chequeo=$(echo "$funcionParametro" | grep '.bash$')
						if [ "$chequeo" == "" ]
						then
							funcionDetener="$binPath""$funcionParametro"'.bash'
						else
							funcionDetener="$binPath""$funcionParametro"			
						fi
					fi
				fi
	
			fi

			#Chequeo que exista la funcion en memoria
			funcionEnProceso=$(echo ${funcionDetener##*/})
			chequeo=$(ps -A | grep "$funcionEnProceso")
			if [ "$chequeo" == "" ]
			then
				if [ "$hayFuncion" -eq 1 ]
				then
		
					comandoGraLog=$(echo ${funcionInvoca%.bash})
					"$logDetener" "$comandoGraLog" "No se puede detener: $funcionParametro porque no esta en ejecucion" "ERR"
				else
					echo "Detener: No se puede detener $funcionParametro porque no esta en ejecucion"
				fi

				exit 1
		
			fi
		
			#Obtengo Id del proceso para matarlo
			funcionEnProceso=$(echo ${funcionDetener##*/})
			idProceso=$(ps -A | grep "$funcionEnProceso" | cut -d ' ' -f 1)
			numeroDeCampo=2
			
			while [ "$idProceso" == "" ]
			do
				idProceso=$(ps -A | grep "$funcionEnProceso" | cut -d ' ' -f "$numeroDeCampo")
				let numeroDeCampo="$numeroDeCampo"+1
			done
			
			if [ "$idProceso" != "" ]
			then
				#Detengo proceso
				kill "$idProceso"
				resultadoKill=$?
		
				#Logeo
				if [ "$hayFuncion" -eq 1 ]
				then
					comandoGraLog=$(echo ${funcionInvoca%.bash})

					if [ $resultadoKill -eq 0 ]
					then
						"$logDetener" "$comandoGraLog" "$funcionParametro se detuvo correctamente"
						exit 0
					else
						"$logDetener" "$comandoGraLog" "$funcionParametro no se pudo detener" "ERR"
						exit 1
					fi

				else

					if [ $resultadoKill -eq 0 ]
					then
						echo "Detener: "$funcionParametro" se detuvo correctamente"
						exit 0
					else
						echo "Detener: "$funcionParametro" no se pudo detener"
						exit 1
					fi

				fi
		
			else
				if [ "$hayFuncion" -eq 1 ]
				then
					comandoGraLog=$(echo ${funcionInvoca%.bash})
					"$logDetener" "$comandoGraLog" "No existe PID de $funcionParametro" "ERR"
				else
					echo "Detener: No existe PID de "$funcionParametro"" "ERR"
				fi
			fi
	
		else
			echo "Detener: no existe "$logDetener""
			exit 1
		fi

	else
		echo "Detener: cantidad de parametros incorrecta"
		exit 1
	fi

else
	echo "Detener: No se puede iniciar si no esta inicializado el ambiente"
	exit 1
fi
