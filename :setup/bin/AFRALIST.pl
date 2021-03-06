#! /usr/bin/env perl

#use strict;
#use warnings;
use Fcntl qw(:flock);
use feature qw/switch/; 
#use Switch;
no warnings 'experimental::smartmatch';


our %posCamposCentrales = (
			'codigo' => 0,
			'descripcion' => 1,	
			);

 our %posCamposAgentes = (
			'id' =>0,
                         'nombreCompleto'=>2,
	                 'oficina'=>3,
			 'email'=>4
			     

			);

  our %posCamposPaises =(
			'id' => 0,
			'nombre' => 1,
                          
		        );
our %posCamposCodigosArea=(
		         'codigoArea' => 1,
			'area' => 0,

);

our %posCamposUmbrales= (
		         'idUmbral' => 0,
			

);


our %posCamposLlamadasSospechosa= (
				   'idCentral' => 0,
				   'idAgente' => 1,
				    'idUmbral'=>2,
			            'tipoLlamada'=>3,
				    'inicioLlamada'=>4,
				    'tConv'=>5,
				    'nroArea'=>6,
			            'nroAlinea'=>7,
                                    'nroBcdp'=>8,
                                    'nroBcda'=>9,
                                    'nroBlinea'=>10,
                                    'FechaArchivo'=>11,
	
);
our $pidioGuardar = 0;
our %centralesDesc;
our %agentesMail;
our %agentesOficina;
our %paisesDesc;
our %codigosAreaDesc;
our %rankingOficinas;
our %rankingCentrales;
our %rankingAgentes;
our %rankingUmbrales;
our %rankingLlamadaSospechosa;
our %lineaDestinoArea;
our %lineaDestinoPais;
###### Se valida que el comando no este en ejecución#####
open(my $script_fh, '<', $0)
   or die("No se pudo abrir el archivo: $!\n");

unless (flock($script_fh, LOCK_EX|LOCK_NB)) {
    print "$0 ya se encuentra en ejecución.\n";
    exit(1);
}

###### Se valida ejecucion de AFRAINIC######
# Si no existen las variables de ambiente sabemos que Afranic no se ejecuto
if (!exists($ENV{"MAEDIR"}) && !exists($ENV{"PROCDIR"})  && !exists($ENV{"NOVEDIR"}))
{
	 print "Previamente debe inicializar el ambiente\n";
     exit(1);	  
} 


###### MENU ##############################
###### Si no ingresa ningún parametro se mostrará la ayuda
my $num_parametros = $#ARGV + 1;
#cargarMapaGestiones();
#cargarMapaEmisores();
#cargarMapaNormas();

if ($num_parametros < 1) {
    print "Debe ingresar una opción.\n";
    mostrarAyuda();
    exit;
}else{
	my $primero=$ARGV[0];
	if($primero eq "-h") { mostrarAyuda(); }
	elsif($primero eq "-r") { informar();}
	elsif($primero eq "-i") { informar(); }
	elsif($primero eq "-s") { estadisticas();}
	else { 
		print "Opción incorrecta.\n";
    		mostrarAyuda();
    		exit;
    	}
}




sub mostrarAyuda {

print "Ayuda: AFRALIST [opción]
	  -h                  			Muestra esta ayuda.
	  -r   					Consulta.
	  -s                  			Estadísticas.

 	[argumentos] 
	  -w                  			Grabar. \n";

}

sub consultar {


}


sub informar {

	local ($seGuarda);
	if ( $ARGV[1] eq "-w" ) {
		$seGuarda = 1;
	} else {
		$seGuarda = 0;
	}

	&menuInformesPrincipal;

}


sub estadisticas {

       
	validarGuardarInforme();
	menu_estadistica();


}

sub validarGuardarInforme
{
	my $ultimaEntrada = $ARGV[$#ARGV];
	#print "ultima entrada: $ultimaEntrada";
	if(defined $ultimaEntrada and $ultimaEntrada eq "-w"){
		$pidioGuardar = 1;	
	}

}

# esta función determina si hay que procesar el archivo que se está leyendo. 
sub hayQueProcesar {

return 1; 

}

#*******************************
#métodos de cargas iniciales

sub cargarMapaCentrales
{
	#my $ruta ='./MAEDIR';
	my $ruta = $ENV{"MAEDIR"};
	my $filename = $ruta.'/CdC.mae';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $descripcion = $data[$posCamposCentrales{'descripcion'}];
			my $codigo = $data[$posCamposCentrales{'codigo'}];
			$centralesDesc{$codigo} = $descripcion;
                        $rankingCentrales{$codigo}=0;
		}
	close ($fh);
                                 # print $centralesDesc{'BEL'};
}


sub cargarMapaAgentes
{
        #my $ruta ='./MAEDIR';
	my $ruta = $ENV{"MAEDIR"};
        #print "$ruta";
	my $filename = $ruta.'/agentes.mae';

       

	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $id = $data[$posCamposAgentes{'nombreCompleto'}];
			my $oficina = $data[$posCamposAgentes{'oficina'}];
			my $email=$data[$posCamposAgentes{'email'}];
			
                        $agentesOficina{$id}=$oficina;
			$agentesMail{$id}=$email;
			$rankingOficinas{$oficina}=0;
			$rankingAgentes{$id}=0;
                        #print "$agentesMail{$id}, $id \n";

		}
	close ($fh);
            
                      #print "$agentesOficina{'CARRO'},' ' ,$agentesMail{'CARRO'} \n";


	
}

