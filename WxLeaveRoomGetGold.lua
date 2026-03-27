function GrantRandomGoldOnRoomExit(currentRun, door)
    
    
    -- 1. Kiểm tra điều kiện cơ bản để đảm bảo lượt chơi đang diễn ra [2, 3]
    if currentRun == nil or currentRun.Hero == nil then
        return
    end

    -- 2. Kiểm tra nếu người chơi có các kỹ năng (Traits) chặn nhận vàng [4, 5]
    -- Sử dụng HasHeroTraitValue để kiểm tra thuộc tính "BlockMoney" [5]
    if HasHeroTraitValue("BlockMoney") then
        return
    end

    -- 3. Tạo lượng vàng ngẫu nhiên từ 10 đến 100 [6-8]
    -- Hàm RandomInt được sử dụng rộng rãi trong các logic ngẫu nhiên [6, 9]
    local depth = currentRun.RunDepthCache or 1
    local goldAmount = RandomInt(5, math.min(30, depth * 5))

    -- 4. Cấp vàng và tạo hiệu ứng bay vào túi trên HUD [10]
    -- Sử dụng hàm AddResource với các tham số UI để icon vàng bay về góc màn hình [10]
    AddResource( "Money", goldAmount, "RoomExitBonus", {
        StartId = CurrentRun.Hero.ObjectId
    })

    -- 5. Hiển thị văn bản thông báo trực tiếp trên đầu nhân vật [12, 13]
    -- 2. Dùng thread để đảm bảo Text hiện lên không làm gián đoạn logic chuyển cảnh
    -- thread( InCombatText, CurrentRun.Hero.ObjectId,"+" .. goldAmount .. " Gold", 2, { ShadowScaleX = 1.5 } )

    -- thread( PopOverheadText, {
    --     TargetId = CurrentRun.Hero.ObjectId,
    --     Amount = goldAmount,
    --     Text = "{#UseMoneyFormat}+{$TempTextData.Amount}{!Icons.Currency}",         -- Sử dụng mã văn bản đã được định cấu hình có icon [1]
    --     Duration = 2.0,               -- Thời gian hiển thị
    -- })
    -- UpdateMoneyUI( true )
    local nextMoney =  GetResourceAmount( "Money" ) or 0 + goldAmount
    MoneyGainPresentation(nextMoney,goldAmount)
    

end