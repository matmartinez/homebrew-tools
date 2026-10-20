class Blocksay < Formula
  desc "Render text as blocky ASCII art"
  homepage "https://github.com/matmartinez/blocksay"
  url "https://github.com/matmartinez/blocksay/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "d5a54c0a1e37aa9848becb304eeddb59263079e7ea961448566b51430a733c95"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/matmartinez/tools"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "bffa71e5ca957d6d3b1783578df207ef2a7eb69bf4d30638758824e848619fe9"
  end

  on_linux do
    depends_on "swift" => :build
  end

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/blocksay"
  end

  test do
    output = shell_output("#{bin}/blocksay a")
    assert_equal 4, output.lines.count
  end
end