sub cargarCodigoPaises
{

   #my $ruta ='./MAEDIR';
	my $ruta = $ENV{"MAEDIR"};
	my $filename = $ruta.'/CdP.mae';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $id = $data[$posCamposPaises{'id'}];
			my $nombrePais = $data[$posCamposPaises{'nombre'}];
			
			
                        $paisesDesc{$id}=$nombrePais;
			

		}
	close ($fh);

                
}

sub cargarCodigoArea
{

        #my $ruta ='./MAEDIR';
	my $ruta =$ENV{"MAEDIR"};
        
	my $filename = $ruta.'/CdA.mae';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $codigoArea = $data[$posCamposCodigosArea{'codigoArea'}];
			my $nombreArea = $data[$posCamposCodigosArea{'area'}];
			
			
                        $codigosAreaDesc{$codigoArea}=$nombreArea;
			

		}
	close ($fh);

                       
}

sub cargarUmbrales
{
    #my $ruta ='./MAEDIR';
	my $ruta =$ENV{"MAEDIR"};
        
	my $filename = $ruta.'/umbral.tab';
	open(my $fh,"<$filename")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $filename \n";
		#Leo cada linea 
		while (my $row = <$fh>) {
			chomp $row;
			my @data = split(";",$row);
			my $idUmbral = $data[$posCamposUmbrales{'idUmbral'}];
			
			
			
                        $rankingUmbrales{$idUmbral}=0;
			#print "$rankingUmbrales{$idUmbral}, $idUmbral,\n";

		}
	close ($fh);



}


#******************** calculo estadísticas**************
# se carga el rankings de centrales, previamente tiene que ser inicializado en cero. 
sub leerPorCentrales
{

        limpiarRankingCentrales();
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			my $idCentral = $data[$posCamposLlamadasSospechosa{'idCentral'}];

                        my $idAgente=$data[$posCamposLlamadasSospechosa{'idAgente'}];

                	$rankingCentrales{$idCentral}=$rankingCentrales{$idCentral}+1;

                         #print "$rankingCentrales{$idCentral}, ' ',$idAgente,' ',$idCentral \n";
		}
                close(ENT);
		
	  }
          #print "cantidad de registros $count \n";
	
          
       
}

sub leerPorUmbrales
{

limpiarRankingUmbrales();
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			my $idUmbral = $data[$posCamposLlamadasSospechosa{'idUmbral'}];

                        

                	$rankingUmbrales{$idUmbral}=$rankingUmbrales{$idUmbral}+1;

                         #print "$rankingUmbrales{$idUmbral}, ' ',$idUmbral \n";
		}
                close(ENT);
		
	  }
          #print "cantidad de registros $count \n";
	




}

sub leerPorDestinoSospechoso
{

        limpiarRankingDestinoSospechoso();
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			my $lineaDestino = $data[$posCamposLlamadasSospechosa{'nroBlinea'}];
                        my $codigoArea=$data[$posCamposLlamadasSospechosa{'nroBcda'}];
                        my $codigoPais=$data[$posCamposLlamadasSospechosa{'nroBcdp'}];
                        

                	$rankingLlamadaSospechosa{$lineaDestino}=$rankingLlamadaSospechosa{$lineaDestino}+1;
                        $lineaDestinoArea{$lineaDestino}=$codigoArea;
                        $lineaDestinoPais{$lineaDestino}=$codigoPais;
                        if ($codigoPais eq ''){
			$lineaDestinoPais{$lineaDestino}=54;
			}

                         #print "$rankingUmbrales{$idUmbral}, ' ',$idUmbral \n";
		}
                close(ENT);
		
	  }
          #print "cantidad de registros $count \n";
	




}


sub leerPorOficinas
{
        limpiarRankingOficinas();
	#limpiarRankingCentrales();
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
               
		my @fields = split /_/, $nombreArchivo;
                
		my $oficina = $fields[0];
                
		$rankingOficinas{$oficina}=$rankingOficinas{$oficina} +1;

		#print "$oficina,$rankingOficinas{$oficina}\n";


          	#print "$nombreArchivo \n";


                close(ENT);
		
	  }




}


#carga el ranking de agentes, previamente tiene que estar inicializado en 0
sub leerPorAgentes
{

        limpiarRankingAgentes();

        
        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			#my $idCentral = $data[$posCamposLlamadasSospechosa{'idCentral'}];

                        my $idAgente=$data[$posCamposLlamadasSospechosa{'idAgente'}];
                       # print "$rankingAgentes{$idAgente},$idAgente \n";

                	$rankingAgentes{$idAgente}=$rankingAgentes{$idAgente}+1;

                         #print "$rankingAgentes{$idAgente}, ' ',$idAgente \n";
		}
                close(ENT);
		
	  }
          
	
          
       





}

sub limpiarRankingCentrales{
           
          foreach my $name (keys %rankingCentrales) {
	    	 $rankingCentrales{$name}=0;
	}
		 
                 

             
}

