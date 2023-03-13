local Pkg = require "mason-core.package"
local _ = require "mason-core.functional"
local github = require "mason-core.managers.github"
local platform = require "mason-core.platform"
local std = require "mason-core.managers.std"

local coalesce, when = _.coalesce, _.when

return Pkg.new {
    name = "java-lsp-server",
    desc = [[A Java language server based on v3.0 of the protocol and implemented using the Java compiler API.]],
    homepage = "https://github.com/georgewfraser/java-language-server",
    languages = { Pkg.Lang.Java },
    categories = { Pkg.Cat.LSP },
    ---@async
    ---@param ctx InstallContext
    install = function(ctx)
        local asset_file = coalesce(
            when(platform.is.mac_arm64, "rust-analyzer-aarch64-apple-darwin.gz"),
            when(platform.is.mac_x64, "rust-analyzer-x86_64-apple-darwin.gz"),
            when(platform.is.linux_x64_gnu, "rust-analyzer-x86_64-unknown-linux-gnu.gz"),
            when(platform.is.linux_arm64_gnu, "rust-analyzer-aarch64-unknown-linux-gnu.gz"),
            when(platform.is.linux_x64_musl, "rust-analyzer-x86_64-unknown-linux-musl.gz"),
            when(platform.is.win_arm64, "rust-analyzer-aarch64-pc-windows-msvc.zip"),
            when(platform.is.win_x64, "rust-analyzer-x86_64-pc-windows-msvc.zip")
        )

        platform.when {
            unix = function()
                github
                    .gunzip_release_file({
                        repo = "rust-lang/rust-analyzer",
                        asset_file = asset_file,
                        out_file = "rust-analyzer",
                    })
                    .with_receipt()
            end,
            win = function()
                github
                    .unzip_release_file({
                        repo = "rust-lang/rust-analyzer",
                        asset_file = asset_file,
                    })
                    .with_receipt()
            end,
        }
        std.chmod("+x", { "rust-analyzer" })
        ctx:link_bin("rust-analyzer", platform.is.win and "rust-analyzer.exe" or "rust-analyzer")
    end,
}
