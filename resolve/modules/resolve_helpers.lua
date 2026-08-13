-- Implementação da lógica de inserção na timeline
local EditCopy = require("modules.editcopy_core")

local handlers = {}

-- Sobrescrever ou adicionar handlers específicos de timeline em editcopy_core.lua
-- ou integrar diretamente no arquivo original.

function handlers.ImportImages(data)
    local resolve = Resolve()
    local projectManager = resolve:GetProjectManager()
    local project = projectManager:GetCurrentProject()
    local mediaPool = project:GetMediaPool()
    local rootFolder = mediaPool:GetRootFolder()
    
    local items = mediaPool:ImportMedia(data.paths)
    return { items = items }
end

function handlers.ApplyImages(data)
    local resolve = Resolve()
    local projectManager = resolve:GetProjectManager()
    local project = projectManager:GetCurrentProject()
    local mediaPool = project:GetMediaPool()
    local timeline = project:GetCurrentTimeline()
    
    if not timeline then return { error = "Timeline não encontrada" } end
    
    -- Importar
    local items = mediaPool:ImportMedia(data.paths)
    if not items or #items == 0 then return { error = "Falha ao importar mídias" } end
    
    local frameRate = timeline:GetSetting("timelineFrameRate")
    local durationInFrames = math.floor(data.duration * frameRate)
    
    -- Inserir na track
    -- A API real do Resolve usa AppendToTimeline ou similar
    -- Para o MVP, iteramos e inserimos
    for i, item in ipairs(items) do
        mediaPool:AppendToTimeline(item)
        -- Ajustar duração e posição conforme necessário usando as APIs de TimelineItem
    end
    
    return { ok = true }
end

return handlers