sub limpiarRankingOficinas
{

     

#my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
               
		my @fields = split /_/, $nombreArchivo;
		my $oficina = $fields[0];
                
		$rankingOficinas{$oficina}=0;

		#print "$oficina,$rankingOficinas{$oficina}\n";


          	#print "$nombreArchivo \n";


                close(ENT);
		
	  }

      


}


sub limpiarRankingDestinoSospechoso
{


        #my $dir= './PROCDIR';
	my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			my $lineaDestino = $data[$posCamposLlamadasSospechosa{'nroBlinea'}];
                        
                        

                	$rankingLlamadaSospechosa{$lineaDestino}=0;

                         #print "$rankingUmbrales{$idUmbral}, ' ',$idUmbral \n";
		}
                close(ENT);
		
	  }
          #print "cantidad de registros $count \n";
	






}

sub limpiarRankingAgentes
{


my $dir = $ENV{"PROCDIR"};
	

	opendir(DIR,$dir) || die "# buscador : no puedo abrir $dir\n";
        my @nodos = grep(!/^\./, (sort(readdir(DIR)))); # esquiva archivos ocultos, . y ..
        closedir(DIR); 
	
	

	foreach my $nodo (@nodos)  
	{
		  
		 my $nombreArchivo = $nodo;
                 
                my $filename = $dir.'/'.$nombreArchivo;
		open(ENT,"<$filename")|| die "NO SE PUEDE REALIZAR LA ACCIÓN. No se encontro el archivo $filename \n";
		#Leo cada linea 
          	
          	while( my $row = <ENT> ) { 
                        #print "$row \n";
			chomp($row);
			my @data = split(";",$row);
			#my $idCentral = $data[$posCamposLlamadasSospechosa{'idCentral'}];

                        my $idAgente=$data[$posCamposLlamadasSospechosa{'idAgente'}];
                       # print "$rankingAgentes{$idAgente},$idAgente \n";

                	$rankingAgentes{$idAgente}=0;

                         #print "$rankingAgentes{$idAgente}, ' ',$idAgente \n";
		}
                close(ENT);
		
	  }





}


sub limpiarRankingUmbrales
{

foreach my $name (keys %rankingUmbrales) {
	    	 $rankingUmbrales{$name}=0;
                # print "$rankingUmbrales{$name}, $name \n";
	}
	



}
#************impresión**************************


sub imprimirRankingCentrales
{
	 my $resultadoArchivo = ""; 
	
          
         
my @keys = sort {$rankingCentrales{$b}  <=> $rankingCentrales{$a} } keys %rankingCentrales;

foreach my $key ( @keys ) {
    
         if ($rankingCentrales{$key} !=0){
          $resultadoArchivo .= "$rankingCentrales{$key}  $key  $centralesDesc{$key}\n";
	 }
}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"rankingCentrales");	
	}

}

sub imprimirRankingOficinas
{

		my $resultadoArchivo = ""; 
		my @keys = sort {$rankingOficinas{$b}  <=> $rankingOficinas{$a} } keys %rankingOficinas;

		foreach my $key ( @keys ) {
                   
                   if ($rankingOficinas{$key} != 0)
                      	{

    
          		$resultadoArchivo .= "$rankingOficinas{$key}  $key \n";
			}
		}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"rankingOficinas");	
	}



}

sub imprimirRankingAgentes
{


		my $resultadoArchivo = ""; 
		my @keys = sort {$rankingAgentes{$b}  <=> $rankingAgentes{$a} } keys %rankingAgentes;

		foreach my $key ( @keys ) {
                   
                   if ($rankingAgentes{$key} != 0)
                      	{

    
          		$resultadoArchivo .= "$rankingAgentes{$key} $key $agentesMail{$key} $agentesOficina{$key} \n";
			}
		}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"rankingAgentes");	
	}







}




sub imprimirRankingUmbrales 
{


   my $resultadoArchivo = ""; 
		my @keys = sort {$rankingUmbrales{$b}  <=> $rankingUmbrales{$a} } keys %rankingUmbrales;

		foreach my $key ( @keys ) {
                   
                   if ($rankingUmbrales{$key} >1)
                      	{

    
          		$resultadoArchivo .= "ocurrencia: $rankingUmbrales{$key} id de Umbral:$key  \n";
			}
		}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"rankingUmbrales");	
	}



}

sub imprimirRankingDestinoSospechoso
{

		my $resultadoArchivo = ""; 
		my @keys = sort {$rankingLlamadaSospechosa{$b}  <=> $rankingLlamadaSospechosa{$a} } keys %rankingLlamadaSospechosa;

		foreach my $key ( @keys ) {
                   
                   if ($rankingLlamadaSospechosa{$key} >0)
                      	{
                              

    
          $resultadoArchivo .= "ocurrencia: $rankingLlamadaSospechosa{$key}  codigo de pais:$lineaDestinoPais{$key} pais:$paisesDesc{$lineaDestinoPais{$key}} codigo de area:$lineaDestinoArea{$key} area:$codigosAreaDesc{$lineaDestinoArea{$key}}  numero de linea:$key  \n";
			}
		}


           print $resultadoArchivo;
	if($pidioGuardar == 1){
		grabar($resultadoArchivo,"rankingLlamadaSospechosa");	
	}



}

