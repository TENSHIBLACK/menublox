-- ============================================
--   PAINEL MOBILE - FLY + TELEPORT
--   Compatível com Delta / Lua Game Scripts
-- ============================================

-- ╔══════════════════════════════════╗
-- ║         CONFIGURAÇÕES            ║
-- ╚══════════════════════════════════╝
local CONFIG = {
    flySpeed       = 10,       -- Velocidade de voo
    flyAltitude    = 50,       -- Altura padrão ao ativar voo
    hpLimite       = 30,       -- HP máximo do inimigo para teleportar (%)
    teclaFly       = "F",      -- Tecla para alternar voo (se teclado disponível)
    teclaTeleport  = "T",      -- Tecla para teleportar
}

-- ╔══════════════════════════════════╗
-- ║         ESTADO GLOBAL            ║
-- ╚══════════════════════════════════╝
local Estado = {
    flyAtivo       = false,
    painelAberto   = true,
    jogador        = nil,
    inimigos       = {},       -- tabela de inimigos no mapa
}

-- ╔══════════════════════════════════╗
-- ║         UTILITÁRIOS              ║
-- ╚══════════════════════════════════╝

-- Calcula distância entre dois pontos 3D
local function distancia(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = (a.z or 0) - (b.z or 0)
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

-- Log no console
local function log(msg)
    print("[PAINEL] " .. tostring(msg))
end

-- ╔══════════════════════════════════╗
-- ║         FUNÇÃO: VOAR             ║
-- ╚══════════════════════════════════╝
local function toggleFly()
    Estado.flyAtivo = not Estado.flyAtivo

    if Estado.flyAtivo then
        log("✈  Voo ATIVADO")

        -- Desativa gravidade do jogador
        if Estado.jogador then
            Estado.jogador.gravidade = false
            Estado.jogador.velocidadeY = CONFIG.flyAltitude
            Estado.jogador.colideSolo = false
        end

        -- Loop de voo (mantém altitude enquanto ativo)
        while Estado.flyAtivo do
            if Estado.jogador then
                -- Mantém o jogador no ar
                if Estado.jogador.y < CONFIG.flyAltitude then
                    Estado.jogador.y = Estado.jogador.y + CONFIG.flySpeed
                end
                Estado.jogador.velocidadeY = 0  -- cancela queda
            end
            coroutine.yield()  -- aguarda próximo frame
        end
    else
        log("🚫 Voo DESATIVADO")

        -- Restaura gravidade
        if Estado.jogador then
            Estado.jogador.gravidade = true
            Estado.jogador.colideSolo = true
        end
    end
end

-- Corrotina de voo (não bloqueia o jogo)
local flyCoroutine = coroutine.create(toggleFly)

local function ativarVoo()
    if coroutine.status(flyCoroutine) == "dead" then
        flyCoroutine = coroutine.create(toggleFly)
    end
    coroutine.resume(flyCoroutine)
end

-- ╔══════════════════════════════════╗
-- ║    FUNÇÃO: TELEPORTAR INIMIGO    ║
-- ╚══════════════════════════════════╝
local function teleportarParaInimigoFraco()
    if not Estado.jogador then
        log("⚠  Jogador não encontrado!")
        return
    end

    if #Estado.inimigos == 0 then
        log("⚠  Nenhum inimigo no mapa!")
        return
    end

    local alvo     = nil
    local menorHP  = math.huge
    local menorDist = math.huge

    -- Busca inimigo com HP mais baixo (abaixo do limite)
    for _, inimigo in ipairs(Estado.inimigos) do
        local hpPct = (inimigo.hp / inimigo.hpMax) * 100

        if hpPct <= CONFIG.hpLimite then
            local dist = distancia(Estado.jogador.pos, inimigo.pos)

            -- Prioridade: menor HP; em empate, mais perto
            if inimigo.hp < menorHP or
               (inimigo.hp == menorHP and dist < menorDist) then
                alvo      = inimigo
                menorHP   = inimigo.hp
                menorDist = dist
            end
        end
    end

    if alvo then
        -- Teleporta jogador para 2 unidades atrás do inimigo
        Estado.jogador.pos.x = alvo.pos.x - 2
        Estado.jogador.pos.y = alvo.pos.y
        Estado.jogador.pos.z = alvo.pos.z or 0

        log(string.format(
            "⚡ Teleportado para inimigo '%s' | HP: %d/%d (%.0f%%)",
            alvo.nome or "Desconhecido",
            alvo.hp, alvo.hpMax,
            (alvo.hp / alvo.hpMax) * 100
        ))
    else
        log(string.format(
            "❌ Nenhum inimigo com HP abaixo de %d%%",
            CONFIG.hpLimite
        ))
    end
end

-- ╔══════════════════════════════════╗
-- ║      PAINEL UI (MOBILE)          ║
-- ╚══════════════════════════════════╝

-- Renderiza painel (adapte para a API de UI do seu jogo/engine)
local function renderizarPainel()
    if not Estado.painelAberto then return end

    -- Cabeçalho
    UI.janela("⚙ PAINEL", 10, 10, 200, 160, function()

        -- Status do Voo
        local labelFly = Estado.flyAtivo and "✈ VOO: ON" or "🚫 VOO: OFF"
        local corFly   = Estado.flyAtivo and "verde" or "vermelho"

        UI.texto(labelFly, corFly)

        -- Botão Fly
        if UI.botao("▲ Alternar Voo") then
            ativarVoo()
        end

        UI.separador()

        -- Botão Teleport
        if UI.botao("⚡ Teleport → Inimigo Fraco") then
            teleportarParaInimigoFraco()
        end

        -- Info HP limite
        UI.texto(string.format("  HP limite: %d%%", CONFIG.hpLimite), "cinza")

        UI.separador()

        -- Fechar painel
        if UI.botao("✖ Fechar") then
            Estado.painelAberto = false
        end
    end)
end

-- ╔══════════════════════════════════╗
-- ║      ENTRADA POR TECLADO         ║
-- ╚══════════════════════════════════╝
local function verificarTeclas()
    if Input.pressionou(CONFIG.teclaFly) then
        ativarVoo()
    end

    if Input.pressionou(CONFIG.teclaTeleport) then
        teleportarParaInimigoFraco()
    end

    -- Reabrir painel com P
    if Input.pressionou("P") then
        Estado.painelAberto = not Estado.painelAberto
        log(Estado.painelAberto and "📱 Painel aberto" or "📱 Painel fechado")
    end
end

-- ╔══════════════════════════════════╗
-- ║      INICIALIZAÇÃO               ║
-- ╚══════════════════════════════════╝
local function iniciar()
    log("=== Script carregado com sucesso! ===")
    log("Tecla [" .. CONFIG.teclaFly     .. "] → Alternar Voo")
    log("Tecla [" .. CONFIG.teclaTeleport.. "] → Teleportar")
    log("Tecla [P] → Abrir/Fechar Painel")

    -- Referência ao jogador (adapte para sua API)
    Estado.jogador = Game.getJogador()

    -- Popula lista de inimigos (adapte para sua API)
    Estado.inimigos = Game.getInimigos()

    log(string.format("🎮 %d inimigo(s) detectado(s)", #Estado.inimigos))
end

-- ╔══════════════════════════════════╗
-- ║      LOOP PRINCIPAL              ║
-- ╚══════════════════════════════════╝

-- Registra callbacks no motor do jogo
Game.aoIniciar(iniciar)

Game.cadaFrame(function()
    verificarTeclas()
    renderizarPainel()

    -- Atualiza voo se ativo
    if Estado.flyAtivo and coroutine.status(flyCoroutine) == "suspended" then
        coroutine.resume(flyCoroutine)
    end
end)

-- ============================================
--  FIM DO SCRIPT
-- ============================================
