#!/bin/bash

CICLOS=1
cantArch=0
esValido=1
comando=AFRARECI
tiempoSuenio="10s"

#Ciclo infinito
while [ 0 -eq 0 ]
do

	#Chequeo ambiente
	if [ "$BINDIR" != "" ] && [ "$MAEDIR" != "" ] && [ "$NOVEDIR" != "" ] && [ "$ACEPDIR" != "" ] && [ "$RECHDIR" != "" ] && [ "$CONFDIR" != "" ]
	then
		cantArch=0

		#Chequeo / en los archivos
		chequeo=$(echo "$BINDIR" | grep '/$')

		if [ "$chequeo" == "" ]
		then
			moverA=$(echo "$BINDIR"'/MoverA.bash')
			graLog=$(echo "$BINDIR"'/GraLog.bash')
		else
			moverA=$(echo "$BINDIR"'MoverA.bash')
			graLog=$(echo "$BINDIR"'GraLog.bash')
		fi
		
		#Chequeo que exista GraLog
		if [ -e "$graLog" ]
		then
		
			#Chequeo que exista MoverA
			if [ -e "$moverA" ]
			then
	
				#Grabar log
				"$graLog" "$comando" "Ciclo numero $CICLOS" INFO

				#Para todos los archivos de novedades
				cd "$NOVEDIR"
				for ARCH in *
				do
					esValido=1
					#Si el archivo existe y no esta vacio
					
					if [ -f "$ARCH" ] && [ -s "$ARCH" ]
					then
						#Chequeo que sea comun
						chequeo=$(file "$ARCH" --mime-type | grep '^.*: text')
						if [ "$chequeo" != "" ]
						then

							#Analizo si tiene mas de dos campos
							esValido=0
							tercerCampo=$(echo "$ARCH" | cut -s -d "_" -f 3)
							if [ "$tercerCampo" == "" ]
							then
								#Analizo codigo de central
								codCentral=$(echo "$ARCH" | cut -s -d "_" -f 1)

								#Analizo si tiene codigo de central
								if [ "$codCentral" != "" ]
								then


									#Chequeo / en maedir
									chequeo=$(echo "$MAEDIR" | grep '/$')
									if [ "$chequeo" == "" ]
									then
										codArch=$(echo "$MAEDIR"'/CdC.mae')
									else
										codArch=$(echo "$MAEDIR"'CdC.mae')
									fi
				
									codValido=$(grep "$codCentral" "$codArch")
			
									#Si es valido
									if [ "$codValido" != "" ]
									then
										#Analizo fecha
										fecha=$(echo "$ARCH" | cut -s -d "_" -f 2)
										fecha=$(echo ${fecha%.*})
										anioActual=$(date "+%Y")
										mesActual=$(date "+%m")
										diaActual=$(date "+%d")
										esValido=0
				
										#Chequeo principal de la fecha
										fechaNumerica=$(echo "$fecha" | grep '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$')
										if [ "$fechaNumerica" != "" ]
										then
											#Chequeo mes y sus dias
											mesFecha=$(echo "$fecha" | cut -c 5,6)
											diasFecha=$(echo "$fecha" | cut -c 7,8)
											anioFecha=$(echo "$fecha" | cut -c 1-4)
					
											#Meses con 31 dias
											if [ "$mesFecha" -eq 1 ] || [ "$mesFecha" -eq 3 ] || [ "$mesFecha" -eq 5 ] || [ "$mesFecha" -eq 7 ] || [ "$mesFecha" -eq 8 ] || [ "$mesFecha" -eq 10 ] || [ "$mesFecha" -eq 12 ]
											then
												if [ "$diasFecha" -ge 1 ] && [ "$diasFecha" -le 31 ]
												then
													esValido=1
												fi
											fi

											#Meses con 30 dias
											if [ "$mesFecha" -eq 4 ] || [ "$mesFecha" -eq 6 ] || [ "$mesFecha" -eq 9 ] || [ "$mesFecha" -eq 11 ]
											then
												if [ "$diasFecha" -ge 1 ] && [ "$diasFecha" -le 30 ]
												then						
													esValido=1
												fi
											fi
						
											#Febrero
											if [ "$mesFecha" -eq 2 ] && [ "$diasFecha" -ge 1 ] && [ "$diasFecha" -le 29 ]
											then

												#Anio bisiesto
												if [ "$diasFecha" -eq 29 ]
												then
													
													#Chequeo anio bisiesto actual
													let validarAnioUno=$anioActual%4
													let validarAnioDos=$anioActual%100
													if [ "$validarAnioUno" -eq 0 ] && [ "$validarAnioDos" -ne 0 ]
													then
														esValido=1
													else
														let validarAnioUno=$anioActual%400
														if [ "$validarAnioUno" -eq 0 ]
														then
															esValido=1
														fi
													fi

													#Chequeo anio bisiesto de la fecha
													let validarAnioUno=$anioFecha%4
													let validarAnioDos=$anioFecha%100
													if [ "$validarAnioUno" -eq 0 ] && [ "$validarAnioDos" -ne 0 ]
													then
														esValido=1
													else
														let validarAnioUno=$anioFecha%400
														if [ "$validarAnioUno" -eq 0 ]
														then
															esValido=1
														fi
													fi

												else
													esValido=1
												fi
					
											fi
							
											#Si estuvo todo en orden
											if [ "$esValido" -eq 1 ]
											then
												#Valido antiguedad del mes con el año y los dias
												anioFecha=$(echo "$fecha" | cut -c 1-4)
												let anioValid=$anioActual-$anioFecha
												esValido=0
							
												#Si es de este año
												if [ "$anioValid" -eq 0 ] 
												then
													#Si el mes es menor al actual
													if [ "$mesFecha" -lt "$mesActual" ]
													then
														esValido=1
													else
														#Si el mes es el mismo y los dias son menores o el mismo
														if [ "$mesFecha" -eq "$mesActual" ] && [ "$diasFecha" -le "$diaActual" ]
														then
															esValido=1
														fi
													fi
												else
													#Si es del año pasado
													if [ "$anioValid" -eq 1 ] 
													then
														#Si el mes es mayor al actual
														if [ "$mesFecha" -gt "$mesActual" ]
														then
															esValido=1
														else
															#Si el mes es el mismo y los dias son mayores o el mismo
															if [ "$mesFecha" -eq "$mesActual" ] && [ "$diasFecha" -ge "$diaActual" ]
															then
																esValido=1
															fi
														fi
													fi
												fi
					
												#Si estuvo todo en orden
												if [ "$esValido" -eq 1 ]
												then
													#lo muevo a ACEPDIR
			
													#Chequeo / en NOVEDIR
													chequeo=$(echo "$NOVEDIR" | grep '/$')
													if [ "$chequeo" == "" ]
													then
														archAmover=$(echo "$NOVEDIR"'/'"$ARCH")
													else
														archAmover=$(echo "$NOVEDIR""$ARCH")
													fi

													"$moverA" "$archAmover" "$ACEPDIR" "AFRARECI"
													resultadoMoverA=$?

													#Chequeo que salio todo bien
													if [ $resultadoMoverA -eq 0 ]
													then
														"$graLog" "$comando" "Archivo $archAmover aceptado" INFO
													fi

												else
													#Grabar log
													"$graLog" "$comando" "Archivo $ARCH no tiene una fecha valida. Rechazado" WAR
							
												fi
						
											else
												#Grabar log
												"$graLog" "$comando" "Archivo $ARCH no tiene una fecha valida. Rechazado" WAR
							
											fi
					
										else

											#Grabar log
											"$graLog" "$comando" "Archivo $ARCH no tiene una fecha valida. Rechazado" WAR

										fi
				
									else

										#Grabar log
										"$graLog" "$comando" "Archivo $ARCH no tiene un codigo de central valido. Rechazado" WAR

									fi

								else								
									#Grabar log
									"$graLog" "$comando" "Archivo $ARCH no tiene un nombre valido. Rechazado" WAR
								fi
		
							else

								#Grabar log
								"$graLog" "$comando" "Archivo $ARCH no tiene un nombre valido. Rechazado" WAR
							fi
						
						else
							esValido=0
							esTexto=0
						fi

					else
						if [ -e "$ARCH" ]
						then
							esValido=0
						fi
					fi
		
					#Si el archivo no es valido lo muevo a RECHDIR
					if [ "$esValido" -eq 0 ]
					then
						#Chequeo / al final
						chequeo=$(echo "$NOVEDIR" | grep '/$')

						if [ "$chequeo" == "" ]
						then
							archAmover=$(echo "$NOVEDIR"'/'"$ARCH")
						else
							archAmover=$(echo "$NOVEDIR""$ARCH")
						fi
			
						#muevo archivo
						"$moverA" "$archAmover" "$RECHDIR" "AFRARECI"

						#Logeo
						#Si hay algun archivo
						if [ -e "$ARCH" ]
						then
				
							#Si no esta vacio
							if [ -s "$ARCH" ]	
								then
						
									#Si no era texto
									if [ "$esTexto" -eq 0 ]	
									then
										#Grabar log
										"$graLog" "$comando" "Archivo $ARCH no es un tipo valido. Rechazado" WAR
									fi

								else
								#Grabar log
								"$graLog" "$comando" "Archivo $ARCH esta vacio. Rechazado" WAR
							fi

						fi

					fi

					let cantArch=cantArch+1	
				done

				#Chequeo archivos en ACEPDIR
				hayArchivos=$(find "$ACEPDIR" -type f)

				#Si hay archivos
				if [ "$hayArchivos" != "" ]
				then
					#chequear que AFRAUMBR no este corriendo
					proceso=$(ps -A -f)
					proceso=$(echo "$proceso" | grep 'AFRAUMBR')
					if [ "$proceso" == "" ]
					then
						#Chequeo / al final
						chequeo=$(echo "$BINDIR" | grep '/$')

						if [ "$chequeo" == "" ]
						then
							afraumbr=$(echo "$BINDIR"'/AFRAUMBR.bash')
						else
							afraumbr=$(echo "$BINDIR"'AFRAUMBR.bash')
						fi

						#Chequeo que exista AFRAUMBR
						if [ -e "$afraumbr" ]
						then
			
							#Ejecuto
							"$afraumbr"
							resultadoUmbr=$?

							#Grabar log
							if [ $resultadoUmbr -ne 0 ]
							then
								"$graLog" "$comando" "No se pudo iniciar AFRAUMBR" ERR	
							fi
						
						else
							"$graLog" "$comando" "No se pudo iniciar AFRAUMBR porque no existe" ERR
						fi

					else
						#Grabar log
						"$graLog" "$comando" "Invocación de AFRAUMBR pospuesta para el siguiente ciclo" INFO
					fi

				fi

			else
				echo "AFRARECI: No se puede iniciar porque no existe "$moverA""
				exit 1
			fi

		else
			echo "AFRARECI: No se puede iniciar porque no existe "$graLog""
			exit 1
		fi

	else
		echo "AFRARECI: No se puede iniciar si no esta inicializado el ambiente"
		exit 1

	fi
	
	#Incremento ciclos
	let CICLOS=$CICLOS+1

	#A dormir
	sleep $tiempoSuenio

done
