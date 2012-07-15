# ABSTRACT: Sleep for n seconds while events still fire
package AnyEvent::Sleep;
use strict;
use warnings;
use AnyEvent;
use Sub::Exporter -setup => {
    exports => [qw( sleep sleep_until )],
    groups => { default => [qw( sleep sleep_until )] },
    };

=helper sub sleep( Num $secs ) is export

Sleep for $secs while allowing AnyEvent events to emit (and Coroutine threads to run)

=cut

sub sleep($) {
    my( $sleep_for ) = @_;
    AE::now_update;
    my $start = AE::time;
    while ( AE::time - $start < $sleep_for ) {
        my $cv = AE::cv;
        my $w=AE::timer( $sleep_for - (AE::time-$start), 0, sub { $cv->send } );
        $cv->recv;
    }
    return;
}

=helper sub sleep_until( Num $epochtime ) is export

Sleep until $epochtime while allowing events to emit (and Coroutine threads to run)

=cut

sub sleep_until($) {
    my $for = $_[-1] - AE::time;
    return if $for <= 0;
    my $cv = AE::cv;
    my $w=AE::timer( $for, 0, sub { $cv->send } );
    $cv->recv;
    uncef $cv;
    return;
}

1;

=head1 SYNOPSIS

    use AnyEvent::Sleep;

    # Sleep for 3 seconds without blocking events from firing
    sleep 3;

    # Sleep for an hour
    sleep_until time() + 3600;

=head1 DESCRIPTION

This module provides event-loop safe sleep loops.  Sleeps can be useful to
setup timeouts-- try something, sleep, if it hasn't returned cancel it.

If you are using Coro, then sleep is probably better gotten from
L<Coro::AnyEvent>.

The helpers in this module are exported by L<Sub::Exporter>.

=head1 SEE ALSO

Coro::AnyEvent

