class Ocx < Formula
  desc "OCX - AI coding tool"
  homepage "https://github.com/kdcokenny/ocx"
  version "0.1.4"  # Versionsnummer aus dem Release anpassen

  on_macos do
    on_arm do
      url "https://github.com/kdcokenny/ocx/releases/download/v#{version}/ocx-darwin-arm64"
      sha256 "2421257685ed7c2c738d137d3dfa452c06be4666447661f8c7e4ce6f532cb0e3"
    end
    on_intel do
      url "https://github.com/kdcokenny/ocx/releases/download/v#{version}/ocx-darwin-x64"
      sha256 "280578a90dad5bc067c7009b885777d79c6677eb88ce16523131d298b8fec3aa"
    end
  end

  def install
    binary_name = Hardware::CPU.arm? ? "ocx-darwin-arm64" : "ocx-darwin-x64"
    bin.install binary_name => "ocx"
  end

  test do
    system "#{bin}/ocx", "--version"
  end
end