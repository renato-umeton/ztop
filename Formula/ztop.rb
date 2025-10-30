class Ztop < Formula
  desc "All-in-one terminal system monitor with 5-pane layout for macOS"
  homepage "https://github.com/renato-umeton/ztop"
  url "https://github.com/renato-umeton/ztop/archive/refs/tags/v1.6.tar.gz"
  sha256 "41c5bf773dc78b560c99525062e464360245cf6fbef5d6e1f57a2a8ae8606b51"
  license "MIT"

  depends_on "tmux"
  depends_on "htop"
  depends_on "mactop"
  depends_on "ctop"
  depends_on "nethogs"
  depends_on :macos

  def install
    # Explicitly reference files from buildpath
    bin.install buildpath/"ztop.sh" => "ztop"

    # Install Oh My Zsh plugin
    (share/"oh-my-zsh/custom/plugins/ztop").install buildpath/"ztop.plugin.zsh"
    (share/"oh-my-zsh/custom/plugins/ztop").install buildpath/"ztop.sh"
    (share/"oh-my-zsh/custom/plugins/ztop").install buildpath/"test_ztop.sh"
    (share/"oh-my-zsh/custom/plugins/ztop").install buildpath/"README.md"
    (share/"oh-my-zsh/custom/plugins/ztop").install buildpath/"CLAUDE.md"

    # Create symlink for zz alias
    bin.install_symlink bin/"ztop" => "zz"
  end

  def post_install
    # Automatically configure passwordless sudo for ztop tools
    htop_path = "#{HOMEBREW_PREFIX}/bin/htop"
    mactop_path = "#{HOMEBREW_PREFIX}/bin/mactop"
    nethogs_path = "#{HOMEBREW_PREFIX}/bin/nethogs"

    sudoers_line = "%admin ALL=(ALL) NOPASSWD: #{htop_path}, #{mactop_path}, #{nethogs_path}"

    # Check if already configured
    system "sudo", "grep", "-q", "NOPASSWD.*htop.*mactop.*nethogs", "/etc/sudoers", "/etc/sudoers.d/*"
    return if $?.success?

    ohai "Configuring passwordless sudo for htop, mactop, and nethogs..."

    # Create temporary sudoers file
    temp_file = "/tmp/ztop_sudoers_#{Process.pid}"
    File.write(temp_file, "#{sudoers_line}\n")

    # Validate syntax
    if system "visudo", "-c", "-f", temp_file
      # Append to sudoers
      system "sudo", "sh", "-c", "echo '#{sudoers_line}' >> /etc/sudoers"
      opoo "Sudoers configured successfully!"
    else
      opoo "Failed to validate sudoers syntax. Please configure manually."
    end

    # Clean up
    File.delete(temp_file) if File.exist?(temp_file)
  end

  def caveats
    <<~EOS
      ZTop has been installed!

      Passwordless sudo has been automatically configured for htop, mactop, and nethogs.

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
