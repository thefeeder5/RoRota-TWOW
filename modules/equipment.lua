-- Equipment swapping system for weapon/trinket swaps
-- Extracted and simplified from ItemRack by Gello
-- Handles queued swaps with lock management for rotation-based equipment changes

RoRota.Equipment = {}
local Equipment = RoRota.Equipment

-- Swap queue and state
Equipment.swapQueue = {} -- {slot, itemName, fromBag, fromSlot}
Equipment.isSwapping = false
Equipment.lockList = {} -- [bag][slot] = true for locked slots

-- Slot constants
local SLOT_MAINHAND = 16
local SLOT_OFFHAND = 17
local SLOT_TRINKET1 = 13
local SLOT_TRINKET2 = 14

-- Get item info from bag or inventory slot
-- Returns: texture, itemID, itemName, equipSlot
function Equipment:GetItemInfo(bag, slot)
    local itemLink, itemID, itemName, equipSlot, texture
    
    if slot then
        itemLink = GetContainerItemLink(bag, slot)
    else
        itemLink = GetInventoryItemLink("player", bag)
    end
    
    if itemLink then
        local _, _, id = string.find(itemLink, "(item:%d+:%d+:%d+:%d+)")
        if id then
            local _, _, cleanID = string.find(id, "item:(%d+:%d+:%d+):%d+")
            itemID = cleanID
            itemName, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(id)
        end
    end
    
    return texture, itemID, itemName, equipSlot
end

-- Check if bag is a normal container (not quiver/ammo pouch)
function Equipment:IsValidBag(bagID)
    if bagID == 0 then
        return true
    end
    
    local invID = ContainerIDToInventoryID(bagID)
    local _, _, linkID = string.find(GetInventoryItemLink("player", invID) or "", "item:(%d+)")
    
    if linkID then
        local _, _, _, _, _, bagType = GetItemInfo(linkID)
        return bagType == "Container" or bagType == "Bag"
    end
    
    return false
end

-- Find item in bags or inventory by item link
-- Returns: invSlot, bag, slot
function Equipment:FindItem(itemLink)
    if not itemLink then return nil end
    
    -- Check bags first
    for bag = 0, 4 do
        if not self.lockList[bag] then
            self.lockList[bag] = {}
        end
        
        for slot = 1, GetContainerNumSlots(bag) do
            if not self.lockList[bag][slot] then
                local bagLink = GetContainerItemLink(bag, slot)
                if bagLink == itemLink then
                    return nil, bag, slot
                end
            end
        end
    end
    
    -- Check inventory slots
    for invSlot = 0, 19 do
        local invLink = GetInventoryItemLink("player", invSlot)
        if invLink == itemLink then
            return invSlot, nil, nil
        end
    end
    
    return nil
end

-- Find free bag space
-- Returns: bag, slot
function Equipment:FindSpace()
    for bag = 4, 0, -1 do
        if self:IsValidBag(bag) then
            for slot = 1, GetContainerNumSlots(bag) do
                if not self.lockList[bag][slot] and not GetContainerItemLink(bag, slot) then
                    self.lockList[bag][slot] = true
                    return bag, slot
                end
            end
        end
    end
    return nil
end

-- Clear lock list
function Equipment:ClearLocks()
    for bag = 0, 4 do
        if not self.lockList[bag] then
            self.lockList[bag] = {}
        end
        for slot in pairs(self.lockList[bag]) do
            self.lockList[bag][slot] = nil
        end
    end
end

-- Queue a single item swap
function Equipment:QueueSwap(slot, itemLink)
    if not itemLink then return end
    
    -- Check if already wearing this item
    local currentLink = GetInventoryItemLink("player", slot)
    if currentLink == itemLink then
        return
    end
    
    -- Find the item
    local invSlot, bag, bagSlot = self:FindItem(itemLink)
    
    if not invSlot and not bag then
        local itemName = self:GetItemNameFromLink(itemLink)
        RoRota:Print("Equipment: Could not find " .. (itemName or "item"))
        return
    end
    
    -- Add to queue
    table.insert(self.swapQueue, {
        slot = slot,
        itemLink = itemLink,
        fromInv = invSlot,
        fromBag = bag,
        fromSlot = bagSlot
    })
end

-- Extract item name from item link
function Equipment:GetItemNameFromLink(itemLink)
    if not itemLink then return nil end
    local name = string.match(itemLink, "%[(.+)%]")
    return name
end

-- Swap to an equipment set
function Equipment:SwapToSet(setName)
    if not setName or setName == "" then return end
    
    local profile = RoRota.db.profile
    local set = profile.equipmentSets and profile.equipmentSets[setName]
    
    if not set then
        return
    end
    
    self:ClearLocks()
    
    -- Queue all swaps (up to 4 items: 2 weapons + 2 trinkets)
    -- Use full item links for exact matching
    if set.mainHand then
        self:QueueSwap(SLOT_MAINHAND, set.mainHand)
    end
    if set.offHand then
        self:QueueSwap(SLOT_OFFHAND, set.offHand)
    end
    if set.trinket1 then
        self:QueueSwap(SLOT_TRINKET1, set.trinket1)
    end
    if set.trinket2 then
        self:QueueSwap(SLOT_TRINKET2, set.trinket2)
    end
    
    -- Start processing queue
    self:ProcessQueue()
end

-- Process the swap queue
function Equipment:ProcessQueue()
    if table.getn(self.swapQueue) == 0 then
        self.isSwapping = false
        return
    end
    
    if self.isSwapping then
        return
    end
    
    if SpellIsTargeting() or CursorHasItem() then
        return
    end
    
    self.isSwapping = true
    
    local swap = self.swapQueue[1]
    
    -- Handle inventory to inventory swap
    if swap.fromInv then
        PickupInventoryItem(swap.fromInv)
        PickupInventoryItem(swap.slot)
    -- Handle bag to inventory swap
    elseif swap.fromBag then
        -- Check if slot needs emptying first
        local currentItem = GetInventoryItemLink("player", swap.slot)
        if currentItem then
            local freeBag, freeSlot = self:FindSpace()
            if freeBag then
                PickupInventoryItem(swap.slot)
                PickupContainerItem(freeBag, freeSlot)
            else
                RoRota:Print("Equipment: No bag space for swap")
                table.remove(self.swapQueue, 1)
                self.isSwapping = false
                return
            end
        else
            PickupContainerItem(swap.fromBag, swap.fromSlot)
            PickupInventoryItem(swap.slot)
        end
    end
end

-- Check if any items are locked
function Equipment:AnyLocked()
    for i = 0, 19 do
        if IsInventoryItemLocked(i) then
            return true
        end
    end
    
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, _, locked = GetContainerItemInfo(bag, slot)
            if locked then
                return true
            end
        end
    end
    
    return false
end

-- Handle item lock changes
function Equipment:OnItemLockChanged()
    if not self.isSwapping then
        return
    end
    
    if not self:AnyLocked() then
        -- Swap completed, remove from queue
        table.remove(self.swapQueue, 1)
        self.isSwapping = false
        
        -- Process next swap
        self:ProcessQueue()
    end
end

-- Initialize equipment sets in profile
function Equipment:InitializeProfile(profile)
    if not profile.equipmentSets then
        profile.equipmentSets = {}
    end
end
