use Modern::Perl;
use HackaMol::X::Orca;
use Math::Vector::Real;
use HackaMol;
use Time::HiRes qw(time);
use Data::Dumper;

my $t1 = time;
my $mol = HackaMol::Molecule->new(
          charges => [0],
          atoms   => [
                   HackaMol::Atom->new(Z =>7, coords=>[V(0.0,0.0,0.0)] ),
                   HackaMol::Atom->new(Z =>7, coords=>[V(1.5,0.0,0.0)] ),
          ]
);

$mol->multiplicity(1);

my $orca = HackaMol::X::Orca->new(
      mol     => $mol,
      theory  => 'HF-3c',
      exe     => '/Users/riccade/perl5/apps/orca_3_0_3_macosx_openmpi165/orca',
      scratch => 'tmp',
);

my $t2 = time;

#my @energies = $orca->engrad;
my $mol2 = $orca->load_engrad;
my @energies = ();
#my $mol2 = $orca->mol;
$mol2->print_xyz;

my $t3 = time;
printf ("HackaMol setup time: %10.2f\n", $t2-$t1);
printf ("Orca     Calc  time: %10.2f\n", $t3-$t2);

