package Data::Sah::Format::js::iso8601_datetime;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub format {
    my %args = @_;

    my $dt    = $args{data_term};
    my $fargs = $args{args} // {};

    my $attempt_parse = $fargs->{attempt_parse} // 1;

    my $res = {};

    $res->{expr} = join(
        "",
        "$dt instanceof Date ? (isNaN($dt) ? d : $dt.toISOString().substring(0, 19) + 'Z') : ",
        $attempt_parse ? "(function(pd) { pd = new Date($dt); return isNaN(pd) ? $dt : pd.toISOString().substring(0, 19) + 'Z' })()" : "$dt",
    );

    $res;
}

1;
# ABSTRACT: Format date as ISO8601 datetime (e.g. 2016-06-13T03:08:00Z)

=for Pod::Coverage ^(format)$

=head1 DESCRIPTION


=head1 FORMATTER ARGUMENTS

=head2 attempt_parse => bool (default: 1)

If this argument is set to true (which is the default), then non-Date instance
value (e.g. numbers, strings) will be attempted to be converted to Date
instances first then formatted if possible.

If this argument is set to false, then non-Date instance values will be passed
unformatted.
