# typed: false
# frozen_string_literal: true

class Plannotator < Formula
  desc "Interactive code review UI for OpenCode and Claude Code"
  homepage "https://github.com/backnotprop/plannotator"
  version "0.9.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/backnotprop/plannotator/releases/download/v0.9.1/plannotator-darwin-arm64"
      sha256 "51fc2fe53afd1c52f6a1289ab3720a162da3553483e7cdef0dd3cca70868fd68"
    end

    on_intel do
      url "https://github.com/backnotprop/plannotator/releases/download/v0.9.1/plannotator-darwin-x64"
      sha256 "1d8ec4f43d0b22d46a8ed971680dd8d2f4d37088250ec87d1c55cefe8ee582ed"
    end
  end

  def install
    # The downloaded artifact IS the binary (no archive to unpack)
    binary = Hardware::CPU.arm? ? "plannotator-darwin-arm64" : "plannotator-darwin-x64"
    bin.install binary => "plannotator"
  end

  def post_install
    # ── OpenCode slash command ──────────────────────────────────────────────
    opencode_commands_dir = Pathname.new(
      ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")
    ) / "opencode" / "command"
    opencode_commands_dir.mkpath

    (opencode_commands_dir / "plannotator-review.md").write <<~MARKDOWN
      ---
      description: Open interactive code review for current changes
      ---
      The Plannotator Code Review has been triggered. Opening the review UI...
      Acknowledge "Opening code review..." and wait for the user's feedback.
    MARKDOWN

    # ── Claude Code slash command ───────────────────────────────────────────
    claude_commands_dir = Pathname.new(Dir.home) / ".claude" / "commands"
    claude_commands_dir.mkpath

    (claude_commands_dir / "plannotator-review.md").write <<~MARKDOWN
      ---
      description: Open interactive code review for current changes
      allowed-tools: Bash(plannotator:*)
      ---
      ## Code Review Feedback
      !`plannotator review`
      ## Your task
      Address the code review feedback above. The user has reviewed your changes in the Plannotator UI and provided specific annotations and comments.
    MARKDOWN

    # ── Clear stale caches (harmless if they don't exist) ──────────────────
    cache_paths = [
      Pathname.new(Dir.home) / ".cache" / "opencode" / "node_modules" / "@plannotator",
      Pathname.new(Dir.home) / ".bun" / "install" / "cache" / "@plannotator",
    ]
    cache_paths.each { |p| FileUtils.rm_rf(p) if p.exist? }
  end

  def caveats
    <<~EOS
      Plannotator has been installed and the slash commands have been set up:

        • OpenCode:    ~/.config/opencode/command/plannotator-review.md
        • Claude Code: ~/.claude/commands/plannotator-review.md

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      REQUIRED: Add the OpenCode plugin to your opencode.json
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      Edit ~/.config/opencode/opencode.json (or your project's opencode.json)
      and add the plugin entry:

        {
          "plugin": ["@plannotator/opencode@latest"]
        }

      If you already have other plugins, append to the existing array:

        {
          "plugin": [
            "some-other-plugin",
            "@plannotator/opencode@latest"
          ]
        }

      The plugin is required for OpenCode to communicate with the
      Plannotator review UI. The binary alone is not sufficient.

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Usage
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      Start a review from the terminal:
        plannotator review

      Or trigger via slash command inside OpenCode / Claude Code:
        /plannotator-review
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/plannotator --version 2>&1", 0)
  end
end
