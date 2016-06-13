package Data::Sah::Format::perl::iso8601_datetime;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub format {
    my %args = @_;

    my $dt    = $args{data_term};
    my $fargs = $args{args} // {};

    my $format_datetime   = $fargs->{format_datetime} // 1;
    my $format_timemoment = $fargs->{format_timemoment} // 1;

    my $res = {};

    $res->{expr} = join(
        "",
        "$dt =~ /\\A\\d+(\\.\\d+)?\\z/ ? do { my \@t = gmtime($dt); sprintf('%04d-%02d-%02dT%02d:%02d:%02dZ', \$t[5]+1900, \$t[4]+1, \$t[3], \$t[2], \$t[1], \$t[0]) } : ",
        ($format_datetime ?
             # convert to UTC first
             "ref($dt) eq 'DateTime' ? DateTime->from_epoch(epoch => $dt\->epoch)->iso8601 . 'Z' : " : ""),
        ($format_timemoment ?
             "ref($dt) eq 'Time::Moment' ? $dt\->at_utc->strftime('%Y-%m-%dT%H:%M:%SZ') : " : ""),
        $dt,
    );

    $res;
}

1;
# ABSTRACT: Format date as ISO8601 datetime (e.g. 2016-06-13T03:08:00Z)

=for Pod::Coverage ^(format)$

=head1 DESCRIPTION

Will format epoch as ISO8601 datetime. By default will also format L<DateTime>
and L<Time::Moment> instances, but this can be turned off. Will leave other kind
of data unformatted.


=head1 FORMATTER ARGUMENTS

=head2 format_datetime => bool (default: 1)

=head2 format_timemoment => bool (default: 1)
