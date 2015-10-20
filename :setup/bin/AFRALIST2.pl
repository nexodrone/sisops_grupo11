#!/usr/bin/perl -w
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
	elsif($primero eq "-r") { consultar();}
	elsif($primero eq "-i") { informar(); }
	elsif($primero eq "-s") { estadisticas();}
	else { 
		print "Opción incorrecta.\n";
    		mostrarAyuda();
    		exit;
    	}
}




sub mostrarAyuda {

print "Ayuda: AFRALIST [opción] [argumentos] 
	  -h                  			Muestra esta ayuda.
	  -w                  			Grabar. 
	  -r[palabra clave]   			Consulta .
	  -i[lista de archivos resultado]   	Información
	  -s                  			Estadísticas\n";
}

sub consultar {


}


sub informar {

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
