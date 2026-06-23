cask "findhcb-app" do
  version "0.1.9"
  sha256 "a8052a70de24866fe51ad4f398192bd9e7e39c670cb56eb8e18c1ca2bea26029"

  url "https://github.com/mbperry/cB-chart-Control-Limit/releases/download/v#{version}/findhcB-macos.dmg"
  name "findhcB"
  desc "Data-depth CUSUM control-limit calibration with web interface"
  homepage "https://github.com/mbperry/cB-chart-Control-Limit"

  app "findhcB.app"

  uninstall quit: "com.mbperry.findhcb"

  zap trash: [
    "~/Library/Application Support/findhcB",
    "~/Library/Caches/findhcb",
  ]
end