sub grabar 
{
	my $resultado = $_[0];
	my $nombre = $_[1];
	my $ruta = $ENV{"GRUPO"}.'/'.'reportes';
	
	
	my $epoc = time();
	my $nombreArchivo = $ruta."/".$nombre."_".$epoc.".txt";
	
	if(defined $resultado){
		open FILE, ">".$nombreArchivo or die $!; 
		print FILE "$resultado\n"; 
		close FILE;
		print "Se generó el archivo $nombreArchivo\n";
	}else{
		print "La consulta no produjo resultados.\n";
	}

}


sub clear_screen
{
    system("clear");
}
#*****************Estadisticas*********************
sub menu_estadistica
{ 
limpiarRankingOficinas();
cargarMapaAgentes();
cargarMapaCentrales();
cargarCodigoPaises();
cargarCodigoArea();
cargarUmbrales();
leerPorCentrales();
leerPorOficinas();
leerPorAgentes();
leerPorUmbrales();
leerPorDestinoSospechoso();
#clear_screen();

	my $input = '';

	while ($input ne '6')
	{
	    
	    print " \n";
 	    print "************MENÚ Estadisticas************ \n";		
	    print "1. Ranking de centrales con llamadas sospechosas\n". 
		  "2. Ranking de oficinas con llamadas sospechosas\n". 
                  "3. Ranking de agentes con llamadas sospechosas \n".
                  "4. Ranking de destinos con llamadas sospechosas \n".
                  "5. Ranking de umbrales con mas de una llamada sospechosa \n".
		  "6. Salir\n";

	    print "Ingrese su opción: ";
	    $input = <STDIN>;
	    chomp($input);

	    given ($input)
	    {
		when('1')
		{
		    imprimirRankingCentrales();

		}
		when('2')

		{   
                    imprimirRankingOficinas();
		    	
		}
		when('3') { imprimirRankingAgentes(); }
		
                when('4'){imprimirRankingDestinoSospechoso();}
                
                when('5') {imprimirRankingUmbrales(); }
               
                when('6') {}


		default {
			print "Opción Incorrecta! \n";
		}

	    }#del switch
	}#del while

	exit(0);             
}









#     PARTE INFORMES -----------------------------------------------------------


#opcion -r


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
		print "$tokens[2] \n";
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


sub mostrarTipoLlamadas{
	print "\n";
	print "Tipos de llamadas:\n";
	print "\n";
	$arch = $ENV{"MAEDIR"}."/tllama.tab";
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
		print "$_\n";
	}
	print "\n";

}





#-------------------------------------------------------------------
#MENUS e INTERFACES-------------------------------------------------
#-------------------------------------------------------------------


sub menuInformesPrincipal
{	
	
	my $input = '';
	while ($input ne '3')
	{
		&clearScreen;

		print "Por favor ingrese la opcion deseada ( 1 , 2 o 3 ):\n";
		print "1- Realizar consultas sobre archivos de llamadas sospechosas \n";
		print "2- Realizar consultas sobre archivos de consultas previas \n";
		print "3- Salir\n";

		$input = <STDIN>;
		chomp($input);
		
		if ( $input eq '1' ) { &llamadasSospechosas; }	#Consultas sobre archivos llam sospe
		elsif ( $input eq '2' ) { &consultasPrevias; } # Consultas previas
		elsif ( $input eq '3' ) { } #Salir
		else {  &clearScreen;
			print "Opcion invalida por favor ingrese nuevamente \n";
			print "\n";}

			
	}
	
	&clearScreen;
}


sub hayArchivosDeSubllamadas{
	my $dir = $ENV{"REPODIR"};
	opendir(DIR,"$dir");
	@FILES = readdir(DIR);
	foreach $file (@FILES){
		
		my ($subllam,$num) = split(/\./,$file);
		
		if( $subllam eq "subllamadas")
		{ closedir(DIR); return 0; }

	}

	closedir(DIR);
	return 1;


}

sub imprimirNumerosDeSubllamadasPosibles{
	my $dir = $ENV{"REPODIR"};
	opendir(DIR,"$dir");
	@FILES = readdir(DIR);
	print "Numeros posibles:\n";
	foreach $file (@FILES){
		
		my ($subllam,$num) = split(/\./,$file);
		
		if( $subllam eq "subllamadas")
		{ print "$num\n";}

	}
	print "\n";

	closedir(DIR);


}


sub comprobarSubllamadas{
	my ($subllamadas) = @_;
	if ( $subllamadas eq "" ) {return 0;}
	my $dir = $ENV{"REPODIR"};
	opendir(DIR,"$dir");
	my @FILES = readdir(DIR);

	my @SUBLLAMS = split(/,/,$subllamadas);

	foreach $file (@FILES){
		
		my ($subllam,$num) = split(/\./,$file);
		
		if( $subllam eq "subllamadas")
		{ 	foreach my $llam (@SUBLLAMS){
				if( $num eq $llam ){
					closedir(DIR); return 0; }
			}
		}

	}
	print "Numero incorrecto por favor intente nuevamente\n";
	closedir(DIR);
	return 1;
	

}





