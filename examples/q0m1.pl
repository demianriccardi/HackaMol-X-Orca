use Modern::Perl;
use HackaMol::X::Orca;
use Math::Vector::Real;
use HackaMol;
use Time::HiRes qw(time);
use Data::Dumper;

my $t1 = time;

my $mol = HackaMol->new->read_file_mol(shift);

$mol->push_charges(0);
$mol->multiplicity(1);

my $orca2 = HackaMol::X::Orca->new(
      mol    => $mol,
      theory => 'HF-3c',
      exe    => '/Users/riccade/perl5/apps/orca_3_0_3_macosx_openmpi165/orca',
      scratch => 'tmp',
);

foreach (0 .. $mol->tmax){
  my @energies = $orca2->ener;
  print Dumper \@energies;
}
#$orca->map_input;
#$orca2->load_engrad;

my $t2 = time;

printf ("%10.2f\n", $t2-$t1);
