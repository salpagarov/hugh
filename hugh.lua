#!/usr/bin/env lua

fs, json = require "lfs", require "rxi-json"

function isV(x) return type(x) ~= 'table' end
function isT(x) return type(x) == 'table' and #x == 0 end
function isA(x) return type(x) == 'table' and #x ~= 0 end

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
    for k,_ in pairs(a) do
      if not b[k] or not less(a[k], b[k]) then return false end
    end
    return true
  end
  
  if isV(b) then b={b} end
  if isV(a) then
    for _,v in pairs(b) do
      if a == v or v == "" then return true end
    end
    return false
  end
  if isA(a) then
    local f = true
    for _,v in pairs(a) do
      if not less(v,b) then f=false end
    end
    return f
  end
  return false
end

function enrich(a,b)
  if isT(a) and isT(b) then
    for k,_ in pairs(b) do
      if a[k] then a[k]=enrich(a[k],b[k]) else a[k] = b[k] end
    end
  else
    if isV(a) then a={a} end
    
    if isV(b) then b={b} end
    if isA(a) and isA(b) then
      for k1,v1 in pairs(b) do
        local f = false
        for k2,v2 in ipairs(a) do
          if a[k2] == v1 then f=true end
        end
        if not f then table.insert(a,v1) end
      end
      if #a == 1 then a=a[1] end
    end
  end
  return a
end

function enlean(a,b)
  if isV(a) then a={a} end
  if isV(b) then b={b} end
  if isA(a) and isA(b) then
    local t = {}
    for k,v in pairs(a) do t[v]=k end
    for _,v in pairs(b) do
      if t[v] then t[v] = nil end
    end
    local x = {}
    for k,v in pairs(t) do
      if v then x[v]=k end
    end
    return x
  end
  if isT(a) and isT(b) then
    for k,v in pairs(a) do
      if b[k] then a[k] = enlean(a[k], b[k]) end
    end
  end
  return a
end

function edit(meta, update)
  for k,v in pairs(update) do
    if isV(v) then
      meta[k]=enrich(meta[k],meta[v])
    end
  end
  return meta
end

do
  local path = fs.currentdir()
  local magic = { __lt = less, __add = enrich, __sub = enlean }
  local command, filter, update = arg[1] or 'help', setmetatable(json.decode(arg[2] or '{}'), magic), setmetatable(json.decode(arg[3] or '{}'), magic)
  local core, meta = setmetatable({}, magic), setmetatable({}, magic)
  
  if command == "list" then 
    for _, filename in ipairs(get_files(path)) do
      meta = get_data(filename)
      if meta > filter then print(filename) end
    end
  end
  
  if command == "core" then 
    for _,filename in pairs(get_files(path)) do
      meta = get_data(filename)
      if meta > filter then 
        core = core + meta
      end
    end
    print(json.encode(core))
  end
  
  if command == "add" then 
    for _, filename in ipairs(get_files(path)) do
      meta,text = get_data(filename)
      if meta > filter then 
        meta = meta + update
        print(filename)
        put_data(filename,meta,text)
      end
    end
  end
  
  if command == "del" then 
    for _, filename in ipairs(get_files(path)) do
      meta,text = get_data(filename)
      if meta > filter then 
        meta = meta - update
        print(filename)
        put_data(filename,meta,text)
      end
    end
  end
  
  if command == "edit" then 
    for _, filename in ipairs(get_files(path)) do
      meta,text = get_data(filename)
      if meta > filter then 
        put_data(filename,edit(meta,update),text)
        print(filename)
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
      mod     modify metadata
      
    Example:
      hugh add '{"categories" : "video"}' '{"tags" : "video"}'
      hugh del '{"categories" : "video"}' '{"categories" : "video"}'
      hugh mod '{}' '{"authors" : "persons"}'
      
    Requirments:
      luafilesystem, rxi-json
    ]=])
  end
end