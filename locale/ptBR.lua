local CTM2, C, L, _ = unpack(select(2, ...))
if CTM2.locale ~= "ptBR" and CTM2.locale ~= "ptPT" then return end

-----------------------------
--	ptBR and ptPT clients
-----------------------------
-- main frame
L.gui_threat		= "Ameaça"
