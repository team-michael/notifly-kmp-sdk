#!/usr/bin/env ruby

version = ARGV.fetch(0) do
  warn "usage: #{$PROGRAM_NAME} <version>"
  exit 2
end

version_line = /^\s*-\s+#{Regexp.escape(version)}\s+\(/
exit(STDIN.each_line.any? { |line| line.match?(version_line) } ? 0 : 1)
