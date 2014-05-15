#!/usr/bin/perl

$state = 0;
foreach $line (<>) {
  if ($line =~ /STAD/ && $line =~ m/cpu.php.*?id=\d+\">(.*?)<\//) {
    $state = 0;
    $name = $1;
    if ($name =~ m/intel/i || $name =~ m/amd/i) {
      $state = 1;
      if ($line =~ m/STAD.*?span>\s*([\d,]+)\s*<\//) {
        $state = 2;
        $score = $1;
      } else {
        $state = 0;
      }
    }
  }
  if ($state==2 && $line =~ m/cpu.php.*?#price\">(.*?)<\//) {
    $state = 0;
    print "$name\n$score\n$1\n";
  }

  if ($line =~ /price performance/i) { break; }
}
