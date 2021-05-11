# castyml ![linux](https://github.com/uperl/App-castyml/workflows/linux/badge.svg)

C-family abstract syntax tree output to YAML

# SYNOPSIS

```
castyml [ -raw | -r ] [ -function | -f regex ] csource.c [ ... ]
castyml --help | -h
castyml --version | -v
```

# DESCRIPTION

The [castyml](https://metacpan.org/pod/castyml) tool takes introspected C code from `castxml` and
denormalizes some of it to make it easier to see how the
different objects inter-relate.  It outputs into [YAML](https://metacpan.org/pod/YAML) format
instead of `XML`, which I find easier to read.

# OPTIONS

## --raw | -r

```
$ castyml -r foo.c
```

Prints the raw data structures from `castxml` without denormalization.
(It is still will be in [YAML](https://metacpan.org/pod/YAML) format though).

## --function | -f regex

```
$ castyml -f '^archive'
```

Display only the top level functions that match the given regular expression.

## --help | -h

```
$ castyml -h
```

Displays the documentation for [castyml](https://metacpan.org/pod/castyml) and quits.

## --version | -v

Displays the version of [castyml](https://metacpan.org/pod/castyml) and quits.

# SEE ALSO

- [Clang::CastXML](https://metacpan.org/pod/Clang::CastXML)

    Interface to `castxml`

# AUTHOR

Author: Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
