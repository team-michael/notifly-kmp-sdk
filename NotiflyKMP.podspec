Pod::Spec.new do |spec|
  spec.name = "NotiflyKMP"
  spec.version = "0.1.0-alpha.1"
  spec.summary = "Shared Kotlin Multiplatform implementation used by the Notifly SDKs."
  spec.homepage = "https://github.com/team-michael/notifly-kmp-sdk"
  spec.license = { :type => "MIT" }
  spec.author = { "Notifly" => "engineering@notifly.tech" }
  spec.source = {
    :http => "https://github.com/team-michael/notifly-kmp-sdk/releases/download/v#{spec.version}/NotiflyKMP.xcframework.zip"
  }
  spec.ios.deployment_target = "15.0"
  spec.vendored_frameworks = "NotiflyKMP.xcframework"
end
