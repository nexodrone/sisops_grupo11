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
		funcionArrancar="$binPath"'AFRARECI.bash'

		#Armo GraLog
		logArrancar="$binPath"'GraLog.bash'

		#Chequeo que exista GraLog
		if [ -e "$logArrancar" ]
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
						funcionArrancar="$binPath""$funcionParametro"'.bash'
					else
						funcionArrancar="$binPath""$funcionParametro"			
					fi

				else
					if [ "$3" == "-c" ]
					then
						funcionParametro="$4"
						#Chequeo extension de la funcion
						chequeo=$(echo "$funcionParametro" | grep '.bash$')
						if [ "$chequeo" == "" ]
						then
							funcionArrancar="$binPath""$funcionParametro"'.bash'
						else
							funcionArrancar="$binPath""$funcionParametro"			
						fi
					fi
				fi
	
				#Chequeo que exista la funcion
				chequeo=$(ls "$binPath" | grep "$funcionParametro")
				if [ "$chequeo" == "" ]
				then
					if [ "$hayFuncion" -eq 1 ]
					then
		
						comandoGraLog=$(echo ${funcionInvoca%.bash})
						"$logArrancar" "$funcionInvoca" "No se puede arrancar "$funcionParametro" porque no existe" "ERR"
					else
						echo "Arrancar: No se puede arrancar "$funcionParametro" porque no existe"
					fi
					exit 1
			
				fi
	
			fi

			#Chequeo que no este corriendo el proceso
			procesosCorriendo=$(ps -A -f)
			chequeo=$(echo "$procesosCorriendo" | grep "$funcionArrancar")
			if [ "$chequeo" != "" ]
			then
				#Muestro el error de ya esta corriendo
				if [ "$hayFuncion" -eq 1 ]
				then			
					comandoGraLog=$(echo ${funcionInvoca%.bash})
					"$logArrancar" "$funcionInvoca" "No se puede arrancar "$funcionParametro" porque ya esta en ejecucion" "ERR"
				else
					echo "Arrancar: No se puede arrancar "$funcionParametro" porque ya esta en ejecucion"
				fi
		
				exit 1

			else
		
				#Chequeo que exista funcion a arrancar
				if [ -e "$funcionArrancar" ]
				then
		
					#Arranco proceso
					"$funcionArrancar" &
					resultadoArrancar=$?
		
					#Logeo
					if [ "$hayFuncion" -eq 1 ]
					then
						comandoGraLog=$(echo ${funcionInvoca%.bash})

						if [ $resultadoArrancar -eq 0 ]
						then
							"$logArrancar" "$funcionInvoca" ""$funcionParametro" se inicio correctamente"
							exit 0
						else
							"$logArrancar" "$funcionInvoca" ""$funcionParametro" no se pudo iniciar" "ERR"
							exit 1
						fi

					else

						if [ $resultadoArrancar -eq 0 ]
						then
							echo "Arrancar: "$funcionParametro" se inicio correctamente"
							exit 0
						else
							echo "Arrancar: "$funcionParametro" no se pudo iniciar"
							exit 1
						fi

					fi

				else
					echo "Arrancar: no existe "$funcionArrancar""
				fi

			fi

		else
			echo "Arrancar: cantidad de parametros incorrecta"
			exit 1
		fi
	
	else
		echo "Arrancar: no existe "$logArrancar""	
	fi

else
	echo "Arrancar: No se puede iniciar si no esta inicializado el ambiente"
	exit 1
fi
