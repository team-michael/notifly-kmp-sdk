#!/usr/bin/env ruby

version, checksum = ARGV

unless version&.match?(/\A\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\z/)
  abort "usage: #{$PROGRAM_NAME} <version> <64-character-checksum>"
end

unless checksum&.match?(/\A[0-9a-f]{64}\z/)
  abort "usage: #{$PROGRAM_NAME} <version> <64-character-checksum>"
end

root = File.expand_path("..", __dir__)
package_path = File.join(root, "Package.swift")
podspec_path = File.join(root, "NotiflyKMP.podspec")

package = File.read(package_path)
package.sub!(%r{/download/v[^/]+/NotiflyKMP\.xcframework\.zip}, "/download/v#{version}/NotiflyKMP.xcframework.zip")
package.sub!(/checksum: "[0-9a-f]{64}"/, "checksum: \"#{checksum}\"")
File.write(package_path, package)

podspec = File.read(podspec_path)
podspec.sub!(/spec\.version = "[^"]+"/, "spec.version = \"#{version}\"")
podspec.sub!(/:sha256 => "[0-9a-f]{64}"/, ":sha256 => \"#{checksum}\"")
File.write(podspec_path, podspec)
