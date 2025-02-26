--------------------------------------------------------------------
-- Economics Popup
--------------------------------------------------------------------
local m_Data = {}
--------------------------------------------------------------------
function UpdateDisplay()
	local bTitle = (m_Data.Title~=nil)
	local bText = (m_Data.Text~=nil)
	if bTitle then
		Controls.Title:SetText(m_Data.Title)
	end
	if bText then
		Controls.Text:SetText(m_Data.Text)
	end

	Controls.Title:SetHide(not bTitle)
	Controls.Text:SetHide(not bText)
end
--------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )      
    if(uiMsg == KeyEvents.KeyDown) then
        if (wParam == Keys.VK_ESCAPE) then
			OnClose()
			return true
        end
    end
end
ContextPtr:SetInputHandler( InputHandler )
--------------------------------------------------------------------
function OnClose()
	ContextPtr:SetHide(true)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)
--------------------------------------------------------------------
function ShowHideHandler(bIsHide, bInitState)
	if (not bInitState and not bIsHide) then
		UpdateDisplay()
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)
--------------------------------------------------------------------
function OnEconPopup(data)
	m_Data = data or {}
	ContextPtr:SetHide(false)
end
LuaEvents.FA_Economics_EconPopup.Add( OnEconPopup )
--------------------------------------------------------------------
