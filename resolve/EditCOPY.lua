-- EditCOPY Launcher para DaVinci Resolve
-- Este script deve ser colocado em: %AppData%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp\EditCOPY.lua

local PORT = 56002

-- Simulação de carregamento de módulos (em prod usar caminhos reais)
print("[EditCOPY] Iniciando Integração...")

-- Tentar carregar o core
local status, core = pcall(require, "modules.editcopy_core")
if not status then
    print("[EditCOPY] Erro ao carregar modules.editcopy_core: " .. tostring(core))
    -- Em ambiente real, adicionar o caminho ao package.path aqui
end

-- Lógica básica de servidor HTTP seria implementada aqui usando luasocket
-- Para o MVP, este arquivo é o ponto de entrada que o usuário clica no Resolve.

print("[EditCOPY] Servidor pronto na porta " .. PORT)
