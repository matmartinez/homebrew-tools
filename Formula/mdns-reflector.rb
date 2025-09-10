class MdnsReflector < Formula
  desc "Lightweight and performant mDNS reflector"
  homepage "https://github.com/matmartinez/mdns-reflector"
  url "https://github.com/matmartinez/mdns-reflector/archive/refs/tags/v0.1.0-macos1.tar.gz"
  sha256 "f300cb7cbf9f6c2d553b46ba7d72415780ba6de947bc1f07db040b7c9ae5179d"
  license "GPL-3.0-or-later"
  head "https://github.com/matmartinez/mdns-reflector.git", branch: "main"

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DCMAKE_BUILD_TYPE=Release", *std_cmake_args
      system "cmake", "--build", "."
      system "cmake", "--install", "."
    end
  
    # Create a default config on first install (user can edit later)
    conf = etc/"mdns-reflector.conf"
    unless conf.exist?
      conf.write <<~EOS
        # mdns-reflector Homebrew service configuration
        # Space-separated network interfaces (first is the "from", the rest are "to")
        interfaces="en0 bridge100"
        # Optional extra flags, e.g. "-4 -f"
        extraFlags=""
      EOS
    end
  
    # Wrapper that reads the config and starts the daemon with those args
    (bin/"mdns-reflector-service").write <<~SH
      #!/bin/bash
      set -euo pipefail
      
      CONF="#{etc}/mdns-reflector.conf"
      
      interfaces=""
      extraFlags=""
      if [[ -f "$CONF" ]]; then
        # shellcheck disable=SC1090
        source "$CONF"
      fi
      
      # shellcheck disable=SC2206
      interfaces_args=(${interfaces:-"en0 bridge100"})
      # shellcheck disable=SC2206
      extra_args=(${extraFlags:-})
      
      exec "#{opt_bin}/mdns-reflector" \
        "${extra_args[@]}" \
        -fn \
        "${interfaces_args[@]}"
    SH
    chmod 0755, bin/"mdns-reflector-service"
  end
  
  service do
    # Run the wrapper so changes in etc/mdns-reflector.conf take effect on restart
    run [opt_bin/"mdns-reflector-service"]
    keep_alive true
    log_path var/"log/mdns-reflector.log"
    error_log_path var/"log/mdns-reflector.log"
  end

  test do
    output = shell_output("#{bin}/mdns-reflector -h")
    assert_match "mdns-reflector", output
  end
end