sub consultasPrevias{

	if (&hayArchivosDeSubllamadas ne '0'){
		print "Actualmente no hay archivos de subllamadas en el directorio\n";
		return 0;
	}
	print "Por favor ingrese la o las oficinas para las cuales desea realizar la consulta\n";
	print "\n";
	print "Para esto escriba los numeros de los archivos (subllamada.numero) separadas por , \n";
	print "\n";
	print "Por ejemplo:\n";
	print "\n";
	print "1,2,3\n";
	print "\n";
	print "Si desea realizar la consulta para todos los archivos no ingrese ninguno ( presione ENTER )\n";
	print "\n";
	&imprimirNumerosDeSubllamadasPosibles;

	my $input = '1';

	do
	{
		$input = <STDIN>;
		chomp( $input );
	}while ( &comprobarSubllamadas($input) ne '0' );
	
	my $nroSubllam = $input;
	my @filtrosRegistros = &filtrosParaRegistros;

	
	&filtrarConsultasPrevias($nroSubllam,@filtrosRegistros);

}




sub llamadasSospechosas
{
	&clearScreen;
	print "Usted escogio la opcion de realizar consultas sobre archivos de llamadas sospechosas \n \n";
	#RECOPILACION DE DATOS POR ENTRADA ESTANDAR

	#OFICINAS----------------------------------------------------------------

	print "Por favor ingrese la o las oficinas para las cuales desea realizar la consulta\n";
	print "\n";
	print "Para esto escriba los nombres de las oficinas separadas por , \n";
	print "\n";
	print "Por ejemplo:\n";
	print "OFICINA1,OFICINA2,OFICINA3,OFICINA4\n";
	print "\n";
	print "Si desea realizar la consulta para todas las oficinas no ingrese ninguna\n";
	print "\n";

	my $input = '1';

	do
	{
		$input = <STDIN>;
		chomp( $input );
	}while ( &comprobarOficinas($input) ne '0' );

	my $oficinas= $input;
	
	print "\n";	
	
	&clearScreen;

	#FECHAS----------------------------------------------------------------

	print "Por favor ingrese la o las fechas ( Anio mes: aaaamm ) para las cuales desea realizar la consulta\n";
	print "\n";
	print "Para esto escriba las fechas separadas por , \n";
	print "\n";
	print "Por ejemplo si queremos las de julio del 2015 y de enero del 2014:\n";
	print "201507,201401\n";
	print "\n";
	print "Si desea realizar la consulta para todas las fechas no ingrese ninguna\n";
	print "\n";


	$input = '1';
	
	do
	{
		
		$input = <STDIN>;
		chomp( $input );
		
	}while ( &comprobarFecha($input) ne '0' );

	my $fechas= $input;

	
	print "\n";

	
	#Filtros-------------------------------------------------------------------
	my @filtrosRegistros = &filtrosParaRegistros;

	
	&filtrarLlamadasSospechosas($oficinas,$fechas,@filtrosRegistros);
	
}













sub obtenerFiltros
{
	my ($ejemplo) = @_;

	print "Por favor ingrese los filtros que desee agregar:\n";
	print "Debe agregarlos de la siguiente manera:\n";
	print "$ejemplo \n";
	print "Para ver los filtros disponibles ingrese: -h\n";
	print "Recuerde que debe ingresar al menos 1 filtro valido para continuar:\n";
	my $filtros = <STDIN>;
	chomp( $filtros );
	return $filtros;
}








