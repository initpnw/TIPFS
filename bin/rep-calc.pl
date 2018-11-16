#!/usr/bin/env perl
use POSIX;

$peer_count=$ARGV[0];
print ceil($peer_count/(($peer_count/12.0)+3))+2;
