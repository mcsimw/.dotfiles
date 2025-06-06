return {
	{
		"nvim-treesitter",
		after = function()
			require("nvim-treesitter.configs").setup({
				sync_install = false,
				auto_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
			})
		end,
	},
}
