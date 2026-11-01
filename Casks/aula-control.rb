cask "aula-control" do
  version "1.0.0"
  sha256 "a1a620ed25247e067ed6e5bfce458ca0c34fcbbdaeebdfd0062c237b1d3e002d"

  url "https://github.com/RakshithBhat03/aula-control/releases/download/v#{version}/AULA-Control-#{version}.dmg"
  name "AULA Control"
  desc "Configure the AULA F108 Pro keyboard: lighting, per-key RGB, remapping and macros"
  homepage "https://github.com/RakshithBhat03/aula-control"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "AULA Control.app"
  binary "#{appdir}/AULA Control.app/Contents/Resources/bin/aula"

  # The app is ad-hoc signed, not notarized; without this Gatekeeper refuses the first launch.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/AULA Control.app"],
        writable_paths: ["{{appdir}}/AULA Control.app"]
  end

  zap trash: [
    "~/Library/Application Support/AULA Control",
    "~/Library/Preferences/com.aulacontrol.app.plist",
    "~/Library/Saved Application State/com.aulacontrol.app.savedState",
  ]

  caveats <<~EOS
    Grant Input Monitoring (and Accessibility for macOS remapping) in
    System Settings → Privacy & Security the first time you open the app.
  EOS
end
