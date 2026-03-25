-- Mod này để luôn set vũ khí đang chơi sẽ là vũ khí active lượt tới
function GetRandomUnequippedWeapon( prevRun )
    local candidateWeapons = {}
    
    -- 1. Kiểm tra an toàn: Nếu chưa có lượt chơi trước, chọn đại một vũ khí chính
    if prevRun == nil or prevRun.WeaponsCache == nil then
        return GetRandomValue( WeaponSets.HeroPrimaryWeapons )
    end

    -- 2. Duyệt qua danh sách vũ khí chính để tìm vũ khí đã dùng lần trước
    for k, weaponName in ipairs( WeaponSets.HeroPrimaryWeapons ) do
        -- Kiểm tra xem tên vũ khí này có trong Cache của lần chơi trước không
        if prevRun.WeaponsCache[weaponName] then
            -- Kiểm tra xem vũ khí này có hợp lệ để nhận Bonus không
            if IsWeaponEligible( CurrentRun, WeaponData[weaponName] ) then
                table.insert(candidateWeapons, weaponName)
            end
        end
    end

    -- 3. Trả về kết quả
    if not IsEmpty(candidateWeapons) then
        -- Trả về vũ khí đã chơi (nếu có nhiều hơn 1, ví dụ do lỗi cache, sẽ chọn ngẫu nhiên)
        return GetRandomValue(candidateWeapons)
    else
        -- Fallback: Nếu không tìm thấy vũ khí cũ trong Cache, chọn ngẫu nhiên để tránh lỗi game
        return GetRandomValue( WeaponSets.HeroPrimaryWeapons )
    end
end

function RecordRunStats()
    CurrentRun.RunResult = GetRunResult( CurrentRun )
    CurrentRun.EndingRoomName = CurrentRun.CurrentRoom.Name
    CurrentRun.WeaponsCache = DeepCopyTable( CurrentRun.Hero.Weapons )
    
    CurrentRun.TraitRarityCache = CurrentRun.TraitRarityCache or {}
    for k, traitData in ipairs( CurrentRun.Hero.Traits ) do
        if not traitData.RecordCacheOnEquip then
            CurrentRun.TraitCache[traitData.Name] = (CurrentRun.TraitCache[traitData.Name] or 0) + 1
        end
        CurrentRun.TraitRarityCache[traitData.Name] = traitData.Rarity or "Common"
    end
    CurrentRun.ShrinePointsCache = GetTotalSpentShrinePoints()
    CurrentRun.ShrineUpgradesCache = DeepCopyTable( GameState.ShrineUpgrades ) 
    CurrentRun.MetaUpgradeCostCache = GameState.MetaUpgradeCostCache
    if GameState.HighestRunDepthCache < CurrentRun.RunDepthCache then
        GameState.HighestRunDepthCache = CurrentRun.RunDepthCache
    end

    -- send progression events before updating 'cleared' counts
    local roomNames = {}
    for k, room in ipairs( CurrentRun.RoomHistory ) do
        table.insert( roomNames, room.Name )
    end
    table.insert( roomNames, CurrentRun.CurrentRoom.Name )
    SendProgressionEvents({ Names = roomNames, CompletedRuns = GameState.CompletedRunsCache, ClearedUnderworldRuns = GameState.ClearedUnderworldRunsCache, ClearedSurfaceRuns = GameState.ClearedSurfaceRunsCache, Cleared = CurrentRun.Cleared, GameplayTime = GameState.GameplayTime, TotalTime = GameState.TotalTime })

    -- 'cleared' means achieved a victory condition as opposed to dying 
    local runsCleared = 0
    local underworldRunsCleared = 0
    local surfaceRunsCleared = 0
    if CurrentRun.Cleared then
        runsCleared = runsCleared + 1
        if WasUnderworldRun( CurrentRun ) then
            underworldRunsCleared = underworldRunsCleared + 1
            if GameState.HighestShrinePointClearUnderworldCache < CurrentRun.ShrinePointsCache then
                GameState.HighestShrinePointClearUnderworldCache = CurrentRun.ShrinePointsCache
            end
            if GameState.FastestUnderworldClearTimeCache > CurrentRun.GameplayTime then
                GameState.FastestUnderworldClearTimeCache = CurrentRun.GameplayTime
            end
        else
            surfaceRunsCleared = surfaceRunsCleared + 1
            if GameState.HighestShrinePointClearSurfaceCache < CurrentRun.ShrinePointsCache then
                GameState.HighestShrinePointClearSurfaceCache = CurrentRun.ShrinePointsCache
            end
            if GameState.FastestSurfaceClearTimeCache > CurrentRun.GameplayTime then
                GameState.FastestSurfaceClearTimeCache = CurrentRun.GameplayTime
            end
        end
    end
    for k, run in ipairs( GameState.RunHistory ) do
        if run.RunResult == RunResultData.UnderworldSuccess then
            runsCleared = runsCleared + 1
            underworldRunsCleared = underworldRunsCleared + 1
        elseif run.RunResult == RunResultData.SurfaceSuccess then
            runsCleared = runsCleared + 1
            surfaceRunsCleared = surfaceRunsCleared + 1
        end
    end
    GameState.ClearedRunsCache = runsCleared
    GameState.ClearedUnderworldRunsCache = underworldRunsCleared
    GameState.ClearedSurfaceRunsCache = surfaceRunsCleared

    UpdateLifetimeTraitRecords( CurrentRun )

    for bossName, healthFraction in pairs( CurrentRun.BossHealthBarRecord ) do
        GameState.LastBossHealthBarRecord[bossName] = healthFraction
    end

    for bossName, bossData in pairs( BossDifficultyShrineEncounterMap ) do
        if CurrentRun.EncountersOccurredCache[bossData.Encounter] then
            GameState.LastBossDifficultyRecord[bossName] = false
        elseif CurrentRun.EncountersOccurredCache[bossData.AltEncounter] then
            GameState.LastBossDifficultyRecord[bossName] = true
        end
    end

    -- Trong hàm RecordRunStats
    CurrentRun.WeaponsCache = DeepCopyTable( CurrentRun.Hero.Weapons )
    -- Ép game nhận diện vũ khí này là Unused cho lượt sau ngay lập tức
    for weaponName, v in pairs(CurrentRun.WeaponsCache) do
        if IsWeaponEligible(CurrentRun, WeaponData[weaponName]) then
            CurrentRun.BonusUnusedWeaponName = weaponName
            break
        end
    end
end
