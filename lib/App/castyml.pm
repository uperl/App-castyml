package App::castyml;

use strict;
use warnings;
use Path::Tiny qw( path );
use Clang::CastXML;
use YAML ();
use Getopt::Long qw( GetOptions );
use 5.022;
use experimental qw( signatures postderef );

# ABSTRACT: C-family abstract syntax tree output to YAML
# VERSION

=head1 SYNOPSIS

 perldoc castyml

=head1 DESCRIPTION

This module provides the private machinery for L<castyml>.  See its documentation for usage.

=head1 SEE ALSO

=over 4

=item L<castyml>

=back

=cut

sub main
{
  local (undef, @ARGV) = @_;

  my %opt = (
    raw => 0,
    function => undef,
  );

  GetOptions(
    'help|h'       => sub { ... },
    'version|n'    => sub { say STDERR "castyml version @{[ $App::castyml::VERSION // 'dev' ]}"; exit 0 },
    'raw|r'        => \$opt{raw},
    'function|f=s' => \$opt{function},
  );

  my $bad = 0;

  my $castxml = Clang::CastXML->new;

  my $count=0;
  foreach my $path (map { path $_ } @ARGV)
  {
    $count++;
    my $container = $castxml->introspect( $path );
    my $href = $container->to_href;

    unless($opt{raw})
    {

      my %ids;

      my $recurse1 = sub ($h) {
        if(my $id = $h->{id})
        {
          $ids{$id} = $h;
        }
        if(my $inner = $h->{inner})
        {
          __SUB__->($_) for $inner->@*;
        }
      };

      $recurse1->($href);

      my $recurse2 = sub ($h) {
        foreach my $key (qw( type returns original_type ))
        {
          if(my $id = $h->{$key})
          {
            if($ids{$id})
            {
              $h->{$key} = $ids{$id};
            }
            else
            {
              say STDERR "bad id: $id";
              $bad = 1;
            }
          }
        }

        ## unfortunately, this causes a cycle
        #if($h->{members})
        #{
        #  my @members = map { $ids{$_} } split /\s+/, $h->{members};
        #  $h->{members} = \@members;
        #}

        ## for debug onlyo
        #foreach my $key (keys $h->%*)
        #{
        #  next if $key eq 'context';
        #  next if $key eq 'id';
        #  my $value = $h->{$key};
        #  if($value =~ /^_[0-9]+$/)
        #  {
        #    say STDERR "$key looks like an id";
        #  }
        #  if($value =~ /^(_[0-9]+\s)+_[0-9]+$/n)
        #  {
        #    say STDERR "$key looks like a list of ids";
        #  }
        #}

        if(my $id = delete $h->{file})
        {
          my @file;
          push @file, $ids{$id}->{name};
          push @file, delete $h->{line} if defined $h->{line};
          $h->{file} = join ':', @file;
        }
        if(my $inner = $h->{inner})
        {
          __SUB__->($_) for $inner->@*;
        }
      };

      $recurse2->($href);

      $href->{inner} = [ grep { $_->{_class} ne 'File' } $href->{inner}->@* ];
    }

    if(my $regex = $opt{function})
    {
      $href->{inner} = [ grep { $_->{_class} eq 'Function' && $_->{name} =~ /$regex/n } $href->{inner}->@* ];
    }

    local $YAML::UseAliases = 0;
    print YAML::Dump($href);
  }

  unless($count)
  {
    say STDERR "no source files provided";
    $bad = 1;
  }

  $bad ? 2 : 0;
}

1;


