local CTM, C, L, _ = unpack(select(2, ...))
if CTM.locale ~= "ptBR" and CTM.locale ~= "ptPT" then return end

-----------------------------
--	ptBR and ptPT clients
-----------------------------
-- main frame
L.gui_threat		= "Ameaça"
