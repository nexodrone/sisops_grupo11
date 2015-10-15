#!/usr/bin/perl -w

#opcion -r




#-------------------------------------------------------------------
#MENUS e INTERFACES-------------------------------------------------
#-------------------------------------------------------------------


sub menuInformesPrincipal
{	
	&clearScreen;
	
	my $input = '';
	while ($input ne '3')
	{
		

		print "Por favor ingrese la opcion deseada ( 1 , 2 o 3 ):\n";
		print "1- Realizar consultas sobre archivos de llamadas sospechosas \n";
		print "2- Realizar consultas sobre archivos de consultas previas \n";
		print "3- Salir\n";

		$input = <STDIN>;
		chomp($input);
		
		if ( $input eq '1' ) { &llamadasSospechosas; }	#Consultas sobre archivos llam sospe
		elsif ( $input eq '2' ) { } # Consultas previas
		elsif ( $input eq '3' ) { } #Salir
		else {  &clearScreen;
			print "Opcion invalida por favor ingrese nuevamente \n";
			print "\n";}

			
	}
	

}





sub llamadasSospechosas
{
	print "Usted escogio la opcion de realizar consultas sobre archivos de llamadas sospechosas \ņ \n";
	#RECOPILACION DE DATOS POR ENTRADA ESTANDAR

	#OFICINAS----------------------------------------------------------------

	print "Por favor ingrese la o las oficinas para las cuales desea realizar la consulta\n";
	print "Para esto escriba los nombres de las oficinas separadas por , \n";
	print "Por ejemplo:\n";
	print "OFICINA1,OFICINA2,OFICINA3,OFICINA4\n";
	print "Si desea realizar la consulta para todas las oficinas ingrese: TODAS\n";
	
	my $input = '';

	while ( &comprobarOficinas($input) ne '0' )
	{
		$input = <STDIN>;
		chomp( $input );
	}

	$oficinas= $input;
	
	print "\n";	

	#FECHAS----------------------------------------------------------------

	print "Por favor ingrese la o las fechas ( Anio mes: aaaamm ) para las cuales desea realizar la consulta\n";
	print "Para esto escriba las fechas separadas por , \n";
	print "Por ejemplo si queremos las de julio del 2015 y de enero del 2014:\n";
	print "201507,201401\n";
	print "Si desea realizar la consulta para todas las fechas ingrese: TODAS\n";
	
	$input = '';
	
	while ( &comprobarFecha($input) ne '0' )
	{
		$input = <STDIN>;
		chomp( $input );
	}

	$fechas= $input;

	
	print "\n";

	
	#Filtros-------------------------------------------------------------------
	@filtrosRegistros = &filtrosParaRegistros;

	
	&filtrarLlamadasSospechoss($oficinas,$fechas,@filtrosRegistros);
	
}












sub comprobarCentrales{
	my ($centrales) = @_;
	if ( $centrales eq '' ){return 1;}
	return 0;
		
	
}




sub obtenerFiltros
{
	print "Por favor ingrese los filtros que desee agregar:\n";
	print "Debe agregarlos de la siguiente manera:\n";
	print "FILTRO1,FILTRO2,FILTRO3\n";
	print "Para ver los filtros disponibles ingrese: -h\n";
	my $filtros = <STDIN>;
	chomp( $filtros );
	return $filtros;
}








#Faltan las comprobaciones y definir un par de temas sobre los filtros
sub filtrosParaRegistros
{
	
	my $filtros = '';
	
	#CENTRALES-------------------------------------------------
	print "Desea agregar filtros por central? S/N\n";
	my $respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarCentrales;			
			}
		}
		$filtroCentral=$filtro;
	}
	else{my $filtroCentral = '';}	
	



	#AGENTES---------------------------------------------------------
	print "Desea agregar filtros por agente? S/N\n";
	$respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			print "Filtro Agentes\n";
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarAgentes;			
			}
		}
		$filtroAgente=$filtro;
	}
	else{my $filtroAgente ='';}



	#UMBRALES----------------------------------------------------
	print "Desea agregar filtros por umbral? S/N\n";
	$respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarUmbrales;			
			}
		}
		
	}
	else{my $filtroUmbral ='';}




	#LLAMADAS-------------------------------------------------------
	print "Desea agregar filtros por tipo de llamada? S/N\n";
	$respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarTipoLlamadas;			
			}
		}
	}
	else{my $filtroTipoLlamada ='';}





	#TIEMPO CONVERS--------------------------------------------------
	print "Desea agregar filtros por tiempo de conversacion? S/N\n";
	$respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarTiempoConversacion;			
			}
		}
	}
	else{my $filtroTiempoConvers ='';}




	#NUMERO LINEA Y AREA-----------------------------------------------
	print "Desea agregar filtros por area y numero de linea? S/N\n";
	$respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarNumeroA;			
			}
		}
	}
	else{my $filtroNumeroA ='';}


	#PAIS NUMERO DE LINEA-----------------------------------------------
	print "Desea agregar filtros por pais y numero de linea? S/N\n";
	$respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		$filtros = '';
		while( &comprobarCentrales($filtros) ne '0' ){
			$filtros = &obtenerFiltros;
			if ( "$filtros" eq '-h' ) {
				&mostrarNumeroB;			
			}
		}
	}
	else{my $filtroNumeroB ='';}




	@retvalue = ($filtroCentral,$filtroAgente,$filtroUmbral,$filtroTipoLlamada,$filtroTiempoConvers,$filtroNumeroA,$filtroNumeroB);

	return @retvalue;

}














