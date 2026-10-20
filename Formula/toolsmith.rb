class Toolsmith < Formula
  desc "Bridge MCP transports and expose command-line tools as MCP servers"
  homepage "https://github.com/matmartinez/toolsmith"
  url "https://github.com/matmartinez/toolsmith/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "ed9cac616f64ee8193401eb0c8a757f08f1f44e61e011a2c8c045798e01ddcd0"
  license "MIT"
  head "https://github.com/matmartinez/toolsmith.git", branch: "main"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/toolsmith"
    pkgshare.install "samples"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toolsmith --version")

    (testpath/"cli-tools.json").write <<~JSON
      {
        "cliServers": {
          "echo": {
            "executable": "/bin/echo",
            "tools": [
              {
                "name": "say",
                "description": "Echo text",
                "inputSchema": {
                  "type": "object",
                  "properties": { "text": { "type": "string" } },
                  "required": ["text"]
                },
                "argv": [{ "argument": "text" }]
              }
            ]
          }
        }
      }
    JSON

    port = free_port
    pid = spawn bin/"toolsmith", "--port", port.to_s, "--cli-tools-config", testpath/"cli-tools.json"
    begin
      30.times do
        break if quiet_system "curl", "-sf", "http://127.0.0.1:#{port}/status"

        sleep 0.5
      end
      request = '{"jsonrpc":"2.0","id":1,"method":"tools/call",' \
                '"params":{"name":"say","arguments":{"text":"hello brew"}}}'
      output = shell_output("curl -s -X POST http://127.0.0.1:#{port}/servers/echo/mcp " \
                            "-H 'Content-Type: application/json' " \
                            "-H 'Accept: application/json, text/event-stream' " \
                            "-d '#{request}'")
      assert_match "hello brew", output
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
