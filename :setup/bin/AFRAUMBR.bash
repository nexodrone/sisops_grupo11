#!/bin/bash
# AFRAUMBR

GraLog.bash AFRAUMBR "Inicio de AFRAUMBR"
#echo "Inicio de AFRAUMBR"  >> AFRAUMBR.log

GraLog.bash AFRAUMBR "Cantidad de archivos a procesar: $(ls $ACEPDIR -1 | wc -l)"
#echo "Cantidad de archivos a procesar: $(ls $ACEPDIR -1 | wc -l)" >> AFRAUMBR.log


for arch in "$ACEPDIR"/*
do
 FNAME=$(basename $arch)
 CODCENTRAL=$(echo $FNAME | cut -d'_' -f1)
 FECHAYPUNTO=$(echo $FNAME | cut -d'_' -f2)
 FECHA=$(echo $FECHAYPUNTO | cut -d'.' -f1)

	

 llamadas=0
 recha=0
 conumb=0
 sinumb=0
 sospe=0
 nosospe=0



 # me fijo si esta duplicado
 if [ -f "$PROCDIR/proc/$FNAME" ]
 then
	GraLog.bash AFRAUMBR "Se rechaza $FNAME por estar DUPLICADO" 	
	#echo "Se rechaza $FNAME por estar DUPLICADO" >> AFRAUMBR.
	MoverA.bash "$ACEPDIR/$FNAME" "$RECHDIR" AFRAUMBR
 	#mv $ACEPDIR/$FNAME $RECHDIR

 else


 CAMPOS=$(head -1 "$ACEPDIR/$FNAME" | awk -F ';' '{print NF}')
 if [ "$CAMPOS" != "" ] && [ "$CAMPOS" -ne 8 ]
 then
	GraLog.bash AFRAUMBR "Se rechaza el archivo $FNAME porque su estructura no se corresponde con el formato esperado"
	#echo "Se rechaza el archivo $FNAME porque su estructura no se corresponde con el formato esperado" >> AFRAUMBR.log
	MoverA.bash "$ACEPDIR/$FNAME" "$RECHDIR" AFRAUMBR
	#mv $ACEPDIR/$FNAME $RECHDIR
 else
	#esto tiene que ir al log
	GraLog.bash AFRAUMBR "Archivo a procesar $FNAME"
	#echo "Archivo a procesar $FNAME" >> AFRAUMBR.log
 fi

 IFS=$'\n'
 set -f 
 for registro in $(cat "$ACEPDIR/$FNAME") ; do

  let llamadas++
  
  REGVALIDO=true

  FECHAIN=$(echo $registro | cut -d';' -f2)
  INICIOL=$(echo $FECHAIN | cut -d' ' -f2)
  FECHAANIO=$(echo $FECHAIN | cut -d' ' -f1 | cut -d'/' -f3)
  FECHAMES=$(echo $FECHAIN | cut -d' ' -f1 | cut -d'/' -f2)




  #Valido el nombre del agente
  AGENTE=$(echo $registro | cut -d';' -f1)
  AGENREG=$(grep "$AGENTE" "$MAEDIR"/agentes.mae | cut -d";" -f3)
  if [ "$AGENTE" != "$AGENREG" ]
  then
     REGVALIDO=false
     echo "$FNAME;$AGENTE no coincide con ningun agente;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech"
  fi



  #valido el numero de area
  CODAREA=$(echo $registro | cut -d';' -f4)
  CODSAREG=$(grep ";$CODAREA"$ "$MAEDIR"/CdA.mae | cut -d";" -f2)
  if [ "$CODAREA" != "$CODSAREG" ]
  then
     REGVALIDO=false
     echo "$FNAME;El codigo de area $CODAREA no existe;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech"  
  fi




  #valido el numero de linea
  NUMERO=$(echo $registro | cut -d';' -f5)
  NLINEA=$CODAREA$NUMERO
  if [ $(expr "${NLINEA}" : '.*') -ne 10 ]
  then
     REGVALIDO=false
     echo "$FNAME;El numero A: $NLINEA deberia tener 10 digitos;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech"
  fi



  #valido el numero B (al que llama)
  NUMEROB=$(echo $registro | cut -d';' -f8)
  CAREAB=$(echo $registro | cut -d';' -f7)
  CPAIS=$(echo $registro | cut -d';' -f6)
  if [ -z "$CPAIS" ]
  then
  	NBCOMPLETO=$CAREAB$NUMEROB
	if [ "$CAREAB" = "$CODAREA" ]
	then
		TIPOLLAMADA="LOC"
	else
		TIPOLLAMADA="DDN"
		CODSAREG=$(grep ";$CAREAB"$ "$MAEDIR/CdA.mae" | cut -d";" -f2)
		if [ "$CAREAB" != "$CODSAREG" ]
  		then 
			REGVALIDO=false
     			echo "$FNAME;El codigo de area $CAREAB no existe;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech"  
  		fi
	fi
  else
	TIPOLLAMADA="DDI"
	CPAISREG=$(grep ^"$CPAIS;" "$MAEDIR"/CdP.mae | cut -d";" -f1)
	CPAISREG=$(echo $CPAISREG | cut -d" " -f1)
	if [ "$CPAIS" != "$CPAISREG" ]
	then
		REGVALIDO=false
		echo "$FNAME;El codigo de pais $CPAIS no existe;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech"
	fi
  fi
  if [ $(expr "${NBCOMPLETO}" : '.*') -ne 10 ]
  then
     REGVALIDO=false
     echo "$FNAME;El numero B: $NBCOMPLETO deberia tener 10 digitos;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech"
  fi




  #valido el Tiempo de conversación
  TCONV=$(echo $registro | cut -d';' -f3)
  if [ ! $TCONV -ge 0 ]
  then
	REGVALIDO=false
	echo "$FNAME;El tiempo de conversación: $TCONV deberia ser mayor o igual a 0;$registro" >> "$RECHDIR/llamadas/$CODCENTRAL.rech" 
  fi




  #proceso registro si es valido
  if [ $REGVALIDO = true ]
  then
	oficina=$(grep "$AGENTE" "$MAEDIR"/agentes.mae | cut -d";" -f4)
	fuesospe=false
	tieneumb=false
	if [ $TIPOLLAMADA = "DDI" ]
	then	
		UMBRAL=$(grep ^".*;$CODAREA;$NUMERO;DDI;$CPAIS;.*;Activo"$ "$MAEDIR"/umbral.tab)
		UMBRALV=$(grep ^".*;$CODAREA;$NUMERO;DDI;;.*;Activo"$ "$MAEDIR"/umbral.tab)

		if [ "$UMBRAL" != "" ] || [ "$UMBRALV" != "" ]
		then
			let conumb++
			tieneumb=true
		else
			let sinumb++
		fi

		UMBTIEMPO=$(echo $UMBRAL | cut -d';' -f6)
		UMBVTIEMPO=$(echo $UMBRALV | cut -d';' -f6)

		if [ "$UMBTIEMPO" != "" ] && [ "$UMBTIEMPO" -lt "$TCONV" ]
		then
			let sospe++
			fuesospe=true
			IDUMBRAL=$(echo $UMBRAL | cut -d';' -f1)
			echo "$CODCENTRAL;$AGENTE;$IDUMBRAL;$TIPOLLAMADA;$INICIOL;$TCONV;$CODAREA;$NUMERO;$CPAIS;$CAREAB;$NUMEROB;$FECHA"  >> "$PROCDIR"/"$oficina"_"$FECHAANIO$FECHAMES"
		else
			if [ "$UMBVTIEMPO" != "" ] && [ "$UMBVTIEMPO" -lt "$TCONV" ]
			then
			  fuesospe=true
			  let sospe++
			  IDUMBRAL=$(echo $UMBRALV | cut -d';' -f1)
			  echo "$CODCENTRAL;$AGENTE;$IDUMBRAL;$TIPOLLAMADA;$INICIOL;$TCONV;$CODAREA;$NUMERO;$CPAIS;$CAREAB;$NUMEROB;$FECHA" >> "$PROCDIR"/"$oficina"_"$FECHAANIO$FECHAMES"
			fi
		fi
	else
		UMBRAL=$(grep ^".*;$CODAREA;$NUMERO;$TIPOLLAMADA;$CAREAB;.*;Activo"$ "$MAEDIR"/umbral.tab)
		UMBRALV=$(grep ^".*;$CODAREA;$NUMERO;$TIPOLLAMADA;;.*;Activo"$ "$MAEDIR"/umbral.tab)

		if [ "$UMBRAL" != "" ] || [ "$UMBRALV" != "" ]
		then
			let conumb++
			tieneumb=true
		else
			let sinumb++
		fi

		UMBTIEMPO=$(echo $UMBRAL | cut -d';' -f6)
		UMBVTIEMPO=$(echo $UMBRALV | cut -d';' -f6)

		if [ "$UMBTIEMPO" != "" ] && [ $UMBTIEMPO -lt $TCONV ]
		then
			let sospe++
			fuesospe=true
			IDUMBRAL=$(echo $UMBRAL | cut -d';' -f1)
			echo "$CODCENTRAL;$AGENTE;$IDUMBRAL;$TIPOLLAMADA;$INICIOL;$TCONV;$CODAREA;$NUMERO;$CPAIS;$CAREAB;$NUMEROB;$FECHA" >> "$PROCDIR"/"$oficina"_"$FECHAANIO$FECHAMES"
		else
			if [ "$UMBVTIEMPO" != "" ] && [ "$UMBVTIEMPO" -lt "$TCONV" ]
			then
			   fuesospe=true 
			   let sospe++
			   IDUMBRAL=$(echo $UMBRALV | cut -d';' -f1)
			   echo "$CODCENTRAL;$AGENTE;$IDUMBRAL;$TIPOLLAMADA;$INICIOL;$TCONV;$CODAREA;$NUMERO;$CPAIS;$CAREAB;$NUMEROB;$FECHA" >> "$PROCDIR"/"$oficina"_"$FECHAANIO$FECHAMES"
			fi
		fi		
	fi

	if [ $fuesospe = false ] && [ $tieneumb = true ]
 	then
		let nosospe++
  	fi

  else
	let recha++
  fi

  

 done


 GraLog.bash AFRAUMBR "Llamadas $llamadas, con umbral: $conumb, sin umbral: $sinumb, rechazadas: $recha"
 GraLog.bash AFRAUMBR "Sospechosas: $sospe"
 GraLog.bash AFRAUMBR "No sospechosas: $nosospe"
 #echo "Llamadas $llamadas, con umbral: $conumb, sin umbral: $sinumb, rechazadas: $recha" >> AFRAUMBR.log
 #echo "Sospechosas: $sospe" >> AFRAUMBR.log
 #echo "No sospechosas: $nosospe" >> AFRAUMBR.log

 MoverA.bash "$ACEPDIR/$FNAME" "$PROCDIR/proc" AFRAUMBR
fi
done




