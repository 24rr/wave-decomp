_G.decomp = function(servicePath)
    local WaveDecompiler = {}
    local AnalyzedScripts = {}

    local function DecompileSingleScript(intricateScript)
        local success, intricateSource = pcall(decompile, intricateScript)
        if not success or not intricateSource then
            return "-- Decompilation unsuccessful | Script is inaccessible or hardly-readable"
        else
            return intricateSource:gsub("\0", "\\0")
        end
    end

    WaveDecompiler.AnalyzeAndDisplayScript = function(intricateScript)
        local intricateSource = DecompileSingleScript(intricateScript)
        AnalyzedScripts[intricateScript] = intricateScript
        print(intricateSource)
    end

    WaveDecompiler.ArchiveScriptToDisk = function(intricateScript)
        local intricateSource = DecompileSingleScript(intricateScript)
        local complexFolderName = "Place_" .. game.PlaceId .. "_ScriptsArchive"
        makefolder(complexFolderName)
        local complexFilename = complexFolderName .. "/" .. intricateScript.Name .. ".txt"
        writefile(complexFilename, intricateSource)
        print("Archived script at: " .. complexFilename)
    end

    WaveDecompiler.ExtractScriptFunctions = function(intricateScript)
        pcall(function()
            local secureGetGc = getgc or get_gc_objects
            local secureGetUpvalues = (debug and debug.getupvalues) or getupvalues or getupvals
            local secureGetConstants = (debug and debug.getconstants) or getconstants or getconsts
            local secureGetInfo = (debug and (debug.getinfo or debug.info)) or getinfo
            local intricateOutput = ("\n-- Function Analysis\n-- Script Identifier: %s\n\n--[["):format(intricateScript:GetFullName())
            local comprehensiveDump = intricateOutput
            local intricateDataSet = {}

            local function addDetailToDump(str, levelOfIndentation)
                comprehensiveDump = comprehensiveDump .. string.rep("    ", levelOfIndentation) .. tostring(str) .. "\n"
            end

            local function retrieveFunctionName(func)
                local funcName = secureGetInfo(func).name
                return funcName ~= "" and funcName or "Unnamed Function"
            end

            local function analyzeTable(tbl, levelOfIndentation)
                levelOfIndentation = levelOfIndentation < 0 and 0 or levelOfIndentation
                addDetailToDump(("[%s] %s"):format(tostring(type(tbl)), tostring(tbl)), levelOfIndentation)
                local itemCount = 0
                for key, value in pairs(tbl) do
                    itemCount = itemCount + 1
                    if type(value) == "function" then
                        addDetailToDump(("%d [function] = %s"):format(itemCount, retrieveFunctionName(value)), levelOfIndentation + 1)
                    elseif type(value) == "table" then
                        if not intricateDataSet[value] then
                            intricateDataSet[value] = true
                            addDetailToDump(("%d [table]:"):format(itemCount), levelOfIndentation + 1)
                            analyzeTable(value, levelOfIndentation + 2)
                        else
                            addDetailToDump(("%d [table] (Recursive)"):format(itemCount), levelOfIndentation + 1)
                        end
                    else
                        addDetailToDump(("%d [%s] = %s"):format(itemCount, type(value), tostring(value)), levelOfIndentation + 1)
                    end
                end
            end

            local function analyzeFunction(func, levelOfIndentation)
                addDetailToDump(("Function Analysis: %s"):format(retrieveFunctionName(func)), levelOfIndentation)
                addDetailToDump(("Function Upvalues: %s"):format(retrieveFunctionName(func)), levelOfIndentation)
                for index, upvalue in pairs(secureGetUpvalues(func)) do
                    if type(upvalue) == "function" then
                        addDetailToDump(("%d [function] = %s"):format(index, retrieveFunctionName(upvalue)), levelOfIndentation + 1)
                    elseif type(upvalue) == "table" then
                        if not intricateDataSet[upvalue] then
                            intricateDataSet[upvalue] = true
                            addDetailToDump(("%d [table]:"):format(index), levelOfIndentation + 1)
                            analyzeTable(upvalue, levelOfIndentation + 2)
                        else
                            addDetailToDump(("%d [table] (Recursive)"):format(index), levelOfIndentation + 1)
                        end
                    else
                        addDetailToDump(("%d [%s] = %s"):format(index, type(upvalue), tostring(upvalue)), levelOfIndentation + 1)
                    end
                end
                addDetailToDump(("Function Constants: %s"):format(retrieveFunctionName(func)), levelOfIndentation)
                for index, constant in pairs(secureGetConstants(func)) do
                    if type(constant) == "function" then
                        addDetailToDump(("%d [function] = %s"):format(index, retrieveFunctionName(constant)), levelOfIndentation + 1)
                    elseif type(constant) == "table" then
                        if not intricateDataSet[constant] then
                            intricateDataSet[constant] = true
                            addDetailToDump(("%d [table]:"):format(index), levelOfIndentation + 1)
                            analyzeTable(constant, levelOfIndentation + 2)
                        else
                            addDetailToDump(("%d [table] (Recursive)"):format(index), levelOfIndentation + 1)
                        end
                    else
                        addDetailToDump(("%d [%s] = %s"):format(index, type(constant), tostring(constant)), levelOfIndentation + 1)
                    end
                end
            end

            for _, func in pairs(secureGetGc()) do
                if type(func) == "function" and getfenv(func).script == intricateScript then
                    analyzeFunction(func, 0)
                    addDetailToDump("\n" .. ("="):rep(100), 0)
                end
            end
            local finalOutput = comprehensiveDump
            if comprehensiveDump ~= intricateOutput then
                finalOutput = finalOutput .. comprehensiveDump .. "]]"
            end
            print(finalOutput)
        end)
    end

    local function analyzeScripts(servicePath)
        local intricateServiceScripts = game:GetService(servicePath):GetDescendants()
        for _, intricateScript in pairs(intricateServiceScripts) do
            if intricateScript:IsA("LocalScript") or intricateScript:IsA("ModuleScript") then
                if not AnalyzedScripts[intricateScript] then
                    WaveDecompiler.AnalyzeAndDisplayScript(intricateScript)
                    WaveDecompiler.ArchiveScriptToDisk(intricateScript)
                    WaveDecompiler.ExtractScriptFunctions(intricateScript)
                end
            end
        end
    end

    analyzeScripts(servicePath)
end
