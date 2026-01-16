class Blocksay < Formula
  desc "Render text as blocky ASCII art"
  homepage "https://github.com/matmartinez/blocksay"
  url "https://github.com/matmartinez/blocksay.git",
      using: :git,
      revision: "fdbb65247ccae8f7ae1f4dfb7af7206c69b71d9b"
  version "0.1.0"

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