sub filtrarLlamadasSospechosas{

	
	my ($oficinas,$fechas,@filtrosRegistros) = @_;
	
	my $dir = $ENV{"PROCDIR"}."/";
	opendir(DIR,"$dir");
	@FILES = readdir(DIR);

	foreach $file (@FILES){

		

	}



}







#-------------------------------------------------------------------
#INFORMACION--------------------------------------------------------
#-------------------------------------------------------------------



sub mostrarCentrales{
	print "\n";
	print "Centrales Posibles ; Descripcion:\n";
	print "\n";
	$archCentrales = $ENV{"MAEDIR"}."/CdC.mae";
	open(CENTRALES,$archCentrales);
	while(<CENTRALES>){
		chomp;
		print "$_ \n";
	}
	print "\n";
}



sub mostrarAgentes{
	
	print "\n";
	print "Agentes Posibles:\n";
	print "\n";
	$archAgentes = $ENV{"MAEDIR"}."/agentes.mae";
	open(AGENTES,$archAgentes);
	while(<AGENTES>){
		chomp;
		@tokens = split(/;/,$_);
		print "$tokens[0] \n";
	}
	print "\n";


}


sub mostrarUmbrales{
	
	print "\n";
	print "Umbrales Posibles:\n";
	print "Formato:\n";
	print "id umbral; codigo de area de origen; numero de linea origen; tipo de llamada; codigo destino; tope; estado\n";
	print "\n";
	$arch = $ENV{"MAEDIR"}."/umbral.tab";
	open(ARCH,$arch);
	while(<ARCH>){
		chomp;
		print "$_ \n";
	}
	print "\n";


}


sub mostrarTipoLlamada{
	print "\n";
	print "Tipos de llamadas:\n";
	print "\n";
	$arch = $ENV{"MAEDIR"}."/tllama.mae";
	open(ARCH,$arch);
	while(<ARCH>){
		chomp;
		@tokens = split(/;/,$_);
		print "$tokens[1] \n";
	}
	print "\n";

}


sub mostrarNumeroA{
	print "\n";
	print "Codigos de area:\n";
	print "Recuerde que el filtro solo es el numero y no la descripcion \n";
	print "\n";
	$arch = $ENV{"MAEDIR"}."/CdA.mae";
	open(ARCH,$arch);
	while(<ARCH>){
		chomp;
		print "$_\n";
	}
	print "\n";

}



sub mostrarNumeroB{
	print "\n";
	print "Codigos de Pais:\n";
	print "Recuerde que el filtro solo es el numero y no la descripcion \n";
	print "\n";
	$arch = $ENV{"MAEDIR"}."/CdP.mae";
	open(ARCH,$arch);
	while(<ARCH>){
		chomp;
		print "@_\n";
	}
	print "\n";

}




#-------------------------------------------------------------------
#VALIDACIONES-------------------------------------------------------
#-------------------------------------------------------------------

sub comprobarOficinas
{
	my ($oficinas) = @_;
	if ( $oficinas eq '0'){ return 0;}
	else{ return 1; }

}


sub comprobarFecha
{
	my ($entrada) = @_;
	if ( $entrada eq '0' ) { return 0; }
	return 1;
	

}


#-------------------------------------------------------------------
#OTROS--------------------------------------------------------------
#-------------------------------------------------------------------




sub clearScreen
{
	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0

}



sub obtenerSioNo
{
	
	my $entradaCorrecta = 'no';

	while ( $entradaCorrecta ne 'si' ){

		my $input = <STDIN>;
		chomp($input);
		$input = lc( $input );
		if ( $input eq 's' ){ return 0;}
		elsif ( $input eq 'n' ) { return 1;}
		else { print "Entrada incorrecta por favor vuelva a intentar:\n"; }
	}

}





#-----------------------------------------------------------------------------
#CODIGO PRINCIPAL ------------------------------------------------------------
#-----------------------------------------------------------------------------






&menuInformesPrincipal;
