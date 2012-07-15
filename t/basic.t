use strict;
use warnings;
use Test::More tests => 2;
use AnyEvent;
use AnyEvent::Sleep 'sleep' => { -as => 'aesleep' };
use Time::HiRes qw( sleep time );

sub sleep_with {
    my $sleep = shift;
    
    # Sleeps like those in Time::HiRes muck up AnyEvent's sense of time,
    # this forces it to update
    AE::now_update;
    my $cnt = 0;
    my $w; 
    $w = AE::timer 0.2, 0.2, sub { $cnt++ };
    
    $sleep->(0.5);
    return $cnt;
}


is( sleep_with(\&sleep), 0, "Our timer didn't tick at all using stock sleep" );

is( sleep_with(\&aesleep), 2, "Our timer ticked using our sleep" );

