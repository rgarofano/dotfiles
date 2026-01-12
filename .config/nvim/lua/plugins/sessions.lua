return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    },
    keys = {
        { "<leader>fs", "<cmd>AutoSession search<Enter>", desc = "Find session" },
    },
}
