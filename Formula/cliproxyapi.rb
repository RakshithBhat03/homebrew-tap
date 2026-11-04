# Prebuilt GitHub release of CLIProxyAPI, so new releases land within minutes instead of
# waiting on homebrew-core. url/sha256 are bumped by bin/update-cliproxyapi.
class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.54/CLIProxyAPI_8.0.54_darwin_aarch64.tar.gz"
  sha256 "02d771a68cdf9978821f01c85c6585db708f1da0f33f85947afc0b5b07b90951"
  license "MIT"
  require "etc"

  # bin/update-cliproxyapi bumps this; skipping keeps the autobump workflow from opening duplicate PRs.
  livecheck do
    skip "Bumped by bin/update-cliproxyapi"
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    libexec.install "cli-proxy-api"

    # Keep the live config outside the Homebrew-managed prefix. Upgrading a formula
    # re-runs install, and `etc.install` would overwrite etc/cliproxyapi.conf with
    # the stock template (plugins disabled, no plugin configs), which silently
    # removes all provider models. A symlink from etc to the user config keeps the
    # usual path working without ever clobbering actual settings.
    # Homebrew points HOME at a temporary build home while installing, so resolve
    # the real user's home from the password database instead of Dir.home.
    user_config = Pathname.new(Etc.getpwuid(Process.uid).dir)/".config/cliproxyapi/config.yaml"
    user_config.dirname.mkpath
    unless user_config.exist?
      user_config.write((buildpath/"config.example.yaml").read)
      user_config.chmod 0600
    end
    etc_config = etc/"cliproxyapi.conf"
    if etc_config.symlink? || etc_config.exist?
      etc_config.delete
    end
    etc_config.make_symlink(user_config)

    # The release binary has no compiled-in config path (the homebrew-core build does),
    # so default -config to the stable user config unless the caller passes one.
    (bin/"cliproxyapi").write <<~SH
      #!/bin/bash
      for arg in "$@"; do
        case "$arg" in -config|--config|-config=*|--config=*) exec "#{libexec}/cli-proxy-api" "$@" ;; esac
      done
      exec "#{libexec}/cli-proxy-api" -config "#{user_config}" "$@"
    SH
    chmod 0755, bin/"cliproxyapi"
  end

  service do
    run [opt_bin/"cliproxyapi"]
    keep_alive true
  end

  test do
    assert_match "Version: #{version}", shell_output("#{libexec}/cli-proxy-api -h 2>&1")
  end
end
