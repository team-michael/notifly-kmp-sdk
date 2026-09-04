#!/usr/bin/env ruby

require "open3"

root = File.expand_path("..", __dir__)

def assert_contract(condition, message)
  abort "release contract failed: #{message}" unless condition
end

workflow = File.read(File.join(root, ".github/workflows/release.yml"))
wrapper = File.read(File.join(root, "gradle/wrapper/gradle-wrapper.properties"))
package = File.read(File.join(root, "Package.swift"))
podspec = File.read(File.join(root, "NotiflyKMP.podspec"))
updater = File.read(File.join(root, "scripts/update_release_manifests.rb"))

assert_contract(workflow.include?("ref: main"), "release checkout must be pinned to main")
assert_contract(workflow.include?("id: release-state"), "release workflow must detect existing publication state")
assert_contract(!workflow.include?('git rev-parse "v$VERSION" >/dev/null 2>&1 && exit 1'), "existing tags must be resumable")
assert_contract(workflow.include?('npm view "@notifly/kmp-sdk@$VERSION"'), "npm publication must be detected before retry")
assert_contract(workflow.include?("pod trunk info NotiflyKMP"), "CocoaPods publication must be detected before retry")
assert_contract(workflow.include?('gh release view "$tag"'), "GitHub release state must be detected before retry")

expected_wrapper_checksum = "d725d707bfabd4dfdc958c624003b3c80accc03f7037b5122c4b1d0ef15cecab"
assert_contract(
  wrapper.include?("distributionSha256Sum=#{expected_wrapper_checksum}"),
  "Gradle 8.9 distribution checksum must be pinned"
)

swift_checksum = package[/checksum: "([0-9a-f]{64})"/, 1]
pod_checksum = podspec[/:sha256 => "([0-9a-f]{64})"/, 1]
assert_contract(swift_checksum == pod_checksum, "SwiftPM and CocoaPods checksums must match")
assert_contract(updater.include?("podspec.sub!(/:sha256"), "manifest updater must update the CocoaPods checksum")

version_checker = File.join(root, "scripts/cocoapods-version-exists.rb")
assert_contract(File.executable?(version_checker), "CocoaPods exact-version checker must exist")
partial_match_output = "NotiflyKMP\n- Versions:\n  - 0.1.0-alpha.10 (2026-09-04 00:00:00 UTC)\n"
_, _, partial_status = Open3.capture3(version_checker, "0.1.0-alpha.1", stdin_data: partial_match_output)
assert_contract(!partial_status.success?, "CocoaPods alpha.1 must not match alpha.10")

exact_match_output = partial_match_output + "  - 0.1.0-alpha.1 (2026-09-03 00:00:00 UTC)\n"
_, _, exact_status = Open3.capture3(version_checker, "0.1.0-alpha.1", stdin_data: exact_match_output)
assert_contract(exact_status.success?, "CocoaPods alpha.1 must match the complete alpha.1 version field")

puts "release contracts verified"
