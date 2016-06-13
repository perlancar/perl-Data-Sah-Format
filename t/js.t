#!perl

use 5.010001;
use strict;
use warnings;

use Data::Sah::FormatJS;
use Nodejs::Util qw(get_nodejs_path);
use Test::Exception;
use Test::More 0.98;
use Test::Needs;

plan skip_all => 'Node.js not available'
    unless get_nodejs_path();

test_format(
    format => 'iso8601_date',
    data   => [1465789176*1000       , "foo", []],
    fdata  => ["2016-06-13"          , "foo", []],
);

test_format(
    format => 'iso8601_datetime',
    data   => [1465789176*1000       , "foo", []],
    fdata  => ["2016-06-13T03:39:36Z", "foo", []],
);

sub test_format {
    my %args = @_;
    my $formatter;
    subtest +($args{name} // $args{format}) => sub {
        lives_ok {
            $formatter = Data::Sah::FormatJS::gen_formatter(
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

done_testing;
