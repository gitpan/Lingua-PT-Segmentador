package Lingua::PT::Segmentador;

use 5.006001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Lingua::PT::Segmentador ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(separa_frases sentences);
our $VERSION = '0.01';


our %savit_p = ();
our $savit_n = 0;

sub savit{
  my $a=shift;
  $savit_p{++$savit_n}=$a ;
  " __MARCA__$savit_n "
}

sub loadit{
  my $a = shift;
  $a =~ s/ ?__MARCA__(\d+) ?/$savit_p{$1}/g;
  $savit_n = 0;
  $a;
}

sub sentences{
  my $protect = '
       \#n\d+
    |  \w+\'\w+
    |  [\w_.-]+ \@ [\w_.-]+\w                    # emails
    |  \w+\.[��]                                 # ordinals
    |  <[^>]*>                                   # marcup XML SGML
    |  \d+(?:\.\d+)+                             # numbers
    |  \d+\:\d+                                  # the time
    |  ((https?|ftp|gopher)://|www)[\w_./~-]+\w  # urls
    |  \w+(-\w+)+                                # d�-lo-�
 ';

  my $abrev = join '|', qw( srt?a? dra? etc exa? jr profs? arq av estr?
  			  et al vol no eng tv lgo pr Oliv ig mrs? min rep );

  my $terminador='([.?!;]+[�]?|<[pP]\b.*?>|<br>|:[\s\n](?=[-�"][A-Z]))';

  my @r;
  my $MARCA = "\0x01";
  my $par = shift;
  for ($par) {
    s!($protect)!          savit($1)!xge;
    s!\b(($abrev)\.)!      savit($1)!ige;
    s!\b(([A-Z])\.)!       savit($1)!ge;  # este � parte para n�o apanhar min�lculas (s///i)
    s!($terminador)!$1$MARCA!g;
    $_ = loadit($_);
    @r = split(/$MARCA/,$_);
  }
  if (@r && $r[-1] =~ /^\s*$/s)        {pop(@r);}
  @r;
}


sub tratar_pontuacao_interna {
  my $par = shift;

  #    print "Estou no pontua��o interna... $par\n";

  for ($par) {
    # proteger o �
    s/�/��/g;

    # tratar das retic�ncias
    s/\.\.\.+/�/g;

    s/\+/\+\+/g;

    # tratar de iniciais seguidas por ponto, eventualmente com
    # par�nteses, no fim de uma frase
    s/([A-Z])\. ([A-Z])\.(\s*[])]*\s*)$/$1+ $2+$3 /g;

    # iniciais com espa�o no meio...
    s/ a\. C\./ a+C+/g;
    s/ d\. C\./ d+C+/g;

    # tratar dos pontos nas abreviaturas
    s/\.�/�+/g;
    s/�\./+�/g;
    s/\.�/+�/g;
    s/�\./�+/g;

    #s� mudar se n�o for amb�guo com ponto final
    s/�\. +([^A-Z��������\�])/�+ $1/g;

    # formas de tratamento
    s/Ex\./Ex+/g; # Ex.
    s/ ex\./ ex+/g; # ex.
    s/Exa(s*)\./Exa$1+/g; # Exa., Exas.
    s/ exa(s*)\./ exa$1+/g; # exa., exas
    s/Pe\./Pe+/g;
    s/Dr(a*)\./Dr$1+/g; # Dr., Dra.
    s/ dr(a*)\./ dr$1+/g; # dr., dra.
    s/ drs\./ drs+/g; # drs.
    s/Eng(a*)\./Eng$1+/g; # Eng., Enga.
    s/ eng(a*)\./ eng$1+/g; # eng., enga.
    s/([Ss])r(t*)a\./$1r$2a+/g; # Sra., sra., Srta., srta.
    s/([Ss])r(s*)\./$1r$2+/g; # Sr., sr., Srs., srs.
    s/ arq\./ arq+/g; # arq.
    s/Prof(s*)\./Prof$1+/g; # Prof., Profs.
    s/Profa(s*)\./Profa$1+/g; # Profa., Profas.
    s/ prof(s*)\./ prof$1+/g; # prof., profs.
    s/ profa(s*)\./ profa$1+/g; # profa., profas.
    s/\. Sen\./+ Sen+/g; # senador (vem sempre depois de Av. ou R. ...)
    s/ua Sen\./ua Sen+/g; # senador (depois [Rr]ua ...)
    s/Cel\./Cel+/g; # coronel
    s/ d\. / d+ /g; # d. Luciano

    # partes de nomes (pospostos)
    s/ ([lL])da\./ $1da+/g; # limitada
    s/ cia\./ cia+/g; # companhia
    s/Cia\./Cia+/g; # companhia
    s/Jr\./Jr+/g;

    # moradas
    s/Av\./Av+/g;
    s/ av\./ av+/g;
    s/Est(r*)\./Est$1+/g;
    s/Lg(o*)\./Lg$1+/g;
    s/ lg(o*)\./ lg$1+/g;
    s/T(ra)*v\./T$1v+/g; # Trav., Tv.
    s/([^N])Pq\./$1Pq+/g; # Parque (cuidado com CNPq)
    s/ pq\./ pq+/g; # parque
    s/Jd\./Jd+/g; # jardim
    s/Ft\./Ft+/g; # forte
    s/Cj\./Cj+/g; # conjunto
    s/ ([lc])j\./ $1j+/g; # conjunto ou loja
    #    $par=~s/ al\./ al+/g; # alameda tem que ir para depois de et.al...

    s/Tel(e[fm])*\./Tel$1+/g; # Tel., Telef., Telem.
    s/ tel(e[fm])*\./ tel$1+/g; # tel., telef., telem.
    s/Fax\./Fax+/g; # Fax.
    s/ cx\./ cx+/g; # caixa

    # abreviaturas greco-latinas
    s/ a\.C\./ a+C+/g;
    s/ a\.c\./ a+c+/g;
    s/ d\.C\./ d+C+/g;
    s/ d\.c\./ d+c+/g;
    s/ ca\./ ca+/g;
    s/etc\.([.,;])/etc+$1/g;
    s/etc\.\)([.,;])/etc+)$1/g;
    s/etc\. --( *[a-z��������,])/etc+ --$1/g;
    s/etc\.(\)*) ([^A-Z�������])/etc+$1 $2/g;
    s/ et\. *al\./ et+al+/g;
    s/ al\./ al+/g; # alameda
    s/ q\.b\./ q+b+/g;
    s/ i\.e\./ i+e+/g;
    s/ibid\./ibid+/g;
    s/ id\./ id+/g; # se calhar � preciso ver se n�o vem sempre precedido de um (
    s/op\.( )*cit\./op+$1cit+/g;
    s/P\.S\./P+S+/g;

    # unidades de medida
    s/([0-9][hm])\. ([^A-Z��������])/$1+ $2/g; # 19h., 24m.
    s/([0-9][km]m)\. ([^A-Z��������])/$1+ $2/g; # 20km., 24mm.
    s/([0-9]kms)\. ([^A-Z��������])/$1+ $2/g; # kms. !!
    s/(\bm)\./$1+/g; # metros no MINHO

    # outros
    s/\(([Oo]rgs*)\.\)/($1+)/g; # (orgs.)
    s/\(([Ee]ds*)\.\)/($1+)/g; # (eds.)
    s/s�c\./s�c+/g;
    s/p�g(s*)\./p�g$1+/g;
    s/pg\./pg+/g;
    s/pag\./pag+/g;
    s/ ed\./ ed+/g;
    s/Ed\./Ed+/g;
    s/ s�b\./ s�b+/g;
    s/ dom\./ dom+/g;
    s/ id\./ id+/g;
    s/ min\./ min+/g;
    s/ n\.o(s*) / n+o$1 /g; # abreviatura de numero no MLCC-DEB
    s/ ([Nn])o\.(s*)\s*([0-9])/ $1o+$2 $3/g; # abreviatura de numero no., No.
    s/ n\.(s*)\s*([0-9])/ n+$1 $2/g; # abreviatura de numero n. no ANCIB
    s/ num\. *([0-9])/ num+ $1/g; # abreviatura de numero num. no ANCIB
    s/ c\. ([0-9])/ c+ $1/g; # c. 1830
    s/ p\.ex\./ p+ex+/g;
    s/ p\./ p+/g;
    s/ pp\./ pp+/g;
    s/ art(s*)\./ art$1+/g;
    s/Min\./Min+/g;
    s/Inst\./Inst+/g;
    s/vol(s*)\./vol$1+ /g;
    s/ v\. *([0-9])/ v+ $1/g; # abreviatura de volume no ANCIB
    s/\(v\. *([0-9])/\(v+ $1/g; # abreviatura de volume no ANCIB
    s/^v\. *([0-9])/v+ $1/g; # abreviatura de volume no ANCIB
    s/Obs\./Obs+/g;

    # Abreviaturas de meses
    s/(\W)jan\./$1jan+/g;
    s/\Wfev\./$1fev+/g;
    s/(\/\s*)mar\.(\s*[0-9\/])/$1mar+$2/g; # a palavra "mar"
    s/(\W)mar\.(\s*[0-9]+)/$1mar\+$2/g;
    s/(\W)abr\./$1abr+/g;
    s/(\W)mai\./$1mai+/g;
    s/(\W)jun\./$1jun+/g;
    s/(\W)jul\./$1jul+/g;
    s/(\/\s*)ago\.(\s*[0-9\/])/$1ago+$2/g; # a palavra inglesa "ago"
    s/ ago\.(\s*[0-9\/])/ ago+$1/g; # a palavra inglesa "ago./"
    s/(\W)set\.(\s*[0-9\/])/$1set+$2/g; # a palavra inglesa "set"
    s/([ \/])out\.(\s*[0-9\/])/$1out+$2/g; # a palavra inglesa "out"
    s/(\W)nov\./$1nov+/g;
    s/(\/\s*)dez\.(\s*[0-9\/])/$1dez+$2/g; # a palavra "dez"
    s/(\/\s*)dez\./$1dez+/g; # a palavra "/dez."

    # Abreviaturas inglesas
    s/Bros\./Bros+/g;
    s/Co\. /Co+ /g;
    s/Co\.$/Co+/g;
    s/Com\. /Com+ /g;
    s/Com\.$/Com+/g;
    s/Corp\. /Corp+ /g;
    s/Inc\. /Inc+ /g;
    s/Ltd\. /Ltd+ /g;
    s/([Mm])r(s*)\. /$1r$2+ /g;
    s/Ph\.D\./Ph+D+/g;
    s/St\. /St+ /g;
    s/ st\. / st+ /g;

    # Abreviaturas francesas
    s/Mme\./Mme+/g;

    # Abreviaturas especiais do Di�rio do Minho
    s/ habilit\./ habilit+/g;
    s/Hab\./Hab+/g;
    s/Mot\./Mot+/g;
    s/\-Ang\./-Ang+/g;
    s/(\bSp)\./$1+/g; # Sporting
    s/(\bUn)\./$1+/g; # Universidade

    # Abreviaturas especiais do Folha
    s/([^'])Or\./$1Or+/g; # alemanha Oriental, evitar d'Or
    s/Oc\./Oc+/g; # alemanha Ocidental

  }

  # tratar dos conjuntos de iniciais
  my @siglas_iniciais = ($par =~ /^(?:[A-Z]\. *)+[A-Z]\./);
  my @siglas_finais   = ($par =~ /(?:[A-Z]\. *)+[A-Z]\.$/);
  my @siglas = ($par =~ m#(?:[A-Z]\. *)+(?:[A-Z]\.)(?=[]\)\s,;:!?/])#g); #trata de conjuntos de iniciais
  push (@siglas, @siglas_iniciais);
  push (@siglas, @siglas_finais);
  my $sigla_antiga;
  foreach my $sigla (@siglas) {
    $sigla_antiga = $sigla;
    $sigla =~ s/\./+/g;
    $sigla_antiga =~ s/\./\\\./g;
    #	print "SIGLA antes: $sigla, $sigla_antiga\n";
    $par =~ s/$sigla_antiga/$sigla/g;
    #	print "SIGLA: $sigla\n";
  }

  # tratar de pares de iniciais ligadas por h�fen (� francesa: A.-F.)
  for ($par) {
    s/ ([A-Z])\.\-([A-Z])\. / $1+-$2+ /g;
    # tratar de iniciais (�nicas?) seguidas por ponto
    s/ ([A-Z])\. / $1+ /g;
    # tratar de iniciais seguidas por ponto
    s/^([A-Z])\. /$1+ /g;
    # tratar de iniciais seguidas por ponto antes de aspas "D. Jo�o
    # VI: Um Rei Aclamado"
    s/([("\�])([A-Z])\. /$1$2+ /g;
  }

  # Tratar dos URLs (e tamb�m dos endere�os de email)
  # email= url@url...
  # aceito endere�os seguidos de /hgdha/hdga.html
  #  seguidos de /~hgdha/hdga.html
  #    @urls=($par=~/(?:[a-z][a-z0-9-]*\.)+(?:[a-z]+)(?:\/~*[a-z0-9-]+)*?(?:\/~*[a-z0-9][a-z0-9.-]+)*(?:\/[a-z.]+\?[a-z]+=[a-z0-9-]+(?:\&[a-z]+=[a-z0-9-]+)*)*/gi);

  my @urls = ($par =~ /(?:[a-z][a-z0-9-]*\.)+(?:[a-z]+)(?:\/~*[a-z0-9][a-z0-9.-]+)*(?:\?[a-z]+=[a-z0-9-]+(?:\&[a-z]+=[a-z0-9-]+)*)*/gi);
  my $url_antigo;
  foreach my $url (@urls) {
    $url_antigo = $url;
    $url_antigo =~ s/\./\\./g; # para impedir a substitui��o de P.o em vez de P\.o
    $url_antigo =~ s/\?/\\?/g;
    $url =~ s/\./+/g;
    # Se o �ltimo ponto est� mesmo no fim, n�o faz parte do URL
    $url =~ s/\+$/./;
    $url =~ s/\//\/\/\/\//g; # p�e quatro ////
    $par =~ s/$url_antigo/$url/;
  }
  # print "Depois de tratar dos URLs: $par\n";

  for ($par) {
    # de qualquer maneira, se for um ponto seguido de uma v�rgula, �
    # abreviatura...
    s/\. *,/+,/g;
    # de qualquer maneira, se for um ponto seguido de outro ponto, �
    # abreviatura...
    s/\. *\./+./g;

    # tratamento de numerais
    s/([0-9]+)\.([0-9]+)\.([0-9]+)/$1_$2_$3/g;
    s/([0-9]+)\.([0-9]+)/$1_$2/g;

    # tratamento de numerais cardinais
    # - tratar dos n�meros com ponto no in�cio da frase
    s/^([0-9]+)\. /$1+ /g;
    # - tratar dos n�meros com ponto antes de min�sculas
    s/([0-9]+)\. ([a-z��������])/$1+ $2/g;

    # tratamento de numerais ordinais acabados em .o
    s/([0-9]+)\.([oa]s*) /$1+$2 /g;
    # ou expressos como 9a.
    s/([0-9]+)([oa]s*)\. /$1$2+ /g;

    # tratar numeracao decimal em portugues
    s/([0-9]),([0-9])/$1#$2/g;

    #print "TRATA: $par\n";

    # tratar indica��o de horas
    #   esta � tratada na tokeniza��o - n�o separando 9:20 em 9 :20
  }
  return $par;
}


sub separa_frases {
  my $par = shift;

  # $num++;

  $par = &tratar_pontuacao_interna($par);

  #  print "Depois de tratar_pontuacao_interna: $par\n";

  for ($par) {

    # primeiro junto os ) e os -- ao caracter anterior de pontua��o
    s/([?!.])\s+\)/$1\)/g; # p�r  "ola? )" para "ola?)"
    s/([?!.])\s+\-/$1-/g; # p�r  "ola? --" para "ola?--"
    s/([?!.])\s+�/$1�/g; # p�r  "ola? ..." para "ola?..."
    s/�\s+\-/$1-/g; # p�r  "ola� --" para "ola�--"

    # junto tb o travess�o -- `a pelica '
    s/\-\- \' *$/\-\-\' /;

    # separar esta pontua��o, apenas se n�o for dentro de aspas, ou
    # seguida por v�rgulas ou par�nteses o a-z est�o l� para n�o
    # separar /asp?id=por ...
    s/([?!]+)([^-\�'�,�?!)"a-z])/$1.$2/g;

    # Deixa-se o travess�o para depois
    # print "Depois de tratar do ?!: $par";

    # separar as retic�ncias entre par�nteses apenas se forem seguidas
    # de nova frase, e se n�o come�arem uma frase elas pr�prias
    s/([\w?!])�([\�"�']*\)) *([A-Z������])/$1�$2.$3/g;

    # print "Depois de tratar das retic. seguidas de ): $par";

    # separar os pontos antes de par�nteses se forem seguidos de nova
    # frase
    s/([\w])\.([)]) *([A-Z������])/$1 + $2.$3/g;

    # separar os pontos ? e ! antes de par�nteses se forem seguidos de
    # nova frase, possivelmente tb iniciada por abre par�nteses ou
    # travess�o
    s/(\w[?!]+)([)]) *((?:\( |\-\- )*[A-Z������])/$1 $2.$3/g;

    # separar as retic�ncias apenas se forem seguidas de nova frase, e
    # se n�o come�arem uma frase elas pr�prias trata tamb�m das
    # retic�ncias antes de aspas
    s/([\w\d!?])\s*�(["\�'�]*) ([^\�"'a-z��������,;?!)])/$1�$2.$3/g;
    s/([\w\d!?])\s*�(["\�'�]*)\s*$/$1�$2. /g;

    # aqui trata das frases acabadas por aspas, eventualmente tb
    # fechando par�nteses e seguidas por retic�ncias
    s/([\w!?]["\�'�])�(\)*) ([^\�"a-z��������,;?!)])/$1�$2.$3/g;

    #print "depois de tratar das reticencias seguidas de nova frase: $par\n";

    # tratar dos dois pontos: apenas se seguido por discurso directo
    # em mai�sculas
    s/: \�([A-Z������])/:.\�$1/g;
    s/: (\-\-[ \�]*[A-Z������])/:.$1/g;

    # tratar dos dois pontos se eles acabam o par�grafo (� preciso p�r
    # um espa�o)
    s/:\s*$/:. /;

    # tratar dos pontos antes de aspas
    s/\.(["\�'�])([^.])/+$1.$2/g;

    # tratar das aspas quando seguidas de novas aspas
    s/\�\s*[\�"]/\�. \�/g;

    # tratar de ? e ! seguidos de aspas quando seguidos de mai�scula
    # eventualmente iniciados por abre par�nteses ou por travess�o
    s/([?!])([\�"'�]) ((?:\( |\-\- )*[A-Z��������])/$1$2. $3/g;

    # separar os pontos ? e ! antes de par�nteses e possivelmente
    # aspas se forem o fim do par�grafo
    s/(\w[?!]+)([)][\�"'�]*) *$/$1 $2./;

    # tratar dos pontos antes de aspas precisamente no fim
    s/\.([\�"'�])\s*$/+$1. /g;

    # tratar das retic�ncias e outra pontua��o antes de aspas ou
    # plicas precisamente no fim
    s/([!?�])([\�"'�]+)\s*$/$1$2. /g;

    #tratar das retic�ncias precisamente no fim
    s/�\s*$/�. /g;

    # tratar dos pontos antes de par�ntesis precisamente no fim
    s/\.\)\s*$/+\). /g;

    # aqui troco .) por .). ...
    s/\.\)\s/+\). /g;
  }

  # tratar de par�grafos que acabam em letras, n�meros, v�rgula ou
  # "-", chamando-os fragmentos #ALTERACAO
  my $fragmento;
  if ($par =~/[A-Za-z�������������0-9\),-][\�\"\'�>]*\s*\)*\s*$/) {
    $fragmento = 1
  }

  for ($par) {
    # se o par�grafo acaba em "+", deve-se juntar "." outra vez.
    s/([^+])\+\s*$/$1+. /;

    # se o par�grafo acaba em abreviatura (+) seguido de aspas ou par�ntesis, deve-se juntar "."
    s/([^+])\+\s*(["\�'�\)])\s*$/$1+$2. /;

    # print "Par�grafo antes da separa��o: $par";
  }

  my @sentences = split /\./,$par;
  if (($#sentences > 0) and not $fragmento) {
    pop(@sentences);
  }

  my $resultado = "";
  # para saber em que frase p�r <s frag>
  my $num_frase_no_paragrafo = 0;
  foreach my $frase (@sentences) {
    $frase = &recupera_ortografia_certa($frase);

    if (($frase=~/[.?!:;][\�"'�]*\s*$/) or
	($frase=~/[.?!] *\)[\�"'�]*$/)) {
      # frase normal acabada por pontua��o
      $resultado .= "<s> $frase </s>\n";
    }

    elsif (($fragmento) and ($num_frase_no_paragrafo == $#sentences)) {
      $resultado .= "<s frag> $frase </s>\n";
      $fragmento = 0;
    }
    else {
      $resultado .= "<s> $frase . </s>\n";
    }
    $num_frase_no_paragrafo++;
  }

  return $resultado;
}


sub recupera_ortografia_certa {
  # os sinais literais de + s�o codificados como "++" para evitar
  # transforma��o no ponto, que � o significado do "+"

  my $par = shift;

  for ($par) {
    s/([^+])\+(?!\+)/$1./g; # um + n�o seguido por +
    s/\+\+/+/g;
    s/^�(?!�)/.../g; # se as retic�ncias come�am a frase
    s/([^�(])�(?!�)\)/$1... \)/g; # porque se juntou no separa_frases 
    # So nao se faz se for (...) ...
    s/([^�])�(?!�)/$1.../g; # um � n�o seguido por �
    s/��/�/g;
    s/_/./g;
    s/#/,/g;
    s#////#/#g; #passa 4 para 1
    s/([?!])\-/$1 \-/g; # porque se juntou no separa_frases
    s/([?!])\)/$1 \)/g; # porque se juntou no separa_frases 
  }
  return $par;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Lingua::PT::Segmentador - Perl extension for Portuguese segmentation

=head1 SYNOPSIS

  use Lingua::PT::Segmentador;

  my @frases = sentences($texto);
  my $frases = separa_frases($texto);

=head1 DESCRIPTION

This module is intended to be for Portuguese audience. So, sorry but I
will switch to Portuguese.


Este m�dulo � uma extens�o Perl para a segmenta��o de textos em
linguagem natural. O objectivo principal ser� a possibilidade de
segmenta��o a v�rios n�veis, no entanto esta primeira vers�o permite
apenas a separa��o em frases (frasea��o) usando uma de duas variantes:

=over 4

=item Projecto Natura

  @frases = sentences($texto);

Esta � a implementa��o do Projecto Natura, que retorna uma lista de
frases.

=item Linguateca

  $frases = separa_frases($texto);

Esta � a implementa��o da Linguateca, que retorna um texto com uma
frase por linha.

=back

Estas duas implementa��es ir�o ser testadas e aglomeradas numa �nica
que permita ambas as funcionalidades.

=head1 AUTHOR

Linguateca (http://www.linguateca.pt -- contacto@linguateca.pt)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003 by Linguateca

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

Esta biblioteca � software livre; pode distribu�-la e/ou modific�-la
nos mesmos termos do Perl, quer vers�o 5.8.1 ou, na sua opini�o, 
qualquer outra vers�o de Perl 5 que tenha dispon�vel.

=cut
