def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(arr)
  temp = Array.new # temp is to store values after removing whitespace and unwanted elements from the array recieved in the parameter.
  arr.each do |line|
    line.strip! # .strip returns the copy of the string after removing the whitespace as we used !(Exclamatory) at the end it is done in place.
    temp << line.split(", ") if line != "" and line[0] != "#"
  end
  temp
end

def resolve(records, chain, target)
  records.each do |record|
    if record[1] == target
      chain << record[2]
      chain = resolve(records, chain, record[2]) if record[0] == "CNAME"
    end
  end
  (puts "Error: record not found for #{chain[0]}"; exit) if chain.length == 1
  chain
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
