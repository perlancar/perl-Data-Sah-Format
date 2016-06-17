package Test::Data::Sah::Format;

use 5.010001;
use strict 'subs', 'vars';
use warnings;

use Data::Sah::Format;
use Test::Exception;
use Test::More 0.98;

use Exporter qw(import);
our @EXPORT = qw(test_format);

sub test_format {
    my %args = @_;

    my $compiler = $args{compiler} // 'perl';
    my $module;
    if ($compiler eq 'perl') {
        $module = "Data::Sah::Format";
    } elsif ($compiler eq 'js') {
        $module = "Data::Sah::FormatJS";
    } else {
        die "Unknown compiler '$compiler'";
    }
    eval "use $module"; die if $@;

    my $formatter;
    subtest +($args{name} // $args{format}) => sub {

        lives_ok {
            $formatter = &{"$module\::gen_formatter"}(
                format => $args{format},
                formatter_args => $args{formatter_args},
            );
        };
        if (exists $args{data}) {
            for my $i (0..$#{ $args{data} }) {
                my $data  = $args{data}[$i];
                my $fdata = $formatter->($data);
                is_deeply($fdata, $args{fdata}[$i]);
            }
        }
    };
}

1;
# ABSTRACT: Test routines for testing Data::Sah::Format::* modules

=head1 FUNCTIONS

=head2 test_format(%args)
