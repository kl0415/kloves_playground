#!/usr/bin/env ruby

#
#Pre Commit Hook:
#
#Ensuring that our format (shown below) is followed for all commits
#No lines can be longer than 75 characters
#
#[BUGFIX|TASK|USERSTORY|SPEC-CHANGE] Short description of your commit
#
# Be more descriptive of your commit here. Be specific about the changes.
# Why was it changed; if code changes are major, describe the important pieces 
# of those changes; and also include a "How to test:" section if necessary.
#
# * Bullets are allowed 
# * 1 space between asterisk and the bullet code
#
# * Please do not write lines longer than 80 characters
#
# Resolves: #put ticket IDs here. IF Rally Use R<ID>  if QC use "QC<ID>"
# Examples: R014512 QC4827
#
# Target Release: 
#  Example - use the release id as assigned, BF-3.10-9.14
#
#
#
#

editor = ENV['EDITOR'] != 'none' ? ENV['EDITOR'] : 'vim'

$type_regex = /\[(BUGFIX|TASK|USERSTORY|SPEC|CHANGE)\] (.*)/
$resolves_regex = /Resolves: (R|QC)(\d+)/
$release_regex = /Release[s]?: ([a-zA-Z0-9_\-\+\.]+)/
$comment_regex = /^#/

$type_match = false
$resolves_match = false
$release_match = false
$line_count = 0

message_file = ARGV[0]
commit_lines = File.readlines(message_file)
detail_desc = ""

commit_lines.each do |l| 
  next if ($comment_regex.match(l) || l.strip.empty?)
  if ($line_count == 0) && !($type_match)
    if ($type_regex.match(l)) && !($type_regex.match(l)[2].strip.empty?) 
      $type_match = true 
      $line_count += 1
    end
    next
  end

  #pull the description together 
  if($line_count && !$resolves_regex.match(l) && !$release_regex.match(l))
    detail_desc.concat(l)
    next
  end  
  
  if($line_count) && ($resolves_regex.match(l))
    $resolves_match = true
    $line_count += 1
  end
    
  if($line_count) && ($release_regex.match(l))
    $release_match = true
    $line_count += 1
  end

  # no need to read further after we get our release and resolves lines
  break if ($release_match && $resolves_match)
end
$exit_value = -1

$description_good = true
#puts "DESCRIPTION: #{detail_desc}"
#
if (detail_desc.split.count < 10)
  $description_good = false
end

#after we've seen the entire commit message, check for formatting errors
if (!$type_match || !$resolves_match || !$release_match)
  puts "Commit does not meet the required standard for commit comments:\n"

  if(!$type_match)
   puts "\tMissing Initial Descriptor line: [COMMIT_TYPE] Short Description\n" 
  end

  if(!$resolves_match)
   puts "\tMissing \"Resolves: QCxxxx Rxxxx\" line\n" 
  end

  if(!$release_match)
   puts "\tMissing \"Release: xxxx\" line\n" 
  end
  
  if(!$description_good)
    puts "Commit Description is not of a sufficient word length\n"
    puts " Consider being a bit more descriptive\n"
  end

  $exit_value = -1;
else
  $exit_value = 0
end

exit $exit_value
