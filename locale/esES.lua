local CTM2, C, L, _ = unpack(select(2, ...))
if CTM2.locale ~= "esES" and CTM2.locale ~= "esMX" then return end

-----------------------------
--	esES and esMX clients
-----------------------------
-- main frame
L.gui_threat		= "Amenaza"
