class Pastedown < Formula
  desc "macOS Pasteboard to Markdown"
  homepage "https://github.com/cloudygreybeard/pastedown"
  url "https://github.com/cloudygreybeard/pastedown/releases/download/v0.1.0/pastedown"
  sha256 "b7599480bfc4cc097c3d7840ed841c3b3984d88a8a18e6ab4fa1d852e6500947"
  version "0.1.0"
  license "Apache-2.0"

  depends_on :macos

  def install
    bin.install "pastedown"
  end

  test do
    system "#{bin}/pastedown", "--version"
  end
end
