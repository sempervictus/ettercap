--- 
-- The purpose of this lib is to provide a simple way of defining the style of 
-- session tracking that would be employed by a given script.

local ffi = require("ettercap_ffi")

local shortsession = {}

-- We need the size of a pointer so that we know how to address things properly.
local ptr_size = ffi.sizeof("void *")

local ident_magic_ptr = ffi.typeof("struct ident_magic *")

function magic_session(packet_object, magic_vals)
  -- Make sure that we've got a table.
  if (not type(magic_vals) == "table") then
    return nil
  end

  local session = packet_object.session
  while true do
    if not session then
      return nil
    end
    local ident = session.ident
    if ident then
      local ident_magic = ffi.cast(ident_magic_ptr, ident)
      local magic = tonumber(ident_magic.magic)
      -- If we have the magic value in our table, then we have are in the 
      -- right spot!
      if magic_vals[magic] then
        break
      end
    end

    -- go to the next session in the chain...
    session = session.prev_session
  end

  -- If we've gotten here, then we've found a session.
  return(ffi.string(session, ptr_size))

end

local ip_magic_vals = {[ffi.C.IP_MAGIC] = 1, [ffi.C.IP6_MAGIC] = 1}
local tcp_magic_vals = {[ffi.C.TCP_MAGIC] = 1}
-- Search down through the session structures for either an IP or IPv6 
-- session object. If we find that, then use it. If we don't find the session
-- structure, then return nil.
--
-- @return string (on success) or nil (on failure)
ip_session = function(prefix)
  return(function(packet_object)
    local sess_memory_addr = magic_session(packet_object, ip_magic_vals)
    if not sess_memory_addr then
      return nil
    end
    return(table.concat({prefix, sess_memory_addr}, "-"))
  end)
end

-- Search down through the session structures for either a TCP
-- session object. If we find that, then use it. If we don't find the session
-- structure, then return nil.
--
-- @return string (on success) or nil (on failure)
tcp_session = function(prefix)
  return(function(packet_object)
    local sess_memory_addr = magic_session(packet_object, tcp_magic_vals)
    if not sess_memory_addr then
      return nil
    end
    return(table.concat({prefix, sess_memory_addr}, "-"))
  end)
end

shortsession.ip_session = ip_session
shortsession.tcp_session = tcp_session

return shortsession
