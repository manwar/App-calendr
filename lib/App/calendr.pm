package App::calendr;

$App::calendr::VERSION = '0.01';

=head1 NAME

App::calendr - Application to display supported Calendar.

=head1 VERSION

Version 0.01

=cut

use 5.006;
use Data::Dumper;
use Module::Pluggable
    search_path => [ 'Calendar' ],
    require     => 1,
    inner       => 0,
    max_depth   => 2;

use Moo;
use namespace::clean;

use Types::Standard -all;
use MooX::Options;

has calendars => (is => 'rw');
option month  => (is => 'ro', isa => Int, format => 'i', doc => 'Month number e.g. 1,2,3' );
option year   => (is => 'ro', isa => Int, format => 'i', doc => 'Year number (3/4 digits)'  );
option name   => (is => 'ro', isa => Str, format => 's', required => 1, doc => 'Calendar name e.g. Bahai,Hijri,Persian,Saka'  );

=head1 DESCRIPTION

It provides simple  command  line  interface  to the package L<App::calendr>. The
distribution contains a script C<calendr>, using package L<App::calendr>.

=head1 SYNOPSIS

You can list all command line options by giving --help flag.

    $ calendr --help

    USAGE: calendr [-h] [long options...]

        --month: Int
            Month number e.g. 1,2,3


        --name: String
            Calendar type e.g. Bahai,Hijri,Persian,Saka


        --year: Int
            Year number (3/4 digits)


        --usage:
            show a short help message


        -h --help:
            show a help message


        --man:
            show the manual

=head1 SUPPORTED CALENDARS

The following  supported  calendars can be installed individually or they all can
be installed in one go using L<Task::Calendar>.

    $ cpanm Task::Calendar

=over 4

=item * L<Calendar::Bahai>

=item * L<Calendar::Hijri>

=item * L<Calendar::Persian>

=item * L<Calendar::Saka>

=back

=cut

sub BUILD {
    my ($self) = @_;

    my $plugins = [ plugins ];
    foreach my $plugin (@$plugins) {
        my $name = _load_calendar($plugin);
        if (defined $name) {
            $self->{calendars}->{uc($name)} = $plugin->new;
        }
    }
}

=head1 METHODS

=head2 run()

This  is the only method provided by package L<App::calendr>. It does not  expect
any parameter. Here is the code from the supplied C<calendr> script.

    use strict; use warnings;
    use App::calendr;

    App::calendr->new_with_options->run;

=cut

sub run {
    my ($self) = @_;

    my $month = $self->month;
    my $year  = $self->year;
    my $name  = $self->name;

    my $supported_calendars = _supported_calendars();
    die "ERROR: Unsupported calendar [$name] received.\n"
        unless (exists $supported_calendars->{uc($name)});

    my $calendar = $self->get_calendar($name);
    if (defined $calendar) {
        if (defined $month && defined $year) {
            $calendar->month($month);
            $calendar->year($year);
        }
        print $calendar, "\n";
    }
    else {
        die "ERROR: Calendar [$name] is not installed.\n";
    }
}

sub get_calendar {
    my ($self, $name) = @_;

    return unless defined $name;
    return $self->{calendars}->{uc($name)} if exists $self->{calendars}->{uc($name)};
    return;
}

#
#
# PRIVATE METHODS

sub _load_calendar {
    my ($plugin) = @_;
    return unless defined $plugin;

    my $calendars = _supported_calendars();
    foreach my $name (keys %$calendars) {
        return $name if ($calendars->{$name} eq $plugin);
    }
    return;
}

sub _supported_calendars {

    return {
        'BAHAI'   => 'Calendar::Bahai',
        'HIJRI'   => 'Calendar::Hijri',
        'PERSIAN' => 'Calendar::Persian',
        'SAKA'    => 'Calendar::Saka',
    };
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/App-calendr>

=head1 BUGS

Please  report any bugs or feature requests to C<bug-app-calendr at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-calendr>.
I will  be notified and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::calendr

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-calendr>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-calendr>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-calendr>

=item * Search CPAN

L<http://search.cpan.org/dist/App-calendr/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain  a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of App::calendr