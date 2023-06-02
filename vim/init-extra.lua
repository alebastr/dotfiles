-- Configuration specific for Neovim

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

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

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
    tsserver = {},
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
        server = {
            on_attach = on_attach,
            flags = { debounce_text_changes = 150, },
        },
        extensions = {
            inlay_hints = {
                max_len_align = true,
            },
        },
    }
    return x
end):or_else(function (_)
    servers['clangd'] = {}
end)

try_require('lspconfig'):map(function (lspconfig)
    for lsp, opt in pairs(servers) do
        lspconfig[lsp].setup {
            on_attach = on_attach,
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
        ensure_installed = { 'c', 'cpp',  'markdown', 'typescript', 'tsx' },
        highlight = {
            enable = true,
        },
    }
    return x
end)
