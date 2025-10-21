--[[ compatibility fixes ]]--
-- Fixes for compatibility issues with other addons

function RoRota:ApplyCompatibilityFixes()
    -- tooltip fix: prevent nil owner crashes from other addons
    if GameTooltip and type(GameTooltip.SetOwner) == "function" then
        if hooksecurefunc then
            hooksecurefunc(GameTooltip, "SetOwner", function(self, owner, anchor)
                if not owner then
                    pcall(function() GameTooltip:Hide() end)
                end
            end)
        else
            local origSetOwner = GameTooltip.SetOwner
            GameTooltip.SetOwner = function(self, owner, anchor)
                if not owner then
                    pcall(function() GameTooltip:Hide() end)
                    return
                end
                return origSetOwner(self, owner, anchor)
            end
        end
    end
end
