# Prebuilt GitHub release of CLIProxyAPI, so new releases land within minutes instead of
# waiting on homebrew-core. url/sha256 are bumped by bin/update-cliproxyapi.
class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.23/CLIProxyAPI_8.0.23_darwin_aarch64.tar.gz"
  sha256 "3c056b42ec4c80d06a74d3c5abf47ae0adb06285e32f5cf31a29bdd07017feb3"
  license "MIT"

  # bin/update-cliproxyapi bumps this; skipping keeps the autobump workflow from opening duplicate PRs.
  livecheck do
    skip "Bumped by bin/update-cliproxyapi"
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    libexec.install "cli-proxy-api"
    # The release binary has no compiled-in config path (the homebrew-core build does),
    # so default -config to the same etc file unless the caller passes one.
    (bin/"cliproxyapi").write <<~SH
      #!/bin/bash
      for arg in "$@"; do
        case "$arg" in -config|--config|-config=*|--config=*) exec "#{libexec}/cli-proxy-api" "$@" ;; esac
      done
      exec "#{libexec}/cli-proxy-api" -config "#{etc}/cliproxyapi.conf" "$@"
    SH
    chmod 0755, bin/"cliproxyapi"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
  end

  service do
    run [opt_bin/"cliproxyapi"]
    keep_alive true
  end

  test do
    assert_match "Version: #{version}", shell_output("#{libexec}/cli-proxy-api -h 2>&1")
  end
end
