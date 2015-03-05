#!/usr/bin/env lua

--[[
--
-- Author: OndraK
--
-- This piece of lua code can be distributed under the terms of GNU GPL v3
--
--]]

package.path = './.config/openbox/pipe_menus/?.lua;' .. package.path
local l10n = require "l10n"
local system = require 'system'
local openboxMenu = require 'openboxMenu'

local cmds = {
	processDetail = "ps -o comm,nice,pcpu,args --pid %d h",
	topProcesses = "ps -eo pid --sort=-pcpu h | head -%d | tr -d ' '",
	reniceProcess = "renice -n %d --pid %d"
}

-- use only processManager part of l10n
l10n = l10n.cz.processManager

local function processMenu(info)
	openboxMenu.title(info.prikaz)
	openboxMenu.item(string.format("pCPU: %1.2f", info.pcpu))
	openboxMenu.button(l10n.restartProcess, { string.format("kill -9 %d", info.pid), info.prikaz })
	if info.nice < 19 then
		openboxMenu.button(string.format(l10n.lowerPriority, info.nice), string.format(cmds.reniceProcess, info.nice + 5, info.pid))
	else
		openboxMenu.item(string.format(l10n.priority, info.nice))
	end
	openboxMenu.button(l10n.endProcess, string.format("kill %d", info.pid))
	openboxMenu.button(l10n.killProcess, string.format("kill -9 %d", info.pid))
end

local function nonexistingProcess(pid)
	openboxMenu.item(string.format(l10n.nonExistingProcess, pid))
end

local function processMenagement(pid)
	local psCmd = system.pipe(string.format(cmds.processDetail, pid), "tr -s ' '")
	local ps = system.singleResult(psCmd) or ""
	local program, nice, pcpu, prikaz = ps:match("(%w+) (%d+) (%d+%.%d+) (.+)")
	openboxMenu.beginMenu("top_processes_" .. pid, string.format("%s (PID: %d)", program or "", pid))
	if program then
		processMenu({ pid = pid, program = program, nice = tonumber(nice), pcpu = pcpu, prikaz = prikaz })
	else
		nonexistingProcess(pid)
	end
	openboxMenu.endMenu()
end

local function topProcesses(pocet)
	pocet = pocet or 5
	for pid in system.resultLines(string.format(cmds.topProcesses, pocet)) do
		processMenagement(pid)
	end
end

local function main()
	openboxMenu.beginPipemenu()
	topProcesses(5)
	openboxMenu.endPipemenu()
end

main()

