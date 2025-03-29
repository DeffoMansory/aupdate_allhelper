script_name('All-Helper')
script_author('New Blood')
script_version('31.03.2025')
script_version = 5
script_description('for owner')


----------------- LIBS ----------------- 
require('lib.moonloader')
local imgui = require 'mimgui'
local event = require 'lib.samp.events'
local encoding = require 'encoding'
local ad = require 'ADDONS'
local ffi = require 'ffi'
local memory = require 'memory'
local faicons = require 'fAwesome6'
local inicfg = require 'inicfg'
local json = require('dkjson')

----------------- LIBS ----------------- 
-------------------- OTHER -----------------
local ass = require('moonloader').audiostream_state
local u8 = encoding.UTF8
local str, sizeof = ffi.string, ffi.sizeof
local new = imgui.new 
encoding.default = 'CP1251'

local search = imgui.new.char[256]()
----------------- OTHER -----------------
---
local directIni = 'AllHelperThemes.ini'
local ini = inicfg.load(inicfg.load({
	styleTheme ={
		theme = 0
    },
}, directIni))
inicfg.save(ini, directIni)
local colorListNumber = new.int(ini.styleTheme.theme)
local colorList = {u8'������������', u8'�����', u8'����� v2', u8'Ҹ����', u8'SoftBlue', u8'SoftOrange', u8'SoftGrey', u8'SoftGreen', u8'SoftRed', u8'SoftBlack'}
local colorListBuffer = imgui.new['const char*'][#colorList](colorList)

function onScriptTerminate(s)
    if s == thisScript() then
		ini.styleTheme.theme = colorListNumber[0]
		inicfg.save(ini, directIni)
    end
end

function update()
    local raw = 'https://raw.githubusercontent.com/DeffoMansory/aupdate_allhelper/refs/heads/main/update.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['last']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['url'], thisScript().path, function (id, status, p1, p2)
                print('�������� '..decodeJson(response.text)['url']..' � '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('������ ��������, ������������...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('������, ���������� ���������� ����������, ���: '..response.status_code, -1)
        end
    end
    return f
end

---
local directConfig = getWorkingDirectory()..'/config/allhelper.json'
print(getWorkingDirectory())
local defaultTable =
{
	['settings'] =
	{	
		['password'] = '',
		['autologin'] = false,
		['apassword'] = '',
		['autoalogin'] = false,
		['ahi'] = false,
		['fastnicks'] = false,
		['chatID'] = false,
		['antiafk'] = false,
		['reloginblock'] = false,
		['getblock'] = false,
		['atp'] = false,
		['shortadm'] = false,
		['akv'] = false,
		['ftp'] = false,
		['autogm'] = false,
		['autoears'] = false,
		['autoleader'] = false,
		['autoconnect'] = false,
		['autoainfo'] = false,
		['leaderid'] = 1,
		['dellServerMessages'] = false,
		['msginfo'] = false,
		['dellacces'] = false,
		['pgetip'] = false
	}
}
local sconfig = {}

if not doesFileExist(directConfig) then
	conf = assert(io.open(directConfig, 'w'), 'No permission to create file')
	conf:write(encodeJson(defaultTable))
	conf:close()
end
conf = io.open(directConfig, 'r')
local config = decodeJson(conf:read("*a"))
conf:close()
if type(config) ~= 'table' then config = defaultTable 
else
	for i, v in pairs(defaultTable) do
		if type(config[i]) == 'table' then
			for i1, v1 in pairs(defaultTable[i]) do
				if type(config[i][i1]) ~= type(v1) then config[i][i1] = v1 end
			end
		elseif type(config[i]) ~= type(v) then config[i] = v end
	end
end
conf = io.open(directConfig, 'w')
conf:write(encodeJson(config))
conf:close()

local elements =
{
	buffer =
	{
		password = new.char[32](config['settings']['password']),
		apassword = new.char[16](config['settings']['apassword'])
	},
	value =
	{
		autologin = new.bool(config['settings']['autologin']),
		autoalogin = new.bool(config['settings']['autoalogin']),
		ahi = new.bool(config['settings']['ahi']),
		fastnicks = new.bool(config['settings']['fastnicks']),
		chatID = new.bool(config['settings']['chatID']),
		antiafk = new.bool(config['settings']['antiafk']),
		reloginblock = new.bool(config['settings']['reloginblock']),
		getblock = new.bool(config['settings']['getblock']),
		atp = new.bool(config['settings']['atp']),
		shortadm = new.bool(config['settings']['shortadm']),
		akv = new.bool(config['settings']['akv']),
		ftp = new.bool(config['settings']['ftp']),
		autogm = new.bool(config['settings']['autogm']),
		autoleader = new.bool(config['settings']['autoleader']),
		autoears = new.bool(config['settings']['autoears']),
		autoconnect = new.bool(config['settings']['autoconnect']),
		autoainfo = new.bool(config['settings']['autoainfo']),
		leaderid = new.int(config['settings']['leaderid']-1),
		dellServerMessages = new.bool(config['settings']['dellServerMessages']),
		msginfo = new.bool(config['settings']['msginfo']),
		dellacces = new.bool(config['settings']['dellacces']),
		pgetip = new.bool(config['settings']['pgetip'])
	}
}
----------------- WINDOW -----------------
local menu 			    = imgui.new.bool()
local setWindow 		= imgui.new.bool()
local punishMenu 		= imgui.new.bool()
----------------- WINDOW -----------------

----------------- INPUT -----------------
local input_nameawarn   = imgui.new.char[128]()
local input_namelwarn   = imgui.new.char[128]()
local input_nameswarn   = imgui.new.char[128]()
local input_setleader   = imgui.new.char[64](-1)
local input_setsupport  = imgui.new.char[64](-1) 
local input_name 	    = imgui.new.char[128]()
local input_id 		    = imgui.new.char[128]()
local set_namemp	    = imgui.new.char[128]()
local set_priz		    = imgui.new.char[128]()
----------------- INPUT -----------------
---
-------------------- COMBO -----------------
local present 		    = new.int()
----------------- COMBO -----------------
---
----------------- SLIDER -----------------
local SliderOne  	   = new.int(-1) 
----------------- SLIDER -----------------

----------------- COMBO ITEM -----------------
local presentlist = {u8'Real Money (/rdonate)', u8'Gold Coins (������� ������)', 'F-Coins (/fcoins)', 'Donate Points (/donate)', u8'Color Ore (������� ����)'}
local ImPresent = imgui.new['const char*'][#presentlist](presentlist)
----------------- COMBO ITEM -----------------

local WhiteAccessories = {}

local commandsList =
{
	{'/alh', '������� ������� ���� �������'},
	{'/amp', '������ /mp, ���� ��� �� ��������'},
	{'/amsg', '�������� MSG ��������� (���������)'},
	{'/arec', '��������� �� ������'},
	{'/recname', '��������� � ��������� �����'},
	{'/punish', '������� ����� ������ � ����� ����'}
}

local amsg1 =
{
	{'/msg ��������� ������. ��������� ���, ���..'},
	{'/msg ������ ����, � 17:00 �� ��� �������� ������� 50-�� ����� ������ (/donat).'},
	{'/msg � 19:00 �������� ����������� �� 50 �������� ������ (/rdonate).'},
}

local amsg2 =
{
	{'/msg ��������� ������. ���� ��� ���������.. ���� �� ������� ������ � ���������� ������������� (/rep).'},
	{'/msg ����������, ��� ���-�� ���� ���� ������������� � �� �� �������� �������� � ���������� ������������� (/rep).'},
	{'/msg ���������, ��� �� ������ ������ ���������� �� ������ �������� ���������� ������� �� offtop (�� 1 �� 30 �����).'}
}
		
local lastUpdate =
{
	{'{ffcc00}28.03.2025 {ffffff}� ����-����������. {ffcc00}������: 3.50'},
	{'{ffffff}� ���� ��������� �������������� �������� pgetip �� getip'},
	{'����� ������������ ����������� � ��������� � "���������" > "����-�������� pgetip �� getip"'},
	{'{ffcc00}09.03.2025 {ffffff}� ����������. {ffcc00}������: 3.40'},
	{'{ffffff}� ��� ������ ������ �������� ���� �������'},
	{'� ��� �������� ������ ������ ������� ������ � �������'},
	{'� �������� ����� ������ "������"'},
	{'� ���� ���������� ��������� ������� �� ������� "���������" � "������"'},
	{'� ��������� ����������� ���� ���� ���� �������'},
	{'� ���������� ������ � ������� ������� ����� ������ "������ ���������"'},
	{'{ffcc00}08.03.2025 {ffffff}� ����-����������. {ffcc00}������: 3.30'},
	{'{ffffff}� ���� �������� � ��������� ��������� ������ � �������'},
	{'� �������� ������� ������ � ������� "���������� ������"'},
	{'� ��������� ��� �������� ���� ������ ���������'},
	{'� ���������� ������� ���� ���� ������ ���������'}
}

local updateText = ""
for _, update in ipairs(lastUpdate) do
    updateText = updateText .. update[1] .. "\n"
end

local afracNames =
{
	{1, 'LSPD'},
	{2, '���'},
	{3, '����� ��'},
	{4, '��������'},
	{5, 'La Cosa Nostra'},
	{6, 'Yakuza'},
	{7, '�����'},
	{11, 'Warlocks MC'},
	{12, 'The Ballas'},
	{13, 'Los Santos Vagos'},
	{14, 'Russian Mafia'},
	{15, 'Grove Street'},
	{16, 'San News'},
	{17, 'Varios Los Aztecas'},
	{18, 'The Rifa'},
	{23, 'Hitmans Agency'},
	{25, 'S.W.A.T'},
	{26, '�������������'}
}
local autoleaderCombo = (function()
    local names = {}
    for _, frac in ipairs(afracNames) do
        table.insert(names, u8(frac[2]))
    end
    return table.concat(names, '\0')
end)()

local fracNames = {
    {0, 'No selected'},
    {1, 'LSPD'},
    {2, 'FBI'},
    {3, 'Army LS'},
    {4, 'Hospital LS'},
    {5, 'La Cosa Nostra'},
    {6, 'Yakuza'},
    {7, 'Mayor'},
    {11, 'Warlocks MC'},
    {12, 'The Ballas'},
    {13, 'Los Santos Vagos'},
    {14, 'Russian Mafia'},
    {15, 'Grove Street'},
    {16, 'San News'},
    {17, 'Varios Los Aztecas'},
    {18, 'The Rifa'},
    {23, 'Hitmans Agency'},
    {25, 'S.W.A.T'},
    {26, 'Government'}
};

local comboStr = (function()
    local names = {};
    for _, frac in ipairs(fracNames) do
        table.insert(names, frac[2]);
    end
    return table.concat(names, '\0');
end)();

local selected = imgui.new.int(0);

local menuSwitch = 0
local punishSwitch = 0

local inputTexts = {
    imgui.new.char[256](),
    imgui.new.char[256](),
    imgui.new.char[256](),
    imgui.new.char[256](),
    imgui.new.char[256]()
}
local inputDelays = {
    imgui.new.char[6](),
    imgui.new.char[6](),
    imgui.new.char[6](),
    imgui.new.char[6](),
    imgui.new.char[6]()
}
local inputButtons = {
    new.bool(false),
    new.bool(false),
    new.bool(false),
    new.bool(false),
    new.bool(false)
}
local floodActive = { false, false, false, false }
local saveFilePath = getGameDirectory() .. '\\moonloader\\config\\flooder.json'

local function loadTextFromJson()
    local file = io.open(saveFilePath, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        local data = json.decode(content)
        if data then
            for i = 1, 5 do
                if data["text" .. i] then
                    ffi.copy(inputTexts[i], u8:encode(data["text" .. i]))
                end
                if data["delay" .. i] then
                    ffi.copy(inputDelays[i], u8:encode(data["delay" .. i]))
                end
            end
        end
    end
end

local function saveTextToJson()
    local data = {}
    for i = 1, 5 do
        data["text" .. i] = u8:decode(str(inputTexts[i]))
        data["delay" .. i] = u8:decode(str(inputDelays[i]))
    end
    local file = io.open(saveFilePath, 'w')
    if file then
        file:write(json.encode(data, { indent = true }))
        file:close()
    else
        sampAddChatMessage('[AllHelper]: {FFFFFF}������ ���������� ������!', 0x696969)
    end
end

local function floodLogic(index)
    while floodActive[index] do
        local delay = tonumber(str(inputDelays[index]))
        if not delay or delay <= 0 then
            sampAddChatMessage(string.format('[AllHelper]: {FFFFFF}���������� �������� ��� ������ %d!', index), 0x696969)
            floodActive[index] = false
            inputButtons[index][0] = false
            break
        end
        local message = u8:decode(str(inputTexts[index]))
        if message ~= '' then
            sampSendChat(message)
        end
        wait(delay * 1000)
    end
end
----------------- INICFG -----------------
---
----------------- INICFG -----------------
local delltext = {'Ace_Will', 'attractive-rp.ru', 'SAN', 'SAN', '�����', '���������', '/vacancy', '.* �������� VIP ������������ %w+_%w+%[%d+%]'}
----------------- NAVIGATION LIST -----------------
local navigation = {
    current = 1,
    list = {u8'�������� ����', u8'���. ���������', u8'��������', u8'�����', u8'�����'}
}
local gos_navigation = {
	current = 1,
	list = {u8'������� | ���', u8'�� | �����', u8' San-News', u8'��������'}
}
local mafia_navigation = {
	current = 1,
	list = {u8'LCN | Yakuza | Russian Mafia | Warlocks MC', u8'Hitmans Agency'}
}
local mp_navigation = {
    current = 1,
    list = {u8"���� �������� ����������", u8"������ � ������� �����������"}
}
local warn_navigation = {
    current = 1,
    list = {u8"�������������", u8"������", u8"��������"}
}
local punish_navigation = {
    current = 1,
    list = {u8'������� ������ ���������',u8'������� ��� �������������',u8'������� ��� ������� '}
}

local nickList = {}

----------------- NAVIGATION LIST -----------------
local AllWindows = imgui.OnFrame(function() return menu[0] end, function()
	if menuSwitch == 0 then
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 660, 389
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.PushFont(myFont)
		imgui.Begin(faicons(u8'SHIELD_CHECK')..u8' All Helper', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)--imgui.WindowFlags.NoDecoration)
		imgui.CenterText(faicons(u8'SHIELD_CHECK')..u8' All Helper')
		imgui.SameLine(0,259)
		ad.CloseButton('MainClose', menu, 25)
		imgui.BeginChild('##menu', imgui.ImVec2(325,168), 1)
		if imgui.Button(faicons(u8'CROWN')..u8' ���������� ������ ', imgui.ImVec2(150, 35)) then
			menuSwitch = 1
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'GIFT')..u8' ���������� ��      ', imgui.ImVec2(150, 35)) then
			menuSwitch = 2
		end
		-- if imgui.Button(faicons(u8'USER')..u8' ������ ���������      ', imgui.ImVec2(150, 35)) then
		if imgui.Button(faicons(u8'LIGHT_EMERGENCY_ON')..u8' ������ ���������      ', imgui.ImVec2(150, 35)) then
			menuSwitch = 4
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'FOLDERS')..u8' ������                 ', imgui.ImVec2(150, 35)) then
			menuSwitch = 5
		end
		if imgui.Button(faicons(u8'GEAR')..u8' ���������              ', imgui.ImVec2(150, 35)) then
			menuSwitch = 3
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'SPARKLES')..u8' ������		              ', imgui.ImVec2(150, 35)) then
			menuSwitch = 6
		end
		if imgui.Button(faicons(u8'PAPER_PLANE')..u8' �������� �����      ', imgui.ImVec2(150, 35)) then
			os.execute(('explorer.exe "%s"'):format("https://vk.com/number1241"))
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'CIRCLE_INFO')..u8' ������. ����������      ', imgui.ImVec2(150, 35)) then
			menu[0] = false
			printStyledString(cyrillic("��������� ���������� ����� ~g~28.03.2025"), 1500, 5)
			sampShowDialog(1914, '������ ���������', updateText, '�������', '', 0)
		end
		if imgui.Button(u8'�������� ������', imgui.ImVec2(300, 35)) then
			update():download()
		end
		imgui.EndChild()
		imgui.SameLine(335)
		imgui.BeginChild('##menuDes', imgui.ImVec2(317,168), 1)
		imgui.CenterText(faicons(u8'SQUARE_INFO')..u8' ���������� � �������')
		imgui.Separator()
		imgui.CenterText(u8'������: 4.00')
		imgui.CenterText(u8'���: X')
		imgui.CenterText(u8'�����������: New_Blood')
		imgui.Separator()
		imgui.CenterText(faicons(u8'ADDRESS_CARD')..u8' ����� �������')
		imgui.Separator()
		imgui.CenterText(u8'Orlando_BlackStar, Burger_Endless')
		-- if #nickList > 0 then
		-- 	for _, playerNick in ipairs(nickList) do
		-- 		imgui.CenterText(playerNick)  -- ������� ������ ���
		-- 	end
		-- else
		-- 	imgui.CenterText(u8"������ ����� ����.")
		-- end
		imgui.EndChild()
		imgui.BeginChild('##menuDes2', imgui.ImVec2(640,150), 0)
		imgui.CenterText(faicons(u8'SEAL_QUESTION')..u8' ������')
		imgui.Separator()
		for i=1, #commandsList do
			imgui.CenterText(u8(commandsList[i][1] .. " � " .. commandsList[i][2]))
		end
		imgui.EndChild()
		imgui.PopFont()
		imgui.End()
	elseif menuSwitch == 1 then
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 925, 350
		imgui.PushFont(myFont)
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'���������� ������', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.SetCursorPos(imgui.ImVec2(10, 30))
		if imgui.BeginChild('Name##1'..navigation.current, imgui.ImVec2(140,105), false) then
			for i, title in ipairs(navigation.list) do
				if HeaderButton(navigation.current == i, title) then
					navigation.current = i
				end
			end
		end
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(155, 30))
		if imgui.BeginChild('Name##2'..navigation.current, imgui.ImVec2(760, 310), true) then
				if navigation.current == 1 then
				imgui.BeginChild('##getleader', imgui.ImVec2(165, 60), 0)
				imgui.PushItemWidth(155)
				if (imgui.ComboStr('', selected, comboStr .. '\0', -1)) then
					print('Selected frac name', fracNames[selected[0] + 1][2]);
				end
				imgui.PopItemWidth()
				if imgui.Button(u8'������ ���������', imgui.ImVec2(155,25)) then
					setWindow[0] = not setWindow[0]
				end
				imgui.EndChild()
				imgui.BeginChild('##msgButtons', imgui.ImVec2(520, 175), 0)
				if imgui.Button(u8'���������� � ������ (�����)', imgui.ImVec2(250,45)) then
					if selected[0] == nil or selected[0] < 1 then
						sampAddChatMessage('[������]: {ffffff}�������� ��������� ��������� ��� ����������� ���������� ������!', 0xFF6600)
					else
						local selected_value = fracNames[selected[0] + 1][2]
						sampSendChat('/msg [�����]: ������ ������ ����� �� ���� ��������� "'..selected_value..'". �������� - /gotp (�� ������ ����).')
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'���������� � ��������� ����������', imgui.ImVec2(250,45)) then
					if selected[0] == nil or selected[0] < 1 then
						sampAddChatMessage('[������]: {ffffff}�������� ��������� ��������� �� ������� ��������� �����!', 0xFF6600)
					else
						local selected_value = fracNames[selected[0] + 1][2]
						sampSendChat('/msg [�����]: ����� �� ��������� ��������� "'..selected_value..'" ��� ������ ��-�� ��������� ����������.')
					end
				end
				if imgui.Button(u8'���������� � ������ (�������)', imgui.ImVec2(250,45)) then
					sampSendChat('/msg [�����]: ������ ������ ����� �� ��������� "�������". �������� - /gotp (�� ������ ����)')
				end
				imgui.SameLine()
				if imgui.Button(u8'�������� �������', imgui.ImVec2(250,45)) then
					lua_thread.create(function()
						sampSendChat('/m �����������! �� ������ �� �����. ������ ��� ����� �������� �������.')
						wait(1500)
						sampSendChat('/m [�������]: ������� �� ����� 15 ������, ��������� �� 10 ������.')
						wait(1500)
						sampSendChat('/m [�������]: ��������� ������������ ���/������� � �����. ����������: sms/rep ��� ������ �����������.')
						wait(1500)
						sampSendChat('/m [�������]: �������� �������� �� �����, ������ AFK 4+ ������� � �������� ��� �������.')
						wait(1500)
						sampSendChat('/m [�������]: ��������� ������ ����������/����������� ������ ��� ���-���� �������� ������� �������.')
						wait(1500)
						sampSendChat('/m [����������]: ���� ���-�� ������� ��������� � ������ ������ ����� � ��� ��� ����� ���������� ���������� � �����.')
						wait(1500)
						sampSendChat('/m �����!')
					end)
				end
				imgui.EndChild()
			elseif navigation.current == 2 then
				if imgui.Button(u8'���� ����-����') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� ����?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}�������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'��� ����� ������ �� �������') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� �������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}������ + /ban', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'������������ ���������') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� ������������ ���������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}��� �������� + mute', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'��������� �������� ����') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������, ���� ��� ����������� ������� ����')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'DeathMatch') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� DM')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}������� + jail', -1)
					end)
				end
				if imgui.Button(u8'����������� 1 ����') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� ����������� ����� 1 ����?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'NonRP �������� ������') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� NonRP �������� ������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}2 ��������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'5 ������ �� ������� ����� ����� � �������') then
						lua_thread.create(function()
						sampSendChat('/m �������� 5 ������, �� ������� ����� ����� � ����� ������')
						wait(110)
						sampAddChatMessage('��������� �������: {ffcc00}����. �����, ����, ���� � �������, �������, ����� ���, ������� 5+, ����, �������, ���������� ����� �������..', -1)
						sampAddChatMessage('��������� �������: {ffcc00}3/3 ���������� ������, 3/3 ������� ��������������, 4/4 ������ ��������������.', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'���������� �����') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ �� ���������� �����?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}������ + mute', -1)
					end)
				end
				if imgui.Button(u8'3 ������� �� ������� ����� �������� 2 ��������') then
						lua_thread.create(function()
						sampSendChat('/m �������� 3 �������, �� ������� ����� �������� 2 �������� (���)')
						wait(110)
						sampAddChatMessage('�������: {ffcc00}NonRP �������� ������, ���������� ������, ������ ��������������� �����..', -1)
						sampAddChatMessage('�������: {ffcc00}����� �� ���, ������������� ��������� � {ff0000}������� �������������', -1)
					end)
				end
				imgui.Separator()
				for i, title in ipairs(gos_navigation.list) do
					if HeaderButton(gos_navigation.current == i, title) then
						gos_navigation.current = i
					end
					if i ~= #gos_navigation.list then
						imgui.SameLine(nil, 30)
					end
				end
				imgui.Separator()
				if gos_navigation.current == 1 then
				if imgui.Button(u8'[������� | ���] ��� ������ ������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ������ ������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/su(spect)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[������� | ���] ��� ������ ����� � �������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ������ ����� � �������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}(/m)egaphone', -1)
					end)
				end
				if imgui.Button(u8'[������� | ���] ��� ���������� ������ �������������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ���������� ������ ������������� �����? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/wanted', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[������� | ���] ��� ������ ����� � �����������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ������ ����� � �����������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}(/d)epartments /db (���� �� ����)', -1)
					end)
				end
				if imgui.Button(u8'[������� | ���] ��� �������� ������') then
					lua_thread.create(function()
					sampSendChat('/m ��� �������� ������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/frisk', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[������� | ���] ��� ������ ����� � ���. �������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ������ ����� � ���. �������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}(/gov)ernment', -1)
					end)
				end
				if imgui.Button(u8'[������� | ���] ��� ��������� ����') then
					lua_thread.create(function()
					sampSendChat('/m ��� ? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/block', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[������� | ���] ��� ����� ���') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ���? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/shield', -1)
					end)
				end
				if imgui.Button(u8'[������� | ���] ��� ������ ���� �� �������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ������ ���� �� �������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/givecopkeys', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[������� | ���] ��� ��������� �������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ��������� ������� (����� ���, �����, ����������, ��������� � �.�)? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/break', -1)
					end)
				end
				if imgui.Button(u8'[���] ��� �������� / ������� �������� � ������ �����������') then
				lua_thread.create(function()
					sampSendChat('/m ��� �������� / ������� �������� � ������ �����������? (�������)')
					wait(110)
					sampAddChatMessage('{ffcc00}/demote',-1)
				end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[���] ��� �������� ���� ����� ������� �������') then
					lua_thread.create(function()
						sampSendChat('��� �������� ���� ����� ������� �������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/frazer',-1)
					end)
				end
				if imgui.Button(u8'[���] ��� ����� ����������') then
					lua_thread.create(function()
						sampSendChat('/m ��� ����� ����������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/spy (/hmask)',-1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[���] ��� ������������ ����� ������ �����������') then
					lua_thread.create(function()
						sampSendChat('/m ��� ������������ ����� ������ �����������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/follow',-1)
					end)
				end
				if imgui.Button(u8'[������� | ���] ��� ���������� ������ ����� ����� ����������� ������') then
					lua_thread.create(function()
						sampSendChat('/m ��� ���������� ������ ����� ����� ����������� ������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/members',-1)
					end)
				end
				elseif gos_navigation.current == 2 then
				if imgui.Button(u8'[�� | �����] ��� ������ ������ ���. ���������') then
					lua_thread.create(function()
						sampSendChat('/m ��� ������ ������ ���. ���������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/govsu',-1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[�����] ��� ����� ������ � ����� �����') then
					lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ � ����� �����? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/takekazna',-1)
					end)
				end
				if imgui.Button(u8'[��] ��� �������� / ������� �������� � ������ �����������') then
					lua_thread.create(function()
						sampSendChat('/m ��� �������� / ������� �������� � ������ �����������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/demote',-1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[��] ��� �������� ���� ����� ������� �������') then
					lua_thread.create(function()
						sampSendChat('/m ��� �������� ���� ����� ������� �������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/ftazer',-1)
					end)
				end
				elseif gos_navigation.current == 3 then
				if imgui.Button(u8'��� ������������� ����������') then
					lua_thread.create(function()
						sampSendChat('/m ��� ������������� ����������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/edit',-1)
					end)
				end
				elseif gos_navigation.current == 4 then
				if imgui.Button(u8'�����') then
					lua_thread.create(function()
						sampSendChat('/m ��� ������ ���������� �����? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/lomka',-1)
					end)
				end imgui.SameLine()
				if imgui.Button(u8'���. �����') then
					lua_thread.create(function()
						sampSendChat('/m ��� ������ �������� ���. �����? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/givemedcard',-1)
					end)
				end
				if imgui.Button(u8'��������') then
					lua_thread.create(function()
						sampSendChat('/m ��� �������� ��������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/medhelp (/heal)',-1)
					end)
				end imgui.SameLine()
				if imgui.Button(u8'������� �� ������') then
					lua_thread.create(function()
						sampSendChat('/m ��� ������� �������� �� ������? (�������)')
						wait(110)
						sampAddChatMessage('{ffcc00}/mdpell',-1)
					end)
				end
			end
		elseif navigation.current == 3 then
				if imgui.Button(u8'������������� ������ ��') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ������������� ������ �������� ���������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}�������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'��������� ����� �������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ���������� ����� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}������', -1)
					end)
				end
				if imgui.Button(u8'������� 24 ����') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ������� 24 ����?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'�������� �����') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� �������� �����?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}�������', -1)
					end)
				end
				if imgui.Button(u8'NonRP ���') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� NonRP ���?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}������', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'�������� � ������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ������� � ������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}�������', -1)
					end)
				end
				if imgui.Button(u8'������/������������� � ������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ������� ������, ���������� ������������� ��� ������, ������������� ������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}�������', -1)
					end)
				end
				if imgui.Button(u8'������������� �����') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ������������� �����?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}������ + jail/warn', -1)
					end)
				end
				if imgui.Button(u8'DeathMatch') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� DM?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}������� + jail', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'0 �������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �������� �� ������� 0 �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}2 ��������', -1)
					end)
				end
		elseif navigation.current == 4 then
				if imgui.Button(u8'��� ����� ����� �� ���') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� �� ��������������� ����� �� ����� �����, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}2/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'����� �� �����') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� �� ������������� ����������� �� ����� �����, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}1/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
				if imgui.Button(u8'Fly Hack') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� ������������� Fly Hack, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}2/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'CARSHOT') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� ������������� CARSHOT, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ /ban', -1)
					end)
				end
				if imgui.Button(u8'���������� SK') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� �� ���������� SK, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}2/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'���� �������/�������') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� �� ���� ������/�������, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
				if imgui.Button(u8'3/3 ���� (����� � ����)') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ������, ���� ��� ����� �������� 3/3, ����� �� ��� � ����?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}�������', -1)
					end)
				end
				if imgui.Button(u8'�������� �� ������������� ����') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� �����, ���� ���-�� �� ��� ����� �������� �� ������������� ����, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ ������ (���� ����� - �������)', -1)
					end)
				end
				if imgui.Button(u8'Silent-AIM') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� �� ������������� AIM, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'���. +C �� ����� ����+�') then
					lua_thread.create(function()
					sampSendChat('/m ��� ����� ����� �� +� �� ���� +� �����, � ������ ������� ������� �������?')
					wait(110)
					sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
					end)
				end
			elseif navigation.current == 5 then
				for i, title in ipairs(mafia_navigation.list) do
					if HeaderButton(mafia_navigation.current == i, title) then
						mafia_navigation.current = i
					end
					if i ~= #mafia_navigation.list then
						imgui.SameLine(nil, 30)
					end
				end
				imgui.Separator()
				if mafia_navigation.current == 1 then
					if imgui.Button(u8'������') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ����� �� �������� �� ������ � ������� 3-� �����?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}3/3 �����, ���� ����� ��� � ���� - �������', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'�����') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������ � ����� �� ������������� ����� �� ������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}1/3 �����, ������ jail/warn.', -1)
						end)
					end
					if imgui.Button(u8'+C') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� �����, ���� ���-�� �� ������ �� ��� ����� ������������ +�, � ������ ������� ������� �������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}1/3 �����, ������ jail/warn', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'3/3 ������ (����� � ����)') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ������, ���� ��� ����� �������� 3/3, ����� �� ��� � ����?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}�������', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'FLY') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� �����, ���� ���-�� �� ������ �� ��� ����� ������������ FLY, � ������ ������� ������� �������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}1/3 �����, ������ jail/warn', -1)
						end)
					end
					if imgui.Button(u8'����������� ��') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� �����, ���� ���-�� �� ������ �������� �� Hunter | Hydra, � ��� ����� ������ ������� ������� �������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
						end)
					end
					if imgui.Button(u8'����-������ �������') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� ����� �� ����-������ �������?')
						wait(110)
						sampAddChatMessage('������: {ffcc0}LCN ���� �������� ������ Yakuza, �� Yakuza ����� ���, ����� ��� �� �� ����� ������')
						sampAddChatMessage('������: {ffcc00}ID 1 LCN, ID 2 - Yakuza. ���� ID 2 ���� ID 1, �� ID 2 �������� ����')
						sampAddChatMessage('���������: {ffcc00}3/3 �����, ������ jail/warn (������ ������� ���� �� � ����)', -1)
						end)
					end
					if imgui.Button(u8'���') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� �����, ���� ���-�� �� ������ ������� �� ��������������� �����, � ��� ����� ������ ������� ������� �������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}2/3 �����, ������ jail/warn', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'�������/��������� � ���') then
						lua_thread.create(function()
						sampSendChat('/m ��� ����� �����, ���� ���-�� �� ������ ����� ������������ �������/��������� � ���, � ��� ����� ������ ������� ������� �������?')
						wait(110)
						sampAddChatMessage('���������: {ffcc00}1/3 �����, ������ jail/warn', -1)
						end)
					end
				elseif mafia_navigation.current == 2 then
					if imgui.Button(u8'����� ����������� ���-�� ���������� ��� ������') then
						lua_thread.create(function()
							sampSendChat('/m ����� ����������� ���-�� ���������� ��� ������?')
							wait(110)
							sampAddChatMessage('{ffcc00}3 ���������',-1)
						end)
					end imgui.SameLine()
					if imgui.Button(u8'�� �������� ����� ������ ������� ����� ��� ������') then
						lua_thread.create(function()
							sampSendChat('/m �� �������� ����� ������ ������� ����� ��� ������?')
							wait(110)
							sampAddChatMessage('{ffcc00}15 �����',-1)
						end)
					end
					if imgui.Button(u8'�� �������� ����� ������ ������� ���������� ����� ������ � ������ ������� ��� ������') then
						lua_thread.create(function()
							sampSendChat('/m �� �������� ����� ������ ������� ���������� ����� ������ � ������ ������� ��� ������?')
							wait(110)
							sampAddChatMessage('{ffcc00}10 �����',-1)
						end)
					end
					if imgui.Button(u8'��� ����� ����������') then
						lua_thread.create(function()
							sampSendChat('/m ��� ����� ����������?')
							wait(110)
							sampAddChatMessage('{ffcc00}/spy (/hmask)',-1)
						end)
					end
			end
		end
	end
	imgui.EndChild()
	imgui.PopFont()
	elseif menuSwitch == 2 then
		local resX, resY = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(485, 255))
		imgui.PushFont(myFont)
		imgui.Begin(u8'���������� ��', menu, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		if mp_navigation.current == 1 then -- Home
			if imgui.BeginChild('child##1', imgui.ImVec2(470,215), 0) then
				for i, title in ipairs(mp_navigation.list) do
					if HeaderButton(mp_navigation.current == i, title) then
						mp_navigation.current = i
					end
					if i ~= #mp_navigation.list then
						imgui.SameLine(nil, 110)
					end
				end
				imgui.Separator()
				imgui.Combo('', present, ImPresent, #presentlist)
				imgui.InputTextWithHint(u8'##4', u8'�������� �����������', set_namemp, sizeof(set_namemp))
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##5'..faicons('trash')) then 
					imgui.StrCopy(set_namemp,'')
				end
				imgui.TextQuestionMp(u8'���: ��������\n������������ ��� �������� ���������� � /msg')
				imgui.InputTextWithHint(u8'##5', u8'����� �����', set_priz, sizeof(set_priz), imgui.InputTextFlags.CharsDecimal)
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##6'..faicons('trash')) then 
					imgui.StrCopy(set_priz,'')
				end
				imgui.TextQuestionMp(u8'���: �����\n������������ ��� �������� ���������� � /msg')
				imgui.InputTextWithHint(u8'##1', u8'Nickname ���������� �����������', input_name, sizeof(input_name))
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##7'..faicons('trash')) then 
					imgui.StrCopy(input_name,'')
				end
				imgui.TextQuestionMp(u8'���: �������\n������������ ��� �������� ���������� � /msg')
				imgui.InputTextWithHint(u8'##2', u8'ID ���������� �����������', input_id, sizeof(input_id), imgui.InputTextFlags.CharsDecimal)
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##8'..faicons('trash')) then 
					imgui.StrCopy(input_id,'')
				end
				imgui.TextQuestionMp(u8'��� ��������� "����������� �����������"\n������������� �� Real Money (/rdonate)')
				imgui.Separator()
				imgui.Text('')
				-- imgui.SameLine(100)
				if imgui.Button(faicons('play')..u8'  ������', imgui.ImVec2(145,0)) then
					local set_namemp = str(set_namemp)
					local set_priz = str(set_priz)
					local selected_prize = u8:decode(ffi.string(presentlist[present[0] + 1]))
					if u8:decode(ffi.string(set_namemp)) ~= '' and u8:decode(ffi.string(set_priz)) ~= '' and selected_prize ~= 0 then
						sampSendChat('/msg �������� ����������� "'..u8:decode(ffi.string(set_namemp))..'" �� '..u8:decode(ffi.string(set_priz))..' '..selected_prize..'. �������� - /gotp.')
					else
						sampAddChatMessage('[������] {ffffff}�������� ������� �������', 0x696969)
					end
				end  
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'��������� � ������ �����������')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(faicons('pause')..u8'  ���������', imgui.ImVec2(145,0)) then
					local input_name = str(input_name)
					local set_namemp = str(set_namemp)
					local set_priz = str(set_priz)
					local selected_prize = u8:decode(ffi.string(presentlist[present[0] + 1]))
					if u8:decode(ffi.string(set_namemp)) ~= '' and u8:decode(ffi.string(set_priz)) ~= '' and u8:decode(ffi.string(input_name)) ~= '' and selected_prize ~= 0 then
						sampSendChat('/msg ���������� ����������� "'..u8:decode(ffi.string(set_namemp))..'" �� '..u8:decode(ffi.string(set_priz))..' '..selected_prize..' � '..u8:decode(ffi.string(input_name))..'. �����������!')
					else
						sampAddChatMessage('[������] {ffffff}�������� ������� �������', 0x696969)
					end
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'��������� � ���������� �����������')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(faicons('star')..u8'  ������', imgui.ImVec2(145,0)) then
					local set_namemp = str(set_namemp)
					local input_id = str(input_id)
					local selected_prize = u8:decode(ffi.string(presentlist[present[0] + 1]))
					if u8:decode(ffi.string(set_namemp)) ~= '' and u8:decode(ffi.string(input_id)) ~= '' and selected_prize ~= 1 then
						sampSendChat('/winner '..u8:decode(ffi.string(input_id))..' '..u8:decode(ffi.string(set_namemp))..'')
					else
						sampAddChatMessage('[������] {ffffff}�������� ������� �������', 0x696969)
					end
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'��� ��������� "����������� �����������"\n������������� �� Real Money (/rdonate)')
					imgui.EndTooltip()
				end
				imgui.EndChild()
				end
		elseif mp_navigation.current == 2 then -- Regulations
			if imgui.BeginChild('child##2', imgui.ImVec2(470,205), 0) then
				for i, title in ipairs(mp_navigation.list) do
					if HeaderButton(mp_navigation.current == i, title) then
						mp_navigation.current = i
					end
					if i ~= #mp_navigation.list then
						imgui.SameLine(nil, 110)
					end
				end
				imgui.Separator()
				if imgui.Button(u8'������� (�� �������)', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ���������: �������� �����/����, ���������� � ����� �� �����, ������������ /me, /do, /todo � /try � �.�')
						wait(1000)
						sampSendChat('/m ���������: ��� ���� �������� ������� �������')
						wait(1000)
						sampSendChat('/m ���������: �������� �� ����� � ������ ������')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m �����! ���� ����� �� �������')
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'������� ������� (�� �������)')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n���������: �������� �����/����, ���������� � ����� �� �����, ������������ /me, /do, /todo � /try � �.�\n���������: ��� ���� �������� ������� �������\n���������: �������� �� ����� � ������ ������\n�����! ���� ����� �� �������')
					imgui.EndTooltip()
				end
					imgui.SameLine()
				if imgui.Button(u8'������� (�� ������)', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ���������: �������� �����/����, ���������� � ����� �� �����, ������������ /me, /do, /todo � /try � �.�')
						wait(1000)
						sampSendChat('/m ���������: ��� ���� �������� ������� �������')
						wait(1000)
						sampSendChat('/m ���������: �������� �� ����� � ������ ������')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m �����! ���� ����� �� ������')
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'������� ������� (�� ������/spawn)')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n���������: �������� �����/����, ���������� � ����� �� �����, ������������ /me, /do, /todo � /try � �.�\n���������: ��� ���� �������� ������� �������\n���������: �������� �� ����� � ������ ������\n�����! ���� ����� �� ������')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'����� ������', imgui.ImVec2(151,30)) then 
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')                        
						wait(1000)
						sampSendChat('/m ���������: �������� �����/���� � ������������ ��������')
						wait(1000)
						sampSendChat('/m ���������: AFK ����� ��� 10 ������, ��������� ������ ��������� ���� ��, ��������������� ������������ �� �����������')
						wait(1000)
						sampSendChat('/m ���������: ��� ���� �������� ������� �������')
						wait(1000)
						sampSendChat('/m ��������! ���������� �� ����� ����� �� ��� ��������.')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m ������!')
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'����� ������')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n���������: �������� �����/���� � ������������ ��������\n���������: AFK ����� ��� 10 ������, ��������� ������ ��������� ���� ��, ��������������� ������������ �� �����������\n���������: ��� ���� �������� ������� �������\n/m ��������! ���������� �� ����� ����� �� ��� ��������\n������!')
					imgui.EndTooltip()
				end
				if imgui.Button(u8'������ �����', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ���������: �������� �����/����, �������� � ����������/������/����������� ����������� ��� �������')
						wait(1000)
						sampSendChat('/m ���������: ��� ���� �������� ������� �������')
						wait(1000)
						sampSendChat('/m ���������: �������� �� ����� � ������ ������')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m ���� ��������� ���, ��� ������� � �������� �����')
					end)
				end 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'������ �����')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n���������: �������� �����/����, �������� � ����������/������/����������� ����������� ��� �������\n���������: ��� ���� �������� ������� �������\n���������: �������� �� ����� � ������ ������\n���� ��������� ���, ��� ������� � �������� �����')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'������', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ���������: �������� �����/����, ������� ����� � ������������ ��������')
						wait(1000)
						sampSendChat('/m ���������: ��� ���� �������� ������� �������')
						wait(1000)
						sampSendChat('/m ���������: ������������ �����-����������� � ������������')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m � ��� ���� ������, ����� ���� ��� ������')
						wait(1000)
						sampSendChat('/m ������!')
					end)
				end 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'������')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n���������: �������� �����/����, ������� ����� � ������������ ��������\n���������: ��� ���� �������� ������� �������\n���������: ������������ �����-����������� � ������������\n� ��� ���� ������, ����� ���� ��� ������\n������!')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'����� ������', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ���� ������ �������� ��������� � �����')
						wait(1000)
						sampSendChat('/m � ���� �� ��� �������� �� ������')
						wait(1000)
						sampSendChat('/m ���������:')
						wait(1000)
						sampSendChat('/m ������ AFK ����� ��� 5 ������')
						wait(1000)
						sampSendChat('/m ������������ ����� ����, ��������� ��, ������ �����/����')
						wait(1000)
						sampSendChat('/m ��� ���� �������� ������� �������, ������������� ������������ �� �����������')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
					end)
				end 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'����� ������')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n���� ������ �������� ��������� � �����\n� ���� �� ��� �������� �� ������\n���������:\n������ AFK ����� ��� 5 ������\n������������ ����� ����, ��������� ��, ������ �����/����\n��� ���� �������� ������� �������, ������������� ������������ �� �����������')
					imgui.EndTooltip()
				end
				if imgui.Button(u8'���������', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m �� ��������� � ������� � � ����� ���� ������')
						wait(1000)
						sampSendChat('/m ���� ������ �������� ��������� � �����')
						wait(1000)
						sampSendChat('/m ��������� ���������� ��, ���. ����������� � ��������� ����� ������ �������')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m ������!') 
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� �������� ��������������')
					imgui.Separator()
					imgui.CenterText(u8'���������')
					imgui.Separator()
					imgui.Text(u8'������� ��:\n�� ��������� � ������� � � ����� ���� ������\n���� ������ �������� ��������� � �����\n��������� ���������� ��, ���. ����������� � ��������� ����� ������ �������\n������!')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'�������. ������ ��', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m ���� ��:')
						wait(1000)
						sampSendChat('/m � ������� ����� � ��� ������ �� ������ ������ ����.')
						wait(1000)
						sampSendChat('/m �� ������ ��� ������.')
						wait(1000)
						sampSendChat('/m � ���� ������� � ������� �� ���� ������.')
						wait(1000)
						sampSendChat('/m ��������� ��� ���� � ���� ������ ��� ��������� ����� �������� � �������� �����.')
						wait(1000)
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ��������� ���������� ��, ���. ����������� � ��������� ����� ������ �������.')
						wait(1000)
						sampSendChat('/m ����� �����/������, �������� �� ����.')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m �����!') 
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� "����������� �����������"')
					imgui.Separator()
					imgui.CenterText(u8'��������� ������ ��')
					imgui.Separator()
					imgui.Text(u8'���� ��:\n� ������� ����� � ��� ������ �� ������ ������ ����.\n�� ������ ��� ������.\n� ���� ������� � ������� �� ���� ������.\n��������� ��� ���� � ���� ������ ��� ��������� ����� �������� � �������� �����.\n������� ��:\n��������� ���������� ��, ���. ����������� � ��������� ����� ������ �������.\n����� �����/������, �������� �� ����.\n�����!')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'����� ��������', imgui.ImVec2(151,30)) then
					local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
					lua_thread.create(function()
						sampSendChat('/m ���� ��:')
						wait(1000)
						sampSendChat('/m ���-�� � LS ���������� �������, ������� �� ������ �����.')
						wait(1000)
						sampSendChat('/m ���� �� ����� ������ ������� - ������ ��� � /sms [ID: '..myID..']')
						wait(1000)
						sampSendChat('/m �� ������ ����� ����� �� � ������ ������ �������.')
						wait(1000)
						sampSendChat('/m ������� ��:')
						wait(1000)
						sampSendChat('/m ��������� ����, ���. ����������� � ��������� ����� ������ �������.')
						wait(1000)
						sampSendChat('/m ����� �����/������.')
						wait(1000)
						sampSendChat('/m ������ = ���. ��� ���. ������� + ���. �� ��������� ������ + ���.')
						wait(1000)
						sampSendChat('/m ������ � ��� ������ ���� �������.') 
					end)
				end
				if imgui.IsItemHovered() then
					local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
					imgui.BeginTooltip()
					imgui.CenterText(u8'��� ��������� "����������� �����������"')
					imgui.Separator()
					imgui.CenterText(u8'����� ��������')
					imgui.Separator()
					imgui.Text(u8'���� ��:\n���-�� � LS ���������� �������, ������� �� ������ �����.\n���� �� ����� ������ ������� - ������ ��� � /sms [ID: '..myID..']')
					imgui.Text(u8'�� ������ ����� ����� �� � ������ ������ �������.\n������� ��:\n��������� ����, ���. ����������� � ��������� ����� ������ �������.\n����� �����/������.\n������ � ��� ������ ���� �������.')
					imgui.EndTooltip()
				end
				imgui.EndChild()
			end
		end
		imgui.PopFont()
	elseif menuSwitch == 3 then
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 695, 235
		imgui.PushFont(myFont) 
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'���������', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.BeginChild('##settings1', imgui.ImVec2(300,195), 0)
		if ad.ToggleButton(u8'Login', elements.value.autologin) then
			config['settings']['autologin'] = elements.value.autologin[0]
			saveConfig()
		end imgui.TextQuestion(u8'�������������� ���� ��� �������')
		if ad.ToggleButton(u8'Alogin', elements.value.autoalogin) then
			config['settings']['autoalogin'] = elements.value.autoalogin[0]
			saveConfig()
		end imgui.TextQuestion(u8'�������������� ���� ��� �������')
		if ad.ToggleButton(u8'TEMPLEADER ��� �����', elements.value.autoleader) then
			config['settings']['autoleader'] = elements.value.autoleader[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ����� ��� ������� �������� ��� ��������� �������')
		if ad.ToggleButton(u8'AGM ��� �����', elements.value.autogm) then
			config['settings']['autogm'] = elements.value.autogm[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ����� ��� ������� ���������� /agm')
		if ad.ToggleButton(u8'CONNECT ��� �����', elements.value.autoconnect) then
			config['settings']['autoconnect'] = elements.value.autoconnect[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ����� ��� ������� ���������� /connect')
		if ad.ToggleButton(u8'����������� ��� ����� ��� �������', elements.value.ahi) then 
			config['settings']['ahi'] = elements.value.ahi[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ����� ��� ������� ���������������� ���� �����������')
		if ad.ToggleButton(u8'����������� ���', elements.value.shortadm) then 
			config['settings']['shortadm'] = elements.value.shortadm[0]
			saveConfig()
		end imgui.TextQuestion(u8'�������� "�������������" �� "A:" � ����������� ��������')
		if ad.ToggleButton(u8'����-�������� pgetip �� getip', elements.value.pgetip) then
			config['settings']['pgetip'] = elements.value.pgetip[0]
			saveConfig()
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##settings2', imgui.ImVec2(350,195), 0)
		imgui.PushItemWidth(150)
		if imgui.InputText(u8'##pass', elements.buffer.password, 32, imgui.InputTextFlags.Password) then
			config['settings']['password'] = str(elements.buffer.password)
			saveConfig()
		end
		if imgui.InputText(u8'##apass', elements.buffer.apassword, 16, imgui.InputTextFlags.Password) then
			config['settings']['apassword'] = str(elements.buffer.apassword)
			saveConfig()
		end
		if imgui.ComboStr('##autoleader', elements.value.leaderid, autoleaderCombo .. '\0', -1) then
			config['settings']['leaderid'] = elements.value.leaderid[0]+1
	        saveConfig()
		end
		if ad.ToggleButton(u8'EARS ��� �����', elements.value.autoears) then
			config['settings']['autoears'] = elements.value.autoears[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ���� ��� ������� ���������� /ears')
		if ad.ToggleButton(u8'AINFO ��� �����', elements.value.autoainfo) then
			config['settings']['autoainfo'] = elements.value.autoainfo[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ����� ��� ������� ����������� /ainfo')
		if ad.ToggleButton(u8'�������������� �� � ����� ��� AFK', elements.value.akv) then
			config['settings']['akv'] = elements.value.akv[0]
			saveConfig()
		end imgui.TextQuestion(u8'����� ����� ��� ������� ���������������� � /inter 72') 
		if ad.ToggleButton(u8'MSG-���������', elements.value.msginfo) then
			config['settings']['msginfo'] = elements.value.msginfo[0]
			saveConfig()
		end imgui.TextQuestion(u8'�����������: /amsg [1-2]')
		imgui.PopItemWidth()
		imgui.EndChild()
		imgui.PopFont()
	elseif menuSwitch == 4 then
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 695, 240
		imgui.PushFont(myFont)
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'������ ���������', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.SetCursorPos(imgui.ImVec2(10, 30))
		imgui.BeginChild('Nakaz##1'..warn_navigation.current, imgui.ImVec2(140,105), false)
		for i, title in ipairs(warn_navigation.list) do
			if HeaderButton(warn_navigation.current == i, title) then
				warn_navigation.current = i
			end
		end
		imgui.EndChild()
		imgui.SameLine(145)
		imgui.BeginChild('Nakaz##2', imgui.ImVec2(540,200), 0)
		if warn_navigation.current == 1 then
			imgui.InputTextWithHint(u8'##333', u8'������� nickname', input_nameawarn, sizeof(input_nameawarn))
			imgui.TextQuestionMp(u8'������� ��� � �������� ���� �������')
			if imgui.CollapsingHeader(u8'������ ���������') then
				if imgui.Button(u8'1. ������������� ������� � ���, � ������� �������/��������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 1')
				end
				if imgui.Button(u8'2. DM ������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 2')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 2')
					end)
				end
				if imgui.Button(u8'3. �������� ��������� �� ���� ������������� ��������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 3')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 3')
					end)
				end
				if imgui.Button(u8'4. ��������� ������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 4')
				end
				if imgui.Button(u8'5. ����������� ���������������/������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 5')
				end
				if imgui.Button(u8'6. �������/������� ����-���� � /a � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 6')
				end
				if imgui.Button(u8'7. ������ ������ ��������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 7')
				end
				if imgui.Button(u8'8. �������/������� � ������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 8')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 8')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 8')
					end)
				end
				if imgui.Button(u8'9. ������ � /msg � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 9')
				end
				if imgui.Button(u8'10. ���� ����-���� �� �������/��������������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 10')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 10')
					end)
				end
				if imgui.Button(u8'11. ������/�������� � �� ������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 11')
				end
				if imgui.Button(u8'12. �������� ������� �� ���� ����� ����� ��� ������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 12')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 12')
					end)
				end
				if imgui.Button(u8'13. ���������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 13')
				end
				if imgui.Button(u8'14. ������������� ����� ������ ������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 14')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 14')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 14')
					end)
				end
				if imgui.Button(u8'15. ������ ��������� �� ������� ������� �������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 15')
				end
				if imgui.Button(u8'16. ������� ����� 1 ����� �������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 16')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 16')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 16')
					end)
				end
				if imgui.Button(u8'17. ������ ��������� �� SMS ������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 17')
				end
				if imgui.Button(u8'18. ������ ��������� �� �� ������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 18')
				end
				if imgui.Button(u8'19. �������� ��������� � ������') then 
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 19')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 19')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 19')
					end)
				end
				if imgui.Button(u8'20. ������������ ������ ������ �� ������ � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 20', -1)
				end
				if imgui.Button(u8'21. ������ �������� � ����� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 21', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 21', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 21', -1)
					end)
				end
				if imgui.Button(u8'22. ���������� �������� �� ������ � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 22', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 22', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 22', -1)
					end)
				end
				if imgui.Button(u8'23. ������ ��������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 23', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 23', -1)
					end)
				end
				if imgui.Button(u8'24. ��������� ������ ������������� 3+ ��� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 24', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 24', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 24', -1)
					end)
				end
				if imgui.Button(u8'25. ���. ������� ������������� � ����������/���. �� ����� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 25', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 25', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 25', -1)
					end)
				end
				if imgui.Button(u8'26. ������������ ��������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 26', -1)
				end
				if imgui.Button(u8'27. ������ ��������������� ����� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 27', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 27', -1)
					end)
				end
				if imgui.Button(u8'28. ��������������� ��������� �������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 28', -1)
				end
				if imgui.Button(u8'29. ��������������� ������ � /a /v � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 29', -1)
				end
				if imgui.Button(u8'30. ������ �� �����/������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 30', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 30', -1)
					end)
				end
				if imgui.Button(u8'31. ���� ����������/�������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 31', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 31', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
					end)
				end
				if imgui.Button(u8'32. ����������� ��� ������� ������ � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
					end)
				end
				if imgui.Button(u8'33. ��������� ��������� � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 33', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 33', -1)
					end)
				end
				if imgui.Button(u8'34. ������������� ����� ������� ��� ��������� ������������ ������ � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 34', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 34', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 34', -1)
					end)
				end
				if imgui.Button(u8'35. ��������� ������ �������� ����� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 35', -1)
				end
				if imgui.Button(u8'36. ����������� ������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 36', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 36', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 36', -1)
					end)
				end
				if imgui.Button(u8'37. ������������� /pm � ������ ����� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 37', -1)
				end
				if imgui.Button(u8'38. ���� �����-��������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 38', -1)
				end
				if imgui.Button(u8'39. ���. ����.�����/����.���� � ������� ������ �������/��� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 39', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 39', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 39', -1)
					end)
				end
				if imgui.Button(u8'40. �����������/���������� ������������� ��� ����� ����������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 40', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 40', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 40', -1)
					end)
				end
				if imgui.Button(u8'41. ����/���� � ���, � ������� �������/��������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 41', -1)
				end
				if imgui.Button(u8'42. �������� ������ ��������� ������/�������������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 42', -1)
				end
				if imgui.Button(u8'43. �������� ������������ ������ �� ������ � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 43', -1)
				end
				if imgui.Button(u8'44. ������� ��������� �� �������� ������ � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 44', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 44', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 44', -1)
					end)
				end
				if imgui.Button(u8'45. ���� ��������� ������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 45', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 45', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 45', -1)
					end)
				end
				if imgui.Button(u8'46. �������/��������/����� �������� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 46', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 46', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 46', -1)
					end)
				end
				if imgui.Button(u8'47. NonRP ������ | ������ | ������ /try � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 47', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 47', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 47', -1)
					end)
				end
				if imgui.Button(u8'48. NonRP NickName � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 48', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 48', -1)
					end)
				end
				if imgui.Button(u8'49. ���� ���� � ������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 49', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 49', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 49', -1)
					end)
				end
				if imgui.Button(u8'50. �������������� ����� ������ � 2 ��������') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 50', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 50', -1)
					end)
				end
				if imgui.Button(u8'51. ������ ��������� � �������� �������� � 1 �������') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 51', -1)
				end				
			end
		elseif warn_navigation.current == 2 then
			imgui.InputTextWithHint(u8'##444', u8'������� nickname', input_namelwarn, sizeof(input_namelwarn))
			imgui.TextQuestionMp(u8'������� ��� � �������� ���� �������')
			if imgui.CollapsingHeader(u8'������ �������') then
				if imgui.Button(u8'������� 24+ �����') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ������� 24+ �����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� 24+ �����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� 24+ �����', -1)
					end)
				end
				if imgui.Button(u8'����� ������� ��������� �� ���� 1 ���.') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ��� ����� ������� 1 ���.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ��� ����� ������� 1 ���.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ��� ����� ������� 1 ���.', -1)
					end)
				end
				if imgui.Button(u8'���������� ������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ���������� ������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���������� ������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���������� ������', -1)
					end)
				end
				if imgui.Button(u8'���������') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' ���������')
				end
			end
			if imgui.CollapsingHeader(u8'��� ��/���') then
				if imgui.Button(u8'[���. ���������] ���������� ������ 1/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ���������� ������ 1/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ���������� ������ 1/3', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'[���. ���������] �������� ����� 1/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' �������� ����� 1/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' �������� ����� 1/4', -1)
						end)
					end
					if imgui.Button(u8'[���. ���������] ���������� ������ 2/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ���������� ������ 2/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ���������� ������ 2/3', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'[���. ���������] �������� ����� 2/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' �������� ����� 2/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' �������� ����� 2/4', -1)
						end)
					end
					if imgui.Button(u8'[���. ���������] ���������� ������ 3/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ���������� ������ 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ���������� ������ 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ���������� ������ 3/3', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'[���. ���������] �������� ����� 3/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' �������� ����� 3/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' �������� ����� 3/4', -1)
						end)
					end
					if imgui.Button(u8'[���. ���������] �������� ����� 4/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' �������� ����� 4/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' �������� ����� 4/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' �������� ����� 4/4', -1)
						end)
					end
					if imgui.Button(u8'[���. ���������] ����� �� �������� ������� � ���������� ������������') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ����� �� �������� ������� � ���������� ������������', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ����� �� �������� ������� � ���������� ������������', -1)
						end)
					end
					if imgui.Button(u8'[����� | �����] ����� ���� �������� �� ���� 1/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 1/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 1/3', -1)
						end)
					end
					if imgui.Button(u8'[����� | �����] ����� ���� �������� �� ���� 2/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 2/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 2/3', -1)
						end)
					end
					if imgui.Button(u8'[����� | �����] ����� ���� �������� �� ���� 3/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' ����� ���� �������� �� ���� 3/3', -1)
						end)
					end
				end
			if imgui.CollapsingHeader(u8'������ ���������') then
				if imgui.Button(u8'���������') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' ���������')
				end
				if imgui.Button(u8'������������ ��������� �� ������') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' ������������ ��������� �� ������')
				end
				if imgui.Button(u8'���������� ������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ���������� ������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���������� ������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���������� ������', -1)
					end)
				end
				if imgui.Button(u8'DeathMatch') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' DeathMatch')
				end
				if imgui.Button(u8'DriveBy') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' DriveBy')
				end
				if imgui.Button(u8'TeamKill') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' TeamKill')
				end
				if imgui.Button(u8'SpawnKill') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' SpawnKill')
				end
				if imgui.Button(u8'���������� ��� ������') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' ���������� ��� ������')
				end
				if imgui.Button(u8'�������� ������ � NonRP ����� � �����������') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' �������� ������ � NonRP ����� � �����������')
				end
				if imgui.Button(u8'NonRP') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' NonRP')
				end
				if imgui.Button(u8'�������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������', -1)
					end)
				end
				if imgui.Button(u8'������� (�� 5+ �������)') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������', -1)
					end)
				end
				if imgui.Button(u8'����') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ����', -1)
					end)
				end
				if imgui.Button(u8'���� � �������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ���� � �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� � �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� � �������', -1)
					end)
				end
				if imgui.Button(u8'����') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' ����')
				end
				if imgui.Button(u8'����� ������� ��������� �� ���� 1 ���.') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ��� ����� ������� 1 ���.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ��� ����� ������� 1 ���.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ��� ����� ������� 1 ���.', -1)
					end)
				end
				if imgui.Button(u8'������� 24+ �����') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ������� 24+ �����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� 24+ �����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� 24+ �����', -1)
					end)
				end
				if imgui.Button(u8'NonRP �������� ������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' NonRP �������� ������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' NonRP �������� ������', -1)
					end)
				end
				if imgui.Button(u8'���� ����������/��������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ���� ����������/��������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� ����������/��������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� ����������/��������', -1)
					end)
				end
				if imgui.Button(u8'������� ����� ����� �������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ������� ����� ����� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� ����� ����� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� ����� ����� �������', -1)
					end)
				end
				if imgui.Button(u8'�������/������� �������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' �������/������� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������/������� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������/������� �������', -1)
					end)
				end
				if imgui.Button(u8'������� �����') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ������� �����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� �����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������� �����', -1)
					end)
				end
				if imgui.Button(u8'���� � ������� �� ��������������� �����/�����') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ���� � ������� �� ��������������� �����/�����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� � ������� �� ��������������� �����/�����', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� � ������� �� ��������������� �����/�����', -1)
					end)
				end
				if imgui.Button(u8'�������� ���������� ����� �� ����� �������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' �������� ���������� ����� �� ����� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������� ���������� ����� �� ����� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' �������� ���������� ����� �� ����� �������', -1)
					end)
				end
				if imgui.Button(u8'������ ��������������� �����, � ��� ����� �������� ������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ������', -1)
					end)
				end
				if imgui.Button(u8'���� �����/�������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ���� �����/�������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� �����/�������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ���� �����/�������', -1)
					end)
				end
				if imgui.Button(u8'����������� �������') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' ����������� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ����������� �������', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' ����������� �������', -1)
					end)
				end
			end
		elseif warn_navigation.current == 3 then
			imgui.InputTextWithHint(u8'##555', u8'������� nickname', input_nameswarn, sizeof(input_nameswarn))
			if imgui.CollapsingHeader(u8'��� ��/���') then
			if imgui.Button(u8'������� 0 ������� �� ����� ��������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ������� 0 ������� �� ����� ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������� 0 ������� �� ����� ��������')
				end)
				end
			end
			if imgui.CollapsingHeader(u8'������ ���������') then
				if imgui.Button(u8'�������� ����� ������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' �������� ����� ������')
				end
				if imgui.Button(u8'������������� ������� ��� ������� � ������ �����') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ������������� ������� ��� ������� � ������ �����')
				end
				if imgui.Button(u8'����� ��������� ������ ������� �� ������� �������� �������� (DM/�����������/���������)') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ��������� ������ ������� �� ������� �������� ��������')
				end
				if imgui.Button(u8'��������� ���� ��������� (�������/�������/����)') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ��������� ���� ���������')
				end
				if imgui.Button(u8'������������� ������� �������� ��������� �� ����������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ������������� ������� �������� ��������� �� ����������')
				end
				if imgui.Button(u8'������ ���������� �������, �� ���� ������������� ���������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ������ ���������� �������, �� ���� ������������� ���������')
				end
				if imgui.Button(u8'������� ������ � ������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ������� ������ � ������')
				end
				if imgui.Button(u8'���������� ������������� ��� ������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ���������� ������������� ��� ������')
				end
				if imgui.Button(u8'������������� ������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' ������������� ������')
				end
				if imgui.Button(u8'�������� � ������ ������ � ������') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' �������� � ������ ������ � ������')
				end
				if imgui.Button(u8'���������������� � ���� ����������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ���������������� � ���� ����������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ���������������� � ���� ����������')
				end)
				end
				if imgui.Button(u8'���������������� � ������ ������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ���������������� � ������ ������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ���������������� � ������ ������')
				end)
				end
				if imgui.Button(u8'�������������� ����� ������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' �������������� ����� ������')
					wait(1300)
					sampSendChat('/swarn '..sname..' �������������� ����� ������')
				end)
				end
				if imgui.Button(u8'���������� ����� ����������� ������� �� ����� (1 ���)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ���������� ����� ����������� ������� �� ����� (1 ���)')
					wait(1300)
					sampSendChat('/swarn '..sname..' ���������� ����� ����������� ������� �� ����� (1 ���)')
					wait(1300)
					sampSendChat('/swarn '..sname..' ���������� ����� ����������� ������� �� ����� (1 ���)')
				end)
				end
				if imgui.Button(u8'������������ � ������� 24 �����') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ������������ � ������� 24 �����')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������ � ������� 24 �����')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������ � ������� 24 �����')
				end)
				end
				if imgui.Button(u8'����������� ������ � ������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ����������� ������ � ������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� ������ � ������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� ������ � ������')
				end)
				end
				if imgui.Button(u8'����������� ������ � ���� ���������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ����������� ������ � ���� ���������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� ������ � ���� ���������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� ������ � ���� ���������')
				end)
				end
				if imgui.Button(u8'�������� �������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' �������� �������')
					wait(1300)
					sampSendChat('/swarn '..sname..' �������� �������')
					wait(1300)
					sampSendChat('/swarn '..sname..' �������� �������')
				end)
				end
				if imgui.Button(u8'����������� ������ � ������������ ��������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ����������� ������ � ������������ ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� ������ � ������������ ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� ������ � ������������ ��������')
				end)
				end
				if imgui.Button(u8'������������ ��������� � ������ (�����������/����/���)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ������������ ��������� � ������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������ ��������� � ������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������ ��������� � ������')
				end)
				end
				if imgui.Button(u8'������������ ��������� � ���� ��������� (�����������/����/���)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ������������ ��������� � ���� ���������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������ ��������� � ���� ���������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������ ��������� � ���� ���������')
				end)
				end
				if imgui.Button(u8'����������� �������� �� ����������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ����������� �������� �� ����������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� �������� �� ����������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ����������� �������� �� ����������')
				end)
				end
				if imgui.Button(u8'NonRP ���') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' NonRP ���')
					wait(1300)
					sampSendChat('/swarn '..sname..' NonRP ���')
					wait(1300)
					sampSendChat('/swarn '..sname..' NonRP ���')
				end)
				end
				if imgui.Button(u8'������������� ����� �� ����� ��������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ������������� ����� �� ����� ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������� ����� �� ����� ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ������������� ����� �� ����� ��������')
				end)
				end
				if imgui.Button(u8'�������������� ������� (�������/����������� ��������)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' �������������� ������� (�������/����������� ��������)')
					wait(1300)
					sampSendChat('/swarn '..sname..' �������������� ������� (�������/����������� ��������)')
					wait(1300)
					sampSendChat('/swarn '..sname..' �������������� ������� (�������/����������� ��������)')
				end)
				end
				if imgui.Button(u8'���� ����� ��������') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' ���� ����� ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ���� ����� ��������')
					wait(1300)
					sampSendChat('/swarn '..sname..' ���� ����� ��������')
				end)
				end
			end
		end
		imgui.EndChild()
		imgui.PopFont()
		elseif menuSwitch == 5 then
			local resX, resY = getScreenResolution()
			local sizeX, sizeY = 505, 200
			imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
			imgui.Begin(u8'������', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			for i = 1, 5 do
				imgui.BeginChild('##flooderChild1', imgui.ImVec2(350, 135), 0)
				imgui.PushItemWidth(350)
				if imgui.InputTextWithHint(u8('##�����'.. i), u8'�����', inputTexts[i], sizeof(inputTexts[i])) then end
				imgui.PopItemWidth()
				imgui.EndChild()
				imgui.SameLine()
				imgui.BeginChild('##flooderChild2', imgui.ImVec2(80, 135), 0)
				imgui.PushItemWidth(75)
				if imgui.InputTextWithHint(u8('##��������'.. i), u8'��������', inputDelays[i], sizeof(inputDelays[i]), imgui.InputTextFlags.CharsDecimal) then end
				imgui.PopItemWidth()
				imgui.EndChild()
				imgui.SameLine()
				imgui.BeginChild('##FlooderChild3', imgui.ImVec2(40, 135), 0)
				if ad.ToggleButton(u8('##�������'.. i), inputButtons[i]) then 
					floodActive[i] = inputButtons[i][0]
					if floodActive[i] then
						lua_thread.create(function() floodLogic(i) end)
					end
				end
				imgui.EndChild()
			end
			imgui.NewLine()
			if imgui.Button(u8'��������� �����', imgui.ImVec2(470, 0)) then
				saveTextToJson()
			end
		elseif menuSwitch == 6 then
			local resX, resY = getScreenResolution()
			local sizeX, sizeY = 695, 235
			imgui.PushFont(myFont) 
			imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
			imgui.Begin(u8'������', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.BeginChild('##otherSettings1', imgui.ImVec2(300,195), 0)
			if ad.ToggleButton(u8'ChatID', elements.value.chatID) then
				config['settings']['chatID'] = elements.value.chatID[0]
				saveConfig()
			end imgui.TextQuestion(u8'����� �������� ������������ ID')
			if ad.ToggleButton(u8'Anti-AFK', elements.value.antiafk) then
			afk = not afk
			config['settings']['antiafk'] = elements.value.antiafk[0]
			saveConfig()
			end
			if ad.ToggleButton(u8'������� ���� �����', elements.value.fastnicks) then
				config['settings']['fastnicks'] = elements.value.fastnicks[0]
				saveConfig()
			end imgui.TextQuestion(u8'@id = ���')
			imgui.PushItemWidth(275)
			if imgui.Combo(u8'',colorListNumber,colorListBuffer, #colorList) then
				theme[colorListNumber[0]+1].change()
				ini.styleTheme.theme = colorListNumber[0]
				inicfg.save(ini, directIni)
			end
			imgui.PopItemWidth()
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('##settings2', imgui.ImVec2(350,195), 0)
			if ad.ToggleButton(u8'������������ ��������', elements.value.ftp) then
				config['settings']['ftp'] = elements.value.ftp[0]
				saveConfig()
			end imgui.TextQuestion(u8'����������� ������������� �� �����')
			if ad.ToggleButton(u8'�������� ���������� �����', elements.value.dellServerMessages) then
				config['settings']['dellServerMessages'] = elements.value.dellServerMessages[0]
				saveConfig()
			end imgui.TextQuestion(u8'�������� Ace_Will, SAN � �.�')
			if ad.ToggleButton(u8'���������� �������� �����������', elements.value.dellacces) then
				config['settings']['dellacces'] = elements.value.dellacces[0]
				saveConfig()
			end
			imgui.EndChild()
			imgui.PopFont()
		end
	imgui.End()
end)

local setFrame = imgui.OnFrame(function() return setWindow[0] and not isGamePaused() end, function()
	imgui.PushFont(myFont)
	local resX, resY = getScreenResolution()
	local sizeX, sizeY = 415, 275
	imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
    imgui.Begin(u8'������/������ ���������', setWindow, imgui.WindowFlags.NoResize)
	imgui.BeginChild('lName##', imgui.ImVec2(399,235), true)
	imgui.PushItemWidth(155) 
	imgui.CenterText(u8'���������')
	imgui.Separator()
	imgui.Text(u8'������� ID ������:')
	imgui.SameLine()
	imgui.InputTextWithHint(u8'������: 0', u8'������� ��������', input_setleader, sizeof(input_setleader), imgui.InputTextFlags.CharsDecimal)
	if imgui.ComboStr(u8'', selected, comboStr .. '\0', -1) then
        print('Selected frac name', fracNames[selected[0] + 1][2]);
    end
    imgui.SliderInt(u8'�������� ����', SliderOne, 1, 311)
    imgui.PopItemWidth()
    if imgui.Button(u8"��������� �� ��������� ������##1") then
        local lead = str(input_setleader)
        if selected[0] ~= 0 and lead ~= '' and tonumber(lead) > 0 then
            local fracID = fracNames[selected[0] + 1][1] 
            sampSendChat('/setleader '..lead..' '..fracID..' '..SliderOne[0])
        else
            sampAddChatMessage('[������]: {ffffff}�������� ��� ������ ��� ������ ���������', 0xFF6600)
        end
    end
	imgui.Separator()
	imgui.CenterText(u8'�������')
	imgui.Separator()
	imgui.Text(u8'������� ID (+ | -)')
	imgui.SameLine()
	imgui.PushItemWidth(155)
	imgui.InputTextWithHint(u8'##2', u8'������� ��������', input_setsupport, sizeof(input_setsupport), imgui.InputTextFlags.CharsDecimal)
	imgui.PopItemWidth()
	imgui.SameLine()
	imgui.Text(u8'������: 303 +')
	if imgui.Button(u8"���������/�������� ��������� ��������##2") then
		sampSendChat('/setsupport '..u8:decode(str(input_setsupport)))
	end
	imgui.EndChild()
	imgui.End()
	imgui.PopFont()
end)


function event.onShowDialog(dialogId, style, title, button1, button2, text)
	if config['settings']['autologin'] and dialogId == 2 then
		sampSendDialogResponse(2, 1, -1, config['settings']['password'])
		return false
	end 
	if config['settings']['autoalogin'] and dialogId == 2934 then
		apopen = false
		sampSendDialogResponse(2934, 1, -1, config['settings']['apassword'])
		return false
	end
	if not apopen and dialogId == 8024 then
		apopen = true
		sampSendDialogResponse(8024, 0, -1, '')
		return false
	end
end
function saveConfig()
	conf = io.open(directConfig, 'w')
	conf:write(encodeJson(config))
	conf:close()
end

function event.onSendMapMarker(position)
	if elements.value.ftp[0] then
    setCharCoordinates(PLAYER_PED, position.x, position.y, position.z)
	end
end

----------------- ONSERVERMESSAGE -----------------

-- sampRegisterChatCommand('banipid', function(text)
--     -- ��������� ��������� ������ �� ��������� (ID, ��� � �������)
--     local id, days, reason = text:match("^(%d+)%s+(%d+)%s+(.+)$")
    
--     -- �������� �� ������������ ����������
--     if not id or not days or not reason then
--         sampAddChatMessage("�������� ������ �������! �������������: /banipid [ID ������] [����] [�������]", -1)
--         return
--     end

--     -- ���������� ������� �� ��������� IP ������
--     sampSendChat('/getip ' .. id)

--     -- ������� ���������� ��� �������� IP
--     local ip = nil

--     -- ������� ����� ��� �������� ����� ����������� ���-��������
--     lua_thread.create(function()
--         local timeout = 5000  -- ������������ ����� �������� � ������������� (5 ������)
--         local startTime = os.clock()

--         -- ������� ����� �� ������� /getip
--         while os.clock() - startTime < timeout do
--             wait(100)  -- ����� ����� ��������� ������ ��������
--         end

--         -- ���� IP ������, ��������� ������� ���
--         if ip then
--             sampAddChatMessage(string.format('/banip %s %s %s', ip, days, reason), -1)
--         else
--             sampAddChatMessage("�� ������� �������� IP ��� ������ � ID " .. id, -1)
--         end
--     end)
-- end)



function event.onServerMessage(color, text)
	-- local ip = text:match("IP %[%d+.%d+.%d+.%d+%]")
    -- if ip then
    --     ip = ip
    -- end
	if elements.value.pgetip[0] then
		if text:find("R%-IP %[%d+.%d+.%d+.%d+%]  IP %[%d+.%d+.%d+.%d+%]") then
			local rip, ip = text:match("R%-IP %[(%d+%.%d+%.%d+%.%d+)%].-IP %[(%d+%.%d+%.%d+%.%d+)%]")
			if ip then
				lua_thread.create(function()
					wait(700)
					print(ip)
					sampSendChat('/pgetip '.. ip)
				end)
			end
		end
	end
	if elements.value.dellServerMessages[0] then
		for _, val in ipairs(delltext) do
			if string.find(text, val) then
			return false
			end
		end
	end
	if text:find('^�� ����� ��� .*') and not text:find('������') then
		lua_thread.create(function()
			wait(1100)

			if config['settings']['autogm'] then sampSendChat('/agm') end
			if config['settings']['autoleader'] then
			if config['settings']['autogm'] then wait(1100) end sampSendChat('/templeader '..fracNames[config['settings']['leaderid']][1]+1) end
			if config['settings']['autoears'] then
			if config['settings']['autoleader'] or config['settings']['autogm'] then wait(1100) end sampSendChat('/ears') end
			if config['settings']['autoconnect'] then
			if config['settings']['akv'] or config['settings']['autogm'] or config['settings']['autoleader'] or config['settings']['autoears'] then wait(1100) end sampSendChat('/connect') end
			if config['settings']['akv'] then
			if config['settings']['autoainfo'] or config['settings']['autogm'] or config['settings']['autoleader'] or config['settings']['autoears'] then wait(1100) end sampSendChat('/inter 72') end
			if config['settings']['autoainfo'] then
			if config['settings']['autoconnect'] or config['settings']['autogm'] or config['settings']['autoleader'] or config['settings']['autoears'] then wait(1100) end sampSendChat('/ainfo') end
		end)
	end
	if elements.value.shortadm[0] then
		if text:find("^������������� (%w+_%w+) ���") or text:find("^������������� (%w+_%w+)%[(%d+)%] ���") then
			local pmtext = text:gsub("�������������", "A:")
			sampAddChatMessage(pmtext, 0xFF9945)
			return false
		end
		if text:find("^������������� (%w+_%w+) �������") or text:find("^������������� (%w+_%w+) ������������ ������") or text:find("^������������� (%w+_%w+) ������") or text:find("^������������� (%w+_%w+) ����� ��������������") or text:find("^������������� (%w+_%w+) ����� �������") or text:find("^������������� (%w+_%w+) ��������") or text:find("^������������� (%w+_%w+) ����") or text:find("^������������� (%w+_%w+) ������� .*") or text:find("^������������� (%w+_%w+)%[(%d+)%] �������") or text:find("^������������� (%w+_%w+)%[(%d+)%] ������������ ������") or text:find("^������������� (%w+_%w+)%[(%d+)%] ������") or text:find("^������������� (%w+_%w+)%[(%d+)%] ����� ��������������") or text:find("^������������� (%w+_%w+)%[(%d+)%] ����� �������") or text:find("^������������� (%w+_%w+)%[(%d+)%] ��������") or text:find("^������������� (%w+_%w+)%[(%d+)%] ����") or text:find("^������������� (%w+_%w+)%[(%d+)%] ������� .*") then
			local ttext = text:gsub("�������������", "A:")
			sampAddChatMessage(ttext, 0xff5030)
			return false
		end
		if text:find("^����������� ����������� .*") then 
			local omptext = text:gsub("����������� �����������", "���")
			sampAddChatMessage(omptext, 0xffcc00)
			return false
		end
		if text:find("^������� ������������� .*") then 
			local gatext = text:gsub("������� �������������", "��")
			sampAddChatMessage(gatext, 0xffcc00)
			return false
		end
		if text:find("^�������� �.� .*") then 
			local gatext = text:gsub("�������� �.�", "���")
			sampAddChatMessage(gatext, 0xffcc00)
			return false
		end
	end
	if elements.value.getblock[0] then 
		if text:find('^%���� ����� �������� �������� �������������') then
			lua_thread.create(function()
				wait(100)
				sampSendChat('/a [�����]: � ������� �����. ���/���/��/����������, ������� ��� ���������� ������� ��������.')
			end)
		end
	end
	if elements.value.reloginblock[0] then
		if text:find('^%���� ����� �������� �������� �������������') then
			local ip, port = sampGetCurrentServerAddress()
			if ip and port then
				sampConnectToServer(ip, port)
			end
		end
	end
    if elements.value.atp[0] then
        if text:find('^�� ����� ��� .*') and not text:find('^�� ����� ��� ������') then
			local t = math.random(123456, 654321)
			lua_thread.create(function()
				wait(3500)
				sampSendChat('/setint 0')
				wait(1000)
				sampSendChat('/setvw '..t)
				setCharCoordinates(1, 1203.4425048828, -941.47076416016, 42.744152069092)
        	end) 
		end
    end
    if elements.value.ahi[0] then
        if text:find('^�� ����� ��� .*') and not text:find('^�� ����� ��� ������') then
			local audio = loadAudioStream('https://github.com/DeffoMansory/dungeon-master/raw/refs/heads/main/winDownload.mp3')
			setAudioStreamState(audio, 1)
        end    
    end
	if elements.value.chatID[0] then
	    for nickname in text:gmatch('(%w+_%w+)') do
	    	if not text:find(nickname..'%[%d+%]') and not text:find(nickname..')')  then
	    		local nid = 1000
		    	for i=0, 299 do
					if sampIsPlayerConnected(i) then
						if sampGetPlayerNickname(i) == nickname then
							nid = i
							break
						end
					end
				end
				if nid ~= 1000 then
					text = text:gsub(nickname, nickname..'['..tostring(nid)..']')
				end
	    	end
	    end 
	    for nickname in text:gmatch('(%w+)') do
	    	if not text:find(nickname..'%[%d+%]') and not text:find(nickname..')') then
	    		local nid = 1000
		    	for i=0, 299 do
					if sampIsPlayerConnected(i) then
						if sampGetPlayerNickname(i) == nickname then
							nid = i
							break
						end
					end
				end
				if nid ~= 1000 then
					text = text:gsub(nickname, nickname..'['..tostring(nid)..']')
				end
	    	end
	    end 
	    return {color, text}
  	end
end
----------------- ONSERVERMESSAGE -----------------

----------------- ONSENDCHAT -----------------
function event.onSendChat(message)
    if message:sub(1, 1) == '!' then
        local command = message:sub(2) -- ������� ������ "!"
        if command == 'alh' then
            -- sampAddChatMessage('������� ���� ���������� ����� !text')
			menu[0] = not menu[0]
            return false -- �������� �������� ������������� ������ � ���
        end
    end
	if elements.value.fastnicks[0] then
		for i in message:gmatch('@(%d+)') do 
			if sampIsPlayerConnected(tonumber(i)) and message:match('(@%d+)') ~= nil then
				message = message:gsub(message:match('(@%d+)'), sampGetPlayerNickname(tonumber(i)))
			end
		end
		return {message}
	end
end
----------------- ONSENDCHAT -----------------
sampRegisterChatCommand('amsg', function(param)
	if elements.value.msginfo[0] then
		if param == '' then
			sampAddChatMessage('[All Helper]: {ffffff}����������� /amsg [1-3]', 0x696969)
		end
		if param == '1' then
			lua_thread.create(function()
				for i, line in ipairs(amsg1) do
					sampSendChat(line[1])  -- ������� ���������
					wait(1200)  -- �������� � 1500 ����������� (1.5 �������)
				end
			end)
		end
		if param == '2' then
			lua_thread.create(function()
				for i, line in ipairs(amsg2) do
					sampSendChat(line[1])  -- ������� ���������
					wait(1200)  -- �������� � 1500 ����������� (1.5 �������)
				end
			end)
		end
	end
end)
----------------- ONSENDCOMMAND -----------------
function event.onSendCommand(command)
	if elements.value.fastnicks[0] then
		for i in command:gmatch('@(%d+)') do 
			if sampIsPlayerConnected(tonumber(i)) and command:match('(@%d+)') ~= nil then
				command = command:gsub(command:match('(@%d+)'), sampGetPlayerNickname(tonumber(i)))
			end
		end
	end
	return {command}
end
----------------- ONSENDCOMMAND -----------------

function event.onSetPlayerAttachedObject(playerId, index, create, object) 
	if elements.value.dellacces[0] then
		if (object.bone == 5) or (object.bone == 6) then 
			return {playerId, index, create, object}
		else
			if #WhiteAccessories > 0 then
				for _, val in ipairs(WhiteAccessories) do
					if (object.modelId == val) then 
						return {playerId, index, create, object}
					else
						if (create == true) then 
							return false;
						else
							return {playerId, index, create, object}
						end
					end 
				end
			else
				if (create == true) then 
					return false;
				else
					return {playerId, index, create, object}
				end
			end
		end
	end
end

--------- MAIN -----------------
function main()
	while not isSampAvailable() do wait(0) end
    -- local lastver = update():getLastVersion()
    -- sampAddChatMessage('������ ��������, ������: '..lastver, -1)
    -- if thisScript().version ~= lastver then
    --     sampRegisterChatCommand('scriptupd', function()
    --         update():download()
    --     end)
    --     sampAddChatMessage('����� ���������� ������� ('..thisScript().version..' -> '..lastver..'), ������� /scriptupd ��� ����������!', -1)
    -- end
	
	repeat wait(0) until isSampAvailable()
	
	local url = 'https://pastebin.com/raw/hRVDc6Ey'
    local request = require('requests').get(url)
    local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    
    local function res()
        for n in request.text:gmatch('[^\r\n]+') do
            if nick:find(n) then return true end
        end
        return false
    end

	if request.text and request.text ~= "" then
        nickList = {}
        for n in request.text:gmatch('[^\r\n]+') do
            table.insert(nickList, n)
        end
    end

    -- if not res() then
    --     sampAddChatMessage('[All Helper]: {ffffff}������: ��� ��� ����������� � ������! ������ ��������.', 0x696969)
    --     sampAddChatMessage('[All Helper]: {ffffff}������: ����� ������������ ������ - ������� ������� ��������������� ��� ������ ���������������� ������.', 0x696969)
    --     sampAddChatMessage('[All Helper]: {ffffff}������: ������ ������ ����� � vk.com/number1241. ����: ����������.', 0x696969)
    --     thisScript():unload()
    --     return
    -- end
	
    local ip, port = sampGetCurrentServerAddress()
    local ipport = ip .. ':' .. port
    if ipport ~= '62.122.213.231:7777' then
        sampAddChatMessage('[All Helper]: {ffffff}������: ������ ������ �������� ������ �� Attractive RP � �� �������� �� ������ ��������!', 0x696969)
        sampAddChatMessage('[All Helper]: {ffffff}������: IP Attractive RP: {00aaff}������� - a.attractive-rp.ru:7777 || �������� - 62.122.213.231:7777', 0x696969)
        sampAddChatMessage('[All Helper]: {ffffff}������: ������ ��������.', 0x696969)
        thisScript():unload()
        return
    end

    sampAddChatMessage('[All Helper]: {ffffff}����-�������� �������������� ��������.', 0x696969)
	sampAddChatMessage(string.format('[All Helper]: {ffffff}��� ��� ��������� �����������: /alh (������: %.2f �� %s).', script_version, thisScript().version), 0x696969)
    sampRegisterChatCommand('amp', function() sampSendChat('/mp') end)
	sampRegisterChatCommand('alh', function() menu[0] = not menu[0] end)
	sampRegisterChatCommand('punish', function() punishMenu[0] = not punishMenu[0] end)
	sampRegisterChatCommand('recname', recname_command)
	sampRegisterChatCommand('arec', rec_command)
	sampRegisterChatCommand('pip', pip)
	sampRegisterChatCommand('map', function()
		sampSendChat('/newobj')
	end)
	sampRegisterChatCommand('nl', function()
		sampSendChat('/nolimits')
	end)
    while true do 
        wait(0)
		if not menu[0] and menuSwitch > 0 then
			menuSwitch = 0
			menu[0] = true
		end
        if menu[0] then
            imgui.ShowCursor = true
        else
            imgui.ShowCursor = false
        end
		if not punishMenu[0] and punishSwitch > 0 then
			punishSwitch = 0
			punishMenu[0] = true
		end
        if punishMenu[0] then
            imgui.ShowCursor = true
        else
            imgui.ShowCursor = false
        end
        if wasKeyPressed(VK_O) and not sampIsCursorActive() then
            menu[0] = not menu[0]
        end
        if afk then
            memory.setuint8(7634870, 1, false)
            memory.setuint8(7635034, 1, false)
            memory.fill(7623723, 144, 8, false)
            memory.fill(5499528, 144, 6, false)
        else
            memory.setuint8(7634870, 0, false)
            memory.setuint8(7635034, 0, false)
            memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
            memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
        end
    end -- end while true do
end
----------------- MAIN -----------------
---
function rec_command(param)
    local ip, port = sampGetCurrentServerAddress()
    if ip and port then
        sampConnectToServer(ip, port)
    end
end
function recname_command(param)
    if param == '' then
        sampAddChatMessage('[AllHelper]: {ffffff}����������� /recname [���]', 0x696969)
    else
        sampSetLocalPlayerName(param)
        printStringNow(param, 1000, 0x00FF00)
        local ip, port = sampGetCurrentServerAddress()
        if ip and port then
            sampConnectToServer(ip, port)
        end
    end
end
function rec_command(param)
    local ip, port = sampGetCurrentServerAddress()
    if ip and port then
        sampConnectToServer(ip, port)
    end
end
----------------- WINDOW STYLE -----------------

imgui.OnInitialize(function() 
    theme[colorListNumber[0]+1].change()
	imgui.GetIO().IniFilename = nil
	local config = imgui.ImFontConfig()
	config.MergeMode = true
	config.PixelSnapH = true
	iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	myFont = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/EagleSans-Regular.ttf', 15, nil, iconRanges, glyph_ranges)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
end)
----------------- HEADER BUTTON -----------------
HeaderButton = function(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
		slct = imgui.GetStyle().Colors[imgui.Col.Text]
    }

    if not AI_HEADERBUT then AI_HEADERBUT = {} end
     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    local degrade = function(before, after, start_time, duration)
        local result = before
        local timer = os.clock() - start_time
        if timer >= 0.00 then
            local offs = {
                x = after.x - before.x,
                y = after.y - before.y,
                z = after.z - before.z,
                w = after.w - before.w
            }

            result.x = result.x + ( (offs.x / duration) * timer )
            result.y = result.y + ( (offs.y / duration) * timer )
            result.z = result.z + ( (offs.z / duration) * timer )
            result.w = result.w + ( (offs.w / duration) * timer )
        end
        return result
    end

    local pushFloatTo = function(p1, p2, clock, duration)
        local result = p1
        local timer = os.clock() - clock
        if timer >= 0.00 then
            local offs = p2 - p1
            result = result + ((offs / duration) * timer)
        end
        return result
    end

    local set_alpha = function(color, alpha)
        return imgui.ImVec4(color.x, color.y, color.z, alpha or 1.00)
    end

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
      
        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = imgui.IsItemHovered()
        local clicked = imgui.IsItemClicked()
      
        if pool.h.state ~= hovered and not bool then
            pool.h.state = hovered
            pool.h.clock = os.clock()
        end
      
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = degrade(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = pushFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end
----------------- HEADER BUTTON -----------------

----------------- LINK -----------------
function imgui.Link(link, text)
    text = text or link
    local tSize = imgui.CalcTextSize(text)
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local col = { 0xFFFF7700, 0xFFFF9900 }
    if imgui.InvisibleButton("##" .. link, tSize) then os.execute("explorer " .. link) end
    local color = imgui.IsItemHovered() and col[1] or col[2]
    DL:AddText(p, color, text)
    DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end
----------------- LINK -----------------

----------------- MPTEXTQUESTION -----------------
function imgui.TextQuestionMp(text)
	imgui.SameLine()
	imgui.TextDisabled(u8'�  ��������')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end
----------------- MPTEXTQUESTION -----------------
---
----------------- TEXTQUESTION -----------------
function imgui.TextQuestion(text)
	imgui.SameLine()
	imgui.TextDisabled(u8'(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end
----------------- TEXTQUESTION -----------------

----------------- CENTERTEXT -----------------
function imgui.CenterText(text)
	imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
	imgui.Text(text)
end
----------------- CENTERTEXT -----------------



-- function themeScript()
-- 	local style = imgui.GetStyle()
-- 	local colors = style.Colors

	-- style.Alpha = 1;
	-- style.WindowPadding = imgui.ImVec2(8.00, 8.00);
	-- style.WindowRounding = 0;
	-- style.WindowBorderSize = 1;
	-- style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
	-- style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
	-- style.ChildRounding = 0;
	-- style.ChildBorderSize = 1;
	-- style.PopupRounding = 0;
	-- style.PopupBorderSize = 1;
	-- style.FramePadding = imgui.ImVec2(4.00, 3.00);
	-- style.FrameRounding = 0;
	-- style.FrameBorderSize = 0;
	-- style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
	-- style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
	-- style.IndentSpacing = 21;
	-- style.ScrollbarSize = 14;
	-- style.ScrollbarRounding = 9;
	-- style.GrabMinSize = 10;
	-- style.GrabRounding = 0;
	-- style.TabRounding = 4;
	-- style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
	-- style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);


-- 	colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
-- 	colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
-- 	colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
-- 	colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
-- 	colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
-- 	colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
-- 	colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
-- 	colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
-- 	colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
-- 	colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
-- 	colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
-- 	colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
-- 	colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
-- 	colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
-- 	colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
-- 	colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
-- 	colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
-- 	colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
-- 	colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
-- 	colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
-- 	colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
-- 	colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
-- 	colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
-- 	colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
-- 	colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
-- 	colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
-- 	colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
-- 	colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
-- 	colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
-- 	colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
-- 	colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
-- 	colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
-- 	colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
-- 	colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
-- 	colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
-- 	colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
-- 	colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
-- 	colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
-- end


local punish = {'����� �������',
'',
'- ���� - /warn /jail (�� 1 �� 30 �����)',
'- ����. ���� - ������ � ������ + /ban (1 ����) /banip (�� 7 ����)',
'- DM/DB/SK/TK - /jail (�� 1 �� 15 �����)',
'����������: �������� DM �� ���������� �����',
'- NonRP (��� NonRP cop) - /warn /jail (�� 1 �� 15 �����)',
'- ������/AFK ��� Esc/�� - /kick /jail (�� 1 �� 5 �����)',
'������: ������ ����� �� �������� � �����',
'- NRP NickName - /kick | ���������� � �����������',
'- ���������� ������ � ���� �� ��������� (5+ ���) - /ban (1 ����)',
'����������: ��������� �������� � ��� ������, ���� �������� ����� ������ ���������� ����� 15-�� �����.',
'- NonRP ������/������ ������ ��� �������/������ /try - /ban (�� 14 ����)',
'����������: � ������ ����������� �� ����� �������, ���� ��������� ���������� ������������� �� 2 ��� (������ ��� �� 16 ����, ������ > �� 18 � ��� �����)',
'- ���� ��������� ������� - ������ � ������ + /ban (�� 1 �� 3 ����)',
'������: ���������� ������ ������� � ����� ���������� ���������� ��������� � ����������� ����� ������� � ���.',
'- �������/������� ��������� �� �������� ������ - �������� ���� ���������',
'- �������/��������/����� �������� - /ban (30 ����)',
'- ������������� ���� �� ����� - /ban (�� 1 �� 3 ����)',
'- ������������� ����� ������� � ����� ��������� ������������ ������ - ������ � ������ + /ban � ���������� ���������, ������ �� �������� ��������',
'������: ������/��� ������� �����, ������ ������ � �.�.',
'',
'������� ����:',
'',
'- ������ � ������ - /rmute (�� ���������� ��������������)',
'- Flood/MG/�������� - /mute (�� 1 �� 10 �����)',
'- ������� - /ban /banip /mute (�� ���������� ��������������)',
'- ����������� �������/������ - /mute (�� 1 �� 15 �����)',
'- ����������� ��������������� - /mute (�� ���������� ��������������)',
'- ���������� ������ - /mute (�� ���������� ��������������)',
'����������: ���������� ����� �������������',
'- ����������� ������� ������������� - /mute (30 �����)',
'- ���������� ������ ������� ������������� - /mute (30 �����)',
'- Caps/��� � /ad, /vad, /r, /d � �.� - /mute (�� 1 �� 10 �����)',
'����������: ��� � �� ���, /f /gc /mc /sms',
'- ������ ��������������� ����� - /mute (�� 1 �� 30 �����)',
'- ��������������� ��������� ������ - /mute (�� 1 �� 30 �����)',
'- ����������� ������� - /mute (�� 1 �� 30 �����)',
'- ���� ����-�������� - /mute (�� 1 �� 15 �����)',
'',
'�����:',
'',
'- �������� �������/���������� ����������� ��������������� ����� (������������� �����, ������� � ������������ �������, ����� ��������������� ������� � ������)',
'���������: ���������� �������� �������� (1 ����), ���������� ��������� �������� (30 ����), ������ � ��������, ����������/�����-�����.',
'- �������� �������/���������� ����������� ��������, ������� ���������������� �����. ���������: ���������� ��������� �������� (30 ����), ������ � ��������, ����������/�����-�����.'}
local arules = {'1. ������������� ������� � ���, � ������� �������/��������������� | �������',
'- ��������� ��������� �������� ���� � ����������� ������� �����',
'- ��������� ������������ ��� ����� � ���������������� � ����� ������� ��������, �� ��������� ��� � ������� ��������',
'2. DM ������� | ��� ��������',
'- �������� ��������� ��������� ���� �����/������� �������� ���/�����������, ���� �� ������� ���� �����',
'3. �������� ���������, �� ���� ������������� ��������� | ��� ��������',
'4. ��������� ������� | �������',
'- ��������� ���������� �����������/���������, ��� ���� ����������� � ��������� ������ � ������',
'- �������, ����������� �� ������ �� ������/��������, ��������� ������ ������ � ������',
'5. ����������� ���������������/�������/������ | �������',
'- ������� �� ���������������� �� �������� ��� (/t)',
'6. �������/������� ����-���� � /a | �������',
'7. ������ ������ ��������������� | �������',
'8. �������/������� � ������� | ������',
'- ��������� ���������� �������� ��������� SAMP/CRMP/GTA V ��������, IP �������, ����������� ������� �������� �� ������ �������',
'9. ������ � /msg | �������',
'- ��������� ������������ ������� ��� ���������� ������� �� �������, ������������, ������ �� �������/��������� � �.�',
'10. ���� ����-���� �� �������/��������������� | ��� ��������',
'- ��������� �������� ������/�����/�� ��������� � �� ���������� �� ������� � ������ ��� �������� ��������������',
'- ��������� ������� ���������� ��� �� ��������',
'- ��������� ������������ ������ �� �������� ���������� � ����� ������ ����������� �������',
'- ��������� ��� ������� �������� ����� ����',
'- ��������� ������������� ��������� �������/���������������',
'- ��������� ��� ������� ������������ ��������� | ����������: ��������� ��������� ��������� �� ����� ����',
'- ��������� ������������ ��������� � ������ (�����-��������) � ������ ��������� � �����-�������� | ��������� ������ ������ �� ������',
'- ��������� ��������������� ������� �� �����������. ��������� ����������� ������ ���� ������ ����� /gotp | ����������: ���� ���� ��������� ��������������� � �����������',
'11. ������ RP/�������� � RP ������� | �������',
'12. �������� ������ �� ���� ����� ����� ��� ������� | ��� ��������',
'- ��������� ������� ������� ������ � �����/������� ��� �������� ������ �� ������� �����',
'13. ���������������� | �������',
'- ��������� ������� ������/���������� � ������ ����, ����� �������, �������� ������� �����-���� � /a, /v, � ����� � /sms, ���� ���������� ������ ����������������',
'- ���������������� ��������� � /t � � ������, ���� ������ ����� ���� � ������ � ��� �� ������',
'14. ������������� ����� ������ ������� | ������',
'- ��������� ����� ����, ������� ����� �������� ���� ������ �������',
'����������: ������������� ����� �� DM ����� ������ �������, ������� �� ������ �� �������� | ��� ��������',
'15. ������ ��������� �� ������� ������� �������������� | �������',
'- �������������, ��� ������� ���� ���������, ��������� �� ����',
'16. ������� ����� 1 ����� �������� | ������ ���� ��������� � �������',
'- ��������� � ������ ���� ���� ����� �� ����� IP, ���� �� ��� ���� ��������������',
'17. ������ ��������� �� SMS ��������������� | �������',
'- �������� ��� ���� ��������� SMS ��� ����� � ����������������, ��� ������� ���� ���������� �����������',
'18. ������ ��������� �� DM ��������������� | �������',
'- ��������������� ������� ��������� ������/�������',
'19. �������� ��������� | ������',
'- ��������� �������� ��������� � ������� �����-��������� � ������, ��� ����� � ������, � �� ��������� � ��������� ������������� ������',
'20. ������������ ������ ������ �� ������ | �������',
'21. ������ ��������(-��) � ����� | ������/������� �������',
'- ���� ��� ������� ������������� (�� �������� �������� ��� ������), ��������� � ����� �������� �������(-�) �� �������� ������ ������� ���������',
'- ���� ��� ������ �������(-�) � �����, ��������� ��������� ���������� ������ ��������������',
'- ��� ��������� ��������(-��) �� �������������� �� �� ��� �� ������ �������� ��� ��������� �� ��������� ������, ���� �� �� ������� ��������������',
'22. ���������� �������� �� ������ | ��� ��������/������',
'- ��������� ������� ������� �������������� �������/������� ��, �� ��� �� ����� �������� ������',
'- ��������� �������� ���������� �������/��������������� � ������� ��������/�����',
'23. ������ ��������� | ��� ��������',
'- ��������� �������/���������� ������������� �� �������� �������/���������������',
'������: ������� �������� ��������, ���������� ��� �������, �������� ��������',
'24. ��������� ������ ������������� 3+ ��� | ������',
'������: ��������� 3 �������� �� ����������� ��������������/������',
'����������: ��������� �������� � ��� ������, ���� �������� ����� ������ ���������� ����� 15-�� �����',
'25. ����������� ������� ���������������, � ����� ����������/����������� �� ����� | ������ + mute �� 30 �����',
'- ������� ���������������� �� ���.����, �������������, �����, ����, ������� (��� �� �������, ���� ��������� ���� �� � ����)',
'26. ������������ ��������� | �������',
'- ��������� ����������� ��������� ���� � ������ � ����������� ������ �� � ����������� ��������/�����������',
'������ � �������: ����� 2 ���� ������� ������� "���� � ��� - mute 10 �����" � �� ������ ��� 20 ����� ���� ������ ���������� �� ������� 10 �����',
'������ � �������: ������������� 2 ���� ������� ������� "DM ������� - �������" � �� ������ ��� ����� 2 �������� ������ ����������� �� ������� ������ ��������',
'- ����� ��������� ������ ���������� ����� ����� ���������. ���� ������ ��������� ��������������/������ � �� ���������� ��������, ��������� �������� ��������� �� ����������� ���������',
'27. ������ ��������������� ����� | ��� ��������',
'28. ��������������� ��������� �������� | �������',
'29. ��������������� ������ � /a /v | �������',
'- �������� ���� �� 2-� (������������) ���� � 2 ������',
'- ��������� ����������� ������� ����, ���������� ��������������� ������',
'30. ������ �� �����/������� | ��� ��������',
'- ��������� ��������� ���� ��������� ������� � �������� � ���������� ����� ������/����������� �� ���������� ��� ��� ���� �����/�����, ��� ����� ������� ��������',
'- ��������� ������ � ����������� �� ����/������, � ����� �� ������������ ����������',
'- ��������� ��������������� ���������� ���� � �����',
'- ��������� ������ ������/����������/��/�����/�����',
'31. ���� ����������/�������� | ������',
'- ��������� ������ ����������/�������� ��� ������������� � �������',
'32. ����������� ��� ������� ������ | ������',
'����������: �������������� � ������� �������� �������������� 12 ������.',
'��������������� �� ������� ������ � ������ "������� ������" - ��������� ����� ��������������.',
'33. ��������� ��������� | ��� ��������',
'- ��������� ���������� ������������ ������ � ����������� ������ ��������� ������',
'������: ������ /ban �� ������� "�����" ������, ���� ��� �� �������� � ���� � ����� � ����� � �������������� ����� � ������� ��������������',
'- ��������� ���������� ������ ������/�����, ��������� ��������/�����, �������� � ����� ���������/��������/���������� ��� �������',
'������: ���� ������ � ��������� ��������� ����������, ����� � ����� ������� ����� �� ����������� �����',
'�� ����������� ���� ������������� ������ ID � ������ ��� ��������',
'- �������� �������� ������� ��� �� ����������',
'������: �������� �� ������� ������� ������ � ������ | ����� �� �������� ������, ����� �������� ���������� � ����, ����/� ���� �� ��������������',
'- ��������� ������ ��������� ������ ����',
'���� �� ������ �������� �����-���� ��������� � ������ ������ ��� ���� ����, ��� �� �������� ������ ��������� �� ������ ���������������',
'������: ������ ������ �� ������, �� ������ �������� ���� ����; �������� ������� �� ��������� ��������� � ��������� �� ������',
'34. ������������� ����� ������� ��� ��������� ������������ ������ | ������ + ���',
'������: ������/��� ������� �����, ������ ������ � �.�.',
'35. ��������� ������ �������� ����� | �������',
'36. ����������� ������� | ������ + ���',
'37. /pm � ������ ����� | �������',
'- ��������� ������������ ����� ����� /pm � �������, ������� �� ����� � ������',
'- ��������� ������������ /pm "�� ���?" � ����� ���������, �� ��� �� �����',
'38. ���� �����-��������� | �������',
'- ��������� �������� ��� �����-����������, �������� ������ ������/��/�����, �������� ������� � ���� � �.�',
'39. ������������� ����.�����/������������� ����.����� � ������� ������ �������/��������������� | ������ + ���',
'40. �����������/���������� ������������� ��� ����� ����������� | ������',
'- ��������� ���������� ����� �������������',
'41. ����/���� � ���, � ������� �������/��������������� | �������',
'- �������� ���� �� 2-� (������������) ���� � 2 ������',
'- ��������� ����������� ������� ����, ���������� ��������������� ������',
'42. �������� ������ ��������� ������/�������������� | �������',
'43. �������� ������������ ������ �� ������ | �������',
'44. �������/������� �������������� ��������� �� �������� ������ | ��� + �������� ��������',
'45. ���� ��������� ������� | ������ + ��� �� 3 ����',
'- ��������� ���������� ������ ������� � ����� ���������� ���������� ��������� � ����������� ����� ������� � ���.',
'46. �������/��������/����� �������� | ������ + ��� �� 30 ����',
'47. NonRP ������ | ������ | ������ /try | ������ + ��� �� 14 ����',
'- ������ � �����-��������� | ������',
'48. NonRP NickName | ��� ��������',
'- ��������� ������������ nRP ���/��� ���������� ������, ������ - EVGENY_CREATOR | iVan_pUPpKin | Evgeny_Creatorrr',
'- ��� ������ ���� ������� � ������� ���_�������, ������ - Evgeny_Creator',
'- ��������� ������������ ��� � ����� ��������� ����� � �����, ������ - EvGeny_Creator',
'49. ���� ���������������� ���� | ������ + ��� �� 30 ���� | ������ ������� (��� �������)',
'50. �������������� ����� ������ | ��� ��������',
'51. ������ ��������� � �������� �������� | �������',
'- ��������� ��������� �������, �� ���������� �� ��� ������ ���� ������ ���������',
'������: ������ ��������� �� ��������: "��������� ������ ����", "��������� ������ �������" � ���� �������� (���������� ��������� ������ �������, �������� "����������� ������")',
'- ��������� ���������� ���������� ������, ������� ������ ���� ������� ��������� ���� �������'}
local lrules = {'- ��������� | ��������� - ��� �������� ������ + mute',
'- ����������� ������� ������������� | ��������� - ������ + mute',
'- ������������ ��������� �� ������ | ��������� - ������� ������',
'- ���������� ������ | ��������� - ������ + mute',
'- DM, DB, TK, SK | ��������� - ������� ������ + jail',
'- ���������� ��� ������ | ���������� - �����/����� | ��������� - ������� ������',
'- �������� ������ � NonRP ����� � ����������� | ��������� - ������� ������',
'- NonRP | ��������� - ������� ������ + jail/warn',
'- ������� | ��������� - ������ � ������� + ban',
'- ������� (�� 5+ �������) | ���������� - �����/�����/������� ����� 1 ���. | ��������� - ������ � ������� + warn',
'����������: ��������� �������� � ��� ������, ���� �������� ����� ������ ����������� ����� 7-�� �����.',
'- ���� | ��������� - ������ � ������� + warn',
'- ���� � ������� | ��������� - ������ � ������� + warn',
'- ���� | ���������� - �����/����� | ��������� - ������� ������',
'- ����� ������� ��������� �� ���� �� 1 ���� | ���������� - ���� ����� �������� �� ��� �� �������� ����� | ��������� - ������ � �������',
'- ������� 24+ ����� | ��������� - ������ � �������',
'- NonRP �������� ������ | ���������� - ����� (����� ������������ � ��������������) | ��������� - 2 �������� ������',
'- ����� ���� ������� �� ���� | ���������� - ����������� ����������� | ��������� - 2 �������� ������',
'- ����� ���� �������� �� ���� | ���������� - ���.��������� | ��������� - 2 �������� ������',
'- ���������� ����� �� ���� | ���������� - ���.���������, ����� | ��������� - 2 �������� ������',
'- ���� ����������/�������� | ��������� - ������ � ������� + warn',
'- ������� ����� ����� ������� | ��������� - ������ ���� �������',
'- ���������� ����� �������� � ������� 3-� ���� | ���������� - ���.���������/���������� ������� ��������������� ����������� | ��������� - ������ � �������',
'- �������/������� ������� | ��������� - ������ � ������� + warn (������� �� �������� ������ - �������� ��������)',
'- ������� ����� | ��������� - ������ � ������� + warn (������� �� �������� ������ - �������� ��������)',
'- ���� � ������� �� ��������������� �����/����� | ��������� - ������ � ������� + warn',
'- �������� ���������� ����� �� ����� ������� (������: ���� � ������� � ������� � ������) | ��������� - ������ � ������� + warn',
'- ������ ��������������� �����, � ��� ����� �������� ������ | ��������� - 2 �������� ������',
'- ����� �� �������� ������� � ���������� ������������ | ���������� - ����������� ����������� | ��������� - 2 �������� ������',
'- ���� �����/������� | ��������� - ������ � ������� + ban',
'- ����������� ������� | ��������� - ������ � ������� + ban',
'- NonRP ��� | ��������� - 2 �������� ������',
'����������: ���� ����� �� ������� ��� �� ���������� � ������� 10-�� ����� ����� ���������, �� ��������� � �����',
'������������� ������ ���������� ������ � (/pm) � ��� ���, � ���� ������� 10 ����� ��� ����� ��������',
'�����: �������������� ��������� ������ �����, ����� ����� ��������� � ����'}
local srules = {'- ���������� ����� ����������� ������� �� ����� (1 ���). | ��������� - ������ � ����� ��������.',
'- ������������ � ������� 24 �����. | ��������� - ������ � ����� ��������.',
'- ����������� ������ � ������ / ���� ���������. | ��������� - ������ � ����� �������� + ������� �� 30 ����� + ������ ������ ��������� ������ �� 10 ����.',
'- �������� ����� ������. | ��������� - �������.',
'- �������� �������. | ��������� - ������ � ����� �������� + ������ ������ ��������� ������ �� 5 ����.',
'- ����������� ������ � ������������ ��������. | ��������� - ������ � ����� �������� + ������ ������ ��������� ������ �� 10 ����.',
'- ������������� ������� ��� ������� � ������ �����. | ��������� - 1 �������.',
'- ������������ ��������� � ������ / ���� ��������� (�����������/����/���). | ��������� - ������ � ����� �������� (��� ��������� ��������� ������ ������ ��������� �� 5 ����).',
'- ����� ��������� ������ ������� �� ������� �������� �������� (DM/�����������/���������). | ��������� - ������� + ��������� �� �������� �������.',
'- ������� 0 ������� �� ����� ��������. | ��������� - 2 ��������.',
'- ����������� �������� �� ����������. | ��������� - ������ � ����� �������� + ������ ������ ��������� ������ �� 5 ����.',
'- ��������� ���� ��������� (�������/�������/����). | ��������� - ������� + ������� �� 10 �����.',
'- NonRP ���. | ��������� - ������ � ����� ��������.',
'- ���������������� � ���� ��������� ��� � ������ ������. | ��������� - 2 ��������.',
'- ������������� ����� �� ����� ��������. | ��������� - ������ � ����� �������� + jail/warn.',
'- �������������� ������� (�������/����������� ��������). | ��������� - ������ � ����� �������� + ������ ������ ��������� ������ �� 5 ����.',
'- ������������� ������� �������� ��������� �� ����������. | ��������� - �������.',
'- ������ ���������� �������, �� ���� ������������� ���������. | ��������� - ������� (�� ������ ������� 2 ��������).',
'- ������� ������, ���������� ������������� ��� ������, ������������� ������. | ��������� - �������.',
'- �������� � ������ ������. | ��������� - �������.',
'- �������������� ����� ������. | ��������� - 2 ��������.',
'- ���� ����� ��������. | ��������� - ������ � ����� �������� + ���������� �� 30 ���� + ������ ������ ��������� ��������.'}
local gosrules = {'- 1. ������ ������� � ������������ ��� ������������� ����: [��� ����� �����������] - [all/������ �����������] - /mute (�� 1 �� 10 �����).',
'- 2. ������������� ����, ���������� ����, ������ ���������, ����������� (/d (/db), /r (/rb), /gov �.�.�) . - /mute (�� 1 �� 10 �����).',
'- 3. ������ � ��������������� �������, �� ����� ��������������� ����� - /mute (�� 1 �� 10 �����).',
'- 4. NonRP Cop - /warn /jail (�� 1 �� 15 �����).',
'- 5. ���������� � ������������ ��� ��� ������� ������� - /mute (�� 1 �� 10 �����).',
'- 6. ���� ��������� - /auninvite + /jail (�� 1 �� 15 �����).',
'- 7. ���������� ���. ��������� � ����� � ����� ������ - /jail (�� 1 �� 10 �����).',
'- 7.1. ��������� ���������� � ����� ��� �������� ����������� (��� �������).',
'- 8. ������������ ������ ��� ������ ������� (������ ������� � NonRP ��������� ��� ���������, ������� �� ������� � ��������� �������: DM, ����, ��������� � �.�). - /warn /jail (�� 1 �� 15 �����).',
'- 8.1. ��������� ��������� ������ ������ �������� ������ ��� � �����.',
'- 9. ���������� ������������� � ������������� ��������� ��� ���������� ����� ��� ��� ������������� ��������������� ����� - /mute (�� 1 �� 10 �����).',
'- 10. ������������ ������ ���������� �������� - /warn /jail (�� 1 �� 15 �����).',
'����������:',
'- 1. ������� ��� ������� ������ ��������������� ���������� ������� San Andreas.',
'- 2. ������� ���������� ������ ���� �� ������� �����. ������������� ������� �� ������ ����� ����� ��������.',
'- 3. ��� ������������ ��������� ������ ��� ������� 9 - �� ������ ������� �� �����������.'}
local orules = {'- 1. ���������� ���������� ����������� ������ � ���� ��� ��� ����������� ������������ (��������� ������� /mp).',
'- 2. ������������ ������� ������ ������.',
'- 3. �������� ���������� ������� ������:',
'',
'������ �������� ����� 15 ������ �� �����, ��������� - 10.',
'��������� ��������� ��, ����������, ������ ��������� � ����� ���, �� ����������� /rep � /sms.',
'',
'- 4. ����������� �� ����� ��� �������, ������� ���� ����� � ��������� ���������� �� ��������� 30 �����, ��� �� ����� ����������� � ������.',
'- 5. ����������� �� ����� �������, ���������� �������� ������ �������.',
'- 6. ���������, ��� �� ������ ������������ �� ����� ��� �������.'}
local tryrules = {'- 1. �������� ���������� ������� � �������� �������� ��� ������ ����',
'> � �������� ������ ���� ��������: �����, ������/�������, ���-�� �����, ���-�� ���������� /try',
'> ������: "������ � /try �� 10�� ��, 1 ������, ������ 3 ����"',
'> ���� ������ �� ���� ��������, ���� ����� �� FCoins',
'> ��� ��������� ������� ���� �� ������ ����� �������������� ����� �� ��� ��������, �� ������� ������� � /try, ���� �� ��������� ��� ���� (��. ����� 3.)',
'> ���� ������������ ����� �� �������, �� �� ������ ����, �� ������ �������� ���������� �� ����� � /try.',
'- 2. � ������ ��������� ������ �� �����, ��������� ������� �������� /mm - 1.',
'> �������������� ��������� ������� � �������� �� ���, � ��� �� ���� ���� (���������/���������� ����, ��� ��� ������ ����������� /try ������ ���������� ���).',
'> �� ��������������� ������ ���� ����� ��������� �����.',
'- 3. ��� ��������� �������, ���� ���-�� ����� �������� ��� ��������, ����� ������� ��� ���. ���� ��� �� ��� ������ ��� ������ �� ��������� � ������� 24�, �� ��������� �������� ���, ��� ����� � /try.',
'- 4. � ������ ��������� � �������� ������������ �����/�������� �� ������ ��������, ��� ����� ������������� �� ������� � ������.',
'- 5. � ������ ��������� � ��������� �������� �����������, ����� ������ ���������� ��������.',
'- 6. ��� ������ ��������� "������" ����� ����������� ���������� ����������� ����, ������������� � ����� ������.',
'- 7. ��������� ���� ������ �� ������������� ������/���������.',
'- 8. ��������� ���� �� �������, ������� � ����.',
'- 9. ��� ������ ������������ ����� ��������� � ��������� ��������� (��� �������).'}
local capturerules = {'�� ������� ���������� ���������:',
'',
'- ����� (/mask)',
'- ������� (/healme)',
'- ��������� (/drugs)',
'- ������������� ����� �������� (������, ������, ����� ���������, +�)',
'�� ������� ���������� ���������:',
'',
'- TK, DB, ���������� | ��������� - Jail/Warn (1/3)',
'- ���� | ���������: Jail/Warn (1/3)',
'- ����: WH, SH, TP, PARKOUR, CLEO ANIM | ��������� - Jail/Warn (1/3)',
'- ����: FLY, ���� ���� | ��������� - Jail/Warn (2/3)',
'- SK (����������: ���� ���� ����������), ��������/��� �� �����, ������ ���� | ��������� - Jail/Warn (2/3)',
'- ���� ����: CARSHOT, DAMAGER, ������ � ������ | ��������� - Ban (3/3)',
'- �� ��������� �� ������������� ���������� � ������� 3-� ����� | (3/3)',
'- ������� ������/������� | ��������� - Jail/Warn (3/3)',
'- �������� �� ������������ ������� | (3/3)',
'- ����-������� | ��������� - Jail/Warn (3/3)',
'- AFK �� ����� �� 1+ ����� | ��������� - Jail/Warn (1/3)',
'- ����, ������� ���� ������������ � ��������: AIM, RAPID, AUTO +C, NO SPREAD, EXTRA W, ����� | ��������� - Jail/Warn (3/3)',
'- ��������������� ����� (����������: �����, �� ������� ����� ������� � ������ ������) | ��������� - Jail/Warn (2/3)',
'- ������ ������ ����� (������ ���������� �� �����, ������� ��������. ������� �����, ������ ������� ���� ��� �����) | ��������� - jail/warn (3/3)',
'- ����� �� ����, �������� � ��� �� �������� ����� | ��������� - Jail/Warn (3/3)',
'- ������������� ������������ ���������� (������� �������: "Hydra", "Hunter" � ������) | ��������� - Jail/Warn (3/3)',
'- +C �� ������ � Anti +C | ���������: Jail/Warn (3/3)'}
local bizwarrules = {'�� ������ ���������:',
'',
'- ������� (/healme)',
'- ��������� (/drugs)',
'- ������������� ����� �������� (����� � Desert Eagle ����� 2-�� ��������, ����� ���������)',
'�� ������ ���������:',
'',
'- +C, ����� ����� 1-�� �������� | ���������: Jail/Warn (1/3)',
'- ����� (/mask) | ��������� - Jail/Warn (1/3)',
'- SK, TK, DB, ���������� | ��������� - Jail/Warn (1/3)',
'- ����: SH, TP, FLY, PARKOUR, CLEO ANIM | ��������� - Jail/Warn (1/3)',
'- AFK �� ������ �� 1+ ����� | ��������� - Jail/Warn (1/3)',
'- NO SPREAD, EXTRA WS, ��������/��� �� ����� | ��������� - Jail/Warn (2/3)',
'- ����, ������� ���� ������������ � ��������: AIM, RAPID, AUTO +C, �����, �������� ������ ������� | ��������� - Jail/Warn (3/3)',
'- ���� ����: CARSHOT, DAMAGER, ������ � ������ | ��������� - Ban (3/3)',
'- �� ��������� �� bizwar � ������� 3-� ����� | (3/3)',
'- ����-������ ������� | ���������: Jail/Warn (3/3)',
'- �������/��������� � ��� | ���������: Jail/Warn (1/3)',
'- ���� | ���������: Jail/Warn (1/3)',
'- ��������������� ����� (����������: �����, �� ������� ����� ������� � ������ ������) | ��������� - Jail/Warn (2/3)',
'- ��� �� ������/����� � ����, ������� �������'}
local codex = {'���������������� ������ (��)',
'1. ������ "��������":',
'1.1. ������������ �������� � ������������ �����: - ��������� ����� ����� ������������ ��������� � �������� ����� � ������� �� 350 000$ �� 900 000$. - �� ������������ �������� � ����� �������� ��������� ����� (8 �������) ����� ������������� � 2 ����.',
'1.2. ������������ �������� �� �������: - ��������� ����� ����� ������������ ������ � �������� ����� � ������� �� 250 000$ �� 500 000$.',
'1.3. ������������ �������� � ���������: - ��������� ����� ����� �������� ����� � ������� �� 150 000$ �� 300 000$.',
'1.4. ��������� ���������� �� ������: - ��������� ����� ����� ������������ ��������� � �������� ����� � ������� �� 350 000$ �� 600 000$. - �� ��������� ���������� �� ���������� ������� ��������� ����� ����� ������������ ��������� � �������� ����� � ������� �� 350 000$ �� 500 000$.',
'1.5. �������� �� ������ ������: - ��������� ����� ����� ������������ ��������� � �������� ����� � ������� 500 000$.',
'1.6. �������� ��������� ������������ ������� ��� �������� ����� �������� ��� ����������� �� ����������� ����� ��� ����������� ��� ���� ��������� ��� ��� ���������� ���������� ������������� ����������: - ����� � ������� 50 000$.',
'2. ������ "��������� ������������� �������":',
'2.1. ������������� ����������� ������� � ������������ �����: - ��������� ����� ����� �������� ����� � ������� 50 000$.',
'2.2. �������� ����������� ��������: - ��������� ����� ����� �������� ����� � ������� 100 000$.',
'2.3. ������� � ������������ �����: - ��������� ����� ����� �������� ����� � ������� 100 000$.',
'2.4. ����� � ������������ �����: - ����� � ������� 50 000$.',
'2.5. ���������� � ����������� ���������: - ����� � ������� 100 000$.',
'2.6. ����������� ����������� ��������������� �����������: - ����� � ������� 500 000$ ��� ����������� ������������� ���������. ������� �������: 2.',
'2.7. ��������� ���������� ��� �������� ����� � ������������ ������: - ����� � ������� 40 000$.',
'� ����� 3. ��������� ���: ��� ���������:',
'3.1. ������ ��������� ���: - ��������� ����� ����� �������� ����� � ������� 300 000$.',
'3.2. ���� �� ��������� ������: - ����� � ������� 150 000$.',
'3.3. ���������� ��������: - ����� � ������� 100 000$.',
'3.4. ����� �� ��������: - ��������� ������, ������� ����, ����� � ������� 400 000$.',
'3.5. ���� � ����� ���: - ��������� ������, ������� ������������ ����, ����� � ������� 450 000$.',
'3.6. �������� ������������� �������� � ��������� ���������: - ������� ����, ����� � ������� 20 000$.',
'3.7. �������� ��������� �������� �� ������: - ��������� ������, ������� ������������ ����, ����� � ������� 250 000$.',
'3.8. ����������� ���� � ������ �����: - ����� � ������� 50 000$.',
'3.9. ����������� ����������� ��� ���������� ��������: - ����� � ������� 50 000$.',
'3.10. �������� �� ��������, ���������, ��������������� �����: - ������� ����, ����� � ������� �� 150 000$ �� 300 000$ (� ����������� �� ���������).',
'3.11. ������ �� ������� ����: - ����� � ������� 500 000$.',
'3.12. �������� ������������� �������� ��� ���������������� �����: - ����� � ������� 300 000$.',
'3.13. ������������ ���������� ������ ��������� �������� �������� ������ ������������� ��������, ������������� ���������������� ������ ������� �� �����������: - ����� � ������� 250 000$.',
'��� ���������:',
'3.13. �������� ��������� ��������: - ����� � ������� 200 000$.',
'3.14. ������������ �� �������� �����: - ����� � ������� 150 000$.',
'3.15. ������� �� ������� ����: - ����� � ������� 50 000$.',
'3.16. ���� �� ��������� �������: - ����� � ������� 170 000$.',
'3.17. ������������� ������ ������������ ����������: - ��������� ������ �������� ����� � ������� 200 000$ � ������ �������� ����.',
'4. ������ "�������"',
'4.1. ������� �� ������ �����: - ��������� ������ �������� ����� � ������� 200 000$.',
'4.2. ���� � ����������� ������������������ �������: - ����� � ������� 300 000$.',
'��������� ������ (��)',
'1. ������ "���������":',
'1.1. ��������� �� ����������� ���� � ����� �������� (������� �������: 4).',
'1.1.1. ��������� �� ���������� ��������������� ����������� � ����� �������� (������� �������: 6).',
'1.2. ��������� �� ����������� ���� � ����� �������� (������� �������: 6).',
'1.2.1. ��������� �� ���������� ��������������� ����������� � ����� �������� (������� �������: 6).',
'1.3. ���������� � ����������� ��������� �� ���������������� ���������� ��� ���������� (������� �������: 6).',
'1.3.1. ���������� � �������� ������������ ���� ��� ���������������� ���������� (������� �������: 4).',
'1.4. ��������� �� ������� ��������������� �������� (������� �������: 6).',
'2. ������ "����������� ������������/����������� ����/������":',
'2.1. ����������� ������������������� �������� (������� �������: 4).',
'2.1.1. ������� � ������������������� �������� (������� �������: 2).',
'2.2. ������� ������ ��������� (������� �������: 3).',
'2.3. �������� ������� ������� ��� ������� ���������� � ���������� ��� ������� (������� �������: 4).',
'2.4. ����� ���������� �� ���������� ����� (������� �������: 5).',
'2.5. �������� � ��������� ������������� ������� � ���������� ��� ������� (������� �������: 6). ������, ���� ��������� ��������� � ��������� ���������� � ������������ � ����������� �����, �� ������� ����� ���� �����������.',
'2.6. ���� ������������� ������� � ����������: - �������� (������� �������: 5). - ���������� (������� �������: 4).',
'2.7. ������������ �������������/������������ ������� (������� �������: 4).',
'2.8. ����� � ���������� �������� (������� �������: 5).',
'2.9. ����������� ����������� �������� ��� (������� �������: 5). 2.11. ���������� ������������ � ���� ������ (������� �������: 5). � ����� ������� ������������ ������� ������ � �������� �� ����.',
'2.10. �������� ��� ������� ������ ��� �������� (������� �������: 3).',
'2.11. ������� ������ � �������� ���� (������� �������: 3). � ����� ������� ������������ ������� �������� �� ������ � ������ ������.',
'2.12. ����������� � ��������������� ����������� ������� (������� �������: 3).',
'2.13. �������������� � ������� ������������/����� (������� �������: 6).',
'2.14. ����������� ������� �����������/����� (������� �������: 6).',
'2.15. ���������� �������������/���������� ������� ��������� ������ (������� �������: 6)',
'3. ������ "��������� ���":',
'3.1. ���� � ����� ��� (������� �������: 3).',
'3.2. �������� ��������� �������� �� ������ (������� �������: 2).',
'3.3. ����� �� �������� (������� ������� ������� �� ������� ��������� � ����� ���� �� 1 �� 3).',
'4. ������ "������������":',
'4.1. ������������ ���������� ������������������ ������� (������� �������: 4). ����� ������� ������� ����������� ��������� ������������� � ��������� �������.',
'4.2. ����� ������� ������ (������� �������: 5).',
'4.3. ����� ������������ ��� ������� ����� ������� (������� �������: 3). ������ ������� ���������� ����� ������������ �������� ��������.',
'4.4. ������������ ������ ���������� (������� �������: 2).',
'4.5. ���������� ������ ��� ������������� ���������� ������ (������� �������: 5).',
'5. ������ "�������":',
'5.1. ��������� ������� ��� ��������������� ����������� � ����� ������ (������� �������: 6).',
'5.2. ���������� �����������, ��������� ��� ��������������� ������� (������� �������: 6).',
'5.3. ������������ ������� (������� �������: 6).',
'5.4. ����������� ������� (������� �������: 6).',
'5.5. �������� ���������������� ����������� (������� �������: 6).',
'5.6. ������ ���������� � ��������� ����� (������� �������: 6).',
'5.7. ������� ���������������� ���������� (������� �������: 6 + ������ ������ ����������� + ����� � ������� 20 000 000).',
'5.8. ���������� ��������� (������� �������: 6).',
'6. ������ "�������������":',
'6.1. ������������� �� ���������� ����������, ��� ������� ������������������ ������� (������� �������: 6).',
'6.2. ������������� �� ������� ���������� ��� ���������� ��������� (������� �������: 4).',
'6.3. ������������� �� ���������� �������� ������� ���� (������� �������: 6).',
'7. ������ "�����������":',
'7.1. ������� � ����������� (������� �������: 4).',
'7.2. ���������� � ������� ������������ (������� �������: 5).',
'7.3. ������������� (������� �������: 6).',
'8. ������ "���� ������ ���������":',
'8.1. ���� �������� ������ ��������� ����������� ������������������ ������� (������� �������: 4)',
'8.2. ������ ����� ����������� �������/��� (������� �������: 4)',
'8.3. �������������� ����������� (������� �������: 5)',
'8.4. ���� ������ ��������� � ����. (����� 5.000.000 �������� � 4 ������� �������)',
'9. ������ "�����������":',
'9.1. �������������� ��������� � ������ �����/������������ (������� �������: 4).',
'9.2. ������ ��������� (������� �������: 3).',
'9.3. ����� ��������� ��������������� ����������� (������� �������: 2) ��� ����� � ������� 500 000 ��������.',
'9.3.1. ����� ��������� ����������� ��� (������� �������: 1).',
'9.4. ������� ����� ������������� �������� (������� �������: 3).',
'9.4.1. ���� ������������� �������� (������� �������: 5).',
'9.5. ������� ������������ ������ �����, ���������� ���� (������� �������: 1). ����������: ������� ������� ��������� ����� �����, ��� ��� ������ ���� �������� ���������� � ����������� ������������������ �������.',
'10. ������ "�������������� �� �������������":',
'10.1. �������������� �� ������� ������������� � ����������� ���� (����� �� 10 000 000 ��������, ������� �������: 5).',
'10.2. �������������� �� ������� ������������� ����� ���������� ����������� ���������� (����� �� 10 000 000 ��������, ������� �������: 6).',
'10.3. �������������� �� ��������������� ������������� � ����� ���� (����� �� 30 000 000 ��������, ������� �������: 6).',
'10.4. ���������� �����/������� ��������������� ������������� (������ � ���������, ����� �� 5 000 000 ��������, ������� �������: 6).',
'11. ������ "���������� ����������� ����������":',
'11.1. ���������� ����������� ���������� � ��������� ����� (������ � ��������� + ������ ������ �����������, ������� �������: 6).',
'����������� ������������� (��)',
'1. ������ "��������� � ������������ �������������"',
'1.1. ����������� ������������� ����������� �������������� ���������� � ����������� ���� ������������� � ��������� ��������������� ��������.',
'1.2. ��������� ������������ ������������� ����� ���� ������������ ���������� ��� ��� ������������ �����.',
'1.3. ����������� ���������� ������������ ������������� ����� �� ���� ��������� ��������������� �����������.',
'1.4. ���������� ��������������� � ���������� ������������ ������������� �� ����������� ����������� � �� ����������� ��� �� ���������������.',
'1.5. � ������, ���� ��������������� �������� ��������� ��������, ������� ����� ��������������� ��� ��������� ��������� ����������-��������� ����, ��������� � ������ �� ����������� ������� ��������������� ���� � ������� �� ����������� �������������.',
'1.6. ���������, ��������������� ����������� ������ ���� ���������, ������������ ���������� ������ �� ��� �� ���������� ������������ ���������, �������� ������� ��������� � ������� �������������� �������������� ��� ��������� � �������.',
'',
'2. ������ "��������� ������������ ��������������� �����������"',
'2.1. ����������� ��������� ��������������� ���� �����, �������� �� ����� ������ ��������������, �������, ��������� ��� ����������.',
'2.2. ����������� ������������� ���������� ��������� � ������ ���������, ��� ����� �������� � ��������� ��� ����������.',
'2.3. ����������� ������������������� ���������� ����������� ����������� �� ����������� ��� ��������������� ���, � ����� �� ���������, ���������� ��������� ��� ����������.',
'2.4. ����������� ��������, ����������� ��� �������������� ������, �� ��� ������������� ���������� � ������������ � ��������� ���������������.',
'2.5. ����������� ������� � ���������� ���������, �������� ��� ���������������� �����, ��� ������ �� ����� ���������� � �������� � ������ ������ ��������������� ��������.',
'2.6. ����������� ���������� ������� ������ � ������� �����, � ���� ����������� ��� �������� ��� ����������, �� ����������� �������, ����� ��������� ��������� � ��������� ������������ ��������.',
'2.7. ����������� ������������, �������, ������� � �������� ������������� �������, ���������� ��������� ��� ����������, �� ����������� �������, ����� ��� ���������� ��� ������������ ������������ ��� ������� ���.',
'2.8. ��� �������� ����� ����������� ���������� �� ��������� ���� ���������� ���������� ����� �������� �����, ����� ������� ��������������, ��������, �� � ������ �����������, ������������ ����������� ��������.',
'2.9. ����������� ���������� ����������� ����������, ��� ����� �������� � ��������, ��������� ��� ����������.',
'2.10. ����������� ����������� ��� ������������ ������������ �� �������� ������ ����� � ������� ��� ����� ��������, ��� ������ �� ����� ������� ��� ���������.',
'2.11. ����������� ���������� ������������� ��������� ��� ����������, �� ��� ������������� ��������������, ������� ��� ����������.',
'2.12. ����������� ������������� ��������� ���������������� ������������ ��� ������������ ��������������� ��������, ���������� �������� ��� ����������.',
'2.13. ����������� ������������� ��������������� �����������, ��� ����� ������� �� ����� �������, ��������� ��� ����������.',
'2.14. ����������� �������� ��������������� ��������, �� ����������� ������� ��� �� ����� ������������ �����������, ����� ��� ������ ������������ ���� ���������� ��� ����������.',
'2.15. ��������� ���������� ��� ��������� ��������������� ���������, ��� ����� � ����������.',
'2.16. ����������� �������������� �������� ������ ���������� ��������������� �����������, ��� �������� ��������� ��� ����������.',
'2.17. ��������� ������������� ������� ������������� �������� �� ����� ���������� ��������� ������������, ��� ����� �������� � ��������, ��������� ��� ����������, �� ����������� ������������ ��������� �����������.',
'2.18. ����������� ���������� � ������� � ����������� ����������� ��� �������� �������������, ��� ������ �� ����� ���������� � �������� � ������ ������ ��������������� ��������, �� ����������� ������� ��� � ��������� ������������ ������������.',
'2.19. ����������� ������������ ����������� �����, �� ��� ������������� �������������� ��� �������.',
'2.20. ����������� �������� � ���� ������������� ������, ������� �� ����������, ��� �������� �������������� ��� ��������.',
'2.21. ����������� ������������� �������� � ������ ����� � ������ �����������, ��� ����� �������� � �������� ��� ���������.',
'2.22. ����������� ������������ �������� � ������� �����, ��� ������ �� ����� ��������������, ������� ��� ����������.',
'2.23. ����������� �������� ����� � ����������� �������, �� ��� ������������� ��������������, ������� ��� ����������, � ���������� ������������.',
'',
'3. ������ "��������� ������������ ����������� ���"',
'3.1. ����������� �������������� ������ ���������� � ���� � ����������� ������ ���, �����������, ����-�����������, �����, ��� �������� ����������.',
'3.2. ����������� �������������� ��������� � ��������� ������ ���, �����������, ����-����������� � �����, ��� ����� �������� � �������� ��� ����������.',
'3.3. ����������� �������� � ���������� ������ ���, �����������, ����-����������� � �����, ��� ������ �� ����� ����������.',
'3.4. ����������� ��������������� ������� �� ������ ���, �����������, ����-����������� � �����, ��� �������� �������� ��� ����������.',
'3.5. ����������� ������������� �������� ���������� ������ ���, �����������, ����-�����������, ��� ����� �������� � �������� ��� ����������.',
'3.6. ����� ��� ����� ����� ������� ������ ���������������� ���������� � ���� ���� ��� ���������� ������, �� ������� ����� �������� � �����.',
'3.7. ����� ��������������� ��������� ������ ���������� ���� ������������� �� ������� ���������� ������ ���, �����������, ����-�����������, ����� ������������� �������, ��������� ��� ����������.',
'3.8. ����������� ����� �� ���������� ������������ ���� ������������� ��� ����������, ���������� ����������� � �������������� � ������ 7.1 ��.',
'3.9. ����������� ���������� �������� ������ ���, ������������ � ����������, ��� �������� ����������.',
'3.10. ����������� ������������� ����������� ������������ ���� �������������, ��� ����� ������� �� ����� �������������� ��� ����������.',
'3.11. ����������� ����� �� ����������� ������������ ��� ���������� ���, �� ����������� �������, ����� ����������� S.W.A.T, � ����� ������ ����������� ����� ����� S.W.A.T.',
'3.12. ����������� �������� �������� �� ��� ��� ��, ��� ����� �������� � ����������.',
'3.13. ����������� �������� ������� ������ ��� ��� ���������� �� ������ ���� 7 ��� ��������������� ����������, ���������� �������� ��� ���������.',
'3.14. ����������� ��������� ������� �� ��������� � ������ ��� ��� ���������� �� ������ ���� 8 ��� ���������� (������ � �.�.), ��� ����� � �������� ��� ���������.',
'',
'4. ������ "����� ������������ � ��������������� �����"',
'4.1. ����������� ���������� ������ ������ ����������� � ����� ������������, ��� ����� ������� �� ����� �������, ��������� ��� ����������.',
'4.2. ������������� ����������� ������������� ����������� ����� ��� ������� � ����� ������������, ��� �������� �������� ��� ���������.',
'4.3. ����������� �������� ��������������� ����� ��� ���������� ������������� �� ����� ������ ������������ ��������, ��� ������ �� ����� �������������� ��� �������.',
'4.4. ����������� ����������� � �������� ����������� �������� ����� �������������, ��� ����� �������� � �������� ��� ����������.',
'4.5. ���� � ��� ���������� �� ��������� ������, �� ����������� �������� � �������� ������, �������� �������������� ��� ��������.',
}

local AllWindowsPunish = imgui.OnFrame(function() return punishMenu[0] end, function()
	if punishSwitch == 0 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 205, 440
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.PushFont(myFont)
		imgui.Begin(u8'�������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.BeginChild('##punishMenu', imgui.ImVec2(195,400), false)
		if imgui.Button(u8'������� �������������', imgui.ImVec2(190, 35)) then
			punishSwitch = 1
		end
		if imgui.Button(u8'������� �������', imgui.ImVec2(190, 35)) then
			punishSwitch = 2
		end
		if imgui.Button(u8'������� ���������', imgui.ImVec2(190, 35)) then
			punishSwitch = 3
		end
		if imgui.Button(u8'������� ���. �����������', imgui.ImVec2(190, 35)) then
			punishSwitch = 4
		end
		if imgui.Button(u8'������� ���������� ������', imgui.ImVec2(190, 35)) then
			punishSwitch = 5
		end
		if imgui.Button(u8'������� ���� � /try', imgui.ImVec2(190, 35)) then
			punishSwitch = 6
		end
		if imgui.Button(u8'����� �������', imgui.ImVec2(190, 35)) then
			punishSwitch = 7
		end
		if imgui.Button(u8'������� ������', imgui.ImVec2(190, 35)) then
			punishSwitch = 8
		end
		if imgui.Button(u8'������� ��������', imgui.ImVec2(190, 35)) then
			punishSwitch = 9
		end
		if imgui.Button(u8'��/��/��', imgui.ImVec2(190, 35)) then
			punishSwitch = 10
		end
		imgui.EndChild()
		imgui.PopFont()
		imgui.End()
	elseif punishSwitch == 1 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� �������������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search1',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(arules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 2 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� �������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search2',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(lrules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 3 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� ���������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search3',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(srules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 4 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 375
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� ���. �����������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search4',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(gosrules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 5 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 275
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� ���������� ������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search5',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(orules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 6 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 375
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� ���� � /try', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search6',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(tryrules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 7 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'����� �������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search7',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(punish) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 8 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� ������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search8',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(capturerules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 9 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'������� �������', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search9',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(bizwarrules) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
	elseif punishSwitch == 10 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 1250, 475
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.Begin(u8'��/��/��', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search10',u8'�����',search,256)
		imgui.Separator()
		for k,v in pairs(codex) do
            if u8(v):find(ffi.string(search)) then
                imgui.Text(u8(v))
            end
        end
        imgui.PopFont()
    end
    imgui.End()
end)

function cyrillic(text)
    local convtbl = {
    	[230] = 155, [231] = 159, [247] = 164, [234] = 107, [250] = 144, [251] = 168,
    	[254] = 171, [253] = 170, [255] = 172, [224] = 097, [240] = 112, [241] = 099, 
    	[226] = 162, [228] = 154, [225] = 151, [227] = 153, [248] = 165, [243] = 121, 
    	[184] = 101, [235] = 158, [238] = 111, [245] = 120, [233] = 157, [242] = 166, 
    	[239] = 163, [244] = 063, [237] = 174, [229] = 101, [246] = 036, [236] = 175, 
    	[232] = 156, [249] = 161, [252] = 169, [215] = 141, [202] = 075, [204] = 077, 
    	[220] = 146, [221] = 147, [222] = 148, [192] = 065, [193] = 128, [209] = 067, 
    	[194] = 139, [195] = 130, [197] = 069, [206] = 079, [213] = 088, [168] = 069, 
    	[223] = 149, [207] = 140, [203] = 135, [201] = 133, [199] = 136, [196] = 131, 
    	[208] = 080, [200] = 133, [198] = 132, [210] = 143, [211] = 089, [216] = 142, 
    	[212] = 129, [214] = 137, [205] = 072, [217] = 138, [218] = 167, [219] = 145
    }
    local result = {}
    for i = 1, string.len(text) do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end

theme = {
	{
		change = function() -- classic
			
			local style = imgui.GetStyle()
			local colors = style.Colors

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);

			style.Colors[imgui.Col.Text] = imgui.ImVec4(0.90, 0.90, 0.90, 1.00);
			style.Colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.60, 0.60, 0.60, 1.00);
			style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.70);
			style.Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
			style.Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.11, 0.11, 0.14, 0.92);
			style.Colors[imgui.Col.Border] = imgui.ImVec4(0.50, 0.50, 0.50, 0.50);
			style.Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
			style.Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.43, 0.43, 0.43, 0.39);
			style.Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.47, 0.47, 0.69, 0.40);
			style.Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.42, 0.41, 0.64, 0.69);
			style.Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.27, 0.27, 0.54, 0.83);
			style.Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.32, 0.32, 0.63, 0.87);
			style.Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.40, 0.40, 0.80, 0.20);
			style.Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.40, 0.40, 0.55, 0.80);
			style.Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.20, 0.25, 0.30, 0.60);
			style.Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.40, 0.40, 0.80, 0.30);
			style.Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.40, 0.40, 0.80, 0.40);
			style.Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.41, 0.39, 0.80, 0.60);
			style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.90, 0.90, 0.90, 0.50);
			style.Colors[imgui.Col.SliderGrab] = imgui.ImVec4(1.00, 1.00, 1.00, 0.30);
			style.Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.41, 0.39, 0.80, 0.60);
			style.Colors[imgui.Col.Button] = imgui.ImVec4(0.35, 0.40, 0.61, 0.62);
			style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.40, 0.48, 0.71, 0.79);
			style.Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.46, 0.54, 0.80, 1.00);
			style.Colors[imgui.Col.Header] = imgui.ImVec4(0.40, 0.40, 0.90, 0.45);
			style.Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.45, 0.45, 0.90, 0.80);
			style.Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.53, 0.53, 0.87, 0.80);
			style.Colors[imgui.Col.Separator] = imgui.ImVec4(0.50, 0.50, 0.50, 0.60);
			style.Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.60, 0.60, 0.70, 1.00);
			style.Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.70, 0.70, 0.90, 1.00);
			style.Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(1.00, 1.00, 1.00, 0.16);
			style.Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.78, 0.82, 1.00, 0.60);
			style.Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.78, 0.82, 1.00, 0.90);
			style.Colors[imgui.Col.Tab] = imgui.ImVec4(0.34, 0.34, 0.68, 0.79);
			style.Colors[imgui.Col.TabHovered] = imgui.ImVec4(0.45, 0.45, 0.90, 0.80);
			style.Colors[imgui.Col.TabActive] = imgui.ImVec4(0.40, 0.40, 0.73, 0.84);
			style.Colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.28, 0.28, 0.57, 0.82);
			style.Colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.35, 0.35, 0.65, 0.84);
			style.Colors[imgui.Col.PlotLines] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
			style.Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
			style.Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
			style.Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
			style.Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.00, 0.00, 1.00, 0.35);
			style.Colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
			style.Colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.45, 0.45, 0.90, 0.80);
			style.Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
			style.Colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
			style.Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.20, 0.20, 0.20, 0.35);
		end
	},
	{
		change = function() -- blue
			local style = imgui.GetStyle()
			local colors = style.Colors

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
			style.Colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
			style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, 0.94);
			style.Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
			style.Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.08, 0.08, 0.08, 0.94);
			style.Colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
			style.Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
			style.Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.16, 0.29, 0.48, 0.54);
			style.Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.40);
			style.Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.26, 0.59, 0.98, 0.67);
			style.Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.04, 0.04, 0.04, 1.00);
			style.Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.16, 0.29, 0.48, 1.00);
			style.Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
			style.Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
			style.Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.02, 0.02, 0.02, 0.53);
			style.Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.31, 0.31, 0.31, 1.00);
			style.Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
			style.Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
			style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
			style.Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.24, 0.52, 0.88, 1.00);
			style.Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
			style.Colors[imgui.Col.Button] = imgui.ImVec4(0.26, 0.59, 0.98, 0.40);
			style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
			style.Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.06, 0.53, 0.98, 1.00);
			style.Colors[imgui.Col.Header] = imgui.ImVec4(0.26, 0.59, 0.98, 0.31);
			style.Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.80);
			style.Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
			style.Colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
			style.Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.10, 0.40, 0.75, 0.78);
			style.Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.10, 0.40, 0.75, 1.00);
			style.Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.26, 0.59, 0.98, 0.25);
			style.Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.67);
			style.Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.26, 0.59, 0.98, 0.95);
			style.Colors[imgui.Col.Tab] = imgui.ImVec4(0.18, 0.35, 0.58, 0.86);
			style.Colors[imgui.Col.TabHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.80);
			style.Colors[imgui.Col.TabActive] = imgui.ImVec4(0.20, 0.41, 0.68, 1.00);
			style.Colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
			style.Colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
			style.Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
			style.Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
			style.Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
			style.Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
			style.Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.26, 0.59, 0.98, 0.35);
			style.Colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
			style.Colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
			style.Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
			style.Colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
			style.Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
		end
	},
	{
		change = function() -- black-blue
			local style = imgui.GetStyle();
            local colors = style.Colors;

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

            colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
            colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
            colors[imgui.Col.WindowBg] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
            colors[imgui.Col.PopupBg] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
            colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
            colors[imgui.Col.FrameBg] = imgui.ImVec4(0.13, 0.18, 0.38, 0.94);
            colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.12, 0.21, 0.53, 0.94);
            colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.14, 0.28, 0.83, 0.94);
            colors[imgui.Col.TitleBg] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
            colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
            colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.53);
            colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.17, 0.19, 0.29, 0.94);
            colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
            colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
            colors[imgui.Col.CheckMark] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
            colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.24, 0.52, 0.88, 1.00);
            colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
            colors[imgui.Col.Button] = imgui.ImVec4(0.26, 0.59, 0.98, 0.40);
            colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
            colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.06, 0.53, 0.98, 1.00);
            colors[imgui.Col.Header] = imgui.ImVec4(0.26, 0.59, 0.98, 0.31);
            colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.80);
            colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
            colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
            colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.10, 0.40, 0.75, 0.78);
            colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.10, 0.40, 0.75, 1.00);
            colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.05, 0.10, 0.28, 0.94);
            colors[imgui.Col.Tab] = imgui.ImVec4(0.25, 0.33, 0.63, 0.94);
            colors[imgui.Col.TabHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.80);
            colors[imgui.Col.TabActive] = imgui.ImVec4(0.20, 0.41, 0.68, 1.00);
            colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
            colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
            colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
            colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
            colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
            colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
            colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.26, 0.59, 0.98, 0.35);
            colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
            colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
            colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
            colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
            colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
		end
	},
	{
		change = function() -- dark
			local style = imgui.GetStyle()


			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			
		
			imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.00, 0.00, 0.00, 0.82)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
            imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
            imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
            imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
		end
	},
	{
		change = function() -- softblue
			local style = imgui.GetStyle()
			local colors = style.Colors
		

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.90, 0.93, 1.00)
			style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
			style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
			style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.13, 0.13, 0.15, 1.00)
			style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
			style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
			style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
			style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
			style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
			style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.10, 0.10, 0.12, 1.00)
			style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
			style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
			style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
			style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
			style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
			style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
			style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.80, 0.80, 0.90, 1.00)
			style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
			style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
			style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
			style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
			style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
			style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
			style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
			style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
			style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.60, 0.60, 0.65, 1.00)
			style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
			style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
			style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
			style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
			style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
			style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
			style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
			style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
			style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.10, 0.10, 0.12, 0.80)
			style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.18, 0.20, 0.22, 1.00)
			style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
			style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
		end
	},
	{
		change = function() -- softorange
			local style = imgui.GetStyle()
			local colors = style.Colors
		

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 0.90, 0.85, 1.00)
			style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.75, 0.60, 0.55, 1.00)
			style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.25, 0.15, 0.10, 1.00)
			style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.30, 0.20, 0.15, 1.00)
			style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.80, 0.35, 0.20, 1.00)
			style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.30, 0.20, 0.15, 1.00)
			style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.45, 0.25, 0.20, 1.00)
			style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.55, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.25, 0.15, 0.10, 1.00)
			style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.20, 0.10, 0.05, 1.00)
			style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.30, 0.20, 0.15, 1.00)
			style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.25, 0.15, 0.10, 1.00)
			style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.25, 0.15, 0.10, 1.00)
			style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.80, 0.35, 0.20, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.90, 0.50, 0.35, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(1.00, 0.65, 0.50, 1.00)
			style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 0.65, 0.50, 1.00)
			style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(1.00, 0.65, 0.50, 1.00)
			style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(1.00, 0.70, 0.55, 1.00)
			style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.30, 0.20, 0.15, 1.00)
			style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.90, 0.50, 0.35, 1.00)
			style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(1.00, 0.55, 0.40, 1.00)
			style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.45, 0.25, 0.20, 1.00)
			style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.55, 0.30, 0.25, 1.00)
			style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.65, 0.40, 0.30, 1.00)
			style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.80, 0.35, 0.20, 1.00)
			style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.90, 0.50, 0.35, 1.00)
			style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(1.00, 0.65, 0.50, 1.00)
			style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.45, 0.25, 0.20, 1.00)
			style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.55, 0.30, 0.25, 1.00)
			style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.65, 0.40, 0.30, 1.00)
			style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.90, 0.50, 0.35, 1.00)
			style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.55, 0.40, 1.00)
			style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.50, 0.35, 1.00)
			style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.55, 0.40, 1.00)
			style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.55, 0.30, 0.25, 1.00)
			style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.25, 0.15, 0.10, 0.80)
			style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.30, 0.20, 0.15, 1.00)
			style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.90, 0.50, 0.35, 1.00)
			style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(1.00, 0.55, 0.40, 1.00)
		end
	},
	{
		change = function() -- softgrey
			local style = imgui.GetStyle()
			local colors = style.Colors
		

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.80, 0.80, 0.83, 1.00)
			style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
			style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.16, 0.16, 0.17, 1.00)
			style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.18, 0.18, 0.19, 1.00)
			style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.31, 0.31, 0.35, 1.00)
			style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
			style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.35, 0.35, 0.37, 1.00)
			style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.45, 0.45, 0.47, 1.00)
			style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
			style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
			style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
			style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
			style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.20, 0.20, 0.22, 1.00)
			style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.33, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
			style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
			style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.60, 0.60, 0.63, 1.00)
			style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
			style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
			style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.45, 0.45, 0.47, 1.00)
			style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
			style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.45, 0.45, 0.48, 1.00)
			style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.30, 0.30, 0.33, 1.00)
			style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
			style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
			style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.30, 0.30, 0.33, 1.00)
			style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.65, 0.65, 0.68, 1.00)
			style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.75, 0.75, 0.78, 1.00)
			style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.65, 0.65, 0.68, 1.00)
			style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.75, 0.75, 0.78, 1.00)
			style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.20, 0.20, 0.22, 0.80)
			style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.25, 0.25, 0.27, 1.00)
			style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.35, 0.35, 0.38, 1.00)
			style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.40, 0.40, 0.43, 1.00)
		end
	},
	{
		change = function() -- softgreen
			local style = imgui.GetStyle()
			local colors = style.Colors
		

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.85, 0.93, 0.85, 1.00)
			style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.55, 0.65, 0.55, 1.00)
			style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.13, 0.22, 0.13, 1.00)
			style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.15, 0.24, 0.15, 1.00)
			style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
			style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
			style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
			style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
			style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.18, 0.28, 0.18, 1.00)
			style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
			style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
			style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.35, 0.45, 0.35, 1.00)
			style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.50, 0.70, 0.50, 1.00)
			style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.50, 0.70, 0.50, 1.00)
			style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.55, 0.75, 0.55, 1.00)
			style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
			style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
			style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
			style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.28, 0.38, 0.28, 1.00)
			style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
			style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
			style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.35, 0.45, 0.35, 1.00)
			style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
			style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
			style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.60, 0.70, 0.60, 1.00)
			style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.65, 0.75, 0.65, 1.00)
			style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.60, 0.70, 0.60, 1.00)
			style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.65, 0.75, 0.65, 1.00)
			style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
			style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.15, 0.25, 0.15, 0.80)
			style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
			style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
			style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
		end
	},
	{
		change = function() -- softred 
			local style = imgui.GetStyle()
			local colors = style.Colors
		

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.85, 0.85, 1.00)
			style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
			style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.15, 0.03, 0.03, 1.00)
			style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.15, 0.03, 0.03, 1.00)
			style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.50, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.25, 0.07, 0.07, 1.00)
			style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.08, 0.08, 1.00)
			style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.30, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.20, 0.05, 0.05, 1.00)
			style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.15, 0.03, 0.03, 1.00)
			style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.25, 0.07, 0.07, 1.00)
			style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.20, 0.05, 0.05, 1.00)
			style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.15, 0.03, 0.03, 1.00)
			style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.50, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.60, 0.12, 0.12, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.70, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.90, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.90, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.90, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.25, 0.07, 0.07, 1.00)
			style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.80, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.90, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.25, 0.07, 0.07, 1.00)
			style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.80, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.90, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.50, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.60, 0.12, 0.12, 1.00)
			style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.70, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.25, 0.07, 0.07, 1.00)
			style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.80, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.90, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.80, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.90, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.80, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.90, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.90, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.20, 0.05, 0.05, 0.80)
			style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.25, 0.07, 0.07, 1.00)
			style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.80, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.90, 0.25, 0.25, 1.00)
		end
	},
	{
		change = function() -- softblack
			local style = imgui.GetStyle()
			local colors = style.Colors
		

			style.Alpha = 1;
			style.WindowPadding = imgui.ImVec2(8.00, 8.00);
			style.WindowRounding = 0;
			style.WindowBorderSize = 1;
			style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
			style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
			style.ChildRounding = 0;
			style.ChildBorderSize = 1;
			style.PopupRounding = 0;
			style.PopupBorderSize = 1;
			style.FramePadding = imgui.ImVec2(4.00, 3.00);
			style.FrameRounding = 0;
			style.FrameBorderSize = 0;
			style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
			style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
			style.IndentSpacing = 21;
			style.ScrollbarSize = 14;
			style.ScrollbarRounding = 9;
			style.GrabMinSize = 10;
			style.GrabRounding = 0;
			style.TabRounding = 4;
			style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
			style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
			

			style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.90, 0.80, 1.00)
			style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.60, 0.50, 0.50, 1.00)
			style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
			style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
			style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
			style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
			style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
			style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
			style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.66, 0.66, 0.66, 1.00)
			style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.66, 0.66, 0.66, 1.00)
			style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
			style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
			style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
			style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
			style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
			style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
			style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)
			style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
			style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
			style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.95, 0.95, 0.70, 1.00)
			style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.70, 0.70, 0.73, 1.00)
			style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.95, 0.95, 0.70, 1.00)
			style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.25, 0.25, 0.15, 1.00)
			style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.10, 0.10, 0.10, 0.80)
			style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
			style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
			style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
		end
	}
}
