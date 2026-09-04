#!/usr/bin/env ruby

require "open3"
require "shellwords"
require "yaml"

root = File.expand_path("..", __dir__)

def assert_contract(condition, message)
  abort "release contract failed: #{message}" unless condition
end

workflow = File.read(File.join(root, ".github/workflows/release.yml"))
workflow_config = YAML.safe_load(workflow, aliases: true)
release_job = workflow_config.fetch("jobs").fetch("release")
release_steps = release_job.fetch("steps")
ci_workflow = File.read(File.join(root, ".github/workflows/ci.yml"))
ci_config = YAML.safe_load(ci_workflow, aliases: true)
ci_steps = ci_config.fetch("jobs").fetch("verify").fetch("steps")
wrapper = File.read(File.join(root, "gradle/wrapper/gradle-wrapper.properties"))
package = File.read(File.join(root, "Package.swift"))
podspec = File.read(File.join(root, "NotiflyKMP.podspec"))
updater = File.read(File.join(root, "scripts/update_release_manifests.rb"))
gradle_build = File.read(File.join(root, "kmp/build.gradle.kts"))
js_smoke_test = File.read(File.join(root, "scripts/smoke-js-package.mjs"))
readme = File.read(File.join(root, "README.md"))

assert_contract(workflow.include?("ref: main"), "release checkout must be pinned to main")
assert_contract(workflow.include?("id: release-state"), "release workflow must detect existing publication state")
assert_contract(!workflow.include?('git rev-parse "v$VERSION" >/dev/null 2>&1 && exit 1'), "existing tags must be resumable")
assert_contract(workflow.include?('npm view "notifly-kmp-sdk@$VERSION"'), "npm publication must be detected before retry")
assert_contract(workflow.include?("pod trunk info NotiflyKMP"), "CocoaPods publication must be detected before retry")
assert_contract(workflow.include?('gh release view "$tag"'), "GitHub release state must be detected before retry")

permissions = workflow_config.fetch("permissions")
assert_contract(permissions["id-token"] == "write", "release workflow must grant OIDC id-token write permission")
assert_contract(release_job["environment"] == "release", "npm trusted publishing must be bound to the release environment")

assert_contract(!workflow.match?(/\b(?:NPM_TOKEN|NODE_AUTH_TOKEN)\b/), "release workflow must not require npm tokens")
assert_contract(!gradle_build.match?(/\b(?:NPM_TOKEN|NODE_AUTH_TOKEN)\b/), "Gradle npm packaging must not require npm tokens")

node_setup = release_steps.find { |step| step["uses"]&.start_with?("actions/setup-node@") }
assert_contract(!node_setup&.fetch("with", {})&.key?("registry-url"), "OIDC setup must not generate a token-based npmrc")
assert_contract(node_setup&.fetch("with", {})&.fetch("package-manager-cache", nil) == false, "release builds must disable package manager caching")

npm_upgrade = release_steps.find { |step| step["name"] == "Upgrade npm" }
assert_contract(npm_upgrade&.fetch("run", nil) == "npm install -g npm@11.5.1", "release workflow must pin an OIDC-capable npm version")

npm_publish = release_steps.find { |step| step["name"] == "Publish npm prerelease" }
npm_publish_command = Shellwords.split(npm_publish&.fetch("run", ""))
assert_contract(
  npm_publish_command.take(2) == ["npm", "publish"] &&
    npm_publish_command.include?("--provenance") &&
    npm_publish_command.none? { |argument| argument.start_with?("--provenance=") },
  "npm publication must emit provenance"
)

release_state = release_steps.find { |step| step["id"] == "release-state" }
assert_contract(release_state&.fetch("run", "")&.include?('npm view "notifly-kmp-sdk" name'), "release state must detect whether npm is bootstrapped")

assert_contract(!gradle_build.include?('organization = "notifly"'), "npm package must not use the unavailable @notifly scope")
assert_contract(gradle_build.include?('packageName = "notifly-kmp-sdk"'), "Gradle must package the unscoped npm name")
assert_contract(js_smoke_test.include?('require("notifly-kmp-sdk")'), "npm smoke test must consume the published package name")
assert_contract(readme.include?("JavaScript: `notifly-kmp-sdk`"), "README must document the published package name")

npm_bootstrap = release_steps.find { |step| step["name"] == "Verify npm trusted publishing bootstrap" }
assert_contract(npm_bootstrap&.fetch("if", "")&.include?("npm_package_exists != 'true'"), "release must stop when the npm package is not bootstrapped")

release_step_names = release_steps.map { |step| step["name"] }.compact
bootstrap_index = release_step_names.index("Verify npm trusted publishing bootstrap")
[
  "Test and build",
  "Commit versioned manifests",
  "Create GitHub release",
  "Publish npm prerelease",
].each do |step_name|
  step_index = release_step_names.index(step_name)
  assert_contract(bootstrap_index && step_index && bootstrap_index < step_index, "npm bootstrap verification must precede #{step_name}")
end

npm_publish_index = release_step_names.index("Publish npm prerelease")
[
  "Commit versioned manifests",
  "Create GitHub release",
].each do |step_name|
  step_index = release_step_names.index(step_name)
  assert_contract(npm_publish_index && step_index && npm_publish_index < step_index, "npm OIDC publication must precede #{step_name}")
end

ci_release_contract = ci_steps.find { |step| step["name"] == "Verify release contracts" }
assert_contract(ci_release_contract&.fetch("run", nil) == "ruby scripts/test-release-contracts.rb", "CI must enforce release contracts")

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
