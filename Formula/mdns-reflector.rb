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
  end
  
  service do
    run [opt_bin/"mdns-reflector", "-fn", "en0", "bridge100"]
    keep_alive true
    log_path var/"log/mdns-reflector.log"
    error_log_path var/"log/mdns-reflector.log"
  end

  test do
    output = shell_output("#{bin}/mdns-reflector -h")
    assert_match "mdns-reflector", output
  end
end
