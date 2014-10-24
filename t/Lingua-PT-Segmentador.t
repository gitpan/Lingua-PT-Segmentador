# -*- cperl -*-

use Test::More tests => 15;

use locale;

BEGIN { use_ok( 'Lingua::PT::Segmentador' ); }

my @ss = sentences(<<"EOT");
Um homem trocou as ruas cheias de neve de Chicago por umas f�rias na
ensolarada Florida.  A esposa estava a viajar em neg�cios e estava a
planear encontrar-se com ele l� no dia seguinte.  Ao chegar ao hotel
resolveu mandar um e-mail para a sua mulher.  Como n�o encontrou o
papelinho onde tinha apontado o e-mail dela, escreveu para o que se
lembrava, esperando que este estivesse certo. Infelizmente, enganou-se
numa letra e a mensagem foi enviada a uma senhora, cujo marido tinha
falecido no dia anterior. Quando ela foi ler os seus e-mails, deu um
grito de profundo horror e caiu morta no ch�o. Ao ouvir o grito, a
fam�lia correu para o quarto e leu o seguinte no ecr� do monitor:
"Querida esposa: acabei de chegar. Foi uma longa viagem. Apesar de s�
estar aqui h� poucas horas, j� estou a gostar muito. Falei aqui com o
pessoal e est� tudo preparado para a tua chegada amanh�. Tenho a
certeza de que tu tamb�m vais gostar... Beijos do teu eterno e
carinhoso marido. P.S.: aqui est� um calor infernal!!
EOT

my $i = 0;
my @sts = ("Um homem trocou as ruas cheias de neve de Chicago por umas f�rias na
ensolarada Florida.","A esposa estava a viajar em neg�cios e estava a
planear encontrar-se com ele l� no dia seguinte.","Ao chegar ao hotel
resolveu mandar um e-mail para a sua mulher.","Como n�o encontrou o
papelinho onde tinha apontado o e-mail dela, escreveu para o que se
lembrava, esperando que este estivesse certo.","Infelizmente, enganou-se
numa letra e a mensagem foi enviada a uma senhora, cujo marido tinha
falecido no dia anterior.","Quando ela foi ler os seus e-mails, deu um
grito de profundo horror e caiu morta no ch�o.", "Ao ouvir o grito, a
fam�lia correu para o quarto e leu o seguinte no ecr� do monitor:",
"\"Querida esposa: acabei de chegar.","Foi uma longa viagem.","Apesar de s�
estar aqui h� poucas horas, j� estou a gostar muito.","Falei aqui com o
pessoal e est� tudo preparado para a tua chegada amanh�.","Tenho a
certeza de que tu tamb�m vais gostar...","Beijos do teu eterno e
carinhoso marido.","P.S.: aqui est� um calor infernal!!");

for (@sts) {
  is(trim($ss[$i++]),$_)
}


##------
sub trim {
  my $x = shift;
  $x =~ s/^[\n\s]*//;
  $x =~ s![\n\s]*$!!;
  $x
}
