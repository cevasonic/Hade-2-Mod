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

    -- 2. KIỂM TRA NẾU LÀ TRẬN ĐÁNH BOSS (Typhon hoặc Chronos)
    -- Chúng ta kiểm tra EncounterType hoặc tên cụ thể của Boss [2], [3]
    local encounter = currentRun.CurrentRoom.Encounter
    if encounter ~= nil then
        if encounter.Name == "Chronos" or encounter.Name == "Typhon" then
            return
        end
    end

    -- 3. Tạo lượng vàng ngẫu nhiên từ 10 đến 100 [6-8]
    -- Hàm RandomInt được sử dụng rộng rãi trong các logic ngẫu nhiên [6, 9]
    local depth = currentRun.RunDepthCache or 1
    local goldAmount = RandomInt(10, depth*10)

    -- 4. Cấp vàng và tạo hiệu ứng bay vào túi trên HUD [10]
    -- Sử dụng hàm AddResource với các tham số UI để icon vàng bay về góc màn hình [10]
    AddResource( "Money", goldAmount, "DoorExitReward", {
        StartId = HUDScreen.Components.InventoryIcon.Id, -- Điểm neo trên HUD [10, 11]
        OffsetX = -120,
        AnchorOffsetY = -50,
        FontSize = 32,
        IgnoreAsLastResourceGained = true -- [10]
    })

    -- 5. Hiển thị văn bản thông báo trực tiếp trên đầu nhân vật [12, 13]
    -- PopOverheadText giúp người chơi thấy ngay số vàng nhận được [13]
    PopOverheadText({
        TargetId = currentRun.Hero.ObjectId, -- ID của nhân vật chính [14]
        Text = "+" .. goldAmount .. " Gold",
        Color = Color.Gold,
        Duration = 1.0
    })

    -- 6. Cập nhật con số hiển thị trên thanh tiền tệ HUD [15]
    -- Hàm UpdateMoneyUI sẽ kích hoạt hoạt ảnh nhảy số tiền [15]
    UpdateMoneyUI() 
end