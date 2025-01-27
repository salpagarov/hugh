#!/usr/bin/env lua

function isV(x) return type(x) ~= 'table' and x ~= nil end
function isA(x) 
  if type(x) == "table" then
    for k,v in ipairs(x) do return true end
  end
  return false
end
function isT(x) 
  if type(x) == "table" then
    for k,v in pairs(x) do return true end
  end
  return false
end
function isE(x)
  return not(isA(x) or isT(x))
end

fs = require "lfs"

function get_files(directory)
  local files = {}
  for name in fs.dir(directory) do
    local fullname = directory..'/'..name
    if fs.attributes(fullname).mode == "directory" and name ~= "." and name ~= ".." then 
      for _, v in ipairs(get_files(fullname)) do 
        table.insert(files, v) 
      end 
    elseif string.sub(fullname, string.len(fullname)-2) == ".md" then 
      table.insert(files, fullname) 
    end
  end
  return files
end

json = require "rxi-json"

function get_data(filename)
  local file, meta, level = io.open(filename, 'r'), '', 0
  repeat
    local char = file:read(1)
    meta = meta .. char
    if char == '{' then level = level + 1 end
    if char == '}' then 
      level = level - 1 
      if level == 0 then break end 
    end
  until char == nil
  local text = file:read("*all") 
  file:close()
  return json.decode(meta),text
end

function put_data(filename, meta, text)
  return io.open(filename, 'w'):write(json.encode(meta)):write(text):close()
end

function less(a, b)
  if isT(a) and isT(b) then
    for k,v in pairs(a) do
      if not b[k] or not less(v,b[k]) then return false end
    end
    return true
  end
  if isA(a) and isA(b) then
    for _,v in pairs(a) do
      if not less(v,b) then return false end
    end
    return true
  end
  if isV(a) and isA(b) then
    for _,v in pairs(b) do
      if less(a,v) then return true end
    end
    return false
  end
  if isV(a) and isV(b) then
    if a == b then return true end
    return false
  end
  if isE(a) and not isE(b) then return true end
  return false
end

function enrich(a,b)
  if isV(a) then a={a} end
  if not isA(a) and not isT(a) then return b end
  if (isT(a) or isA(a)) and isV(b) then
    for k,v in pairs(a) do 
      if b == v then return a end
    end
    table.insert(a,b)
    return a
  end
  if isA(a) and isA(b) then 
    for k,v in pairs(b) do a = enrich(a,v) end
    return a
  end
  if isT(a) and isT(b) then
    for k,v in pairs(b) do a[k] = enrich(a[k],b[k]) end
  end
  return a
end

function enlean(a,b)
  if isE(a) then return nil end
  if isT(a) and isT(b) then
    for k,v in pairs(b) do a[k] = enlean(a[k],b[k]) end
    return a
  end
  if isA(a) and isA(b) then
    for k,v in pairs(b) do a[k] = enlean(a,b[k]) end
    return a
  end
  if isA(a) and isV(b) then
    for k,v in pairs(a) do 
      if a[k] == b[k] then a[k] = nil end
    end
    return a
  end
  if isV(a) and isV(b) then
    if a == b then 
      print("remove last",a,b)
      return nil 
    end
  end
  print("wtf?!",a,b)
end

do
  local path = fs.currentdir()
  local command = arg[1] or 'help'
  local m = { __lt = less }
  local filter, update = setmetatable(json.decode(arg[2] or '{}'), m), setmetatable(json.decode(arg[3] or '{}'), m)
  local core, meta = setmetatable({}, m), setmetatable({}, m)
  
  if command == "list" then 
    for _, filename in ipairs(get_files(path)) do
      meta = get_data(filename)
      if meta > filter then print(filename) end
    end
  end
  
  if command == "core" then 
    for _,filename in pairs(get_files(path)) do
      meta = get_data(filename)
      if meta > filter then core = enrich(core,meta) end
    end
    print(json.encode(core))
  end
  
  if command == "add" then 
    for _, filename in ipairs(get_files(path)) do
      meta,text = get_data(filename)
      if meta > filter then 
        meta = enrich(meta,update)
        print(filename)
        put_data(filename,meta,text)
      end
    end
  end
  
  if command == "del" then 
    for _, filename in ipairs(get_files(path)) do
      meta,text = get_data(filename)
      if meta > filter then 
        meta = enlean(meta,update)
        print(filename)
        put_data(filename,meta,text)
      end
    end
  end
  
  if command == "help" then
    print([=[
    Hugo JSON semantic helper
    Usage:
      hugh [<command> ['<filter-json>' ['<update-json>']]]
      
    Commands:
      help    this text
      core    get taxonomies (semantic core)
      list    get posts list
      add     enrich metadata
      del     enlean metadata
      
    Example:
      hugh add  '{"categories":"video"}' '{"tags":"video"}'
      hugh del  '{"categories":"video"}' '{"categories":"video"}'
      
    Requirments:
      luafilesystem, rxi-json
    ]=])
  end
end