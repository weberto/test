#!/usr/bin/perl
########################################################################
## 03/11/15: 
########################################################################

use File::Find;
use File::Slurp;
use File::Basename;
use Date::Calc qw(Today_and_Now);

my @DIR = ("/best3");
my $today = sprintf("%04d%02d%02d_%02d%02d%02d", Today_and_Now);
my $extension = "nyt3.$today";
my $nyt3_changes = 0;

find(\&wanted, @DIR);

sub wanted {
  if ($File::Find::dir =~ /migration|tests/) {
    return;
  }
  if ($File::Find::name =~ /(.pl|.pm)$/) {
    my @lines = read_file($File::Find::name);
    my @new_lines = ();
    my $changes = 0;
    foreach my $l (@lines) {
      chomp($l);
      if ($l !~ /^\s*#/) { 
        if ($l =~ /NYT3::/) {
          $changes++;

          print "$File::Find::name\n";
          $l = "#$l";
          print "GIVEN 1: \t$l\n";
        } elsif ($l =~ /getStyle/) {
          $changes++;
          print "$File::Find::name\n";
          $l = "#$l\n";
          $l .= "\$style = '<link rel=stylesheet type=\"text/css\" href=\"/styles/best5.css\">';\n";
          print "GIVEN 2: \t$l\n";
        }
      }
      push(@new_lines, "$l\n");
    }
    if ($changes) {
      $nyt3_changes++;
      print "MODIFIED: `cp $File::Find::name $File::Find::name.$extension`\n\n\n";
      `cp $File::Find::name $File::Find::name.$extension`;
      my $new_file = $File::Find::name;
      write_file($new_file, @new_lines);
      my $results = `perl -cT $new_file`; 
      print "$results\n";
    }
  }
}

print "TOTAL CHANGES: $nyt3_changes\n";


