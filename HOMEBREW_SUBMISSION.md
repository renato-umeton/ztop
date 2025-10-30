# ZTop Homebrew Submission Guide

## Step 1: Calculate SHA256 for the Release

After the v1.5 release is created, calculate the SHA256:

```bash
curl -L https://github.com/renato-umeton/ztop/archive/refs/tags/v1.5.tar.gz | shasum -a 256
```

Update the `sha256` field in `Formula/ztop.rb` with this value.

## Step 2: Test the Formula Locally

```bash
# Install from local formula
brew install --build-from-source Formula/ztop.rb

# Test the installation
ztop --help
zz --help

# Test the formula
brew test ztop

# Uninstall for clean test
brew uninstall ztop
```

## Step 3: Submit to Homebrew

### Option A: Homebrew Core (Main Repository)

**Note**: Homebrew Core has strict requirements. They prefer:
- Notable/popular projects
- Stable, well-maintained software
- Good documentation

Steps:
1. Fork https://github.com/Homebrew/homebrew-core
2. Add `Formula/ztop.rb` to the `Formula/` directory
3. Submit Pull Request with title: "ztop 1.5 (new formula)"
4. Follow Homebrew's contribution guidelines

### Option B: Create a Homebrew Tap (Recommended for Now)

Create your own tap for easier distribution:

```bash
# Create a new repository: homebrew-ztop
# Repository name MUST start with "homebrew-"

# Add the formula to the repo
git clone https://github.com/renato-umeton/homebrew-ztop
cd homebrew-ztop
mkdir Formula
cp path/to/ztop/Formula/ztop.rb Formula/
git add Formula/ztop.rb
git commit -m "Add ztop formula"
git push
```

Then users can install with:
```bash
brew tap renato-umeton/ztop
brew install ztop
```

## Step 4: Update README with Homebrew Install Instructions

Add to README.md:

```markdown
## Installation

### Via Homebrew (Easiest)

\`\`\`bash
brew tap renato-umeton/ztop
brew install ztop
\`\`\`

### Via Oh My Zsh Plugin

\`\`\`bash
git clone https://github.com/renato-umeton/ztop.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ztop
# Add 'ztop' to plugins array in ~/.zshrc
source ~/.zshrc
\`\`\`
```

## Current Formula Features

- ✅ Installs `ztop` command to `/usr/local/bin`
- ✅ Creates `zz` symlink for shorter command
- ✅ Installs Oh My Zsh plugin to share directory
- ✅ Declares all dependencies (tmux, htop, mactop, ctop, nethogs)
- ✅ Includes post-install caveats with setup instructions
- ✅ Includes test block for verification
- ✅ macOS-only (specified with `depends_on :macos`)

## Next Steps

1. Calculate and update SHA256
2. Test formula locally
3. Create `homebrew-ztop` repository
4. Push formula to tap
5. Update main README with Homebrew install instructions
6. After gaining popularity, consider submitting to Homebrew Core
