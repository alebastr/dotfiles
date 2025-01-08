-- Configuration specific for Neovim

-- Lua 5.1 and LuaJIT compat
table.unpack = table.unpack or unpack

Result = { ok = false, value = nil }

function Result:new (o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Result:is_ok () return self.ok end
function Result:is_err () return not self.ok end

function Result:map (op)
    if self.ok then
        self.value = op(self.value)
    end
    return self
end

function Result:or_else (op)
    if self:is_err() then
        op()
    end
    return self
end

function try_require(name)
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

local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.completion.completionItem.snippetSupport = true
caps.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

local servers = {
    clangd = {},
    pylsp = {},
    rust_analyzer = {
        capabilities = caps,
        settings = {
            ['rust-analyzer'] = {
                cargo = {
                    loadOutDirsFromCheck = true
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

try_require('clangd_extensions'):map(function (x)
    x.setup {
        inlay_hints = {
            max_len_align = true,
        },
    }
    return x
end)

try_require('lspconfig'):map(function (lspconfig)
    for lsp, opt in pairs(servers) do
        lspconfig[lsp].setup {
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
        ensure_installed = { 'c', 'cpp',  'just', 'markdown', 'typescript', 'tsx' },
        highlight = {
            enable = true,
        },
    }
    return x
end)
