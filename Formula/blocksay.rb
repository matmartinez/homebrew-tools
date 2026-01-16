class Blocksay < Formula
  desc "Render text as blocky ASCII art"
  homepage "https://github.com/matmartinez/blocksay"
  url "https://github.com/matmartinez/blocksay/archive/refs/tags/v0.1.0.tar.gz"
  version "0.1.0"
  sha256 "856df28ef3c33a9e594e6fedc7c81d5eaec9486d3abdea0465923622f7f22b58"

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