#Faltan las comprobaciones y definir un par de temas sobre los filtros
sub filtrosParaRegistros
{
	&clearScreen;

	my $filtros = "";

	my $filtroCentral="";
	#CENTRALES-------------------------------------------------
	print "Desea agregar filtros por central? S/N\n";
	my $respuesta = &obtenerSioNo;
	if ( $respuesta eq '0' ){
		while( &comprobarCentrales($filtroCentral) ne '0' ){
			$filtroCentral = &obtenerFiltros("BEL,ACD,CDG");
			if ( "$filtroCentral" eq '-h' ) {
				&mostrarCentrales;			
			}
		}
	}
	else{ $filtroCentral = "";}	
	

	&clearScreen;

	#AGENTES---------------------------------------------------------
	print "Desea agregar filtros por agente? S/N\n";
	$respuesta = &obtenerSioNo;
	my $filtroAgente ="";
	if ( $respuesta eq '0' ){

		while( &comprobarAgentes($filtroAgente) ne '0' ){
			print "Filtro Agentes\n";
			$filtroAgente = &obtenerFiltros("PEREZJORGE,SIGNORIJAVIER");
			if ( "$filtroAgente" eq '-h' ) {
				&mostrarAgentes;			
			}
		}
	}
	else{$filtroAgente ="";}

&clearScreen;

	#UMBRALES----------------------------------------------------
	print "Desea agregar filtros por umbral? S/N\n";
	$respuesta = &obtenerSioNo;
	my $filtroUmbral ="";
	if ( $respuesta eq '0' ){

		while( &comprobarUmbrales($filtroUmbral) ne '0' ){
			$filtroUmbral = &obtenerFiltros("200,201,199");
			if ( "$filtroUmbral" eq '-h' ) {
				&mostrarUmbrales;			
			}
		}
		
	}
	else{ $filtroUmbral ="";}

&clearScreen;


	#LLAMADAS-------------------------------------------------------
	print "Desea agregar filtros por tipo de llamada? S/N\n";
	$respuesta = &obtenerSioNo;
	my $filtroTipoLlamada ="";
	if ( $respuesta eq '0' ){

		while( &comprobarTipoLlamada($filtroTipoLlamada) ne '0' ){
			$filtroTipoLlamada = &obtenerFiltros("DDI,DDN,LOC");
			if ( "$filtroTipoLlamada" eq '-h' ) {
				&mostrarTipoLlamadas;			
			}
		}
	}
	else{my $filtroTipoLlamada ="";}


&clearScreen;


	#TIEMPO CONVERS--------------------------------------------------
	print "Desea agregar filtros por tiempo de conversacion? S/N\n";
	$respuesta = &obtenerSioNo;
	my $filtroTiempoConvers ="";
	if ( $respuesta eq '0' ){

		while( &comprobarTiempoDeConversacion($filtroTiempoConvers) ne '0' ){
			$filtroTiempoConvers = &obtenerFiltros("133,122,10");
			if ( "$filtroTiempoConvers" eq '-h' ) {
				print "\n";
				print "El tiempo de conversacion debe ser un numero entero decimal\n";	
				print "\n";
			}
		}
	}
	else{my $filtroTiempoConvers ="";}


&clearScreen;

	#NUMERO LINEA Y AREA-----------------------------------------------
	print "Desea agregar filtros por area y numero de linea? S/N\n";
	$respuesta = &obtenerSioNo;
	my $filtroNumeroA ="";
	if ( $respuesta eq '0' ){
		
		while( &comprobarNumeroA($filtroNumeroA) ne '0' ){
			$filtroNumeroA = &obtenerFiltros("codigo de area - numero de linea: 11-31390136,220-31490141");
			if ( "$filtroNumeroA" eq '-h' ) {
				&mostrarNumeroA;			
			}
		}
	}
	else{ $filtroNumeroA ="";}

&clearScreen;


	#PAIS NUMERO DE LINEA-----------------------------------------------
	#print "Desea agregar filtros por pais y numero de linea? S/N\n";
	#$respuesta = &obtenerSioNo;
	#my $filtroNumeroB ="";
	#if ( $respuesta eq '0' ){
	#
	#	while( &comprobarNumeroB($filtroNumeroB) ne '0' ){
	#		$filtroNumeroB = &obtenerFiltros("codigo de pais - numero de linea: 994-31390136,387-31490141");
	#		if ( "$filtroNumeroB" eq '-h' ) {
	#			&mostrarNumeroB;			
	#		}
	#	}
	#}
	#else{ $filtroNumeroB ="";}


&clearScreen;

	

	my @retvalue = ($filtroCentral,$filtroAgente,$filtroUmbral,$filtroTipoLlamada,$filtroTiempoConvers,$filtroNumeroA);

	return @retvalue;

}










#-------------------------------------------------------------------
#VALIDACIONES-------------------------------------------------------
#-------------------------------------------------------------------



sub is_integer {
   defined $_[0] && $_[0] =~ /^[+-]?\d+$/;
}

sub comprobarTiempoDeConversacion{
	my ($valor) = @_;

	@VALORES = split(/,/,$valor);
	foreach $val (@VALORES){
		if( is_integer($val) ){return 0;}

	}
	return 1;

}


sub comprobarOficinas
{
	my ($valor) = @_;
	if ( $valor eq "" ){ return 0;}
	my $arch = $ENV{"MAEDIR"}."/agentes.mae";
	my $pos = 3;
	if ( &comprobarValorEnElArchivo($valor,$arch,$pos) eq '0' ){return 0;}

	print "Oficina/s invalida/s por favor intente nuevamente:\n";

	return 1;

}


sub comprobarFecha
{
	my ($entrada) = @_;
	if($entrada eq ""){return 0;}

	my @FECHAS = split(/,/,$entrada);

	my ($segundo,$min,$h,$d,$mesActual,$anioActual,$diaSemana) = (localtime(time))[0,1,2,3,4,5,6];
	$anioActual += 1900;
	
	foreach my $fecha (@FECHAS){
		
		if( length $fecha eq '6' ){

			my $anio = substr $fecha,0,4;
			my $mes = substr $fecha,4,5;
			$mes =~ s/(0)([0-9])/\2/;


			if( &is_integer($anio) and
				&is_integer($mes) and
				$anio <= $anioActual and
				$mes <= 12 and
				$mes >= 1){
					if( $anio == $anioActual and
						$mes <= $mesActual ){
						return 0;
					}
					elsif( $anio < $anioActual){
						return 0;
					}

				}
				
		}
	} 
	print "Fecha/s invalida/s por favor intente nuevamente:\n";
	return 1;
	

}


sub comprobarCentrales{
	my ($valor) = @_;
	
	my $arch = $ENV{"MAEDIR"}."/CdC.mae";
	my $pos = 0;
	if ( &comprobarValorEnElArchivo($valor,$arch,$pos) eq '0' ){return 0;}
	return 1;	
	
}

sub comprobarAgentes{
	my ($valor) = @_;
	
	my $arch = $ENV{"MAEDIR"}."/agentes.mae";
	my $pos = 2;
	if ( &comprobarValorEnElArchivo($valor,$arch,$pos) eq '0' ){return 0;}
	return 1;	

}


