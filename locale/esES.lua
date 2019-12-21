local CTM, C, L, _ = unpack(select(2, ...))
if CTM.locale ~= "esES" and CTM.locale ~= "esMX" then return end

-----------------------------
--	esES and esMX clients
-----------------------------
-- main frame
L.gui_threat		= "Amenaza"
