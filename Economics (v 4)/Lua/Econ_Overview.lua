function RefreshOurEconomy()
    -- Ensure there is at least two snapshots in the economic archive
    if not g_Economy or #g_Economy < 2 then
        return
    end

    local current = g_Economy[1]
    local previous = g_Economy[2]

    -- Populate Year row
    if Controls.YearData1 then
        Controls.YearData1:SetText( date(current.iYear) )
    end
    if Controls.YearData2 then
        Controls.YearData2:SetText( date(previous.iYear) )
    end

    -- Populate Growth row
    if Controls.GrowthData1 then
        Controls.GrowthData1:SetText( percent(current.fGDP_Growth, 1) )
    end
    if Controls.GrowthData2 then
        Controls.GrowthData2:SetText( percent(previous.fGDP_Growth, 1) )
    end

    -- Populate Total GDP row
    if Controls.GDPData1 then
        Controls.GDPData1:SetText( comma(current.iGDP_Total) )
    end
    if Controls.GDPData2 then
        Controls.GDPData2:SetText( comma(previous.iGDP_Total) )
    end

    -- Populate Consumer GDP row
    if Controls.ConsumerGDPData1 then
        Controls.ConsumerGDPData1:SetText( comma(current.iGDP_Consumer) )
    end
    if Controls.ConsumerGDPData2 then
        Controls.ConsumerGDPData2:SetText( comma(previous.iGDP_Consumer) )
    end

    -- Populate Government GDP row
    if Controls.GovGDPData1 then
        Controls.GovGDPData1:SetText( comma(current.iGDP_Government) )
    end
    if Controls.GovGDPData2 then
        Controls.GovGDPData2:SetText( comma(previous.iGDP_Government) )
    end

    -- Populate Investment GDP row
    if Controls.InvestmentGDPData1 then
        Controls.InvestmentGDPData1:SetText( comma(current.iGDP_Investment) )
    end
    if Controls.InvestmentGDPData2 then
        Controls.InvestmentGDPData2:SetText( comma(previous.iGDP_Investment) )
    end

    -- Populate Trade GDP row
    if Controls.TradeGDPData1 then
        Controls.TradeGDPData1:SetText( comma(current.iGDP_Trade) )
    end
    if Controls.TradeGDPData2 then
        Controls.TradeGDPData2:SetText( comma(previous.iGDP_Trade) )
    end

    -- Populate Unemployment row
    if Controls.UnemploymentData1 then
        Controls.UnemploymentData1:SetText( percent(current.fUnemploymentRate, 1) )
    end
    if Controls.UnemploymentData2 then
        Controls.UnemploymentData2:SetText( percent(previous.fUnemploymentRate, 1) )
    end

    -- Populate Policy row
    if Controls.PolicyData1 then
        Controls.PolicyData1:SetText( GetPolicyString(current.iPolicyID) )
    end
    if Controls.PolicyData2 then
        Controls.PolicyData2:SetText( GetPolicyString(previous.iPolicyID) )
    end
end
