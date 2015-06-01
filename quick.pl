use Modern::Perl;
use HackaMol::X::Orca;
use Math::Vector::Real;
use HackaMol;
use Time::HiRes qw(time);
use Data::Dumper;

my $t1 = time;
my $mol = HackaMol::Molecule->new(
          charges => [0],
          atoms =>[
                   HackaMol::Atom->new(Z =>7, coords=>[V(0.0,0.0,0.0)] ),
                   HackaMol::Atom->new(Z =>7, coords=>[V(1.3,0.0,0.0)] ),
          ]
);
$mol->multiplicity(1);

my $orca = HackaMol::X::Orca->new(
      mol    => $mol,
      theory => 'HF-3c',
      exe    => '/Users/riccade/perl5/apps/orca_3_0_3_macosx_openmpi165/orca',
      scratch => 'tmp',
);

my @energies = $orca->ener;

print Dumper \@energies;
my $t2 = time;

printf ("%10.2f\n", $t2-$t1);

my $mol2 = HackaMol->new->read_file_mol('quick.xyz');

$mol2->push_charges(3);
$mol2->multiplicity(6);


my $orca2 = HackaMol::X::Orca->new(
      mol    => $mol2,
      theory => 'HF-3c',
      exe    => '/Users/riccade/perl5/apps/orca_3_0_3_macosx_openmpi165/orca',
      scratch => 'tmp',
);

@energies = $orca2->ener;

print Dumper \@energies;
$orca->map_input;
$orca2->load_engrad;

my $t3 = time;

printf ("%10.2f\n", $t3-$t2);
