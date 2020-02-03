_author = "Alexey Bogomolov <mail@abogomolov.com>"
_date = "2020-01-29"
_VERSION = "0.1"


if fusion == nil then
	print("[Fusion] Error: Please open up the Fusion GUI before running this tool.\n")
else
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)
end

local mainWindow = fu:GetPrefs("Global.Main.Window")
if not mainWindow or mainWindow.Width == -1 then
	if app:GetVersion().App == 'Fusion' then
		print("[Warning] The Window dimensions are undefined. Please press 'Grab probram layout' button in the Layout Preferences section.")
		mainWindow.Height = 1900
		mainWindow.Width = 1100
	else
		print('this app will work in Fusion Standalone only')
		disp.ExitLoop()
	end
end

local minWidth, minHeight = 265, 75
local originX, originY = mainWindow.Left + (mainWindow.Width/2) - (minWidth/2), mainWindow.Top + ((mainWindow.Height/2) - (minHeight/2)-100)

print(string.format("[Layouter] - v%s %s ", _VERSION, _date))
print(string.format("[Created By] %s\n\n", _author))


function get_cf()
	comp = fu:GetCurrentComp()
	local cf = comp.CurrentFrame
	return cf
end

layouterWin = ui:FindWindow("LT")
if layouterWin then
    layouterWin:Raise()
    layouterWin:ActivateWindow()
    return
end


win = disp:AddWindow({
    ID = 'LT',
    TargetID = 'Layouter',
    Geometry = {originX, originY, minWidth, minHeight},
    WindowTitle = 'Layouter',
    Events = {Close = true, KeyPress = true, KeyRelease = true, },
    ui:VGroup{
        ui:HGroup{
            ui:Button{ID = "LL", Text = "Load Layout",Weight = .3, MinimumSize = {5,10},},
            ui:Button{ID = "reset", Text = "RESET", Weight = .2, MinimumSize = {5,10},},
            ui:Button{ID = "SL", Text = "Save Layout", Weight = .3, MinimumSize = {5,10},},
        },
    ui:HGroup{
        ui:Button{ID = "LClose", Text = "Close", Weight = .9},
        ui:Button{ID = "Info", Text = 'i', Weight = .1, MinimumSize={3,12}, Flat = false}
        }
    },
})
itm = win:GetItems()

function AboutWindow()
	local URL = 'https://abogomolov.com'

	local width, height = 500, 250
	aboutWin = disp:AddWindow({
		ID = "AboutWin",
		WindowTitle = 'About Dialog',
		WindowFlags = {Window = true, WindowStaysOnTopHint = true,},
		Geometry = {200, 200, width, height},

		ui:VGroup{
			ID = 'root',

			-- Add your GUI elements here:
			ui:TextEdit{ID = 'AboutText', ReadOnly = true, Alignment = {AlignHCenter = true, AlignTop = true}, HTML = '<h1>Layouter</h1>\n<p>Version 0.1 - January 31, 2020</p>\n<p>Use this script to quickly switch between layouts in Fusion 16. This is undocumented feature. Most reliably works on MacOS. Sorry for that :)</p> <p>Make sure you are using correct layout presets (installed separately)<p>\n<p>Copyright &copy; 2020 Alexey Bogomolov (MIT License)</p>',},

			ui:VGroup{
				Weight = 0,

                ui:Label{
					ID = "EMAIL",
					Text = 'Email: <a href="' .. 'mailto:mail@abogomolov.com' .. '">' .. 'mail@abogomolov.com' .. '</a>',
					Alignment = {
						AlignHCenter = true,
						AlignTop = true,
					},
					WordWrap = true,
					OpenExternalLinks = true,
				},
                ui:Label{
					ID = "Donate",
					Text = 'Donate: <a href="' .. 'https://paypal.me/aabogomolov/5usd' .. '">' .. 'https://paypal.me/aabogomolov/' .. '</a>',
					Alignment = {
						AlignHCenter = true,
						AlignTop = true,
					},
					WordWrap = true,
					OpenExternalLinks = true,
				},

			},
		},
	})
	itm = aboutWin:GetItems()

	-- The window was closed
	function aboutWin.On.AboutWin.Close(ev)
		disp:ExitLoop()
        win:Show()
	end

	aboutWin:Show()
	disp:RunLoop()
	aboutWin:Hide()

	return aboutWin,aboutWin:GetItems()
end


function win.On.Info.Clicked(ev)
    win:Hide()
    AboutWindow()
end

function win.On.LT.Close(ev)
    disp:ExitLoop()
end

-- A flag to track shift state
local shiftdown = false

function win.On.LClose.Clicked(ev)
    disp:ExitLoop()
end

function win.On.LT.KeyPress(ev)
	if ev.Key == 16777248 then
		shiftdown = true
		itm.LL.Text = "Wow!"
		itm.SL.Text = "Such Script!"
		itm.LClose.Text = "Many Useful!"
		itm.reset.Text = "Wow!"
	end
end

function win.On.LT.KeyRelease(ev)
	if ev.Key == 16777248 then
		shiftdown = false
		itm.LL.Text = "Load Layout"
		itm.SL.Text = "Save layout"
		itm.LClose.Text = "Close"
		itm.reset.Text = "reset"

	end
end


function win.On.SL.Clicked(ev)
	if shiftdown then
		print("don't push that shift button!")
	else
		print("Save current layout")
		get_cf():SaveLayout()
	end
end

-- Now we can use our flag to differentiate button presses
function win.On.LL.Clicked(ev)
	if shiftdown then
		print("don't push that shift button!")
	else
		print("Load existing layout")
        fu:SetData("Layouter.Set", true)
		get_cf():LoadLayout()
	end
end

function win.On.reset.Clicked(ev)
	if shiftdown then
		print("don't push that shift button!")
	else
		print("resetting to default layout")
		get_cf():ResetLayout()
        comp:DoAction("Fusion_View_Show", {view = "Nodes", show = false})
        comp:DoAction("Fusion_View_Show", {view = "Nodes", show = true})
		-- comp:DoAction("Fusion_View_Show", {view = "Time", show = true})
		-- comp:DoAction("Fusion_View_Show", {view = "Inspector", show = true})
        fu:SetData("Layouter.Set", false)
	end
end

win:Show()
disp:RunLoop()
win:Hide()
