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

my @dihes = HackaMol->new->build_dihedrals ($mol->select_atoms( sub{ $_->Z != 1 } ) );
$_->is_constrained(1) foreach @dihes;
$mol->push_dihedrals(@dihes);


my $orca2 = HackaMol::X::Orca->new(
      mol             => $mol,
      has_constraints => 1,      
      theory          => 'HF-3c',
      exe             => '/Users/riccade/perl5/apps/orca_3_0_3_macosx_openmpi165/orca',
      scratch         => 'tmp',
);

foreach (0 .. $mol->tmax){
  my @energies = $orca2->opt;
  print Dumper \@energies;
}

my $mol2 = HackaMol->new->read_file_mol('tmp/mol.xyz');
#$orca->map_input;
#$orca2->load_engrad;

my $t2 = time;

printf ("%10.2f\n", $t2-$t1);
