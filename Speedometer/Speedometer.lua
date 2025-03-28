do
  local ADDON_NAME = ...
  
  local playMusic = 0

  local f=CreateFrame("frame")
  f:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
  local t=f:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
  t:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 1)
  t:SetShadowOffset(1, -1)
  t:SetTextColor(1, 1, 1, 1)
  t:SetJustifyH("LEFT")
  t:SetJustifyV("BOTTOM")
  
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  f:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
  function f:COMBAT_LOG_EVENT_UNFILTERED(...)
    local _, subEvent = ...
    if subEvent=="SPELL_AURA_APPLIED" then
      local _, _, _, _, _, dstGuid, _, _, spellid, spellname = ...
      if (spellid==30452 or spellid==51582) and dstGuid==UnitGUID("player") and playMusic < GetTime() then
        playMusic = GetTime()+6
        PlaySoundFile("interface\\addons\\"..ADDON_NAME.."\\barri-allen.wav")
      elseif spellid==54861 and dstGuid==UnitGUID("player") and playMusic < GetTime() then
        if math.random(1,2)==1 then
          PlaySoundFile("interface\\addons\\"..ADDON_NAME.."\\barri-allen.wav")
          playMusic = GetTime()+6
        else
          PlaySoundFile("interface\\addons\\"..ADDON_NAME.."\\invincibility.wav")
          playMusic = GetTime()+12
        end
      end
    end
  end

  local gradientColor = { 0, 1, 0, 1, 1, 0, 1, 0, 0 }

  local function ColorGradient(perc, ...)
    if (perc > 1) then
      local r, g, b = select(select("#", ...) - 2, ...)
      return r, g, b
    elseif (perc < 0) then
      local r, g, b = ...
      return r, g, b
    end

    local num = select("#", ...) / 3

    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

    if r2 == nil then r2 = 1 end
    if g2 == nil then g2 = 1 end
    if b2 == nil then b2 = 1 end

    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
  end

  local function RGBGradient(num)
    local r, g, b = ColorGradient(num, unpack(gradientColor))

    local hexColor = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)

    return hexColor
  end

  local _t=0
  f:SetScript("OnUpdate",function(_,elapsed)
    _t=_t+elapsed
    if _t<0.01 then return end
    _t=0
    local speed = GetUnitSpeed("player") / 7 *100
    local speedColor = RGBGradient(1 - tonumber(speed) / 250)
    if speed == 0 then speedColor = "aaaaaa" end
    local speedStr = "Скорость бега: |cff"..speedColor.."" .. string.format("%d", speed) .. "%|r"
    if speed >= 250 then speedStr = speedStr.. " |cffff0000(БАРРИ АЛЛЕН)|r" end
    
    -- if playMusic < GetTime() and speed>=200 and not IsMounted() and not IsFalling() and not UnitOnTaxi("player") then
      -- PlaySoundFile("interface\\addons\\"..ADDON_NAME.."\\invincibility.wav")
      -- playMusic = GetTime()+12
    -- end
    
    local res = GetCombatRating(16)
    local resColor = RGBGradient(1 - tonumber(res) / 1414)
    local resStr = "Устойчивость: |cff"..resColor..""..string.format("%d", res).."|r"
    
    local latency = select(3, GetNetStats())
    local latencyColor = RGBGradient(latency / 150)
    local latencyStr = "Lag: |cff"..latencyColor..""..latency.."|r"
    
    local fps = string.format("%d", GetFramerate())
    local fpsColor = RGBGradient(1 - tonumber(fps) / 60)
    local fpsStr = "Fps: |cff"..fpsColor..""..fps.."|r"
    
    local text = ""..latencyStr.."\n"..fpsStr.."\n"..resStr.."\n"..speedStr..""
    
    t:SetText(text)
  end)
end