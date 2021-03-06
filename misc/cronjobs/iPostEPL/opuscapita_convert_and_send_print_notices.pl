#!/usr/bin/perl
# iPost EPL interface for Koha ILS V161102 - written by Pasi Korkalo / Koha-Suomi Oy

# This script will pick up HTML ("pseudo EPL") print mail messages generated by Koha,
# combine them by receipient, create an EPL file and (optionally) send it to OpusCapita
# using SFTP. Sshpass utility is needed for SFTP (apt-get install sshpass).

# Once the notices have been inserted into message queue (advance_notices.pl, overdue_notices.pl)
# run something like this from cron after process_messages.pl:

# 30 20 * * *   perl $KOHA_PATH/misc/cronjobs/iPostEPL/gather_print_notices.pl /home/koha/koha-dev/var/spool/printmail
# 40 20 * * *   perl $KOHA_PATH/misc/cronjobs/iPostEPL/opuscapita_convert_and_send_print_notices.pl demobranch /home/koha/koha-dev/var/spool/printmail/notices-$(date +\%Y-\%m-\%d).html >> /home/koha/koha-dev/var/log/ipost-epl.log 2>&1

# Letters delivered to OpusCapita before 21.00 will be mailed the next day.

use utf8;
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use C4::Context;
use File::Copy;
use Text::Undiacritic qw(undiacritic);

# Get and set some global variables + initialize targetfile
our $branch=$ARGV[0];
our $noticefile=$ARGV[1];
our $letterfile=initletterfile();

die localtime ": You need to enter branchname (configured under branches in koha-conf.xml) and Koha notices file path/name as arguments." unless (defined $branch && defined $noticefile);

sub getkohanotices {
  # Get letters created by Koha and return them as array

  open (NOTICES, "<:encoding(UTF-8)", "$noticefile") or die localtime . ": Can't open NOTICES $noticefile.";
  my @contents=grep /<pre>/, <NOTICES>;
  foreach (@contents) {
    s/ *<pre> *//;
    s/ *<\/pre>\n//;
  }
  close NOTICES;

  return @contents;
}

