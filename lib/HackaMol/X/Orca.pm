package HackaMol::X::Orca;

#ABSTRACT: HackaMol extension for running Orca
use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;
use Math::Vector::Real;
use MooseX::Types::Path::Tiny qw(AbsPath) ;
use HackaMol; # for building molecules
use File::chdir;
use namespace::autoclean;
use Carp;
use MooseX::Types::Path::Tiny qw/Path Paths AbsPath AbsPaths/;

with qw(HackaMol::X::ExtensionRole);

sub build_command {
    my $self = shift;
    my $cmd;
    $cmd = $self->exe;
    $cmd .= " " . $self->in_fn->stringify;

    # we always capture output
    return $cmd;
}

sub save_config {
    # make something that can be used to save the configuration of the calculator
    my $self = shift;

}

sub _build_map_in {
    # this builds the default behavior, can be set anew via new
    return sub { return ( shift->write_input ) };
}

sub load_engrad {
  my $self   = shift;
  local $CWD = $self->scratch if ( $self->has_scratch );
  my @engrad = $self->engrad_fn->lines;
  print foreach @engrad;  

}

sub _build_map_out {
    # this builds the default behavior, can be set anew via new
    my $sub_cr = sub {
        my $self = shift;
        my $qr   = qr/ENERGY \s+ (-\d+\.\d+)/;
        my ( $stdout, $sterr ) = $self->capture_sys_command;
        my @energies = map { m/$qr/; $1 }
                      grep { m/$qr/ }
                      split( "\n", $stdout );
        return (@energies);
    };
    return $sub_cr;
}

# we are using PathRole via ExtensionRole but we still need more files
# orca pumps out a bunch of files

has $_  => (
    is          => 'rw',
    isa         => Path,
    coerce      => 1,
    predicate   => "has_$_",
) foreach qw(engrad_fn gbw_fn opt_fn prop_fn trj_fn xyz_fn) ;

has theory => (
    is  => 'rw',
    isa => 'Str',
    default => 'HF-3c'
);

has has_constraints => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has calc => ( 
    is   => 'rw',
    isa  => 'Str',
    lazy => 1,
    builder => '_build_calc',
);

sub _build_calc { shift->theory} 

sub ener {
    my $self = shift;
    $self->calc($self->theory); 
    $self->map_input;
    return $self->map_output;
}

sub opt {
    my $self = shift;
    $self->calc($self->theory." opt"); 
    $self->map_input;
    return $self->map_output;    
}

sub BUILD {
    my $self = shift;

    if ( $self->has_scratch ) {
        $self->scratch->mkpath unless ( $self->scratch->exists );
    }

    # build in some defaults
    $self->in_fn("mol.inp")              unless ($self->has_in_fn);
    $self->exe($ENV{"HOME"}."/bin/orca") unless $self->has_exe;

    my $base = $self->in_fn->basename('.inp');
    foreach my $fn (qw(out_fn engrad_fn gbw_fn 
                       opt_fn prop_fn trj_fn xyz_fn)){
      my $pred = "has_$fn";
      unless ( $self->$pred ) {
        my $suff = $fn;
        $suff =~ s/\_fn//;
        my $string = $base . "\.$suff";
        $self->$fn($string);
      }
    }

    unless ( $self->has_command ) {
        my $cmd = $self->build_command;
        $self->command($cmd);
    }

    return;
}

sub write_input {
    my $self = shift;
    my $mol = $self->mol;
    my $input;
    $input .= '! '. $self->calc . "\n";
    $input .= '* xyz '. $self->mol->charge . ' '. $self->mol->multiplicity . "\n";
    foreach ($self->mol->all_atoms){
      $input .= sprintf( "%-3s %12.8f %12.8f %12.8f\n", $_->symbol, @{$_->xyz});
    }
    $input .= "\*\n";
# constraints
# https://sites.google.com/site/orcainputlibrary/geometry-optimizations
    if ($self->has_constraints){
      # cartesian constraints
      $input .= "\%geom\nConstraints\n";
      foreach my $group ( $mol->all_groups) {
        next unless $group->is_constrained;
        $input .= "\{C ".$_->iatom . " C\}\n" foreach $group->all_atoms; 
      }
      foreach my $group ( $mol->all_bonds) {
        next unless $group->is_constrained;
        $input .= "\{B ";
        $input .= $_->iatom . " " foreach $group->all_atoms;
        $input .= "C\}\n"
      }
      foreach my $group ( $mol->all_angles) {
        next unless $group->is_constrained;
        $input .= "\{A ";
        $input .= $_->iatom . " " foreach $group->all_atoms;
        $input .= "C\}\n"
      }
      foreach my $group ( $mol->all_dihedrals) {
        next unless $group->is_constrained;
        $input .= "\{D ";
        $input .= $_->iatom . " " foreach $group->all_atoms;
        $input .= "C\}\n"
      }
      $input .= "end\n";
      $input .= "end\n";
    }
    $self->in_fn->spew($input);
    return ($input);
}

__PACKAGE__->meta->make_immutable;

1;
