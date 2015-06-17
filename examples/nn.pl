use Modern::Perl;
use HackaMol::X::Orca;
use Math::Vector::Real;
use HackaMol;
use Time::HiRes qw(time);
use Data::Dumper;

my $t1 = time;
my $mol = HackaMol::Molecule->new;

my $orca = HackaMol::X::Orca->new(
      mol     => $mol,
      theory  => 'HF-3c',
      exe     => '/Users/riccade/perl5/apps/orca_3_0_3_macosx_openmpi165/orca',
      scratch => 'tmp',
);

my $t2 = time;

#my ($mol2) = $orca->engrad;
my $mol2 = $orca->load_trj;
$mol2->print_xyz_ts([0 .. $mol2->tmax]);
say foreach $mol2->all_energy;
