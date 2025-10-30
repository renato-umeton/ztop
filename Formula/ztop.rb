class Ztop < Formula
  desc "All-in-one terminal system monitor with 5-pane layout for macOS"
  homepage "https://github.com/renato-umeton/ztop"
  url "https://github.com/renato-umeton/ztop/archive/refs/tags/v1.5.tar.gz"
  sha256 "cda0551a1531ef3c1f26e9068cc1c979639a4989f2c268fac153abc47b202de8"
  license "MIT"

  depends_on "tmux"
  depends_on "htop"
  depends_on "mactop"
  depends_on "ctop"
  depends_on "nethogs"
  depends_on :macos

  def install
    bin.install "ztop.sh" => "ztop"

    # Install Oh My Zsh plugin
    (share/"oh-my-zsh/custom/plugins/ztop").install "ztop.plugin.zsh"
    (share/"oh-my-zsh/custom/plugins/ztop").install "ztop.sh"
    (share/"oh-my-zsh/custom/plugins/ztop").install "test_ztop.sh"
    (share/"oh-my-zsh/custom/plugins/ztop").install "README.md"
    (share/"oh-my-zsh/custom/plugins/ztop").install "CLAUDE.md"

    # Create symlink for zz alias
    bin.install_symlink bin/"ztop" => "zz"
  end

  def caveats
    <<~EOS
      ZTop has been installed!

      To use as a standalone command:
        ztop    # or
        zz      # shorter

      To use as an Oh My Zsh plugin:
        1. Link to your Oh My Zsh plugins:
           ln -s #{share}/oh-my-zsh/custom/plugins/ztop ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ztop

        2. Add 'ztop' to your plugins array in ~/.zshrc:
           plugins=(... ztop)

        3. Reload your shell:
           source ~/.zshrc

      Configure passwordless sudo (required):
        sudo visudo
        # Add this line:
        %admin ALL=(ALL) NOPASSWD: #{HOMEBREW_PREFIX}/bin/htop, #{HOMEBREW_PREFIX}/bin/mactop, #{HOMEBREW_PREFIX}/bin/nethogs

      For more information, visit: https://github.com/renato-umeton/ztop
    EOS
  end

  test do
    # Test that the script exists and is executable
    assert_predicate bin/"ztop", :exist?
    assert_predicate bin/"ztop", :executable?

    # Test help output
    assert_match "ztop - Multi-pane system monitoring", shell_output("#{bin}/ztop --help")
  end
end
