# More documentation about how to customize your build
# can be found here:
# https://docs.fastlane.tools
fastlane_version "2.68.0"

# This value helps us track success metrics for Fastfiles
# we automatically generate. Feel free to remove this line
# once you get things running smoothly!
generated_fastfile_id "404f0f66-9003-4ea3-a45e-30a34acfc79e"

default_platform :ios

# Fastfile actions accept additional configuration, but
# don't worry, fastlane will prompt you for required
# info which you can add here later
lane :beta do
  # cocoapods

  # build your iOS app
  build_app(
    # scheme: "YourScheme",
    export_method: "ad-hoc"
  )

  # upload to Beta by Crashlytics
  crashlytics(
    api_token: "7d37859cdd48a23d559138042efc16453544c4a2",
    build_secret: "9112f23ee20600c1c4a10809f33ae09d2dfce087e8a2701112d3debafba7421a"
  )
end
