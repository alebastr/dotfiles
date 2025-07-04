-- Configuration specific for Neovim

-- Lua 5.1 and LuaJIT compat
table.unpack = table.unpack or unpack

Result = { ok = false, value = nil }

function Result:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Result:is_ok() return self.ok end

function Result:is_err() return not self.ok end

function Result:map(op)
    if self:is_ok() then
        self.value = op(self.value)
    end
    return self
end

function Result:unwrap_or_else(op)
    if self:is_ok() then
        return self.value
    else
        return op()
    end
end

local try_require = function(name)
    local status, value = pcall(require, name)
    return Result:new { ok = status, value = value }
end

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

local servers = {
    clangd = {},
    lua_ls = {},
    pylsp = {},
    rust_analyzer = {
        settings = {
            ['rust-analyzer'] = {
                cargo = {
                    loadOutDirsFromCheck = true
                },
                completion = {
                    postfix = { enable = false },
                },
                procMacro = {
                    enable = true
                },
            }
        }
    },
    ts_ls = {},
}

try_require("catppuccin"):map(function(x)
    x.setup {
        transparent_background = true,
        integrations = {
            treesitter = true,
            native_lsp = { enabled = true },
        },
    }
    return x
end)

try_require('clangd_extensions'):map(function(x)
    x.setup {
        inlay_hints = {
            max_len_align = true,
        },
    }
    return x
end)

try_require('cmp'):map(function(cmp)
    local compare = require('cmp.config.compare')
    local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

    local format_source_name = function(x)
        local names = {
            nvim_lsp = 'LSP',
        }
        return '[' .. (names[x] or x) .. ']'
    end

    cmp.setup({
        formatting = {
            expandable_indicator = false,
            fields = { 'abbr', 'kind', 'menu' },
            format = function(entry, item)
                item.menu = format_source_name(entry.source.name)
                return item
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<Tab>'] = cmp.mapping(function(fallback)
                cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                cmp_ultisnips_mappings.jump_backwards(fallback)
            end, { 'i', 's' }),
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
        }),
        snippet = {
            expand = function(args)
                vim.fn["UltiSnips#Anon"](args.body)
            end
        },
        sorting = {
            comparators = {
                compare.exact,
                compare.offset,
                compare.order,
                -- compare.scopes,
                compare.score,
                compare.recently_used,
                compare.locality,
                compare.kind,
                compare.sort_text,
                compare.length,
            },
        },
        sources = cmp.config.sources({
            {
                name = 'nvim_lsp',
                -- entry_filter = function(entry, _ctx)
                --     return cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
                -- end,
            },
            { name = 'path',      keyword_length = 4 },
            { name = 'ultisnips', max_item_count = 5 },
        }, {
            { name = 'buffer', keyword_length = 2, max_item_count = 5 }
        }),
        window = {
            -- completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
    })

    -- Use cmdline & path source for ':'
    cmp.setup.cmdline(':', {
        completion = { autocomplete = false },
        mapping = cmp.mapping.preset.cmdline(),
        matching = { disallow_symbol_nonprefix_matching = false },
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        }),
    })

    return cmp
end)

local lsp_caps = try_require('cmp_nvim_lsp'):map(function(x)
    return x.default_capabilities()
end):unwrap_or_else(function()
    local caps = vim.lsp.protocol.make_client_capabilities()
    caps.textDocument.completion.completionItem.snippetSupport = false
    caps.textDocument.completion.completionItem.resolveSupport = {
        properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
        }
    }
    return caps
end)

try_require('lspconfig'):map(function(lspconfig)
    for lsp, opt in pairs(servers) do
        lspconfig[lsp].setup {
            capabilities = lsp_caps,
            flags = { debounce_text_changes = 150, },
            table.unpack(opt)
        }
    end
    return lspconfig
end)

try_require("lspfuzzy"):map(function(x)
    x.setup {}
    return x
end)

try_require('nvim-treesitter.configs'):map(function(x)
    x.setup {
        ensure_installed = { 'c', 'cpp', 'just', 'markdown', 'typescript', 'tsx' },
        highlight = {
            enable = true,
        },
    }
    return x
end)
