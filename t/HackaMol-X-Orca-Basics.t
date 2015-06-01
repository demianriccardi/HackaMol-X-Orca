#!/usr/bin/env perl

use strict;
use warnings;
use Test::Moose;
use Test::More;
use Test::Fatal qw(lives_ok dies_ok);
use Test::Dir;
use Test::Warn;
use HackaMol::X::Orca;
use HackaMol;
use Math::Vector::Real;
use File::chdir;
use Cwd;

BEGIN {
    use_ok('HackaMol::X::Orca');
}

my $cwd = getcwd;

# coderef

{    # test HackaMol class attributes and methods

    my @attributes = qw(
                        engrad_fn gbw_fn opt_fn prop_fn trj_fn xyz_fn
                       );
    my @methods    = qw(
                        build_command write_input map_input map_output 
                        calc 
                       );

    my @roles = qw(HackaMol::ExeRole HackaMol::PathRole);

    map has_attribute_ok( 'HackaMol::X::Orca', $_ ), @attributes;
    map           can_ok( 'HackaMol::X::Orca', $_ ), @methods;
    map          does_ok( 'HackaMol::X::Orca', $_ ), @roles;

}

my $mol = HackaMol::Molecule->new(
          charges => [0],
          atoms =>[
                   HackaMol::Atom->new(Z =>7, coords=>[V(0.0,0.0,0.0)] ),
                   HackaMol::Atom->new(Z =>7, coords=>[V(1.3,0.0,0.0)] ),
          ]
);
$mol->multiplicity(1);
my $obj;

{    # test basic functionality

    lives_ok {
        $obj = HackaMol::X::Orca->new(
            mol      => $mol,
        );
    }
    'barebones object lives';

    is( $obj->in_fn, 'mol.inp',     "default inp" );
    is( $obj->out_fn, 'mol.out',    "default out" );
    is( $obj->engrad_fn, 'mol.engrad',  "default engrad" );
    is( $obj->gbw_fn, 'mol.gbw',    "default gbw" );
    is( $obj->opt_fn, 'mol.opt',    "default opt" );
    is( $obj->prop_fn, 'mol.prop',  "default prop" );
    is( $obj->trj_fn, 'mol.trj',    "default trj" );
    is( $obj->xyz_fn, 'mol.xyz',    "default xyz" );

    lives_ok {
        $obj = HackaMol::X::Orca->new( 
            mol => $mol , 
            in_fn    => 'input',
            exe      => "orca",
        );
    }
    'creation of an obj with mol';
    is( $obj->out_fn, "input.out"  , "output name set" );
    is( $obj->in_fn, 'input', "input name set" );
    is( $obj->exe, 'orca', "exe set" );

    dir_not_exists_ok( "t/tmp", 'scratch directory does not exist yet' );

    is(
        $obj->command,
        $obj->exe . " " . $obj->in_fn,
        "command set to exe and input"
    );

    lives_ok {
        $obj = HackaMol::X::Orca->new(
            mol     => $mol,
            in_fn    => 'input',
            exe      => "orca",
            scratch => "t/tmp",
        );
    }
    'Test creation of an obj with exe in_fn and scratch';

    dir_exists_ok( $obj->scratch, 'scratch directory exists' );
    is(
        $obj->command,
        $obj->exe . " " . $obj->in_fn,
        "command set to exe and input"
    );
    is( $obj->scratch, "$cwd/t/tmp", "scratch directory" );
 
    $obj->scratch->remove_tree;
    dir_not_exists_ok( "t/tmp", 'scratch directory deleted' );

}

{    # test the map_in and map_out

    $obj = HackaMol::X::Orca->new(
        mol            => $mol,
        in_fn          => "foo.inp",
        exe            => '~/bin/orca',
        scratch        => 't/tmp',
        homedir        => '.',
    );

    my $input = $obj->map_input; 
    $CWD = $obj->scratch;
    my $input2 = $obj->in_fn->slurp;
    is( $input, $input2,
        "input written to scratch is that returned by map_input" );
    $CWD = $obj->homedir;
    $obj->scratch->remove_tree;
    dir_not_exists_ok( "t/tmp", 'scratch directory deleted' );

}

done_testing();

