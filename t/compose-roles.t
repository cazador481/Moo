use strictures 1;
use Test::More;

{
  package One; use Role::Tiny;
  around foo => sub { my $orig = shift; (__PACKAGE__, $orig->(@_)) };
  package Two; use Role::Tiny;
  around foo => sub { my $orig = shift; (__PACKAGE__, $orig->(@_)) };
  package Three; use Role::Tiny;
  around foo => sub { my $orig = shift; (__PACKAGE__, $orig->(@_)) };
  package Four; use Role::Tiny;
  around foo => sub { my $orig = shift; (__PACKAGE__, $orig->(@_)) };
  package Base; sub foo { __PACKAGE__ }
}

foreach my $combo (
  [ qw(One Two Three Four) ],
  [ qw(Two Four Three) ],
  [ qw(One Two) ]
) {
  my $combined = Role::Tiny->create_class_with_roles('Base', @$combo);
  is_deeply(
    [ $combined->foo ], [ reverse(@$combo), 'Base' ],
    "${combined} ok"
  );
  my $object = bless({}, 'Base');
  Role::Tiny->apply_roles_to_object($object, @$combo);
  is(ref($object), $combined, 'Object reblessed into correct class');
}

{
  package RoleWithAttr;
  use Moo::Role;

  has attr1 => (is => 'rw');

  package RoleWithAttr2;
  use Moo::Role;

  has attr2 => (is => 'rw');

  package ClassWithAttr;
  use Moo;

  has attr3 => (is => 'rw');
}

Moo::Role->apply_roles_to_package('ClassWithAttr', 'RoleWithAttr', 'RoleWithAttr2');
my $o = ClassWithAttr->new(attr1 => 1, attr2 => 2, attr3 => 3);
is($o->attr1, 1, 'attribute from role works');
is($o->attr2, 2, 'attribute from role 2 works');
is($o->attr3, 3, 'attribute from base class works');

done_testing;
