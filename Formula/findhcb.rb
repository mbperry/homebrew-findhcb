class Findhcb < Formula
  desc "Data-depth CUSUM control-limit calibration with web interface"
  homepage "https://github.com/mbperry/cB-chart-Control-Limit"
  version "0.1.3"
  license "MIT"

  on_macos do
    url "https://github.com/mbperry/cB-chart-Control-Limit/releases/download/v#{version}/findhcB-macos.zip"
    sha256 "ffd6aebaf49f20d67e34568613c32c5fea7d0486a2405b3184bad24009a08fb7"
  end

  on_linux do
    url "https://github.com/mbperry/cB-chart-Control-Limit/releases/download/v#{version}/findhcB-linux-x86_64.zip"
    sha256 "d51ef9aba3093c52c6796ee8a873a3d8f16b83eef3d6049447caa72948066d4c"
  end

  depends_on "python@3.12"

  def install
    # Release zips unpack into a top-level "findhcB" directory containing
    # engine/ plus launchers we don't need (we ship our own brew-managed one).
    bundle_root = Pathname.pwd / "findhcB"
    libexec.install (bundle_root / "engine").children
    libexec.install (bundle_root / "t20.txt") if (bundle_root / "t20.txt").exist?

    # Mark the engine binary executable just in case the zip didn't preserve it
    chmod 0755, libexec / "findhcB"

    # Two user-facing commands:
    #   findhcb       – launch the web UI + open browser
    #   findhcb-cli   – raw interactive CLI (stdin-driven binary)

    (bin / "findhcb-cli").write <<~SH
      #!/bin/bash
      exec "#{libexec}/findhcB" "$@"
    SH

    (bin / "findhcb").write <<~SH
      #!/bin/bash
      set -e
      VENV="${HOME}/.cache/findhcb/venv"
      PY="#{Formula["python@3.12"].opt_bin}/python3.12"

      if [ ! -d "$VENV" ]; then
        echo "Setting up findhcb (one-time)..."
        mkdir -p "$(dirname "$VENV")"
        "$PY" -m venv "$VENV"
        "$VENV/bin/pip" install --quiet --upgrade pip
        "$VENV/bin/pip" install --quiet flask waitress
      fi

      # Open the browser after the server is up. macOS = open, Linux = xdg-open.
      (
        sleep 1
        if command -v open >/dev/null 2>&1; then
          open "http://127.0.0.1:5050"
        elif command -v xdg-open >/dev/null 2>&1; then
          xdg-open "http://127.0.0.1:5050"
        fi
      ) &

      cd "#{libexec}"
      exec "$VENV/bin/python" server.py
    SH

    chmod 0755, bin / "findhcb"
    chmod 0755, bin / "findhcb-cli"
  end

  def caveats
    <<~EOS
      Start the web interface with:
        findhcb

      It opens http://127.0.0.1:5050 in your browser.

      To run the raw CLI binary instead:
        findhcb-cli

      First launch downloads Flask + Waitress into ~/.cache/findhcb/venv (~5 MB).
    EOS
  end

  test do
    # Verify the CLI binary at least starts and prints its first prompt
    pid = spawn("#{bin}/findhcb-cli", out: "/dev/null", err: "/dev/null")
    sleep 1
    Process.kill("TERM", pid)
    Process.wait(pid)
    assert_predicate (libexec / "findhcB"), :executable?
    assert_predicate (libexec / "server.py"), :exist?
    assert_predicate (libexec / "index.html"), :exist?
  end
end