sub hdiacritic {
  # OpusCapita supports a subset of ISO-8859-1, leave characters it can produce alone, convert the rest.

  my $char;
  my $oldchar;
  my $retstring;

  foreach (split(//, $_[0])) {
    $char=$_;
    $oldchar=$char;

    unless ( $char =~/[A-Za-z0-9ÅåÄäÖöÉéÜüÁá]/ ) {
      if    ($char eq 'Ʒ') { $char='Z';  }
      elsif ($char eq 'ʒ') { $char='z';  }
      elsif ($char eq 'ẞ') { $char='SS'; }
      elsif ($char eq 'ß') { $char='ss'; }
      elsif ($char eq 'ʻ') { $char='\''; }
      $char=undiacritic($char) unless "$oldchar" ne "$char";
    }
    $retstring=$retstring . $char;
  }

  return $retstring;
}

sub eplformat {
  # Format a line of text from Koha notices for iPost EPL

  my $line=shift @_;
  chomp $line;
  $line=" 0" . $line unless (grep /^[0-9 ]0/, $line or grep /^EPL/, $line);
  $line=$line . "\r\n";
  return hdiacritic($line);
}

sub paginate {
  # Paginate the letters

  my $contpagecode=C4::Context->config('printmailProviders')->{'opuscapita'}->{'branches'}->{"$branch"}->{'layout'}->{'contpagecode'};
  my $firstpage=C4::Context->config('printmailProviders')->{'opuscapita'}->{'branches'}->{"$branch"}->{'layout'}->{'firstpage'};
  my $otherpages=C4::Context->config('printmailProviders')->{'opuscapita'}->{'branches'}->{"$branch"}->{'layout'}->{'otherpages'};

  undef $contpagecode if $contpagecode eq '';
  undef $firstpage if $firstpage eq '';
  undef $otherpages if $otherpages eq '';

  die localtime . ": Required configuration variables for layout (contpagecode, firstpage, otherpages) are missing from koha-conf.xml.\n" unless (defined $contpagecode && defined $firstpage && defined $otherpages);

  my @letters;

  foreach (@_) {
    my $lines=0;
    my $linesperpage=$firstpage;

    foreach (split/<br \/>/, $_) {
      push @letters, eplformat($_);

      if ( $lines == $linesperpage) {
        $lines=0;
        $linesperpage=$otherpages;
        push @letters, "10\r\n$contpagecode\r\n";
      }

      $lines++;
    }
  }

  return @letters;
}

sub fixnontranslatables {
  # Convert possibly unconverted characters in targetfile with ? to prevent \x{...} mess in the letters.

  open LETTERS, "<encoding(latin1)", "$letterfile" or die localtime . ": Can't open LETTERS $letterfile.";
  my @letters=<LETTERS>;
  close LETTERS;

  open LETTERS, ">encoding(latin1)", "$letterfile" or die localtime . ": Can't open LETTERS $letterfile.";
  foreach my $eplline (@letters) {
    $eplline=~s/\\x\{....\}/?/g;
    print LETTERS $eplline;
  }
  close LETTERS;
}

sub initletterfile {
  # Create target directory if needed and return the target file name

  my $targetdir=C4::Context->config('printmailProviders')->{'opuscapita'}->{'targetdir'};
  undef $targetdir if $targetdir eq '';

  die localtime . ": Required configarion variable targetdir is missing from koha-conf.xml." unless (defined $targetdir);

  mkdir "$targetdir" unless -d "$targetdir" or die localtime . ": Can't create directory $targetdir.";

  my $letterfile=$noticefile;
  $letterfile=~s/^.*\///;
  $letterfile=~s/.html$/.epl/;
  $letterfile="$targetdir/$letterfile";

  return $letterfile;
}

sub writeepl {
  # Write formatted letters to an EPL file

  print localtime . ": Writing letters to $letterfile.\n";
  my $ipostcontact=C4::Context->config('printmailProviders')->{'opuscapita'}->{'branches'}->{"$branch"}->{'contact'};
  my $eplheader=C4::Context->config('printmailProviders')->{'opuscapita'}->{'branches'}->{"$branch"}->{'header'};

  undef $ipostcontact if $ipostcontact eq '';
  undef $eplheader if $eplheader eq '';

  die localtime . ": Required configuration variables (contact, header) are missing from koha-conf.xml." unless (defined $ipostcontact && $eplheader);

  open (LETTERS, ">encoding(latin1)", "$letterfile") or die localtime . ": Can't open LETTERS $letterfile.";
  print LETTERS "$eplheader                $ipostcontact\r\n";
  print LETTERS $_ foreach (@_);
  close LETTERS;

  fixnontranslatables;
}

sub sendletters {
  # Send EPL to OpusCapita with SFTP if it's configured. Net::SFTP isn't up for the task, so
  # we'll just spawn a shell and use "real" SFTP instead. sshpass is needed for this.
  my $letterfile=shift @_;

  my $host=C4::Context->config('printmailProviders')->{'opuscapita'}->{'sftp'}->{'host'};
  my $user=C4::Context->config('printmailProviders')->{'opuscapita'}->{'sftp'}->{'user'};
  my $password=C4::Context->config('printmailProviders')->{'opuscapita'}->{'sftp'}->{'password'};

  undef $host if $host eq '';
  undef $user if $user eq '';
  undef $password if $password eq '';

  if (defined $host && defined $user && defined $password ) {
    print localtime . ": Transferring letters to OpusCapita host $host with SFTP.\n";
    system ("sshpass -p $host sftp $user\@$password > /dev/null 2>&1 << EOF
put $letterfile
bye
EOF");
  } else {
    print localtime . ": SFTP is not configured in koha-conf.xml, not transferring letters.\n"
  }
}

sub moveoldnotices {
  # Move the processed notices out of the way

  my $directory=$noticefile;
  $directory=~m/^.+\//;
  $directory="$&old_notices";
  $directory=~s/^.html//;

  print localtime . ": Moving processed notices to $directory.\n";
  mkdir "$directory" unless -d "$directory" or die localtime . ": Can't create directory $directory.";
  move ("$noticefile", "$directory") or die localtime . ": Can't move $noticefile to $directory.";
}

sub combine {
  # Combine letters across branches?
  my $combine=C4::Context->config('printmailProviders')->{'opuscapita'}->{'combineacrossbranches'};
  $combine='no' unless defined $combine;

  my %signature;
  my %letters;
  my @letters;

  my $totalnotices;
  my $totalletters;

  foreach my $notice (@_) {
    $totalnotices++;
    if ($combine eq "yes") {
      my $header=$notice;
      $header=~s/----.*//;
      my $hashhead=md5_hex($header);

      my $message=$notice;
      $message=~s/.*?----//;
      $message=~s/----.*//;

      # Put signature aside for adding it later
      unless (defined $signature{"$hashhead"}) {
        $signature{"$hashhead"}=$notice;
        $signature{"$hashhead"}=~s/.*----//g;
      }

      # Temporarily put notices in a hash-table
      unless (defined $letters{"$hashhead"}) {
        $letters{"$hashhead"}=$header;
        $totalletters++;
      }
      $letters{"$hashhead"}.=$message;
    } else {
      # No combining, just push notices to an array
      $totalletters++;
      $notice=~s/----//g;
      push @letters, $notice;
    }
  }

  # Add signatures and push notices to an array if we were combining
  if ($combine eq "yes") {
    foreach (keys %letters) {
      $letters{$_}.=$signature{$_};
      push @letters, $letters{$_};
    }
  }

  print localtime . ": $totalnotices notices processed, $totalletters letters created.\n";
  return @letters;
}

print localtime . ": Processing notices in $noticefile.\n";

# Process and write Koha notices to EPL
writeepl(paginate(combine(getkohanotices))); # Silly ;P

# Send created letters with sftp and move processed notices out of the way
sendletters;
moveoldnotices;

print localtime . ": Done.\n";
exit 0;
