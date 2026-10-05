class Portmap < Formula
  desc "Bookmarks for everything listening on localhost"
  homepage "https://github.com/RakshithBhat03/portmap"
  url "https://github.com/RakshithBhat03/portmap/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a098b2fabf83ccd5456c39f2787948e26c1e07a9567de3151ee879ef6919336c"
  license "MIT"
  head "https://github.com/RakshithBhat03/portmap.git", branch: "main"

  depends_on "rust" => :build
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run portmap at login with `brew services start portmap`, then open
      http://localhost:7878. Use either `brew services` or `portmap install`,
      not both; they would compete for the same port.
    EOS
  end

  service do
    run [opt_bin/"portmap", "serve"]
    keep_alive true
    process_type :background
    log_path var/"log/portmap.log"
    error_log_path var/"log/portmap.log"
  end

  test do
    assert_match "portmap #{version}", shell_output("#{bin}/portmap --version")

    port = free_port
    ENV["PORTMAP_HOME"] = testpath/"state"
    ENV["PORTMAP_NO_THUMBS"] = "1"
    pid = spawn bin/"portmap", "serve", "--port", port.to_s
    begin
      sleep 2
      assert_match "<title>", shell_output("curl -s http://127.0.0.1:#{port}/")
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
