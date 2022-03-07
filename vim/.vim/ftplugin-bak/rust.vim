let b:ale_linters = ['analyzer']
let b:ale_fixers = ['rustfmt']
let b:ale_rust_analyzer_config = {
      \ 'diagnostics': { 'disabled': ['unresolved-import'] },
      \ 'cargo': { 'loadOutDirsFromCheck': v:true },
      \ 'procMacro': { 'enable': v:true },
      \ 'checkOnSave': { 'command': 'clippy', 'enable': v:true }
      \ }
