#!/bin/bash

cantParam=$#
hayComando=0

#Chequeo ambiente
if [ "$BINDIR" != "" ] && [ "$CONFDIR" != "" ]
then

	#Chequeo cantidad de parametros
	if [ "$cantParam" -eq 2 ] || [ "$cantParam" -eq 3 ]
	then
		#Chequeo tercer parametro (comando)
		if [ "$cantParam" -eq 3 ]
		then
			hayComando=1
			comandoMoverA="$3"	
		fi

		#Armo archivo de conf
		chequeo=$(echo "$CONFDIR" | grep '/$')
		if [ "$chequeo" != "" ]
		then
			archConf="$CONFDIR""AFRAINST.conf"
		else
			archConf="$CONFDIR"'/'"AFRAINST.conf"
		fi

		#Chequeo que exista archivo de configuracion
		if [ -e "$archConf" ]
		then
			fechaSecuencia=$(date "+%d/%m/%Y_%T")
			usuarioSecuencia=$(whoami)
			#Chequeo numero de secuencia
			SECUENCIA=$(grep 'NUMERODESECUENCIA' "$archConf" | cut -d '=' -f 2)
			if [ "$SECUENCIA" == "" ]
			then
				SECUENCIA=1
				echo "NUMERODESECUENCIA="$SECUENCIA"="$usuarioSecuencia"="$fechaSecuencia"" >> "$archConf"
			fi

		else
			echo "MoverA: No existe "$archConf""
			exit 1
		fi
		

		#Armo GraLog
		chequeo=$(echo "$BINDIR" | grep '/$')
		if [ "$chequeo" != "" ]
		then
			graLogMoverA="$BINDIR""GraLog.bash"
		else
			graLogMoverA="$BINDIR"'/'"GraLog.bash"
		fi

		#Chequeo que exista GraLog
		if [ -e "$graLogMoverA" ]
		then

			archivo="$1"
			destino="$2"
			origen=$(echo ${archivo%/*})
			archivoSolo=$(echo ${archivo##*/})

			#Chequeo que exista el origen y el destino
			if [ -d "$origen" ]
			then

				#Chequeo que exista el archivo
				if [ -e "$archivo" ]
				then
			
					#Chequeo que exista el destino	
					if [ -d "$destino" ]
					then
						#Me aseguro que destino termine con /
						chequeo=$(echo "$destino" | grep '/$')

						if [ "$chequeo" == "" ]
						then
							destino="$destino"'/'
						fi

						#Me aseguro que origen termine con /
						chequeo=$(echo "$origen" | grep '/$')

						if [ "$chequeo" == "" ]
						then
							origen="$origen"'/'
						fi
	
						#Chequeo si origen y destino son iguales
						if [ "$origen" != "$destino" ]
						then
					
							#Chequeo si el archivo ya existe en el directorio
							archivoDestino="$destino""$archivoSolo"

							if [ -e "$archivoDestino" ]
							then
						
								#Chequeo que exista el subdirectorio duplicados
								duplicados="$destino"'duplicados/'				
						
								if [ -d "$duplicados" ]
								then
									destinoDuplicado="$duplicados"

									#Chequeo que exista el archivo en duplicados
									archivoDestino="$duplicados""$archivoSolo"

									if [ -e "$archivoDestino" ]
									then

										#Duplicar archivo en duplicados
										duplicados="$duplicados""$archivoSolo"."$SECUENCIA"
										mv "$archivo" "$duplicados"
										resultado=$?
										if [ "$resultado" -eq 0 ]
										then
											#Loguear todo ok si hay comando
											if [ "$hayComando" -eq 1 ]
											then
												"$graLogMoverA" "$comandoMoverA" "Archivo "$archivoSolo" movido de: "$origen" a: "$destinoDuplicado""
											else
												echo "MoverA: Archivo "$archivoSolo" movido de: "$origen" a: "$destinoDuplicado""
											fi
							
											#Incremento numero de secuencia
											let SECUENCIA=$SECUENCIA+1
											sed -i "s+^NUMERODESECUENCIA=.*+NUMERODESECUENCIA="$SECUENCIA"="$usuarioSecuencia"="$fechaSecuencia"+" "$archConf"

											exit 0
										else
											#Loguear que algo salio mal
											if [ "$hayComando" -eq 1 ]
											then
												"$graLogMoverA" "$comandoMoverA" "No se pudo mover "$archivoSolo"" "ERR"
											else					
												echo "MoverA: No se pudo mover "$archivoSolo""
											fi
											exit 1
										fi								
							
									else
										mv "$archivo" "$duplicados"
										resultado=$?
										if [ "$resultado" -eq 0 ]
										then
											#Loguear todo ok si hay comando
											if [ "$hayComando" -eq 1 ]
											then
												"$graLogMoverA" "$comandoMoverA" "Archivo "$archivoSolo" movido de: "$origen" a: "$destinoDuplicado""
											else
												echo "MoverA: Archivo "$archivoSolo" movido de: "$origen" a: "$destinoDuplicado""
											fi
											exit 0
										else
											#Loguear que algo salio mal
											if [ "$hayComando" -eq 1 ]
											then
												"$graLogMoverA" "$comandoMoverA" "No se pudo mover "$archivoSolo"" "ERR"
											else
												echo "MoverA: No se pudo mover "$archivoSolo""
											fi
											exit 1
										fi
									fi				
								else
									#Creo el directorio y muevo
									mkdir "$duplicados"
									mv "$archivo" "$duplicados"
									resultado=$?
									if [ "$resultado" -eq 0 ]
									then
										#Loguear todo ok si hay comando
										if [ "$hayComando" -eq 1 ]
										then
											"$graLogMoverA" "$comandoMoverA" "Archivo "$archivoSolo" movido de: "$origen" a: "$destinoDuplicado""
										else
											echo "MoverA: Archivo "$archivoSolo" movido de: "$origen" a: "$destinoDuplicado""
										fi
										exit 0
									else
										#Loguear que algo salio mal
										if [ "$hayComando" -eq 1 ]
										then
											"$graLogMoverA" "$comandoMoverA" "No se pudo mover "$archivoSolo"" "ERR"
										else
											echo "MoverA: No se pudo mover "$archivoSolo""							
										fi
										exit 1
									fi

								fi

							else
								#Muevo sin problemas
								mv "$archivo" "$destino"
								resultado=$?
								if [ "$resultado" -eq 0 ]
								then
									#Loguear todo ok si hay comando
									if [ "$hayComando" -eq 1 ]
									then
										"$graLogMoverA" "$comandoMoverA" "Archivo "$archivoSolo" movido de: "$origen" a: "$destino""
									else
										echo "MoverA: Archivo "$archivoSolo" movido de: "$origen" a: "$destino""
									fi
									exit 0
								else

									#Loguear que algo salio mal
									if [ "$hayComando" -eq 1 ]
									then
										"$graLogMoverA" "$comandoMoverA" "No se pudo mover "$archivoSolo"" "ERR"
									else
										echo "MoverA: No se pudo mover "$archivoSolo""
									fi

									exit 1
								fi

							fi
										

						else
							#Loguear destinos iguales
							if [ "$hayComando" -eq 1 ]
							then
								"$graLogMoverA" "$comandoMoverA" "No se puede mover "$archivoSolo" porque el origen y el destino son iguales" "ERR"
							else
								echo "MoverA: No se puede mover "$archivoSolo" porque el origen y el destino son iguales"
							fi
							exit 1
						fi

					else
						#Loguear no existe el destino
						if [ "$hayComando" -eq 1 ]
						then
							"$graLogMoverA" "$comandoMoverA" "No se puede mover "$archivoSolo" porque no existe el destino" "ERR"
						else
							echo "MoverA: No se puede mover "$archivoSolo" porque no existe el destino"			
						fi
						exit 1
					fi
		
				else
					#Loguear no existe el archivo
					if [ "$hayComando" -eq 1 ]
					then
						"$graLogMoverA" "$comandoMoverA" "No se puede mover "$archivoSolo" porque el archivo no existe" "ERR"
					else
						echo "MoverA: No se puede mover "$archivoSolo" porque el archivo no existe"
					fi
				fi

			else
				#Loguear no existe el origen
				if [ "$hayComando" -eq 1 ]
				then
					"$graLogMoverA" "$comandoMoverA" "No se puede mover "$archivoSolo" porque no existe el origen" ERR
				else
					echo "MoverA: No se puede mover "$archivoSolo" porque no existe el origen"
				fi
				exit 1
			fi
	
		else
			echo "MoverA: no existe "$graLogMoverA""
			exit 1
		fi


	else
		echo "MoverA: faltan parametros"
		exit 1
	fi

else
	echo "MoverA: No se puede iniciar si no esta inicializado el ambiente"
	exit 1
fi