sub comprobarUmbrales{
	my ($valor) = @_;
	
	my $arch = $ENV{"MAEDIR"}."/umbral.tab";

	my $pos = 0;
	if ( &comprobarValorEnElArchivo($valor,$arch,$pos) eq '0' ){return 0;}
	return 1;
}


sub comprobarTipoLlamada{
	my ($valor) = @_;
	my $arch = $ENV{"MAEDIR"}."/tllama.tab";
	my $pos = 1;

	if ( &comprobarValorEnElArchivo($valor,$arch,$pos) eq '0' ){return 0;}
	return 1;

}




sub comprobarNumeroA{
	my ($valor) = @_;
	my $arch = $ENV{"MAEDIR"}."/CdA.mae";
	my $pos = 1;
	my $cods = "";
	@NUMEROS = split(/,/, $valor);
	foreach $num (@NUMEROS){
	
		my ($codigo,$linea) = split(/-/,$num);
		
		$cods = $cods.$codigo.",";

	}
	chop($cods);
	if ( &comprobarValorEnElArchivo($cods,$arch,$pos) eq '0' ){return 0;}
	return 1;


}


#sub comprobarNumeroB{
#	my ($valor) = @_;
#	my $arch = $ENV{"MAEDIR"}."/CdP.mae";
#	my $pos = 0;
#	my $cods = "";
#	my @NUMEROS = split(/,/, $valor);
#	foreach my $num (@NUMEROS){
#	
#		my ($codigo,$linea) = split(/-/,$num);
#		
#		$cods = $cods.$codigo.",";
#
#	}
#	chop($cods);
#	if ( &comprobarValorEnElArchivo($cods,$arch,$pos) eq '0' ){return 0;}
#	return 1;
#}


