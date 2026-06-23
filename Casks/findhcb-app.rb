cask "findhcb-app" do
  version "0.1.8"
  sha256 "822a1c63a5a27b6b6d44a0bef4724b667b51eb8665fa08ab0e2c65bf8da59315"

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
