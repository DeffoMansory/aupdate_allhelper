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
local colorList = {u8'Классический', u8'Синий', u8'Синий v2', u8'Тёмный', u8'SoftBlue', u8'SoftOrange', u8'SoftGrey', u8'SoftGreen', u8'SoftRed', u8'SoftBlack'}
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
                print('Скачиваю '..decodeJson(response.text)['url']..' в '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('Скрипт обновлен, перезагрузка...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('Ошибка, невозможно установить обновление, код: '..response.status_code, -1)
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
local presentlist = {u8'Real Money (/rdonate)', u8'Gold Coins (Золотые моенты)', 'F-Coins (/fcoins)', 'Donate Points (/donate)', u8'Color Ore (Цветная руда)'}
local ImPresent = imgui.new['const char*'][#presentlist](presentlist)
----------------- COMBO ITEM -----------------

local WhiteAccessories = {}

local commandsList =
{
	{'/alh', 'открыть главное меню хелпера'},
	{'/amp', 'замена /mp, если она не работает'},
	{'/amsg', 'отправка MSG сообщений (Настройки)'},
	{'/arec', 'перезаход на сервер'},
	{'/recname', 'перезаход с указанным ником'},
	{'/punish', 'большая часть правил в одном окне'}
}

local amsg1 =
{
	{'/msg Уважаемые игроки. Напоминаю вам, что..'},
	{'/msg Каждый день, в 17:00 по МСК проходит раздача 50-ти донат рублей (/donat).'},
	{'/msg В 19:00 проходит мероприятие на 50 реальных рублей (/rdonate).'},
}

local amsg2 =
{
	{'/msg Уважаемые игроки. Хочу вам напомнить.. Если вы увидели читера — оповестите администрацию (/rep).'},
	{'/msg Показалось, что кто-то ведёт себя подозрительно и он не владелец аккаунта — оповестите администрацию (/rep).'},
	{'/msg Напоминаю, что за ложную подачу информации вы можете получить блокировку репорта за offtop (От 1 до 30 минут).'}
}
		
local lastUpdate =
{
	{'{ffcc00}28.03.2025 {ffffff}— мини-обновление. {ffcc00}Версия: 3.50'},
	{'{ffffff}• Было добавлено автоматическое пробитие pgetip по getip'},
	{'Чтобы активировать возможность — перейдите в "Настройки" > "Авто-пробитие pgetip по getip"'},
	{'{ffcc00}09.03.2025 {ffffff}— обновление. {ffcc00}Версия: 3.40'},
	{'{ffffff}• Был изменён дизайн главного меню скрипта'},
	{'• Был добавлен список юзеров имеющих доступ к скрипту'},
	{'• Добавлен новый раздел "Другое"'},
	{'• Были перенесены некоторые функции из раздела "Настройки" в "Другое"'},
	{'• Добавлена возможность меня цвет темы скрипта'},
	{'• Исправлена ошибка с выдачей лидерки через кнопку "Выдача должности"'},
	{'{ffcc00}08.03.2025 {ffffff}— мини-обновление. {ffcc00}Версия: 3.30'},
	{'{ffffff}• Были заменены и добавлены некоторые иконки в скрипте'},
	{'• Изменены размеры кнопок в разделе "Проведение отбора"'},
	{'• Исправлен баг открытия меню выдачи должности'},
	{'• Исправлены размеры окна меню выдачи должности'}
}

local updateText = ""
for _, update in ipairs(lastUpdate) do
    updateText = updateText .. update[1] .. "\n"
end

local afracNames =
{
	{1, 'LSPD'},
	{2, 'ФБР'},
	{3, 'Армия ЛС'},
	{4, 'Больница'},
	{5, 'La Cosa Nostra'},
	{6, 'Yakuza'},
	{7, 'Мэрия'},
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
	{26, 'Правительство'}
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
        sampAddChatMessage('[AllHelper]: {FFFFFF}Ошибка сохранения текста!', 0x696969)
    end
end

local function floodLogic(index)
    while floodActive[index] do
        local delay = tonumber(str(inputDelays[index]))
        if not delay or delay <= 0 then
            sampAddChatMessage(string.format('[AllHelper]: {FFFFFF}Установите задержку для текста %d!', index), 0x696969)
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
local delltext = {'Ace_Will', 'attractive-rp.ru', 'SAN', 'SAN', 'сайте', 'Подсказка', '/vacancy', '.* отправил VIP пользователь %w+_%w+%[%d+%]'}
----------------- NAVIGATION LIST -----------------
local navigation = {
    current = 1,
    list = {u8'Основное меню', u8'Гос. структуры', u8'Саппорты', u8'Гетто', u8'Мафии'}
}
local gos_navigation = {
	current = 1,
	list = {u8'Полиция | ФБР', u8'АП | Мэрия', u8' San-News', u8'Больница'}
}
local mafia_navigation = {
	current = 1,
	list = {u8'LCN | Yakuza | Russian Mafia | Warlocks MC', u8'Hitmans Agency'}
}
local mp_navigation = {
    current = 1,
    list = {u8"Меню настроек оповещений", u8"Список и правила мероприятий"}
}
local warn_navigation = {
    current = 1,
    list = {u8"Администрация", u8"Лидеры", u8"Саппорты"}
}
local punish_navigation = {
    current = 1,
    list = {u8'Правила выдачи наказаний',u8'Правила для администрации',u8'Правила для лидеров '}
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
		if imgui.Button(faicons(u8'CROWN')..u8' Проведение отбора ', imgui.ImVec2(150, 35)) then
			menuSwitch = 1
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'GIFT')..u8' Проведение МП      ', imgui.ImVec2(150, 35)) then
			menuSwitch = 2
		end
		-- if imgui.Button(faicons(u8'USER')..u8' Выдача выговоров      ', imgui.ImVec2(150, 35)) then
		if imgui.Button(faicons(u8'LIGHT_EMERGENCY_ON')..u8' Выдача выговоров      ', imgui.ImVec2(150, 35)) then
			menuSwitch = 4
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'FOLDERS')..u8' Флудер                 ', imgui.ImVec2(150, 35)) then
			menuSwitch = 5
		end
		if imgui.Button(faicons(u8'GEAR')..u8' Настройки              ', imgui.ImVec2(150, 35)) then
			menuSwitch = 3
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'SPARKLES')..u8' Другое		              ', imgui.ImVec2(150, 35)) then
			menuSwitch = 6
		end
		if imgui.Button(faicons(u8'PAPER_PLANE')..u8' Обратная связь      ', imgui.ImVec2(150, 35)) then
			os.execute(('explorer.exe "%s"'):format("https://vk.com/number1241"))
		end
		imgui.SameLine()
		if imgui.Button(faicons(u8'CIRCLE_INFO')..u8' Послед. обновление      ', imgui.ImVec2(150, 35)) then
			menu[0] = false
			printStyledString(cyrillic("Последнее обновление вышло ~g~28.03.2025"), 1500, 5)
			sampShowDialog(1914, 'Список изменений', updateText, 'Закрыть', '', 0)
		end
		if imgui.Button(u8'Обновить скрипт', imgui.ImVec2(300, 35)) then
			update():download()
		end
		imgui.EndChild()
		imgui.SameLine(335)
		imgui.BeginChild('##menuDes', imgui.ImVec2(317,168), 1)
		imgui.CenterText(faicons(u8'SQUARE_INFO')..u8' Информация о скрипте')
		imgui.Separator()
		imgui.CenterText(u8'Версия: 4.00')
		imgui.CenterText(u8'Тип: X')
		imgui.CenterText(u8'Разработчик: New_Blood')
		imgui.Separator()
		imgui.CenterText(faicons(u8'ADDRESS_CARD')..u8' Юзеры скрипта')
		imgui.Separator()
		imgui.CenterText(u8'Orlando_BlackStar, Burger_Endless')
		-- if #nickList > 0 then
		-- 	for _, playerNick in ipairs(nickList) do
		-- 		imgui.CenterText(playerNick)  -- Выводим каждый ник
		-- 	end
		-- else
		-- 	imgui.CenterText(u8"Список ников пуст.")
		-- end
		imgui.EndChild()
		imgui.BeginChild('##menuDes2', imgui.ImVec2(640,150), 0)
		imgui.CenterText(faicons(u8'SEAL_QUESTION')..u8' Помощь')
		imgui.Separator()
		for i=1, #commandsList do
			imgui.CenterText(u8(commandsList[i][1] .. " — " .. commandsList[i][2]))
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
		imgui.Begin(u8'Проведение отбора', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
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
				if imgui.Button(u8'Выдача должности', imgui.ImVec2(155,25)) then
					setWindow[0] = not setWindow[0]
				end
				imgui.EndChild()
				imgui.BeginChild('##msgButtons', imgui.ImVec2(520, 175), 0)
				if imgui.Button(u8'Оповестить о отборе (Лидер)', imgui.ImVec2(250,45)) then
					if selected[0] == nil or selected[0] < 1 then
						sampAddChatMessage('[Ошибка]: {ffffff}Выберите лидерскую должность для дальнейшего проведения отбора!', 0xFF6600)
					else
						local selected_value = fracNames[selected[0] + 1][2]
						sampSendChat('/msg [Отбор]: Сейчас пройдёт отбор на пост лидерства "'..selected_value..'". Желающие - /gotp (от одного часа).')
					end
				end
				imgui.SameLine()
				if imgui.Button(u8'Оповестить о недостачи участников', imgui.ImVec2(250,45)) then
					if selected[0] == nil or selected[0] < 1 then
						sampAddChatMessage('[Ошибка]: {ffffff}Выберите лидерскую должность на которую проводите отбор!', 0xFF6600)
					else
						local selected_value = fracNames[selected[0] + 1][2]
						sampSendChat('/msg [Отбор]: Отбор на должность лидерства "'..selected_value..'" был отменён из-за недостачи участников.')
					end
				end
				if imgui.Button(u8'Оповестить о отборе (Саппорт)', imgui.ImVec2(250,45)) then
					sampSendChat('/msg [Отбор]: Сейчас пройдёт отбор на должность "Саппорт". Желающие - /gotp (от одного часа)')
				end
				imgui.SameLine()
				if imgui.Button(u8'Зачитать правила', imgui.ImVec2(250,45)) then
					lua_thread.create(function()
						sampSendChat('/m Приветствую! Вы попали на отбор. Сейчас Вам будут зачитаны правила.')
						wait(1500)
						sampSendChat('/m [Правила]: Первому на ответ 15 секунд, остальным по 10 секунд.')
						wait(1500)
						sampSendChat('/m [Правила]: Запрещено использовать чат/команды с чатом. Исключение: sms/rep для ответа проводящему.')
						wait(1500)
						sampSendChat('/m [Правила]: Запрещно выбегать из строя, стоять AFK 4+ секунды и отвечать вне очереди.')
						wait(1500)
						sampSendChat('/m [Правила]: Запрещено мешать участникам/проводящему отбора или как-либо нарушать правила проекта.')
						wait(1500)
						sampSendChat('/m [Примечание]: Если кто-то остаётся последним и решает писать ответ в чат без ранее полученого разрешения — спавн.')
						wait(1500)
						sampSendChat('/m Начнём!')
					end)
				end
				imgui.EndChild()
			elseif navigation.current == 2 then
				if imgui.Button(u8'Блат кого-либо') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за блат?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Что будет лидеру за рекламу') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за рекламу?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}снятие + /ban', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Неадекватное поведение') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за неадекватное поведение?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Два выговора + mute', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Получение девяткой варн') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру, если его заместитель получит варн')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Ничего', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'DeathMatch') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за DM')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Выговор + jail', -1)
					end)
				end
				if imgui.Button(u8'Неотыгровка 1 часа') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за неотыгровку нормы 1 часа?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Снятие', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'NonRP название рангов') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за NonRP название рангов?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}2 выговора', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'5 причин по которых могут снять с лидерки') then
						lua_thread.create(function()
						sampSendChat('/m Назовите 5 причин, по которым могут снять с поста лидера')
						wait(110)
						sampAddChatMessage('Примерные причины: {ffcc00}Упом. родни, читы, читы с твинков, реклама, нонРП ник, расформ 5+, слив, неактив, отсутствие нормы онлайна..', -1)
						sampAddChatMessage('Примерные причины: {ffcc00}3/3 отсутствие отчёта, 3/3 строгих предупреждений, 4/4 устных предупреждений.', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Упоминание родни') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру за упоминание родни?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Снятие + mute', -1)
					end)
				end
				if imgui.Button(u8'3 причины по которым можно получить 2 выговора') then
						lua_thread.create(function()
						sampSendChat('/m Назовите 3 причины, по которым можно получить 2 выговора (гос)')
						wait(110)
						sampAddChatMessage('Причины: {ffcc00}NonRP названия рангов, отсутствие отчёта, розжиг межнациональной розни..', -1)
						sampAddChatMessage('Причины: {ffcc00}Отказ от ГРП, неуважительно отношение к {ff0000}красной администрации', -1)
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
				if imgui.Button(u8'[Полиция | ФБР] Как выдать розыск') then
					lua_thread.create(function()
					sampSendChat('/m Как выдать розыск? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/su(spect)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[Полиция | ФБР] Как писать текст в мегафон') then
					lua_thread.create(function()
					sampSendChat('/m Как писать текст в мегафон? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}(/m)egaphone', -1)
					end)
				end
				if imgui.Button(u8'[Полиция | ФБР] Как посмотреть список разыскиваемых') then
					lua_thread.create(function()
					sampSendChat('/m Как посмотреть список разыскиваемых людей? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/wanted', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[Полиция | ФБР] Как писать текст в департамент') then
					lua_thread.create(function()
					sampSendChat('/m Как писать текст в департамент? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}(/d)epartments /db (одно из двух)', -1)
					end)
				end
				if imgui.Button(u8'[Полиция | ФБР] Как обыскать игрока') then
					lua_thread.create(function()
					sampSendChat('/m Как обыскать игрока? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/frisk', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[Полиция | ФБР] Как писать текст в гос. новости') then
					lua_thread.create(function()
					sampSendChat('/m Как писать текст в гос. новости? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}(/gov)ernment', -1)
					end)
				end
				if imgui.Button(u8'[Полиция | ФБР] Как выставить шипы') then
					lua_thread.create(function()
					sampSendChat('/m Как ? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/block', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[Полиция | ФБР] Как одеть щит') then
					lua_thread.create(function()
					sampSendChat('/m Как одеть щит? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/shield', -1)
					end)
				end
				if imgui.Button(u8'[Полиция | ФБР] Как выдать ключ от участка') then
					lua_thread.create(function()
					sampSendChat('/m Как выдать ключ от участка? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/givecopkeys', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[Полиция | ФБР] Как поставить объекты') then
					lua_thread.create(function()
					sampSendChat('/m Как поставить объекты (будка КПП, знаки, ограждения, отбойники и т.д)? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/break', -1)
					end)
				end
				if imgui.Button(u8'[ФБР] Как понизить / уволить человека с другой организации') then
				lua_thread.create(function()
					sampSendChat('/m Как понизить / уволить человека с другой организации? (Команда)')
					wait(110)
					sampAddChatMessage('{ffcc00}/demote',-1)
				end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[ФБР] Как оглушить всех рядом стоящих жителей') then
					lua_thread.create(function()
						sampSendChat('Как оглушить всех рядом стоящих жителей? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/frazer',-1)
					end)
				end
				if imgui.Button(u8'[ФБР] Как одеть маскировку') then
					lua_thread.create(function()
						sampSendChat('/m Как одеть маскировку? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/spy (/hmask)',-1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[ФБР] Как прослушивать рации других организаций') then
					lua_thread.create(function()
						sampSendChat('/m Как прослушивать рации других организаций? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/follow',-1)
					end)
				end
				if imgui.Button(u8'[Полиция | ФБР] Как посмотреть список людей Вашей организации онлайн') then
					lua_thread.create(function()
						sampSendChat('/m Как посмотреть список людей Вашей организации онлайн? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/members',-1)
					end)
				end
				elseif gos_navigation.current == 2 then
				if imgui.Button(u8'[АП | Мэрия] Как выдать розыск гос. служащему') then
					lua_thread.create(function()
						sampSendChat('/m Как выдать розыск гос. служащему? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/govsu',-1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[Мэрия] Как снять деньги с казны штата') then
					lua_thread.create(function()
						sampSendChat('/m Как снять деньги с казны штата? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/takekazna',-1)
					end)
				end
				if imgui.Button(u8'[АП] Как понизить / уволить человека с другой организации') then
					lua_thread.create(function()
						sampSendChat('/m Как понизить / уволить человека с другой организации? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/demote',-1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'[АП] Как оглушить всех рядом стоящих жителей') then
					lua_thread.create(function()
						sampSendChat('/m Как оглушить всех рядом стоящих жителей? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/ftazer',-1)
					end)
				end
				elseif gos_navigation.current == 3 then
				if imgui.Button(u8'Как редактировать объявления') then
					lua_thread.create(function()
						sampSendChat('/m Как редактировать объявления? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/edit',-1)
					end)
				end
				elseif gos_navigation.current == 4 then
				if imgui.Button(u8'Ломка') then
					lua_thread.create(function()
						sampSendChat('/m Как помочь остановить ломку? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/lomka',-1)
					end)
				end imgui.SameLine()
				if imgui.Button(u8'Мед. карта') then
					lua_thread.create(function()
						sampSendChat('/m Как выдать человеку мед. карту? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/givemedcard',-1)
					end)
				end
				if imgui.Button(u8'Вылечить') then
					lua_thread.create(function()
						sampSendChat('/m Как вылечить человека? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/medhelp (/heal)',-1)
					end)
				end imgui.SameLine()
				if imgui.Button(u8'Выгнать из здания') then
					lua_thread.create(function()
						sampSendChat('/m Как выгнать человека из здания? (Команда)')
						wait(110)
						sampAddChatMessage('{ffcc00}/mdpell',-1)
					end)
				end
			end
		elseif navigation.current == 3 then
				if imgui.Button(u8'Игнорирование просьб ГС') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за игнорирование просьб главного следящего?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Отсутсвие нормы онлайна') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за отсутствие нормы онлайны?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Снятие', -1)
					end)
				end
				if imgui.Button(u8'Неактив 24 часа') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за неактив 24 часа?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Снятие', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Неверный ответ') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за неверный ответ?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
					end)
				end
				if imgui.Button(u8'NonRP ник') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за NonRP ник?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Снятие', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Транслит в ответе') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за трансил в ответе?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
					end)
				end
				if imgui.Button(u8'Ошибки/неграмотность в ответе') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за наличие ошибок, проявление неграмотности при ответе, неполноценные ответы?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
					end)
				end
				if imgui.Button(u8'Использование читов') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за использование читов?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Снятие + jail/warn', -1)
					end)
				end
				if imgui.Button(u8'DeathMatch') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за DM?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Выговор + jail', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'0 ответов') then
					lua_thread.create(function()
					sampSendChat('/m Что будет саппорту за наличие 0 ответов?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}2 выговора', -1)
					end)
				end
		elseif navigation.current == 4 then
				if imgui.Button(u8'Что будет банде за ТКД') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде за труднодоступную крышу во время капта, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}2/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Броня на капте') then
					lua_thread.create(function()
					sampSendChat('/m Что будет бинде за использование бронежилета во время капта, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}1/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
					end)
				end
				if imgui.Button(u8'Fly Hack') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде использование Fly Hack, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}2/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'CARSHOT') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде использование CARSHOT, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}3/3 банде, игроку /ban', -1)
					end)
				end
				if imgui.Button(u8'Намеренный SK') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде за намеренный SK, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}2/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Капт Кусоком/обрезом') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде за капт куском/обрезом, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}3/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
					end)
				end
				if imgui.Button(u8'3/3 капт (лидер в сети)') then
					lua_thread.create(function()
					sampSendChat('/m Что будет лидеру, если его банда получила 3/3, когда он был в сети?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
					end)
				end
				if imgui.Button(u8'Стрельба из пассажирского окна') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде, если кто-то из них будет стерлять из пассажирского окна, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}3/3 банде, игроку ничего (если лидер - выговор)', -1)
					end)
				end
				if imgui.Button(u8'Silent-AIM') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде за использование AIM, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}3/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'Исп. +C на капте анти+С') then
					lua_thread.create(function()
					sampSendChat('/m Что будет банде за +С на анти +С капте, и игроку который нарушил правило?')
					wait(110)
					sampAddChatMessage('Наказание: {ffcc00}3/3 банде, игроку jail/warn (лидеру выговор если он в сети)', -1)
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
					if imgui.Button(u8'Неявка') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии за неприезд на стреле в течении 3-х минут?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}3/3 мафии, если лидер был в сети - выговор', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'Маска') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру и мафии за использование маски на стреле?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}1/3 мафии, игроку jail/warn.', -1)
						end)
					end
					if imgui.Button(u8'+C') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии, если кто-то на стреле из них будет использовать +С, и игроку который нарушил правило?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}1/3 мафии, игроку jail/warn', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'3/3 стрела (лидер в сети)') then
						lua_thread.create(function()
						sampSendChat('/m Что будет лидеру, если его мафия получила 3/3, когда он был в сети?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}Выговор', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'FLY') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии, если кто-то на стреле из них будет использовать FLY, и игроку который нарушил правило?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}1/3 мафии, игроку jail/warn', -1)
						end)
					end
					if imgui.Button(u8'Запрещённый ТС') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии, если кто-то на стреле прилетит на Hunter | Hydra, и что будет игроку который нарушил правило?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}3/3 мафии, игроку jail/warn (лидеру выговор если он в сети)', -1)
						end)
					end
					if imgui.Button(u8'Анти-захват бизнеса') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии за анти-захват бизнеса?')
						wait(110)
						sampAddChatMessage('Пример: {ffcc0}LCN едет забивать стрелу Yakuza, но Yakuza убили его, чтобы тот им не забил стрелу')
						sampAddChatMessage('Пример: {ffcc00}ID 1 LCN, ID 2 - Yakuza. Если ID 2 убил ID 1, то ID 2 получает варн')
						sampAddChatMessage('Наказание: {ffcc00}3/3 мафии, игроку jail/warn (лидеру выговор если он в сети)', -1)
						end)
					end
					if imgui.Button(u8'ТДК') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии, если кто-то на стреле залезет на труднодоступную крышу, и что будет игроку который нарушил правило?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}2/3 мафии, игроку jail/warn', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'Аптечка/наркотики в бою') then
						lua_thread.create(function()
						sampSendChat('/m Что будет мафии, если кто-то на стреле будет использовать аптечки/наркотики в бою, и что будет игроку который нарушил правило?')
						wait(110)
						sampAddChatMessage('Наказание: {ffcc00}1/3 мафии, игроку jail/warn', -1)
						end)
					end
				elseif mafia_navigation.current == 2 then
					if imgui.Button(u8'Какое минимальное кол-во контрактов для отчёта') then
						lua_thread.create(function()
							sampSendChat('/m Какое минимальное кол-во контрактов для отчёта?')
							wait(110)
							sampAddChatMessage('{ffcc00}3 контракта',-1)
						end)
					end imgui.SameLine()
					if imgui.Button(u8'От скольких минут должен длиться набор для отчёта') then
						lua_thread.create(function()
							sampSendChat('/m От скольких минут должен длиться набор для отчёта?')
							wait(110)
							sampAddChatMessage('{ffcc00}15 минут',-1)
						end)
					end
					if imgui.Button(u8'От скольких минут должен длиться промежуток между первым и вторым набором для отчёта') then
						lua_thread.create(function()
							sampSendChat('/m От скольких минут должен длиться промежуток между первым и вторым набором для отчёта?')
							wait(110)
							sampAddChatMessage('{ffcc00}10 минут',-1)
						end)
					end
					if imgui.Button(u8'Как одеть маскировку') then
						lua_thread.create(function()
							sampSendChat('/m Как одеть маскировку?')
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
		imgui.Begin(u8'Проведение МП', menu, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
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
				imgui.InputTextWithHint(u8'##4', u8'Название мероприятия', set_namemp, sizeof(set_namemp))
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##5'..faicons('trash')) then 
					imgui.StrCopy(set_namemp,'')
				end
				imgui.TextQuestionMp(u8'Тип: название\nИспользуется для обычного оповещения в /msg')
				imgui.InputTextWithHint(u8'##5', u8'Сумма приза', set_priz, sizeof(set_priz), imgui.InputTextFlags.CharsDecimal)
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##6'..faicons('trash')) then 
					imgui.StrCopy(set_priz,'')
				end
				imgui.TextQuestionMp(u8'Тип: сумма\nИспользуется для обычного оповещения в /msg')
				imgui.InputTextWithHint(u8'##1', u8'Nickname победителя мероприятия', input_name, sizeof(input_name))
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##7'..faicons('trash')) then 
					imgui.StrCopy(input_name,'')
				end
				imgui.TextQuestionMp(u8'Тип: никнейм\nИспользуется для обычного оповещения в /msg')
				imgui.InputTextWithHint(u8'##2', u8'ID победителя мероприятия', input_id, sizeof(input_id), imgui.InputTextFlags.CharsDecimal)
				imgui.SameLine()
				if imgui.Button(faicons('trash')..u8'##8'..faicons('trash')) then 
					imgui.StrCopy(input_id,'')
				end
				imgui.TextQuestionMp(u8'Для должности "Организатор мероприятий"\nИсключительно на Real Money (/rdonate)')
				imgui.Separator()
				imgui.Text('')
				-- imgui.SameLine(100)
				if imgui.Button(faicons('play')..u8'  Начать', imgui.ImVec2(145,0)) then
					local set_namemp = str(set_namemp)
					local set_priz = str(set_priz)
					local selected_prize = u8:decode(ffi.string(presentlist[present[0] + 1]))
					if u8:decode(ffi.string(set_namemp)) ~= '' and u8:decode(ffi.string(set_priz)) ~= '' and selected_prize ~= 0 then
						sampSendChat('/msg Проходит мероприятие "'..u8:decode(ffi.string(set_namemp))..'" на '..u8:decode(ffi.string(set_priz))..' '..selected_prize..'. Желающие - /gotp.')
					else
						sampAddChatMessage('[Ошибка] {ffffff}Значения выбраны неверно', 0x696969)
					end
				end  
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'Оповещает о начале мероприятия')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(faicons('pause')..u8'  Закончить', imgui.ImVec2(145,0)) then
					local input_name = str(input_name)
					local set_namemp = str(set_namemp)
					local set_priz = str(set_priz)
					local selected_prize = u8:decode(ffi.string(presentlist[present[0] + 1]))
					if u8:decode(ffi.string(set_namemp)) ~= '' and u8:decode(ffi.string(set_priz)) ~= '' and u8:decode(ffi.string(input_name)) ~= '' and selected_prize ~= 0 then
						sampSendChat('/msg Победитель мероприятия "'..u8:decode(ffi.string(set_namemp))..'" на '..u8:decode(ffi.string(set_priz))..' '..selected_prize..' — '..u8:decode(ffi.string(input_name))..'. Поздравляем!')
					else
						sampAddChatMessage('[Ошибка] {ffffff}Значения выбраны неверно', 0x696969)
					end
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'Оповещает о завершении мероприятия')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(faicons('star')..u8'  Выдать', imgui.ImVec2(145,0)) then
					local set_namemp = str(set_namemp)
					local input_id = str(input_id)
					local selected_prize = u8:decode(ffi.string(presentlist[present[0] + 1]))
					if u8:decode(ffi.string(set_namemp)) ~= '' and u8:decode(ffi.string(input_id)) ~= '' and selected_prize ~= 1 then
						sampSendChat('/winner '..u8:decode(ffi.string(input_id))..' '..u8:decode(ffi.string(set_namemp))..'')
					else
						sampAddChatMessage('[Ошибка] {ffffff}Значения выбраны неверно', 0x696969)
					end
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'Для должности "Организатор мероприятий"\nИсключительно на Real Money (/rdonate)')
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
				if imgui.Button(u8'Рулетка (На выстрел)', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Запрещено: изменять клист/скин, перебегать с места на место, использовать /me, /do, /todo и /try и т.д')
						wait(1000)
						sampSendChat('/m Запрещено: как либо нарушать правила проекта')
						wait(1000)
						sampSendChat('/m Запрещено: выбегать из строя и мешать другим')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Начнём! Игра будет на выстрел')
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Русская рулетка (На выстрел)')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nЗапрещено: изменять клист/скин, перебегать с места на место, использовать /me, /do, /todo и /try и т.д\nЗапрещено: как либо нарушать правила проекта\nЗапрещено: выбегать из строя и мешать другим\nНачнём! Игра будет на выстрел')
					imgui.EndTooltip()
				end
					imgui.SameLine()
				if imgui.Button(u8'Рулетка (На смерть)', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Запрещено: изменять клист/скин, перебегать с места на место, использовать /me, /do, /todo и /try и т.д')
						wait(1000)
						sampSendChat('/m Запрещено: как либо нарушать правила проекта')
						wait(1000)
						sampSendChat('/m Запрещено: выбегать из строя и мешать другим')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Начнём! Игра будет на смерть')
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Русская рулетка (На смерть/spawn)')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nЗапрещено: изменять клист/скин, перебегать с места на место, использовать /me, /do, /todo и /try и т.д\nЗапрещено: как либо нарушать правила проекта\nЗапрещено: выбегать из строя и мешать другим\nНачнём! Игра будет на смерть')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'Крыша смерти', imgui.ImVec2(151,30)) then 
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')                        
						wait(1000)
						sampSendChat('/m Запрещено: изменять клист/скин и использовать анимации')
						wait(1000)
						sampSendChat('/m Запрещено: AFK более чем 10 секунд, пополнять любыми способами себе ХП, администраторам использовать их возможности')
						wait(1000)
						sampSendChat('/m Запрещено: как либо нарушать правила проекта')
						wait(1000)
						sampSendChat('/m Внимание! Проводящие МП имеют право по вам стрелять.')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Бегите!')
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Крыша смерти')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nЗапрещено: изменять клист/скин и использовать анимации\nЗапрещено: AFK более чем 10 секунд, пополнять любыми способами себе ХП, администраторам использовать их возможности\nЗапрещено: как либо нарушать правила проекта\n/m Внимание! Проводящий МП имеют право по вам стрелять\nБегите!')
					imgui.EndTooltip()
				end
				if imgui.Button(u8'Король дигла', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Запрещено: изменять клист/скин, стрелять в участников/воздух/проводящего мероприятия без причины')
						wait(1000)
						sampSendChat('/m Запрещено: как либо нарушать правила проекта')
						wait(1000)
						sampSendChat('/m Запрещено: выбегать из строя и мешать другим')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Буду оповещать Вас, кто встанет в следущий раунд')
					end)
				end 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Король дигла')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nЗапрещено: изменять клист/скин, стрелять в участников/воздух/проводящего мероприятия без причины\nЗапрещено: как либо нарушать правила проекта\nЗапрещено: выбегать из строя и мешать другим\nБуду оповещать Вас, кто встанет в следущий раунд')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'Прятки', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Запрещено: изменять клист/скин, одевать маску и использовать анимации')
						wait(1000)
						sampSendChat('/m Запрещено: как либо нарушать правила проекта')
						wait(1000)
						sampSendChat('/m Запрещено: использовать админ-возможности и багоюзерство')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m У Вас есть минута, после чего идём искать')
						wait(1000)
						sampSendChat('/m Бегите!')
					end)
				end 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Прятки')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nЗапрещено: изменять клист/скин, одевать маску и использовать анимации\nЗапрещено: как либо нарушать правила проекта\nЗапрещено: использовать админ-возможности и багоюзерство\nУ Вас есть минута, после чего идём искать\nБегите!')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'Арена смерти', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Ваша задача остаться последним в живых')
						wait(1000)
						sampSendChat('/m Я буду по вам стрелять из оружия')
						wait(1000)
						sampSendChat('/m Запрещено:')
						wait(1000)
						sampSendChat('/m Стоять AFK более чем 5 секунд')
						wait(1000)
						sampSendChat('/m Использовать любые читы, пополения ХП, менять клист/скин')
						wait(1000)
						sampSendChat('/m как либо нарушать правила сервера, администрации использовать их возможности')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
					end)
				end 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Арена смерти')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nВаша задача остаться последним в живых\nЯ буду по вам стрелять из оружия\nЗапрещено:\nСтоять AFK более чем 5 секунд\nИспользовать любые читы, пополения ХП, менять клист/скин\nкак либо нарушать правила сервера, администрации использовать их возможности')
					imgui.EndTooltip()
				end
				if imgui.Button(u8'Мясорубка', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Вы забегаете в комнату и я выдаю всем оружие')
						wait(1000)
						sampSendChat('/m Ваша задача остаться последним в живых')
						wait(1000)
						sampSendChat('/m Запрещены пополнения ХП, адм. возможности и нарушения любых правил сервера')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Бегите!') 
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности обычного администратора')
					imgui.Separator()
					imgui.CenterText(u8'Мясорубка')
					imgui.Separator()
					imgui.Text(u8'Правила МП:\nВы забегаете в комнату и я выдаю всем оружие\nВаша задача остаться последним в живых\nЗапрещены пополнения ХП, адм. возможности и нарушения любых правил сервера\nБегите!')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'Последн. заберёт всё', imgui.ImVec2(151,30)) then
					lua_thread.create(function()
						sampSendChat('/m Суть МП:')
						wait(1000)
						sampSendChat('/m Я вызываю людей и они встают во внутрь четырёх стен.')
						wait(1000)
						sampSendChat('/m Вы должны там бегать.')
						wait(1000)
						sampSendChat('/m Я беру гранаты и начинаю их туда кидать.')
						wait(1000)
						sampSendChat('/m Последний кто умрёт в этих стенах или останется живым проходит в следущий раунд.')
						wait(1000)
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Запрещены пополнения ХП, адм. возможности и нарушения любых правил сервера.')
						wait(1000)
						sampSendChat('/m Смена скина/клиста, ВЫЛАЗИТЬ из стен.')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Начнём!') 
					end)
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности "Организатор мероприятий"')
					imgui.Separator()
					imgui.CenterText(u8'Последний заберёт всё')
					imgui.Separator()
					imgui.Text(u8'Суть МП:\nЯ вызываю людей и они встают во внутрь четырёх стен.\nВы должны там бегать.\nЯ беру гранаты и начинаю их туда кидать.\nПоследний кто умрёт в этих стенах или останется живым проходит в следущий раунд.\nПравила МП:\nЗапрещены пополнения ХП, адм. возможности и нарушения любых правил сервера.\nСмена скина/клиста, ВЫЛАЗИТЬ из стен.\nНачнём!')
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Button(u8'Поиск предмета', imgui.ImVec2(151,30)) then
					local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
					lua_thread.create(function()
						sampSendChat('/m Суть МП:')
						wait(1000)
						sampSendChat('/m Где-то в LS расположен предмет, который вы должны найти.')
						wait(1000)
						sampSendChat('/m Если Вы нашли данный предмет - пишите мне в /sms [ID: '..myID..']')
						wait(1000)
						sampSendChat('/m Вы можете брать любой ТС и искать данный предмет.')
						wait(1000)
						sampSendChat('/m Правила МП:')
						wait(1000)
						sampSendChat('/m Запрещены читы, адм. возможности и нарушения любых правил сервера.')
						wait(1000)
						sampSendChat('/m Смена скина/клиста.')
						wait(1000)
						sampSendChat('/m Помеха = кик. Для адм. выговор + кик. За повторную помеху + бан.')
						wait(1000)
						sampSendChat('/m Сейчас я вам покажу этот предмет.') 
					end)
				end
				if imgui.IsItemHovered() then
					local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
					imgui.BeginTooltip()
					imgui.CenterText(u8'Для должности "Организатор мероприятий"')
					imgui.Separator()
					imgui.CenterText(u8'Поиск предмета')
					imgui.Separator()
					imgui.Text(u8'Суть МП:\nГде-то в LS расположен предмет, который вы должны найти.\nЕсли Вы нашли данный предмет - пишите мне в /sms [ID: '..myID..']')
					imgui.Text(u8'Вы можете брать любой ТС и искать данный предмет.\nПравила МП:\nЗапрещены читы, адм. возможности и нарушения любых правил сервера.\nСмена скина/клиста.\nСейчас я вам покажу этот предмет.')
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
		imgui.Begin(u8'Настройки', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.BeginChild('##settings1', imgui.ImVec2(300,195), 0)
		if ad.ToggleButton(u8'Login', elements.value.autologin) then
			config['settings']['autologin'] = elements.value.autologin[0]
			saveConfig()
		end imgui.TextQuestion(u8'Автоматический вход под аккаунт')
		if ad.ToggleButton(u8'Alogin', elements.value.autoalogin) then
			config['settings']['autoalogin'] = elements.value.autoalogin[0]
			saveConfig()
		end imgui.TextQuestion(u8'Автоматический вход под админку')
		if ad.ToggleButton(u8'TEMPLEADER при входе', elements.value.autoleader) then
			config['settings']['autoleader'] = elements.value.autoleader[0]
			saveConfig()
		end imgui.TextQuestion(u8'После входа под админку заходите под временную лидерку')
		if ad.ToggleButton(u8'AGM при входе', elements.value.autogm) then
			config['settings']['autogm'] = elements.value.autogm[0]
			saveConfig()
		end imgui.TextQuestion(u8'После входа под админку включается /agm')
		if ad.ToggleButton(u8'CONNECT при входе', elements.value.autoconnect) then
			config['settings']['autoconnect'] = elements.value.autoconnect[0]
			saveConfig()
		end imgui.TextQuestion(u8'После входа под админку включается /connect')
		if ad.ToggleButton(u8'Приветствие при входе под админку', elements.value.ahi) then 
			config['settings']['ahi'] = elements.value.ahi[0]
			saveConfig()
		end imgui.TextQuestion(u8'После входа под админку воспроизводиться звук приветствия')
		if ad.ToggleButton(u8'Укороченный чат', elements.value.shortadm) then 
			config['settings']['shortadm'] = elements.value.shortadm[0]
			saveConfig()
		end imgui.TextQuestion(u8'Заменяет "Администратор" на "A:" и укорачивает префиксы')
		if ad.ToggleButton(u8'Авто-пробитие pgetip по getip', elements.value.pgetip) then
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
		if ad.ToggleButton(u8'EARS при входе', elements.value.autoears) then
			config['settings']['autoears'] = elements.value.autoears[0]
			saveConfig()
		end imgui.TextQuestion(u8'После вход под админку включается /ears')
		if ad.ToggleButton(u8'AINFO при входе', elements.value.autoainfo) then
			config['settings']['autoainfo'] = elements.value.autoainfo[0]
			saveConfig()
		end imgui.TextQuestion(u8'После входа под админку выключается /ainfo')
		if ad.ToggleButton(u8'Автоматический ТП в место для AFK', elements.value.akv) then
			config['settings']['akv'] = elements.value.akv[0]
			saveConfig()
		end imgui.TextQuestion(u8'После входа под админку телепортируетесь в /inter 72') 
		if ad.ToggleButton(u8'MSG-сообщения', elements.value.msginfo) then
			config['settings']['msginfo'] = elements.value.msginfo[0]
			saveConfig()
		end imgui.TextQuestion(u8'Используйте: /amsg [1-2]')
		imgui.PopItemWidth()
		imgui.EndChild()
		imgui.PopFont()
	elseif menuSwitch == 4 then
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 695, 240
		imgui.PushFont(myFont)
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Выдача выговоров', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
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
			imgui.InputTextWithHint(u8'##333', u8'Введите nickname', input_nameawarn, sizeof(input_nameawarn))
			imgui.TextQuestionMp(u8'Введите ник и выберите ниже причину')
			if imgui.CollapsingHeader(u8'Список наказаний') then
				if imgui.Button(u8'1. Ненормативная лексика в чат, в сторону игроков/администраторов — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 1')
				end
				if imgui.Button(u8'2. DM игроков — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 2')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 2')
					end)
				end
				if imgui.Button(u8'3. Выдавать наказание не имея доказательств нарушения — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 3')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 3')
					end)
				end
				if imgui.Button(u8'4. Засорение репорта — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 4')
				end
				if imgui.Button(u8'5. Оскорбление администраторов/игроков — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 5')
				end
				if imgui.Button(u8'6. Покупка/Продажа чего-либо в /a — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 6')
				end
				if imgui.Button(u8'7. Помеха другим администраторам — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 7')
				end
				if imgui.Button(u8'8. Реклама/Реклама с твинков — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 8')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 8')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 8')
					end)
				end
				if imgui.Button(u8'9. Оффтоп в /msg — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 9')
				end
				if imgui.Button(u8'10. Блат кого-либо из игроков/администраторов — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 10')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 10')
					end)
				end
				if imgui.Button(u8'11. Помеха/Влезание в РП процесс — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 11')
				end
				if imgui.Button(u8'12. Проверка игроков на читы через скайп или дискорд — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 12')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 12')
					end)
				end
				if imgui.Button(u8'13. Попрошайничество — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 13')
				end
				if imgui.Button(u8'14. Использование читов против игроков — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 14')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 14')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 14')
					end)
				end
				if imgui.Button(u8'15. Выдача наказаний по просьбе другого администратора — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 15')
				end
				if imgui.Button(u8'16. Наличие более 1 админ аккаунта — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 16')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 16')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 16')
					end)
				end
				if imgui.Button(u8'17. Выдача наказаний за SMS администрации — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 17')
				end
				if imgui.Button(u8'18. Выдача наказаний за ДМ администрации — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 18')
				end
				if imgui.Button(u8'19. Накрутка репутации — снятие') then 
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 19')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 19')
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 19')
					end)
				end
				if imgui.Button(u8'20. Выпрашивание оценки ответа на репорт — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 20', -1)
				end
				if imgui.Button(u8'21. Выдача выговора в ответ — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 21', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 21', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 21', -1)
					end)
				end
				if imgui.Button(u8'22. Подставные действия на снятие — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 22', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 22', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 22', -1)
					end)
				end
				if imgui.Button(u8'23. Розжиг конфликта — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 23', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 23', -1)
					end)
				end
				if imgui.Button(u8'24. Нарушение правил администрации 3+ раз — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 24', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 24', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 24', -1)
					end)
				end
				if imgui.Button(u8'25. Оск. красной администрации и упоминание/оск. их родни — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 25', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 25', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 25', -1)
					end)
				end
				if imgui.Button(u8'26. Суммирование наказаний — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 26', -1)
				end
				if imgui.Button(u8'27. Розжиг межнациональной розни — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 27', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 27', -1)
					end)
				end
				if imgui.Button(u8'28. Распространение сторонних скриптов — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 28', -1)
				end
				if imgui.Button(u8'29. Злоупотребление капсом в /a /v — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 29', -1)
				end
				if imgui.Button(u8'30. Помощь на капте/бизваре — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 30', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 30', -1)
					end)
				end
				if imgui.Button(u8'31. Слив территорий/бизнесов — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 31', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 31', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
					end)
				end
				if imgui.Button(u8'32. Разглашение цен платных команд — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 32', -1)
					end)
				end
				if imgui.Button(u8'33. Баловство командами — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 33', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 33', -1)
					end)
				end
				if imgui.Button(u8'34. Использование багов сервера для получения материальной выгоды — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 34', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 34', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 34', -1)
					end)
				end
				if imgui.Button(u8'35. Нарушение правил проверки жалоб — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 35', -1)
				end
				if imgui.Button(u8'36. Оскорбление сервера — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 36', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 36', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 36', -1)
					end)
				end
				if imgui.Button(u8'37. Использование /pm в личных целях — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 37', -1)
				end
				if imgui.Button(u8'38. Флуд админ-командами — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 38', -1)
				end
				if imgui.Button(u8'39. Исп. вред.читов/вред.читы с твинков против игроков/адм — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 39', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 39', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 39', -1)
					end)
				end
				if imgui.Button(u8'40. Оскорбление/упоминание родственников или ответ взаимностью — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 40', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 40', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 40', -1)
					end)
				end
				if imgui.Button(u8'41. Капс/флуд в чат, в сторону игроков/администраторов — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 41', -1)
				end
				if imgui.Button(u8'42. Неверная выдача наказания игроку/администратору — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 42', -1)
				end
				if imgui.Button(u8'43. Неверное рассмотрение жалобы на форуме — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 43', -1)
				end
				if imgui.Button(u8'44. Продажа имущества за реальную валюту — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 44', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 44', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 44', -1)
					end)
				end
				if imgui.Button(u8'45. Слив продуктов бизнеса — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 45', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 45', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 45', -1)
					end)
				end
				if imgui.Button(u8'46. Продажа/Передача/Взлом аккаунта — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 46', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 46', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 46', -1)
					end)
				end
				if imgui.Button(u8'47. NonRP развод | Подкид | Развод /try — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 47', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 47', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 47', -1)
					end)
				end
				if imgui.Button(u8'48. NonRP NickName — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 48', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 48', -1)
					end)
				end
				if imgui.Button(u8'49. Слив прав — снятие') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 49', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 49', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 49', -1)
					end)
				end
				if imgui.Button(u8'50. Неуважительный ответ игроку — 2 выговора') then
					local aname = str(input_nameawarn)
					lua_thread.create(function()
						sampSendChat('/awarn '..aname..' /regulations > 50', -1)
						wait(1300)
						sampSendChat('/awarn '..aname..' /regulations > 50', -1)
					end)
				end
				if imgui.Button(u8'51. Выдача наказания с неполной причиной — 1 выговор') then
					local aname = str(input_nameawarn)
					sampSendChat('/awarn '..aname..' /regulations > 51', -1)
				end				
			end
		elseif warn_navigation.current == 2 then
			imgui.InputTextWithHint(u8'##444', u8'Введите nickname', input_namelwarn, sizeof(input_namelwarn))
			imgui.TextQuestionMp(u8'Введите ник и выберите ниже причину')
			if imgui.CollapsingHeader(u8'Частые причины') then
				if imgui.Button(u8'Неактив 24+ часов') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Неактив 24+ часов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Неактив 24+ часов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Неактив 24+ часов', -1)
					end)
				end
				if imgui.Button(u8'Норма онлайна отыгровки за день 1 час.') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Нет нормы онлайна 1 час.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Нет нормы онлайна 1 час.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Нет нормы онлайна 1 час.', -1)
					end)
				end
				if imgui.Button(u8'Упоминание родных') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Упоминание родных', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Упоминание родных', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Упоминание родных', -1)
					end)
				end
				if imgui.Button(u8'Неадекват') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' Неадекват')
				end
			end
			if imgui.CollapsingHeader(u8'Для ГС/ЗГС') then
				if imgui.Button(u8'[Гос. структуры] Отсутствие отчёта 1/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 1/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 1/3', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'[Гос. структуры] Неверный отчёт 1/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Неверный отчёт 1/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Неверный отчёт 1/4', -1)
						end)
					end
					if imgui.Button(u8'[Гос. структуры] Отсутствие отчёта 2/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 2/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 2/3', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'[Гос. структуры] Неверный отчёт 2/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Неверный отчёт 2/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Неверный отчёт 2/4', -1)
						end)
					end
					if imgui.Button(u8'[Гос. структуры] Отсутствие отчёта 3/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Отсутствие отчёта 3/3', -1)
						end)
					end
					imgui.SameLine()
					if imgui.Button(u8'[Гос. структуры] Неверный отчёт 3/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Неверный отчёт 3/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Неверный отчёт 3/4', -1)
						end)
					end
					if imgui.Button(u8'[Гос. структуры] Неверный отчёт 4/4') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Неверный отчёт 4/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Неверный отчёт 4/4', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Неверный отчёт 4/4', -1)
						end)
					end
					if imgui.Button(u8'[Гос. структуры] Отказ от принятия участия в глобальных мероприятиях') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Отказ от принятия участия в глобальных мероприятиях', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Отказ от принятия участия в глобальных мероприятиях', -1)
						end)
					end
					if imgui.Button(u8'[Гетто | Мафии] Менее двух захватов за день 1/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 1/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 1/3', -1)
						end)
					end
					if imgui.Button(u8'[Гетто | Мафии] Менее двух захватов за день 2/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 2/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 2/3', -1)
						end)
					end
					if imgui.Button(u8'[Гетто | Мафии] Менее двух захватов за день 3/3') then
					local lname = str(input_namelwarn)
						lua_thread.create(function()
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 3/3', -1)
							wait(1300)
							sampSendChat('/lwarn '..lname..' Менее двух захватов за день 3/3', -1)
						end)
					end
				end
			if imgui.CollapsingHeader(u8'Список наказаний') then
				if imgui.Button(u8'Неадекват') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' Неадекват')
				end
				if imgui.Button(u8'Неадекватное поведение на форуме') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' Неадекватное поведение на форуме')
				end
				if imgui.Button(u8'Упоминание родных') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Упоминание родных', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Упоминание родных', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Упоминание родных', -1)
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
				if imgui.Button(u8'Увольнение без причин') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' Увольнение без причин')
				end
				if imgui.Button(u8'Принятие игрока с NonRP ником в организацию') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' Принятие игрока с NonRP ником в организацию')
				end
				if imgui.Button(u8'NonRP') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' NonRP')
				end
				if imgui.Button(u8'Реклама') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Реклама', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Реклама', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Реклама', -1)
					end)
				end
				if imgui.Button(u8'Расформ (от 5+ человек)') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Расформ', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Расформ', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Расформ', -1)
					end)
				end
				if imgui.Button(u8'Читы') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Читы', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Читы', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Читы', -1)
					end)
				end
				if imgui.Button(u8'Читы с твинков') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Читы с твинков', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Читы с твинков', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Читы с твинков', -1)
					end)
				end
				if imgui.Button(u8'Блат') then
				local lname = str(input_namelwarn)
				sampSendChat('/lwarn '..lname..' Блат')
				end
				if imgui.Button(u8'Норма онлайна отыгровки за день 1 час.') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Нет нормы онлайна 1 час.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Нет нормы онлайна 1 час.', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Нет нормы онлайна 1 час.', -1)
					end)
				end
				if imgui.Button(u8'Неактив 24+ часов') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Неактив 24+ часов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Неактив 24+ часов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Неактив 24+ часов', -1)
					end)
				end
				if imgui.Button(u8'NonRP названия рангов') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' NonRP названия рангов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' NonRP названия рангов', -1)
					end)
				end
				if imgui.Button(u8'Слив территорий/бизнесов') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Слив территорий/бизнесов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Слив территорий/бизнесов', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Слив территорий/бизнесов', -1)
					end)
				end
				if imgui.Button(u8'Наличие более одной лидерки') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Наличие более одной лидерки', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Наличие более одной лидерки', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Наличие более одной лидерки', -1)
					end)
				end
				if imgui.Button(u8'Продажа/покупка лидерки') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Продажа/покупка лидерки', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Продажа/покупка лидерки', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Продажа/покупка лидерки', -1)
					end)
				end
				if imgui.Button(u8'Продажа ранга') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Продажа ранга', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Продажа ранга', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Продажа ранга', -1)
					end)
				end
				if imgui.Button(u8'Игра с твинков за противоположную банду/мафию') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Игра с твинков за противоположную банду/мафию', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Игра с твинков за противоположную банду/мафию', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Игра с твинков за противоположную банду/мафию', -1)
					end)
				end
				if imgui.Button(u8'Передача лидерского поста на твинк аккаунт') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Передача лидерского поста на твинк аккаунт', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Передача лидерского поста на твинк аккаунт', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Передача лидерского поста на твинк аккаунт', -1)
					end)
				end
				if imgui.Button(u8'Розжиг межнациональной розни, в том числе названия рангов') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Розжиг', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Розжиг', -1)
					end)
				end
				if imgui.Button(u8'Слив поста/лидеров') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Слив поста/лидеров', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Слив поста/лидеров', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Слив поста/лидеров', -1)
					end)
				end
				if imgui.Button(u8'Оскорбление проекта') then
				local lname = str(input_namelwarn)
					lua_thread.create(function()
						sampSendChat('/lwarn '..lname..' Оскорбление проекта', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Оскорбление проекта', -1)
						wait(1300)
						sampSendChat('/lwarn '..lname..' Оскорбление проекта', -1)
					end)
				end
			end
		elseif warn_navigation.current == 3 then
			imgui.InputTextWithHint(u8'##555', u8'Введите nickname', input_nameswarn, sizeof(input_nameswarn))
			if imgui.CollapsingHeader(u8'Для ГС/ЗГС') then
			if imgui.Button(u8'Наличие 0 ответов на посту саппорта') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Наличие 0 ответов на посту саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Наличие 0 ответов на посту саппорта')
				end)
				end
			end
			if imgui.CollapsingHeader(u8'Список наказаний') then
				if imgui.Button(u8'Неверный ответ игроку') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Неверный ответ игроку')
				end
				if imgui.Button(u8'Использование команды для ответов в личных целях') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Использование команды для ответов в личных целях')
				end
				if imgui.Button(u8'Любые нарушения правил сервера со стороны игрового процесса (DM/Оскорбления/Неадекват)') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Нарушение правил сервера со стороны игровоко процесса')
				end
				if imgui.Button(u8'Засорение чата саппортов (Покупка/Продажа/Флуд)') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Засорение чата саппортов')
				end
				if imgui.Button(u8'Игнорирование просьбы главного следящего за саппортами') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Игнорирование просьбы главного следящего за саппортами')
				end
				if imgui.Button(u8'Выдача блокировки репорта, не имея доказательств нарушения') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Выдача блокировки репорта, не имея доказательств нарушения')
				end
				if imgui.Button(u8'Наличие ошибок в ответе') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Наличие ошибок в ответе')
				end
				if imgui.Button(u8'Проявление неграмотности при ответе') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Проявление неграмотности при ответе')
				end
				if imgui.Button(u8'Неполноценные ответы') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Неполноценные ответы')
				end
				if imgui.Button(u8'Транслит в ответе игроку в ответе') then
				local sname = str(input_nameswarn)
				sampSendChat('/swarn '..sname..' Транслит в ответе игроку в ответе')
				end
				if imgui.Button(u8'Попрошайничество в чате саппортову') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Попрошайничество в чате саппортову')
					wait(1300)
					sampSendChat('/swarn '..sname..' Попрошайничество в чате саппортову')
				end)
				end
				if imgui.Button(u8'Попрошайничество в ответе игроку') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Попрошайничество в ответе игроку')
					wait(1300)
					sampSendChat('/swarn '..sname..' Попрошайничество в ответе игроку')
				end)
				end
				if imgui.Button(u8'Неуважительный ответ игроку') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Неуважительный ответ игроку')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неуважительный ответ игроку')
				end)
				end
				if imgui.Button(u8'Отсутствие нормы отыгранного времени за сутки (1 час)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Отсутствие нормы отыгранного времени за сутки (1 час)')
					wait(1300)
					sampSendChat('/swarn '..sname..' Отсутствие нормы отыгранного времени за сутки (1 час)')
					wait(1300)
					sampSendChat('/swarn '..sname..' Отсутствие нормы отыгранного времени за сутки (1 час)')
				end)
				end
				if imgui.Button(u8'Неактивность в течение 24 часов') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Неактивность в течение 24 часов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неактивность в течение 24 часов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неактивность в течение 24 часов')
				end)
				end
				if imgui.Button(u8'Оскорбление родных в ответе') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Оскорбление родных в ответе')
					wait(1300)
					sampSendChat('/swarn '..sname..' Оскорбление родных в ответе')
					wait(1300)
					sampSendChat('/swarn '..sname..' Оскорбление родных в ответе')
				end)
				end
				if imgui.Button(u8'Оскорбление родных в чате саппортов') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Оскорбление родных в чате саппортов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Оскорбление родных в чате саппортов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Оскорбление родных в чате саппортов')
				end)
				end
				if imgui.Button(u8'Накрутка ответов') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Накрутка ответов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Накрутка ответов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Накрутка ответов')
				end)
				end
				if imgui.Button(u8'Разглашение команд и возможностей саппорта') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Разглашение команд и возможностей саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Разглашение команд и возможностей саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Разглашение команд и возможностей саппорта')
				end)
				end
				if imgui.Button(u8'Неадекватное поведение в ответе (Оскорбления/Капс/Мат)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Неадекватное поведение в ответе')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неадекватное поведение в ответе')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неадекватное поведение в ответе')
				end)
				end
				if imgui.Button(u8'Неадекватное поведение в чате саппортов (Оскорбления/Капс/Мат)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Неадекватное поведение в чате саппортов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неадекватное поведение в чате саппортов')
					wait(1300)
					sampSendChat('/swarn '..sname..' Неадекватное поведение в чате саппортов')
				end)
				end
				if imgui.Button(u8'Оскорбление следящих за саппортами') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Оскорбление следящих за саппортами')
					wait(1300)
					sampSendChat('/swarn '..sname..' Оскорбление следящих за саппортами')
					wait(1300)
					sampSendChat('/swarn '..sname..' Оскорбление следящих за саппортами')
				end)
				end
				if imgui.Button(u8'NonRP ник') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' NonRP ник')
					wait(1300)
					sampSendChat('/swarn '..sname..' NonRP ник')
					wait(1300)
					sampSendChat('/swarn '..sname..' NonRP ник')
				end)
				end
				if imgui.Button(u8'Использование читов на посту саппорта') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Использование читов на посту саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Использование читов на посту саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Использование читов на посту саппорта')
				end)
				end
				if imgui.Button(u8'Провокационные вопросы (Команды/Возможности саппорта)') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Провокационные вопросы (Команды/Возможности саппорта)')
					wait(1300)
					sampSendChat('/swarn '..sname..' Провокационные вопросы (Команды/Возможности саппорта)')
					wait(1300)
					sampSendChat('/swarn '..sname..' Провокационные вопросы (Команды/Возможности саппорта)')
				end)
				end
				if imgui.Button(u8'Слив поста саппорта') then
				local sname = str(input_nameswarn)
				lua_thread.create(function()
					sampSendChat('/swarn '..sname..' Слив поста саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Слив поста саппорта')
					wait(1300)
					sampSendChat('/swarn '..sname..' Слив поста саппорта')
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
			imgui.Begin(u8'Флудер', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			for i = 1, 5 do
				imgui.BeginChild('##flooderChild1', imgui.ImVec2(350, 135), 0)
				imgui.PushItemWidth(350)
				if imgui.InputTextWithHint(u8('##Текст'.. i), u8'Текст', inputTexts[i], sizeof(inputTexts[i])) then end
				imgui.PopItemWidth()
				imgui.EndChild()
				imgui.SameLine()
				imgui.BeginChild('##flooderChild2', imgui.ImVec2(80, 135), 0)
				imgui.PushItemWidth(75)
				if imgui.InputTextWithHint(u8('##Задержка'.. i), u8'Задержка', inputDelays[i], sizeof(inputDelays[i]), imgui.InputTextFlags.CharsDecimal) then end
				imgui.PopItemWidth()
				imgui.EndChild()
				imgui.SameLine()
				imgui.BeginChild('##FlooderChild3', imgui.ImVec2(40, 135), 0)
				if ad.ToggleButton(u8('##Чекбокс'.. i), inputButtons[i]) then 
					floodActive[i] = inputButtons[i][0]
					if floodActive[i] then
						lua_thread.create(function() floodLogic(i) end)
					end
				end
				imgui.EndChild()
			end
			imgui.NewLine()
			if imgui.Button(u8'Сохранить текст', imgui.ImVec2(470, 0)) then
				saveTextToJson()
			end
		elseif menuSwitch == 6 then
			local resX, resY = getScreenResolution()
			local sizeX, sizeY = 695, 235
			imgui.PushFont(myFont) 
			imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
			imgui.Begin(u8'Другое', menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.BeginChild('##otherSettings1', imgui.ImVec2(300,195), 0)
			if ad.ToggleButton(u8'ChatID', elements.value.chatID) then
				config['settings']['chatID'] = elements.value.chatID[0]
				saveConfig()
			end imgui.TextQuestion(u8'Около никнейма отображается ID')
			if ad.ToggleButton(u8'Anti-AFK', elements.value.antiafk) then
			afk = not afk
			config['settings']['antiafk'] = elements.value.antiafk[0]
			saveConfig()
			end
			if ad.ToggleButton(u8'Быстрый ввод ников', elements.value.fastnicks) then
				config['settings']['fastnicks'] = elements.value.fastnicks[0]
				saveConfig()
			end imgui.TextQuestion(u8'@id = ник')
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
			if ad.ToggleButton(u8'Моментальный телепорт', elements.value.ftp) then
				config['settings']['ftp'] = elements.value.ftp[0]
				saveConfig()
			end imgui.TextQuestion(u8'Моментально телепортирует на метку')
			if ad.ToggleButton(u8'Удаление серверного флуда', elements.value.dellServerMessages) then
				config['settings']['dellServerMessages'] = elements.value.dellServerMessages[0]
				saveConfig()
			end imgui.TextQuestion(u8'Удаление Ace_Will, SAN и т.п')
			if ad.ToggleButton(u8'Визуальное удаление аксессуаров', elements.value.dellacces) then
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
    imgui.Begin(u8'Выдача/снятие должности', setWindow, imgui.WindowFlags.NoResize)
	imgui.BeginChild('lName##', imgui.ImVec2(399,235), true)
	imgui.PushItemWidth(155) 
	imgui.CenterText(u8'Лидерство')
	imgui.Separator()
	imgui.Text(u8'Введите ID игрока:')
	imgui.SameLine()
	imgui.InputTextWithHint(u8'Пример: 0', u8'Введите значение', input_setleader, sizeof(input_setleader), imgui.InputTextFlags.CharsDecimal)
	if imgui.ComboStr(u8'', selected, comboStr .. '\0', -1) then
        print('Selected frac name', fracNames[selected[0] + 1][2]);
    end
    imgui.SliderInt(u8'Выберите скин', SliderOne, 1, 311)
    imgui.PopItemWidth()
    if imgui.Button(u8"Назначить на должность лидера##1") then
        local lead = str(input_setleader)
        if selected[0] ~= 0 and lead ~= '' and tonumber(lead) > 0 then
            local fracID = fracNames[selected[0] + 1][1] 
            sampSendChat('/setleader '..lead..' '..fracID..' '..SliderOne[0])
        else
            sampAddChatMessage('[Ошибка]: {ffffff}Выберите все данные для выдачи должности', 0xFF6600)
        end
    end
	imgui.Separator()
	imgui.CenterText(u8'Саппорт')
	imgui.Separator()
	imgui.Text(u8'Введите ID (+ | -)')
	imgui.SameLine()
	imgui.PushItemWidth(155)
	imgui.InputTextWithHint(u8'##2', u8'Введите значение', input_setsupport, sizeof(input_setsupport), imgui.InputTextFlags.CharsDecimal)
	imgui.PopItemWidth()
	imgui.SameLine()
	imgui.Text(u8'Пример: 303 +')
	if imgui.Button(u8"Назначить/изменить должность саппорта##2") then
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
--     -- Разбиваем введенную строку на аргументы (ID, дни и причина)
--     local id, days, reason = text:match("^(%d+)%s+(%d+)%s+(.+)$")
    
--     -- Проверка на корректность аргументов
--     if not id or not days or not reason then
--         sampAddChatMessage("Неверный формат команды! Использование: /banipid [ID игрока] [Срок] [Причина]", -1)
--         return
--     end

--     -- Отправляем команду на получение IP игрока
--     sampSendChat('/getip ' .. id)

--     -- Создаем переменную для хранения IP
--     local ip = nil

--     -- Создаем поток для задержки перед выполнением бан-операции
--     lua_thread.create(function()
--         local timeout = 5000  -- Максимальное время ожидания в миллисекундах (5 секунд)
--         local startTime = os.clock()

--         -- Ожидаем ответ на команду /getip
--         while os.clock() - startTime < timeout do
--             wait(100)  -- Пауза перед следующим циклом проверки
--         end

--         -- Если IP найден, выполняем команду бан
--         if ip then
--             sampAddChatMessage(string.format('/banip %s %s %s', ip, days, reason), -1)
--         else
--             sampAddChatMessage("Не удалось получить IP для игрока с ID " .. id, -1)
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
	if text:find('^Вы вошли как .*') and not text:find('блогер') then
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
		if text:find("^Администратор (%w+_%w+) для") or text:find("^Администратор (%w+_%w+)%[(%d+)%] для") then
			local pmtext = text:gsub("Администратор", "A:")
			sampAddChatMessage(pmtext, 0xFF9945)
			return false
		end
		if text:find("^Администратор (%w+_%w+) посадил") or text:find("^Администратор (%w+_%w+) заблокировал репорт") or text:find("^Администратор (%w+_%w+) кикнул") or text:find("^Администратор (%w+_%w+) выдал предупреждение") or text:find("^Администратор (%w+_%w+) выдал выговор") or text:find("^Администратор (%w+_%w+) поставил") or text:find("^Администратор (%w+_%w+) снял") or text:find("^Администратор (%w+_%w+) забанил .*") or text:find("^Администратор (%w+_%w+)%[(%d+)%] посадил") or text:find("^Администратор (%w+_%w+)%[(%d+)%] заблокировал репорт") or text:find("^Администратор (%w+_%w+)%[(%d+)%] кикнул") or text:find("^Администратор (%w+_%w+)%[(%d+)%] выдал предупреждение") or text:find("^Администратор (%w+_%w+)%[(%d+)%] выдал выговор") or text:find("^Администратор (%w+_%w+)%[(%d+)%] поставил") or text:find("^Администратор (%w+_%w+)%[(%d+)%] снял") or text:find("^Администратор (%w+_%w+)%[(%d+)%] забанил .*") then
			local ttext = text:gsub("Администратор", "A:")
			sampAddChatMessage(ttext, 0xff5030)
			return false
		end
		if text:find("^Организатор мероприятий .*") then 
			local omptext = text:gsub("Организатор мероприятий", "ОМП")
			sampAddChatMessage(omptext, 0xffcc00)
			return false
		end
		if text:find("^Главный администратор .*") then 
			local gatext = text:gsub("Главный администратор", "ГА")
			sampAddChatMessage(gatext, 0xffcc00)
			return false
		end
		if text:find("^Помощник Г.А .*") then 
			local gatext = text:gsub("Помощник Г.А", "ПГА")
			sampAddChatMessage(gatext, 0xffcc00)
			return false
		end
	end
	if elements.value.getblock[0] then 
		if text:find('^%Ваши админ действия временно заблокированы') then
			lua_thread.create(function()
				wait(100)
				sampSendChat('/a [Отбор]: Я провожу отбор. ПГА/ЗГА/ГА/основатель, выдайте мне пожалуйста разблок действий.')
			end)
		end
	end
	if elements.value.reloginblock[0] then
		if text:find('^%Ваши админ действия временно заблокированы') then
			local ip, port = sampGetCurrentServerAddress()
			if ip and port then
				sampConnectToServer(ip, port)
			end
		end
	end
    if elements.value.atp[0] then
        if text:find('^Вы вошли как .*') and not text:find('^Вы вошли как блогер') then
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
        if text:find('^Вы вошли как .*') and not text:find('^Вы вошли как блогер') then
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
        local command = message:sub(2) -- Убираем символ "!"
        if command == 'alh' then
            -- sampAddChatMessage('Команда была отправлена через !text')
			menu[0] = not menu[0]
            return false -- Отменяем отправку оригинального текста в чат
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
			sampAddChatMessage('[All Helper]: {ffffff}Используйте /amsg [1-3]', 0x696969)
		end
		if param == '1' then
			lua_thread.create(function()
				for i, line in ipairs(amsg1) do
					sampSendChat(line[1])  -- Выводим сообщение
					wait(1200)  -- Задержка в 1500 миллисекунд (1.5 секунды)
				end
			end)
		end
		if param == '2' then
			lua_thread.create(function()
				for i, line in ipairs(amsg2) do
					sampSendChat(line[1])  -- Выводим сообщение
					wait(1200)  -- Задержка в 1500 миллисекунд (1.5 секунды)
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
    -- sampAddChatMessage('Скрипт загружен, версия: '..lastver, -1)
    -- if thisScript().version ~= lastver then
    --     sampRegisterChatCommand('scriptupd', function()
    --         update():download()
    --     end)
    --     sampAddChatMessage('Вышло обновление скрипта ('..thisScript().version..' -> '..lastver..'), введите /scriptupd для обновления!', -1)
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
    --     sampAddChatMessage('[All Helper]: {ffffff}Ошибка: Ваш ник отсутствует в списке! Скрипт выгружен.', 0x696969)
    --     sampAddChatMessage('[All Helper]: {ffffff}Ошибка: Чтобы использовать скрипт - станьте красным администратором или купите пользовательскую версию.', 0x696969)
    --     sampAddChatMessage('[All Helper]: {ffffff}Ошибка: Купить скрипт можно у vk.com/number1241. Цена: договорная.', 0x696969)
    --     thisScript():unload()
    --     return
    -- end
	
    local ip, port = sampGetCurrentServerAddress()
    local ipport = ip .. ':' .. port
    if ipport ~= '62.122.213.231:7777' then
        sampAddChatMessage('[All Helper]: {ffffff}Ошибка: Данный скрипт работает только на Attractive RP и не работает на других серверах!', 0x696969)
        sampAddChatMessage('[All Helper]: {ffffff}Ошибка: IP Attractive RP: {00aaff}Именной - a.attractive-rp.ru:7777 || Цифровой - 62.122.213.231:7777', 0x696969)
        sampAddChatMessage('[All Helper]: {ffffff}Ошибка: Скрипт выгружен.', 0x696969)
        thisScript():unload()
        return
    end

    sampAddChatMessage('[All Helper]: {ffffff}Мини-помощник администратора загружен.', 0x696969)
	sampAddChatMessage(string.format('[All Helper]: {ffffff}Для его активации используйте: /alh (версия: %.2f от %s).', script_version, thisScript().version), 0x696969)
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
        sampAddChatMessage('[AllHelper]: {ffffff}Используйте /recname [ник]', 0x696969)
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
	imgui.TextDisabled(u8'—  Описание')
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


local punish = {'Общие правила',
'',
'- Читы - /warn /jail (От 1 до 30 минут)',
'- Вред. читы - Снятие с постов + /ban (1 день) /banip (До 7 дней)',
'- DM/DB/SK/TK - /jail (От 1 до 15 минут)',
'Исключение: разрешен DM на территории гетто',
'- NonRP (Или NonRP cop) - /warn /jail (От 1 до 15 минут)',
'- Помеха/AFK без Esc/ПГ - /kick /jail (От 1 до 5 минут)',
'Пример: помеха капту не находясь в банде',
'- NRP NickName - /kick | Увольнение с организации',
'- Повторение одного и того же нарушения (5+ раз) - /ban (1 день)',
'Примечание: наказание выдается в том случае, если интервал между каждым нарушением менее 15-ти минут.',
'- NonRP развод/Подкид обмена или покупки/Развод /try - /ban (От 14 дней)',
'Примечание: С каждой блокировкой по этому правилу, срок следующей блокировки увеличивается на 2 дня (Второй бан на 16 дней, третий > на 18 и так далее)',
'- Слив продуктов бизнеса - Снятие с постов + /ban (От 1 до 3 дней)',
'Пример: намеренная скупка товаров с целью уменьшения количества продуктов и последующим слётом бизнеса в гос.',
'- Попытка/Продажа имущества за реальную валюту - Удаление всех аккаунтов',
'- Продажа/Передача/Взлом аккаунта - /ban (30 дней)',
'- Использование бота на шахту - /ban (От 1 до 3 дней)',
'- Использование багов сервера с целью получения материальной выгоды - Снятие с постов + /ban с обнулением имущества, вплоть до удаления аккаунта',
'Пример: багоюз/дюп золотых монет, редких скинов и т.д.',
'',
'Правила чата:',
'',
'- Оффтоп в репорт - /rmute (На усмотрение администратора)',
'- Flood/MG/транслит - /mute (От 1 до 10 минут)',
'- Реклама - /ban /banip /mute (На усмотрение администратора)',
'- Оскорбление игроков/угрозы - /mute (От 1 до 15 минут)',
'- Оскорбление администраторов - /mute (На усмотрение администратора)',
'- Упоминание родных - /mute (На усмотрение администратора)',
'Исключение: упоминание своих родственников',
'- Оскорбление красной администрации - /mute (30 минут)',
'- Упоминание родных красной администрации - /mute (30 минут)',
'- Caps/Мат в /ad, /vad, /r, /d и т.д - /mute (От 1 до 10 минут)',
'Исключение: мат в РП чат, /f /gc /mc /sms',
'- Розжиг межнациональной розни - /mute (От 1 до 30 минут)',
'- Распространение сторонних файлов - /mute (От 1 до 30 минут)',
'- Оскорбление проекта - /mute (От 1 до 30 минут)',
'- Игра анти-рекламой - /mute (От 1 до 15 минут)',
'',
'Форум:',
'',
'- Форумные аватары/публикации разжигающие межнациональную рознь (Представители стран, военные и политические деятели, любые государственные символы и прочее)',
'Наказание: блокировка игрового аккаунта (1 день), блокировка форумного аккаунта (30 дней), снятие с хелперки, лидерского/админ-поста.',
'- Форумные аватары/публикации разжигающие конфликт, имеющие порнографический смысл. Наказание: блокировка форумного аккаунта (30 дней), снятие с хелперки, лидерского/админ-поста.'}
local arules = {'1. Ненормативная лексика в чат, в сторону игроков/администраторов | Выговор',
'- Запрещено написание матерных слов в присутствии игроков рядом',
'- Разрешено использовать мат рядом с администраторами с целью описать ситуацию, не используя его в сторону человека',
'2. DM игроков | Два выговора',
'- Разрешён случайный единичный удар рукой/оружием ближнего боя/транспортом, если те нанесли мало урона',
'3. Выдавать наказание, не имея доказательств нарушения | Два выговора',
'4. Засорение репорта | Выговор',
'- Запрещено устраивать мероприятия/викторины, чья суть заключается в написании ответа в репорт',
'- Игрокам, находящимся на отборе на лидера/саппорта, разрешено писать ответы в репорт',
'5. Оскорбление администраторов/игроков/угрозы | Выговор',
'- Правило не распространяется на семейный чат (/t)',
'6. Покупка/продажа чего-либо в /a | Выговор',
'7. Помеха другим администраторам | Выговор',
'8. Реклама/Реклама с твинков | Снятие',
'- Запрещено упоминание названий сторонних SAMP/CRMP/GTA V серверов, IP адресов, приглашение игроков поиграть на другом сервере',
'9. Оффтоп в /msg | Выговор',
'- Разрешено использовать команду для оповещения игроков об отборах, мероприятиях, слежке за каптами/бизварами и т.д',
'10. Блат кого-либо из игроков/администраторов | Два выговора',
'- Запрещено выдавать оружие/броню/хп персонажа и хп транспорта по просьбе в репорт или напрямую администратору',
'- Разрешена починка транспорта вне РП процесса',
'- Запрещено осуществлять помеху на семейном ограблении с целью помочь определённым игрокам',
'- Запрещено без причины выдавать донат очки',
'- Запрещено игнорирование нарушений игроков/администраторов',
'- Запрещено без причины аннулировать наказания | Исключение: получение неверного наказания по вашей вине',
'- Запрещено фиксирование нарушения с игрока (твинк-аккаунта) и выдача наказания с админ-аккаунта | Требуется писать жалобу на форуме',
'- Запрещено телепортировать игроков на мероприятие. Посещение мероприятий должно быть строго через /gotp | Исключение: если была ошибочная дисквалификация с мероприятия',
'11. Помеха RP/Влезание в RP процесс | Выговор',
'12. Проверка игрока на читы через скайп или дискорд | Два выговора',
'- Запрещено просить игроков пройти в скайп/дискорд для проверки сборки на наличие читов',
'13. Попрошайничество | Выговор',
'- Запрещено просить валюту/аксессуары и другие вещи, снять выговор, повысить уровень админ-прав в /a, /v, а также в /sms, если собеседник против попрошайничества',
'- Попрошайничество разрешено в /t и у друзей, если стоите рядом друг с другом и они не против',
'14. Использование читов против игроков | Снятие',
'- Запрещены любые читы, которые могут помешать игре других игроков',
'Примечание: Использование читов на DM арене против игроков, которые не влияют на стрельбу | Два выговора',
'15. Выдача наказаний по просьбе другого администратора | Выговор',
'- Администратор, чья просьба была выполнена, наказания не несёт',
'16. Наличие более 1 админ аккаунта | Снятие всех аккаунтов с админки',
'- Разрешено в случае игры двух людей на одном IP, если на это есть доказательства',
'17. Выдача наказаний за SMS администраторам | Выговор',
'- Разрешён сам факт написания SMS для связи с администраторами, все правила чата продолжают действовать',
'18. Выдача наказаний за DM администраторов | Выговор',
'- Администраторов сервера разрешено ранить/убивать',
'19. Накрутка репутации | Снятие',
'- Запрещена накрутка репутации с помощью твинк-аккаунтов и друзей, что пишут в репорт, а вы отвечаете и получаете положительные оценки',
'20. Выпрашивание оценки ответа на репорт | Выговор',
'21. Выдача выговора(-ов) в ответ | Снятие/Изъятие команды',
'- Если вас наказал администратор (на основном аккаунте или твинке), запрещено в ответ выдавать выговор(-ы) за неверную выдачу данного наказания',
'- Если вам выдали выговор(-ы) в ответ, запрещено самолично наказывать такого администратора',
'- При получении выговора(-ов) от администратора вы всё так же можете выдавать ему наказания за нарушение правил, если на то имеются доказательства',
'22. Подставные действия на снятие | Два выговора/Снятие',
'- Запрещено просить другого администратора сказать/сделать то, за что он может получить снятие',
'- Запрещено пытаться подставить игроков/администраторов с помощью программ/читов',
'23. Розжиг конфликта | Два выговора',
'- Запрещено словами/действиями провоцировать на конфликт игроков/администраторов',
'Пример: попытка заткнуть человека, заставлять его молчать, унижение человека',
'24. Нарушение правил администрации 3+ раз | Снятие',
'Пример: получение 3 выговора за оскорбление администратора/игрока',
'Примечание: наказание выдается в том случае, если интервал между каждым нарушением менее 15-ти минут',
'25. Оскорбление красных администраторов, а также упоминание/оскорбление их родни | Снятие + mute на 30 минут',
'- Правило распространяется на соц.сети, видеохостинги, форум, игру, дискорд (мут не выдаётся, если нарушение было не в игре)',
'26. Суммирование наказаний | Выговор',
'- Запрещено суммировать наказания друг с другом и последующая выдача их с увеличенным временем/количеством',
'Пример с игроком: игрок 2 раза нарушил правило "Капс в чат - mute 10 минут" и вы выдали ему 20 минут мута вместо положенных по правилу 10 минут',
'Пример с админом: администратор 2 раза нарушил правило "DM игроков - выговор" и вы выдали ему сразу 2 выговора вместо положенного по правилу одного выговора',
'- Любое наказание должно выдаваться сразу после нарушения. Если выдать наказание администратору/игроку и он продолжает нарушать, разрешено выдавать наказание за последующее нарушение',
'27. Розжиг межнациональной розни | Два выговора',
'28. Распространение сторонних скриптов | Выговор',
'29. Злоупотребление капсом в /a /v | Выговор',
'- Разрешен капс до 2-х (включительно) слов в 2 минуты',
'- Запрещено отправление длинных слов, написанных преимущественно капсом',
'30. Помощь на капте/бизваре | Два выговора',
'- Запрещено назначать себя временным лидером и помогать в увеличении счёта убитых/находящихся на территории той или иной банде/мафии, тем самым помогая выиграть',
'- Запрещена помощь в перемещении на капт/бизвар, а также по оспариваемой территории',
'- Запрещёно телепортировать соперников друг к другу',
'- Запрещена выдача оружия/транспорта/хп/брони/масок',
'31. Слив территорий/бизнесов | Снятие',
'- Запрещена выдача территорий/бизнесов без доказательств и причины',
'32. Разглашение цен платных команд | Снятие',
'Исключение: Информирование о платных командах администратору 12 уровня.',
'Администраторам не имеющим доступ в раздел "Платных команд" - запрещено любое информирование.',
'33. Баловство командами | Два выговора',
'- Запрещена намеренная беспричинная выдача и последующее снятие наказаний игроку',
'Пример: выдача /ban по причине "релог" игроку, если тот не нуждался в этом в связи с багом и невозможностью выйти с сервера самостоятельно',
'- Запрещена намеренная выдача спавна/слапа, изменение здоровья/скина, телепорт с целью навредить/помешать/посмеяться над игроком',
'Пример: слап игрока в грузовике семейного ограбления, спавн с целью забрать лавку на центральном рынке',
'За исключением если администратор ошибся ID и сможет это доказать',
'- Запрещён телепорт игроков без их разрешения',
'Пример: телепорт по просьбе другого игрока в репорт | Чтобы не получить жалобу, нужно спросить разрешения у того, кого/к кому Вы телепортируете',
'- Запрещена выдача наказаний самому себе',
'Если вы должны получить какое-либо наказание и решили выдать его себе сами, это не отменяет выдачу выговоров от других администраторов',
'Пример: увидев жалобу на форуме, вы решили наказать сами себя; получите выговор за баловство командами и наказание по жалобе',
'34. Использование багов сервера для получения материальной выгоды | Снятие + бан',
'Пример: багоюз/дюп золотых монет, редких скинов и т.д.',
'35. Нарушение правил проверки жалоб | Выговор',
'36. Оскорбление сервера | Снятие + бан',
'37. /pm в личных целях | Выговор',
'- Запрещена беспричинная связь через /pm с игроком, который не писал в репорт',
'- Разрешено использовать /pm "Вы тут?" с целью убедиться, не афк ли игрок',
'38. Флуд админ-командами | Выговор',
'- Запрещено засорять чат админ-действиями, например выдача оружия/хп/брони, телепорт игроков к себе и т.д',
'39. Использование вред.читов/использование вред.читов с твинков против игроков/администраторов | Снятие + бан',
'40. Оскорбление/упоминание родственников или ответ взаимностью | Снятие',
'- Разрешено упоминание своих родственников',
'41. Капс/флуд в чат, в сторону игроков/администраторов | Выговор',
'- Разрешен капс до 2-х (включительно) слов в 2 минуты',
'- Запрещено отправление длинных слов, написанных преимущественно капсом',
'42. Неверная выдача наказания игроку/администратору | Выговор',
'43. Неверное рассмотрение жалобы на форуме | Выговор',
'44. Попытка/Продажа внутриигрового имущества за реальную валюту | Бан + удаление аккаунта',
'45. Слив продуктов бизнеса | Снятие + бан до 3 дней',
'- Запрещена намеренная скупка товаров с целью уменьшения количества продуктов и последующим слётом бизнеса в гос.',
'46. Продажа/Передача/Взлом аккаунта | Снятие + бан до 30 дней',
'47. NonRP развод | Подкид | Развод /try | Снятие + бан на 14 дней',
'- Развод с твинк-аккаунтов | Снятие',
'48. NonRP NickName | Два выговора',
'- Запрещено использовать nRP ник/ник написанный капсом, пример - EVGENY_CREATOR | iVan_pUPpKin | Evgeny_Creatorrr',
'- Ник должен быть написан в формате Имя_Фамилия, пример - Evgeny_Creator',
'- Запрещено использовать две и более заглавные буквы в имени, пример - EvGeny_Creator',
'49. Слив административных прав | Снятие + бан до 30 дней | Снятие твинков (При наличии)',
'50. Неуважительный ответ игроку | Два выговора',
'51. Выдача наказания с неполной причиной | Выговор',
'- Запрещено указывать причину, не поясняющую за что именно было выдано наказание',
'Пример: выдача наказаний по причинам: "Нарушение правил чата", "Нарушение правил сервера" и тому подобным (необходимо указывать чёткую причину, например "Оскорбление игрока")',
'- Запрещены непонятные сокращения причин, причина должна быть понятна абсолютно всем игрокам'}
local lrules = {'- Неадекват | Наказание - два выговора лидеру + mute',
'- Оскорбление красной администрации | Наказание - Снятие + mute',
'- Неадекватное поведение на форуме | Наказание - выговор лидеру',
'- Упоминание родных | Наказание - снятие + mute',
'- DM, DB, TK, SK | Наказание - выговор лидеру + jail',
'- Увольнение без причин | Исключение - гетто/мафии | Наказание - выговор лидеру',
'- Принятие игрока с NonRP ником в организацию | Наказание - выговор лидеру',
'- NonRP | Наказание - выговор лидеру + jail/warn',
'- Реклама | Наказание - снятие с лидерки + ban',
'- Расформ (от 5+ человек) | Исключение - гетто/мафии/неактив более 1 мес. | Наказание - снятие с лидерки + warn',
'Примечание: наказание выдается в том случае, если интервал между каждым увольнением менее 7-ми минут.',
'- Читы | Наказание - снятие с лидерки + warn',
'- Читы с твинков | Наказание - снятие с лидерки + warn',
'- Блат | Исключение - гетто/мафии | Наказание - выговор лидеру',
'- Норма онлайна отыгровки за день от 1 часа | Исключение - если лидер назначен за час до проверки нормы | Наказание - снятие с лидерки',
'- Неактив 24+ часов | Наказание - снятие с лидерки',
'- NonRP названия рангов | Исключение - гетто (Кроме неадекватных и оскорбительных) | Наказание - 2 выговора лидеру',
'- Менее двух наборов за день | Исключение - нелегальные организации | Наказание - 2 выговора лидеру',
'- Менее двух захватов за день | Исключение - гос.структуры | Наказание - 2 выговора лидеру',
'- Отсутствие стрел за день | Исключение - гос.структуры, гетто | Наказание - 2 выговора лидеру',
'- Слив территорий/бизнесов | Наказание - снятие с лидерки + warn',
'- Наличие более одной лидерки | Наказание - снятие всех лидерок',
'- Отсутствие нормы захватов в течении 3-х дней | Исключение - гос.структуры/отсутствие лидеров противоположных организаций | Наказание - снятие с лидерки',
'- Продажа/покупка лидерки | Наказание - снятие с лидерки + warn (Продажа за реальную валюту - удаление аккаунта)',
'- Продажа ранга | Наказание - снятие с лидерки + warn (Продажа за реальную валюту - удаление аккаунта)',
'- Игра с твинков за противоположную банду/мафию | Наказание - снятие с лидерки + warn',
'- Передача лидерского поста на твинк аккаунт (Пример: уход с лидерки и покупка с твинка) | Наказание - снятие с лидерки + warn',
'- Розжиг межнациональной розни, в том числе названия рангов | Наказание - 2 выговора лидеру',
'- Отказ от принятия участия в глобальных мероприятиях | Исключение - нелегальные организации | Наказание - 2 выговора лидеру',
'- Слив поста/лидеров | Наказание - снятие с лидерки + ban',
'- Оскорбление проекта | Наказание - снятие с лидерки + ban',
'- NonRP ник | Наказание - 2 выговора лидеру',
'Примечание: Если лидер не изменил ник на допустимый в течение 10-ти минут после наказания, он СНИМАЕТСЯ с поста',
'Администратор обязан оповестить лидера в (/pm) о том что, у него имеется 10 минут для смены никнейма',
'Важно: Предупреждения выносятся только тогда, когда лидер находится в Сети'}
local srules = {'- Отсутствие нормы отыгранного времени за сутки (1 час). | Наказание - снятие с поста саппорта.',
'- Неактивность в течение 24 часов. | Наказание - снятие с поста саппорта.',
'- Оскорбление родных в ответе / чате саппортов. | Наказание - снятие с поста саппорта + затычка на 30 минут + чёрный список саппортов сроком на 10 дней.',
'- Неверный ответ игроку. | Наказание - выговор.',
'- Накрутка ответов. | Наказание - снятие с поста саппорта + чёрный список саппортов сроком на 5 дней.',
'- Разглашение команд и возможностей саппорта. | Наказание - снятие с поста саппорта + чёрный список саппортов сроком на 10 дней.',
'- Использование команды для ответов в личных целях. | Наказание - 1 выговор.',
'- Неадекватное поведение в ответе / чате саппортов (Оскорбления/Капс/Мат). | Наказание - снятие с поста саппорта (при повторном нарушении чёрный список саппортов на 5 дней).',
'- Любые нарушения правил сервера со стороны игрового процесса (DM/Оскорбления/Неадекват). | Наказание - выговор + наказание по правилам сервера.',
'- Наличие 0 ответов на посту саппорта. | Наказание - 2 выговора.',
'- Оскорбление следящих за саппортами. | Наказание - снятие с поста саппорта + чёрный список саппортов сроком на 5 дней.',
'- Засорение чата саппортов (Покупка/Продажа/Флуд). | Наказание - выговор + затычка на 10 минут.',
'- NonRP ник. | Наказание - снятие с поста саппорта.',
'- Попрошайничество в чате саппортов или в ответе игроку. | Наказание - 2 выговора.',
'- Использование читов на посту саппорта. | Наказание - снятие с поста саппорта + jail/warn.',
'- Провокационные вопросы (Команды/Возможности саппорта). | Наказание - снятие с поста саппорта + чёрный список саппортов сроком на 5 дней.',
'- Игнорирование просьбы главного следящего за саппортами. | Наказание - выговор.',
'- Выдача блокировки репорта, не имея доказательств нарушения. | Наказание - выговор (по жалобе выдаётся 2 выговора).',
'- Наличие ошибок, проявление неграмотности при ответе, неполноценные ответы. | Наказание - выговор.',
'- Транслит в ответе игроку. | Наказание - выговор.',
'- Неуважительный ответ игроку. | Наказание - 2 выговора.',
'- Слив поста саппорта. | Наказание - снятие с поста саппорта + блокировка на 30 дней + чёрный список саппортов навсегда.'}
local gosrules = {'- 1. Всякое общение в департаменте без использования тега: [Тег вашей организации] - [all/другая организация] - /mute (от 1 до 10 минут).',
'- 2. Использование фраз, содержащие капс, грубые выражения, оскорбления (/d (/db), /r (/rb), /gov и.т.п) . - /mute (от 1 до 10 минут).',
'- 3. Писать в государственные новости, не заняв государственную волну - /mute (от 1 до 10 минут).',
'- 4. NonRP Cop - /warn /jail (от 1 до 15 минут).',
'- 5. Увольнение с неадекватной или без весомой причины - /mute (от 1 до 10 минут).',
'- 6. Слив должности - /auninvite + /jail (от 1 до 15 минут).',
'- 7. Нахождение гос. работника в гетто с целью ареста - /jail (от 1 до 10 минут).',
'- 7.1. Разрешено находиться в маске для простого перемещения (без арестов).',
'- 8. Несоблюдение правил при выдаче розыска (выдача розыска с NonRP причинами или причинами, которые не указаны в уголовном кодексе: DM, угон, похищение и т.д). - /warn /jail (от 1 до 15 минут).',
'- 8.1. Разрешено указывать только полное название статьи или её пункт.',
'- 9. Проявление неграмотности и неадекватного поведения при проведении эфира или при использовании государственной волны - /mute (от 1 до 10 минут).',
'- 10. Несоблюдение правил проведения проверок - /warn /jail (от 1 до 15 минут).',
'Примечания:',
'- 1. Причина для розыска должна соответствовать Уголовному кодексу San Andreas.',
'- 2. Причина увольнения должна быть на русском языке. Использование причины на другом языке будет наказано.',
'- 3. При многократном нарушении пункта под номером 9 - вы будете уволены из организации.'}
local orules = {'- 1. Необходимо установить минимальный онлайн в один час для возможности телепортации (используя команду /mp).',
'- 2. Активировать функцию записи экрана.',
'- 3. Огласить участникам правила отбора:',
'',
'Первый участник имеет 15 секунд на ответ, остальные - 10.',
'Запрещено применять ДМ, перебегать, писать сообщения в любой чат, за исключением /rep и /sms.',
'',
'- 4. Переместить на спавн тех игроков, которые были сняты с лидерских должностей за последние 30 минут, они не могут участвовать в отборе.',
'- 5. Переместить на спавн игроков, являющихся лидерами других фракций.',
'- 6. Проверить, что на отборе присутствует не менее трёх игроков.'}
local tryrules = {'- 1. Написать правильные условия и получить согласие для начала игры',
'> В условиях должно быть написано: сумма, валюта/предмет, кол-во побед, кол-во написанных /try',
'> Пример: "Играем в /try на 10кк фк, 1 победа, кидаем 3 раза"',
'> Если валюта не была написана, игра будет на FCoins',
'> При оглашении условий игры Вы должны иметь обговариваемую сумму на том аккаунте, на котором играете в /try, либо на указанном Вам нике (см. пункт 3.)',
'> Если обговоренной суммы не имеется, но Вы начали игру, Вы можете получить блокировку за обман в /try.',
'- 2. В случае написания жалобы на обман, требуется сделать скриншот /mm - 1.',
'> Доказательства написания условий и согласие на них, а так же сама игра (скриншоты/видеоролик того, как оба игрока прописывают /try нужное количество раз).',
'> На доказательствах должно быть видно серверное время.',
'- 3. При написании условий, если кто-то готов оплатить Ваш проигрыш, стоит указать его ник. Если ник не был указан или оплаты не произошло в течение 24ч, то наказание получает тот, кто играл в /try.',
'- 4. В случае проигрыша и передачи поставленной суммы/предмета на другие аккаунты, они будут заблокированы за участие в обмане.',
'- 5. В случае проигрыша и нежелания отдавать проигранное, будет выдана блокировка аккаунта.',
'- 6. При равном выпадении "Удачно" нужно согласовать дальнейшее продолжение игры, подтверждение с обеих сторон.',
'- 7. Разрешена игра только на внутриигровую валюту/имущество.',
'- 8. Запрещена игра на желания, выигрыш в долг.',
'- 9. При обмане возвращается сумма проигрыша с аккаунтов обманщика (при наличии).'}
local capturerules = {'На захвате территории разрешено:',
'',
'- Маски (/mask)',
'- Аптечки (/healme)',
'- Наркотики (/drugs)',
'- Использование багов стрельбы (Слайды, отводы, сбивы перекатов, +с)',
'На захвате территории запрещено:',
'',
'- TK, DB, бронежилет | Наказание - Jail/Warn (1/3)',
'- Сбив | Наказание: Jail/Warn (1/3)',
'- Читы: WH, SH, TP, PARKOUR, CLEO ANIM | Наказание - Jail/Warn (1/3)',
'- Читы: FLY, Клео лаги | Наказание - Jail/Warn (2/3)',
'- SK (Исключение: если была провокация), Антифраг/офф от килла, проезд мимо | Наказание - Jail/Warn (2/3)',
'- Вред читы: CARSHOT, DAMAGER, РВАНКА и другие | Наказание - Ban (3/3)',
'- Не приезжать на захватываемую территорию в течении 3-х минут | (3/3)',
'- Каптить куском/обрезом | Наказание - Jail/Warn (3/3)',
'- Стрельба на пассажирском сидении | (3/3)',
'- Анти-каптить | Наказание - Jail/Warn (3/3)',
'- AFK на капте от 1+ минут | Наказание - Jail/Warn (1/3)',
'- Читы, которые дают преимущество в стрельбе: AIM, RAPID, AUTO +C, NO SPREAD, EXTRA W, инвиз | Наказание - Jail/Warn (3/3)',
'- Труднодоступные крыши (Исключение: крыши, на которые можно залезть с одного прыжка) | Наказание - Jail/Warn (2/3)',
'- Помощь другой банде (Выдача территории от банды, которая помогала. Выдаётся банде, против которой были две банды) | Наказание - jail/warn (3/3)',
'- Выход из игры, интерьер в бою на решающем фраге | Наказание - Jail/Warn (3/3)',
'- Использование запрещенного транспорта (Военная техника: "Hydra", "Hunter" и прочее) | Наказание - Jail/Warn (3/3)',
'- +C на каптах с Anti +C | Наказание: Jail/Warn (3/3)'}
local bizwarrules = {'На стреле разрешено:',
'',
'- Аптечки (/healme)',
'- Наркотики (/drugs)',
'- Использование багов стрельбы (Отвод с Desert Eagle после 2-го выстрела, сбивы перекатов)',
'На стреле запрещено:',
'',
'- +C, отвод после 1-го выстрела | Наказание: Jail/Warn (1/3)',
'- Маски (/mask) | Наказание - Jail/Warn (1/3)',
'- SK, TK, DB, бронежилет | Наказание - Jail/Warn (1/3)',
'- Читы: SH, TP, FLY, PARKOUR, CLEO ANIM | Наказание - Jail/Warn (1/3)',
'- AFK на стреле от 1+ минут | Наказание - Jail/Warn (1/3)',
'- NO SPREAD, EXTRA WS, Антифраг/офф от килла | Наказание - Jail/Warn (2/3)',
'- Читы, которые дают преимущество в стрельбе: AIM, RAPID, AUTO +C, инвиз, стрельба сквозь объекты | Наказание - Jail/Warn (3/3)',
'- Вред читы: CARSHOT, DAMAGER, РВАНКА и другие | Наказание - Ban (3/3)',
'- Не приезжать на bizwar в течении 3-х минут | (3/3)',
'- Анти-захват бизнеса | Наказание: Jail/Warn (3/3)',
'- Аптечка/наркотики в бою | Наказание: Jail/Warn (1/3)',
'- Сбив | Наказание: Jail/Warn (1/3)',
'- Труднодоступные крыши (Исключение: крыши, на которые можно залезть с одного прыжка) | Наказание - Jail/Warn (2/3)',
'- Дом на колёсах/спавн в доме, который находит'}
local codex = {'Административный кодекс (АК)',
'1. Раздел "Парковка":',
'1.1. Неправильная парковка в общественном месте: - Сотрудник имеет право эвакуировать транспорт и выписать штраф в размере от 350 000$ до 900 000$. - За неправильную парковку в месте большого скопления людей (8 человек) штраф увеличивается в 2 раза.',
'1.2. Неправильная парковка за городом: - Сотрудник имеет право эвакуировать машину и выписать штраф в размере от 250 000$ до 500 000$.',
'1.3. Неправильная парковка в пригороде: - Сотрудник имеет право выписать штраф в размере от 150 000$ до 300 000$.',
'1.4. Брошенный автомобиль на дороге: - Сотрудник имеет право эвакуировать транспорт и выписать штраф в размере от 350 000$ до 600 000$. - За брошенный автомобиль на скоростных трассах сотрудник имеет право эвакуировать транспорт и выписать штраф в размере от 350 000$ до 500 000$.',
'1.5. Парковка на крышах зданий: - Сотрудник имеет право эвакуировать транспорт и выписать штраф в размере 500 000$.',
'1.6. Парковка воздушных транспортных средств или создание помех движению при приземлении на парковочные места для автомобилей или иные нарушения ПДД при управлении воздушными транспортными средствами: - Штраф в размере 50 000$.',
'2. Раздел "Нарушение общественного порядка":',
'2.1. Использование нецензурной лексики в общественном месте: - Сотрудник имеет право выписать штраф в размере 50 000$.',
'2.2. Распитие алкогольных напитков: - Сотрудник имеет право выписать штраф в размере 100 000$.',
'2.3. Курение в общественном месте: - Сотрудник имеет право выписать штраф в размере 100 000$.',
'2.4. Нужда в общественном месте: - Штраф в размере 50 000$.',
'2.5. Пребывание в алкогольном опьянении: - Штраф в размере 100 000$.',
'2.6. Оскорбление сотрудников государственных организаций: - Штраф в размере 500 000$ при продолжении неподобающего поведения. Уровень розыска: 2.',
'2.7. Запрещено находиться без защитной маски в общественных местах: - Штраф в размере 40 000$.',
'• Пункт 3. Нарушение ПДД: Для водителей:',
'3.1. Грубое нарушение ПДД: - Сотрудник имеет право выписать штраф в размере 300 000$.',
'3.2. Езда по встречной полосе: - Штраф в размере 150 000$.',
'3.3. Превышение скорости: - Штраф в размере 100 000$.',
'3.4. Наезд на пешехода: - Уголовная статья, лишение прав, штраф в размере 400 000$.',
'3.5. Уход с места ДТП: - Уголовная статья, лишение водительских прав, штраф в размере 450 000$.',
'3.6. Вождение транспортного средства в нетрезвом состоянии: - Лишение прав, штраф в размере 20 000$.',
'3.7. Создание аварийной ситуации на дороге: - Уголовная статья, лишение водительских прав, штраф в размере 250 000$.',
'3.8. Выключенные фары в ночное время: - Штраф в размере 50 000$.',
'3.9. Выключенные поворотники при совершении поворота: - Штраф в размере 50 000$.',
'3.10. Движение по обочинам, тротуарам, железнодорожным путям: - Лишение прав, штраф в размере от 150 000$ до 300 000$ (в зависимости от нарушения).',
'3.11. Проезд на красный свет: - Штраф в размере 500 000$.',
'3.12. Движение транспортного средства без регистрационного знака: - Штраф в размере 300 000$.',
'3.13. Невыполнение требования Правил дорожного движения уступить дорогу транспортному средству, пользующемуся преимущественным правом проезда на перекрестке: - Штраф в размере 250 000$.',
'Для пешеходов:',
'3.13. Создание аварийной ситуации: - Штраф в размере 200 000$.',
'3.14. Передвижение по проезжей части: - Штраф в размере 150 000$.',
'3.15. Переход на красный свет: - Штраф в размере 50 000$.',
'3.16. Езда со сломанной машиной: - Штраф в размере 170 000$.',
'3.17. Игнорирование сирены специального транспорта: - Сотрудник вправе выписать штраф в размере 200 000$ и лишить водителя прав.',
'4. Раздел "Клевета"',
'4.1. Клевета на жителя штата: - Сотрудник обязан выписать штраф в размере 200 000$.',
'4.2. Ввод в заблуждение правоохранительных органов: - Штраф в размере 300 000$.',
'Уголовный кодекс (УК)',
'1. Раздел "Нападение":',
'1.1. Нападение на гражданское лицо с целью избиения (Уровень розыска: 4).',
'1.1.1. Нападение на сотрудника государственной организации с целью избиения (Уровень розыска: 6).',
'1.2. Нападение на гражданское лицо с целью убийства (Уровень розыска: 6).',
'1.2.1. Нападение на сотрудника государственной организации с целью убийства (Уровень розыска: 6).',
'1.3. Содействие в вооруженном нападении на государственного сотрудника или гражданина (Уровень розыска: 6).',
'1.3.1. Содействие в избиении гражданского лица или государственного сотрудника (Уровень розыска: 4).',
'1.4. Нападение на колонну государственных служащих (Уровень розыска: 6).',
'2. Раздел "Нелегальная деятельность/Запрещенные вещи/Оружие":',
'2.1. Организация несанкционированных митингов (Уровень розыска: 4).',
'2.1.1. Участие в несанкционированных митингах (Уровень розыска: 2).',
'2.2. Хищение чужого имущества (Уровень розыска: 3).',
'2.3. Открытая реклама продажи или покупки наркотиков и материалов для отмычек (Уровень розыска: 4).',
'2.4. Кража материалов на территории армии (Уровень розыска: 5).',
'2.5. Хранение и перевозка наркотических веществ и материалов для отмычек (Уровень розыска: 6). Однако, если наркотики находятся в небольшом количестве и используются в медицинских целях, их наличие может быть исключением.',
'2.6. Сбыт наркотических веществ и материалов: - Продавец (Уровень розыска: 5). - Покупатель (Уровень розыска: 4).',
'2.7. Употребление наркотических/психотропных веществ (Уровень розыска: 4).',
'2.8. Рэкет и крышевание бизнесов (Уровень розыска: 5).',
'2.9. Организация нелегальных азартных игр (Уровень розыска: 5). 2.11. Незаконное приобретение и сбыт оружия (Уровень розыска: 5). В таких случаях производится изъятие оружия и лицензий на него.',
'2.10. Хранение или ношение оружия без лицензии (Уровень розыска: 3).',
'2.11. Ношение оружия в открытом виде (Уровень розыска: 3). В таких случаях производится изъятие лицензии на оружие и самого оружия.',
'2.12. Выращивание и распространение запрещенных веществ (Уровень розыска: 3).',
'2.13. Принадлежность к уличным группировкам/мафии (Уровень розыска: 6).',
'2.14. Организация уличных группировок/мафии (Уровень розыска: 6).',
'2.15. Незаконное представление/незаконное ношение форменной одежды (Уровень розыска: 6)',
'3. Раздел "Нарушение ПДД":',
'3.1. Уход с места ДТП (Уровень розыска: 3).',
'3.2. Создание аварийной ситуации на дороге (Уровень розыска: 2).',
'3.3. Наезд на пешехода (уровень розыска зависит от тяжести нарушения и может быть от 1 до 3).',
'4. Раздел "Неподчинение":',
'4.1. Неподчинение сотруднику правоохранительных органов (Уровень розыска: 4). Перед выдачей розыска обязательно требуется представиться и объяснить причину.',
'4.2. Отказ выплаты штрафа (Уровень розыска: 5).',
'4.3. Отказ остановиться при просьбе через мегафон (Уровень розыска: 3). Выдача розыска происходит после установления личности водителя.',
'4.4. Несоблюдение указов Президента (Уровень розыска: 2).',
'4.5. Содействие аресту или сопротивление содействию ареста (Уровень розыска: 5).',
'5. Раздел "Теракты":',
'5.1. Похищение граждан или государственных сотрудников с целью выкупа (Уровень розыска: 6).',
'5.2. Ограбление организаций, магазинов или автозаправочных станций (Уровень розыска: 6).',
'5.3. Планирование теракта (Уровень розыска: 6).',
'5.4. Организация теракта (Уровень розыска: 6).',
'5.5. Создание террористических группировок (Уровень розыска: 6).',
'5.6. Взятие заложников и похищение людей (Уровень розыска: 6).',
'5.7. Попытка государственного переворота (Уровень розыска: 6 + Черный Список государства + штраф в размере 20 000 000).',
'5.8. Телефонный терроризм (Уровень розыска: 6).',
'6. Раздел "Проникновение":',
'6.1. Проникновение на охраняемую территорию, под охраной правоохранительных органов (Уровень розыска: 6).',
'6.2. Проникновение на частную территорию без разрешения владельца (Уровень розыска: 4).',
'6.3. Проникновение на территорию закрытой военной базы (Уровень розыска: 6).',
'7. Раздел "Проституция":',
'7.1. Участие в проституции (Уровень розыска: 4).',
'7.2. Вовлечение в занятие проституцией (Уровень розыска: 5).',
'7.3. Изнасилование (Уровень розыска: 6).',
'8. Раздел "Дача ложных показаний":',
'8.1. Дача заведомо ложных показаний сотрудникам правоохранительных органов (Уровень розыска: 4)',
'8.2. Ложный вызов сотрудников полиции/ФБР (Уровень розыска: 4)',
'8.3. Укрывательство преступника (Уровень розыска: 5)',
'8.4. Дача ложных показаний в суде. (Штраф 5.000.000 долларов и 4 уровень розыска)',
'9. Раздел "Хулиганство":',
'9.1. Неуважительное отношение к другим расам/меньшинствам (Уровень розыска: 4).',
'9.2. Угроза расправой (Уровень розыска: 3).',
'9.3. Порча имущества государственных организаций (Уровень розыска: 2) или штраф в размере 500 000 долларов.',
'9.3.1. Порча имущества гражданских лиц (Уровень розыска: 1).',
'9.4. Попытка угона транспортного средства (Уровень розыска: 3).',
'9.4.1. Угон транспортного средства (Уровень розыска: 5).',
'9.5. Ношение гражданскими лицами маски, скрывающей лицо (Уровень розыска: 1). Примечание: Сначала следует попросить снять маску, так как данные лица вызывают подозрения у сотрудников правоохранительных органов.',
'10. Раздел "Посягательство на собственность":',
'10.1. Посягательство на частную собственность с применением силы (Штраф до 10 000 000 долларов, Уровень розыска: 5).',
'10.2. Посягательство на частную собственность путем фабрикации юридических документов (Штраф до 10 000 000 долларов, Уровень розыска: 6).',
'10.3. Посягательство на государственную собственность в любом виде (Штраф до 30 000 000 долларов, Уровень розыска: 6).',
'10.4. Незаконная купля/продажа государственной собственности (Снятие с должности, штраф до 5 000 000 долларов, Уровень розыска: 6).',
'11. Раздел "Превышение должностных полномочий":',
'11.1. Превышение должностных полномочий с корыстной целью (Снятие с должности + Черный Список организации, Уровень розыска: 6).',
'Федеральное постановление (ФП)',
'1. Раздел "Положения к Федеральному Постановлению"',
'1.1. Федеральное Постановление выпускается Администрацией Президента и Федеральным Бюро Расследований в отношении государственных служащих.',
'1.2. Изменение Федерального Постановления может быть осуществлено Директором ФБР или Губернатором штата.',
'1.3. Обязанность соблюдения Федерального Постановления лежит на всем персонале государственных организаций.',
'1.4. Отсутствие осведомленности о содержании Федерального Постановления не оправдывает обвиняемого и не освобождает его от ответственности.',
'1.5. В случае, если государственный служащий совершает действие, которое может рассматриваться как косвенное нарушение нормативно-правового акта, применимо к любому из действующих пунктов законодательной базы с ссылкой на Федеральное Постановление.',
'1.6. Положения, предоставляющие возможность выбора вида наказания, предполагают применение одного из них по усмотрению назначающего наказание, учитывая тяжесть нарушения и наличие предшествующих предупреждений или нарушений в прошлом.',
'',
'2. Раздел "Положения относительно государственных организаций"',
'2.1. Запрещается нарушение законодательной базы штата, влекущее за собой устное предупреждение, выговор, понижение или увольнение.',
'2.2. Запрещается использование служебного положения в личных интересах, что может привести к понижению или увольнению.',
'2.3. Запрещается несанкционированное применение физического воздействия на гражданских или государственных лиц, а также их имущество, подлежащее понижению или увольнению.',
'2.4. Запрещается принятие, предложение или предоставление взяток, за что предусмотрено увольнение с привлечением к уголовной ответственности.',
'2.5. Запрещается участие в преступных действиях, сговорах или террористических актах, что влечет за собой увольнение и внесение в черный список государственных структур.',
'2.6. Запрещается заниматься личными делами в рабочее время, к чему применяются два выговора или увольнение, за исключением случаев, когда сотрудник находится в состоянии чрезвычайной ситуации.',
'2.7. Запрещается употребление, покупка, продажа и хранение наркотических средств, подлежащих понижению или увольнению, за исключением случаев, когда это необходимо при следственных мероприятиях для агентов ФБР.',
'2.8. Для служащих армий запрещается нахождение за пределами мест постоянной дислокации своей воинской части, кроме случаев патрулирования, поставок, ЧС и других мероприятий, утвержденных руководящим составом.',
'2.9. Запрещается превышение должностных полномочий, что может привести к выговору, понижению или увольнению.',
'2.10. Запрещается бездействие или неисполнение обязанностей по оказанию помощи лицам в опасной для жизни ситуации, что влечет за собой выговор или понижение.',
'2.11. Запрещаются проявления неадекватного поведения или провокаций, за что предусмотрены предупреждение, выговор или увольнение.',
'2.12. Запрещается игнорирование нарушений законодательства гражданскими или сотрудниками государственных структур, подлежащее выговору или увольнению.',
'2.13. Запрещается провоцировать государственных сотрудников, что может повлечь за собой выговор, понижение или увольнение.',
'2.14. Запрещается угрожать государственным служащим, за исключением агентов ФБР во время следственных мероприятий, когда они вправе использовать свои полномочия для задержания.',
'2.15. Запрещено передавать или продавать государственное имущество, что ведет к увольнению.',
'2.16. Запрещается предоставление заведомо ложной информации государственным сотрудникам, что подлежит понижению или увольнению.',
'2.17. Запрещено использование личного транспортного средства во время исполнения служебных обязанностей, что может привести к выговору, понижению или увольнению, за исключением определенных категорий сотрудников.',
'2.18. Запрещается вступление в сговоры с преступными синдикатами или уличными группировками, что влечет за собой увольнение и внесение в черный список государственных структур, за исключением агентов ФБР в интересах национальной безопасности.',
'2.19. Запрещается употребление нецензурной брани, за что предусмотрены предупреждение или выговор.',
'2.20. Запрещается заносить в базу разыскиваемых статьи, которых не существует, что подлежит предупреждению или выговору.',
'2.21. Запрещается использование мегафона в личных целях в рамках переговоров, что может привести к выговору или понижению.',
'2.22. Запрещается употребление алкоголя в рабочее время, что влечет за собой предупреждение, выговор или увольнение.',
'2.23. Запрещается унижение чести и достоинства граждан, за что предусмотрены предупреждение, выговор или увольнение, с некоторыми исключениями.',
'',
'3. Раздел "Положения относительно сотрудников ФБР"',
'3.1. Запрещается предоставление ложной информации и ввод в заблуждение Агента ФБР, Губернатора, Вице-Губернатора, Судьи, что подлежит увольнению.',
'3.2. Запрещается провокационное поведение в отношении Агента ФБР, Губернатора, Вице-Губернатора и Судьи, что может привести к выговору или увольнению.',
'3.3. Запрещается угрожать и оскорблять Агента ФБР, Губернатора, Вице-Губернатора и Судью, что влечет за собой увольнение.',
'3.4. Запрещается распространение клеветы на Агента ФБР, Губернатора, Вице-Губернатора и Судью, что подлежит выговору или увольнению.',
'3.5. Запрещается игнорирование законных требований Агента ФБР, Губернатора, Вице-Губернатора, что может привести к выговору или увольнению.',
'3.6. Агент ФБР имеет право вызвать любого государственного сотрудника в офис Бюро без объяснения причин, но причина будет раскрыта в офисе.',
'3.7. Любой государственный сотрудник обязан предъявить свое удостоверение по первому требованию Агента ФБР, Губернатора, Вице-Губернатора, иначе предусмотрено выговор, понижение или увольнение.',
'3.8. Запрещается въезд на территорию Федерального Бюро Расследований без разрешения, карающийся увольнением и приравниваемый к статье 7.1 УК.',
'3.9. Запрещается раскрывать личность агента ФБР, находящегося в маскировке, что подлежит увольнению.',
'3.10. Запрещается преследование автомобилей Федерального Бюро Расследований, что может повлечь за собой предупреждение или увольнение.',
'3.11. Запрещается брать на курирование спецоперации без разрешения ФБР, за исключением случаев, когда отсутствует S.W.A.T, в таком случае курирование берет Лидер S.W.A.T.',
'3.12. Запрещается избегать проверок от ФБР или АП, что может привести к увольнению.',
'3.13. Запрещается отдавать приказы агенту ФБР или сотруднику АП рангом выше 7 без соответствующих полномочий, подлежащее выговору или понижению.',
'3.14. Запрещается применять санкции по отношению к агенту ФБР или сотруднику АП рангом выше 8 при исполнении (штрафы и т.п.), что ведет к выговору или понижению.',
'',
'4. Раздел "Рация департамента и государственная волна"',
'4.1. Запрещается обсуждение работы других организаций в рации департамента, что может повлечь за собой выговор, понижение или увольнение.',
'4.2. Категорически запрещается использование нецензурной брани при общении в рации департамента, что подлежит выговору или понижению.',
'4.3. Запрещается занимать государственную волну для проведения собеседования во время режима Чрезвычайной Ситуации, что влечет за собой предупреждение или выговор.',
'4.4. Запрещается участвовать в создании конфликтных ситуаций между организациями, что может привести к выговору или увольнению.',
'4.5. Если к вам обращаются по закрытому каналу, то запрещается отвечать в открытом канале, подлежит предупреждению или выговору.',
}

local AllWindowsPunish = imgui.OnFrame(function() return punishMenu[0] end, function()
	if punishSwitch == 0 then
		imgui.PushFont(myFont)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 205, 440
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY))
		imgui.PushFont(myFont)
		imgui.Begin(u8'Правила', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.BeginChild('##punishMenu', imgui.ImVec2(195,400), false)
		if imgui.Button(u8'Правила администрации', imgui.ImVec2(190, 35)) then
			punishSwitch = 1
		end
		if imgui.Button(u8'Правила лидеров', imgui.ImVec2(190, 35)) then
			punishSwitch = 2
		end
		if imgui.Button(u8'Правила саппортов', imgui.ImVec2(190, 35)) then
			punishSwitch = 3
		end
		if imgui.Button(u8'Правила гос. организаций', imgui.ImVec2(190, 35)) then
			punishSwitch = 4
		end
		if imgui.Button(u8'Правила проведения отбора', imgui.ImVec2(190, 35)) then
			punishSwitch = 5
		end
		if imgui.Button(u8'Правила игры в /try', imgui.ImVec2(190, 35)) then
			punishSwitch = 6
		end
		if imgui.Button(u8'Общие правила', imgui.ImVec2(190, 35)) then
			punishSwitch = 7
		end
		if imgui.Button(u8'Правила каптов', imgui.ImVec2(190, 35)) then
			punishSwitch = 8
		end
		if imgui.Button(u8'Правила бизваров', imgui.ImVec2(190, 35)) then
			punishSwitch = 9
		end
		if imgui.Button(u8'УК/АК/ФП', imgui.ImVec2(190, 35)) then
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
		imgui.Begin(u8'Правила администрации', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search1',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила лидеров', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search2',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила саппортов', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search3',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила гос. организаций', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search4',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила проведения отбора', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search5',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила игры в /try', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search6',u8'Поиск',search,256)
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
		imgui.Begin(u8'Общие правила', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search7',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила каптов', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search8',u8'Поиск',search,256)
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
		imgui.Begin(u8'Правила бизвара', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search9',u8'Поиск',search,256)
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
		imgui.Begin(u8'УК/АК/ФП', punishMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Separator()
		imgui.InputTextWithHint('##Search10',u8'Поиск',search,256)
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