sub comprobarValorEnElArchivo{

	my ($valor,$arch,$pos) = @_;
	my @VALS = split(/,/,$valor);

	open(ARCH,$arch);

	while(<ARCH>){
		chomp;
		my @tokens = split(/;/,$_);
		foreach my $item (@VALS){
			if( "$item" eq $tokens[$pos] ){return 0;}
		}
	}
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

sub proximaSubllamada
{
	my (@archivos);
	my (@subllamadas);
	my ($local);
	my ($localnum);

	opendir(REPOS,"$ENV{REPODIR}");
	@archivos = readdir(REPOS);
	closedir(REPOS);
	foreach $archivo (@archivos) {
		if ( "$archivo" =~ /^subllamadas\.[0-9][0-9][0-9]$/ ) {
			($local,$localnum) = split(/\./,$archivo);
			if ( "$localnum" =~ /^0[0-9][0-9]$/ ) {
				$localnum =~ s/^(0)([0-9][0-9])$/\2/;
				if ( "$localnum" =~ /^0[0-9]$/ ) {
					$localnum =~ s/^(0)([0-9])$/\2/;
				}
			}
			push(@subllamadas,$localnum);
		}
	}

	if ( @subllamadas > 0 ) {
		@subllamadas = sort { $a <=> $b } @subllamadas;
		my ($proximo) = $subllamadas[$#subllamadas];
		$proximo++;
		if ( "$proximo" =~ /^[0-9]$/ ) {
			$proximo = "00".$proximo;
		}
		if ( "$proximo" =~ /^[0-9][0-9]$/ ) {
			$proximo = "0".$proximo;
		}
		return $proximo;
	} else {
		return "000";
	}
}



sub filtrarRegistrosDelArchivo{

	my $hayQueMostrarlo='0';

	my ($file,@filtrosRegistros) = @_;

	my ($filtroCentral,$filtroAgente,$filtroUmbral,$filtroTipoLlamada,$filtroTiempoConvers,$filtroNumeroA) = @filtrosRegistros;	

	open(ARCH,"$file");

	while ( <ARCH> ){
		my $line = $_;
		my ($central,$agente,$umbral,$tipoLLam,$iniLlam,$tiempo,$Aarea,$Alinea,$Barea,$Blinea,$fecha) = split(/;/,$line); 

		if ( &perteneceAlFiltro($agente,$filtroAgente) eq '0' and
			&perteneceAlFiltro($central,$filtroCentral) eq '0' and
			&perteneceAlFiltro($tipoLLam,$filtroTipoLlamada) eq '0' and
			&perteneceAlFiltro($tiempo,$filtroTiempoConvers) eq '0' and
			&perteneceAlFiltro($Aarea.'-'.$Alinea,$filtroNumeroA) eq '0' and
			&perteneceAlFiltro($umbral,$filtroUmbral) eq '0' )
		{
			push(@registrosFiltrados,$line);

		}
				
	}

	close(ARCH);


}


sub perteneceAlFiltro{
	my ($valor,$filtros) = @_;
	
	if ( defined $filtros ){
		if ( "$filtros" ne "" ){
			@vectorFiltros = split(/,/,$filtros);
			foreach $filtro (@vectorFiltros){
				if ( $valor eq $filtro ){
					return 0;			
				}
			}
		return 1;
		}
	}
	return 0;

}




sub imprimirFiltros{

	my ($filtros,$titulo) = @_;

	if ( $filtros ne "" ){
		print "$titulo\n";
		@FILT = split(/,/,$filtros);
		foreach $filtro (@FILT){
			print "$filtro\n";
		}
		print "\n";
	}
}



sub filtrarConsultasPrevias{
	&clearScreen;

	my ($nroSubllamada,@filtrosRegistros) = @_;


	print "FILTROS UTILIZADOS:\n";
	
	
	&imprimirFiltros($nroSubllamada,"NUMEROS DE ARCHIVOS DE SUBLLAMADAS:");
	
	&imprimirFiltros($filtrosRegistros[0],"CENTRALES:");
	&imprimirFiltros($filtrosRegistros[1],"AGENTES:");
	&imprimirFiltros($filtrosRegistros[2],"UMBRALES:");
	&imprimirFiltros($filtrosRegistros[3],"TIPOS DE LLAMADAS:");
	&imprimirFiltros($filtrosRegistros[4],"TIEMPO DE CONVERSACION:");
	&imprimirFiltros($filtrosRegistros[5],"CODIGO DE AREA Y NUMERO DE LINEA:");
	&imprimirFiltros($filtrosRegistros[6],"CODIGO DE PAIS Y NUMERO DE LINEA:");
	
	local (@registrosFiltrados);
	
	
	my $dir = $ENV{"REPODIR"}."/";
	opendir(DIR,"$dir");
	@FILES = readdir(DIR);

	print "REGISTROS:\n";
	foreach $file (@FILES){
		
		
		my ($subllam,$num) = split(/\./,$file);
		
		
		#filtrar por oficinas y por fechas
		if ( $subllam eq "subllamadas" &perteneceAlFiltro($num,$nroSubllamada) eq '0' ){
			
			#filtros de retgistros
			&filtrarRegistrosDelArchivo($dir.$file,@filtrosRegistros);

			
		
			
			
		}	

	}

	@registrosFiltrados = sort(@registrosFiltrados);
	if ( $seGuarda == 1 ) {
		my ($nroSubllamada) = &proximaSubllamada;
		my ($archivoSubllamada) = "$ENV{REPODIR}/subllamadas.$nroSubllamada";
		open(SUBLLAMADA,">$archivoSubllamada");
		foreach (@registrosFiltrados) {
			print SUBLLAMADA "$_";
		}
		close(SUBLLAMADA);
		print "Se grabaron ".@registrosFiltrados." registros en \"subllamadas.$nroSubllamada\"\n";
	} else {
		foreach (@registrosFiltrados) {
			print "$_\n";
		}
	}
	
	print "\n";
	print "Presione alguna tecla para volver al menu.\n";
	my $input = <STDIN>;



}






sub filtrarLlamadasSospechosas{

	&clearScreen;

	my ($oficinas,$fechas,@filtrosRegistros) = @_;


	print "FILTROS UTILIZADOS:\n";
	
	
	&imprimirFiltros($oficinas,"OFICINAS:");
	
	&imprimirFiltros($fechas,"FECHAS:");
	&imprimirFiltros($filtrosRegistros[0],"CENTRALES:");
	&imprimirFiltros($filtrosRegistros[1],"AGENTES:");
	&imprimirFiltros($filtrosRegistros[2],"UMBRALES:");
	&imprimirFiltros($filtrosRegistros[3],"TIPOS DE LLAMADAS:");
	&imprimirFiltros($filtrosRegistros[4],"TIEMPO DE CONVERSACION:");
	&imprimirFiltros($filtrosRegistros[5],"CODIGO DE AREA Y NUMERO DE LINEA:");
	&imprimirFiltros($filtrosRegistros[6],"CODIGO DE PAIS Y NUMERO DE LINEA:");
	
	local (@registrosFiltrados);
	
	
	my $dir = $ENV{"PROCDIR"}."/";
	opendir(DIR,"$dir");
	@FILES = readdir(DIR);

	print "REGISTROS:\n";
	foreach $file (@FILES){
		
		if ( $file ne 'proc' and $file ne '.' and $file ne '..'){
			my ($oficina,$fecha) = split(/_/,$file);
			
			#filtrar por oficinas y por fechas
			if ( &perteneceAlFiltro($oficina,$oficinas) eq '0' and &perteneceAlFiltro($fecha,$fechas) eq '0'){

				#filtros de retgistros
				&filtrarRegistrosDelArchivo($dir.$file,@filtrosRegistros);

			}
		
			
			
		}	

	}

	@registrosFiltrados = sort(@registrosFiltrados);
	if ( $seGuarda == 1 ) {
		my ($nroSubllamada) = &proximaSubllamada;
		my ($archivoSubllamada) = "$ENV{REPODIR}/subllamadas.$nroSubllamada";
		open(SUBLLAMADA,">$archivoSubllamada");
		foreach (@registrosFiltrados) {
			print SUBLLAMADA "$_";
		}
		close(SUBLLAMADA);
		print "Se grabaron ".@registrosFiltrados." registros en \"subllamadas.$nroSubllamada\"\n";
	} else {
		foreach (@registrosFiltrados) {
			print "$_\n";
		}
	}
	
	print "\n";
	print "Presione alguna tecla para volver al menu.\n";
	my $input = <STDIN>;


}


#-----------------------------------------------------------------------------
#CODIGO PRINCIPAL ------------------------------------------------------------
#-----------------------------------------------------------------------------










