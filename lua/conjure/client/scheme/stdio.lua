local _2afile_2a = "fnl/conjure/client/scheme/stdio.fnl"
local _2amodule_name_2a = "conjure.client.scheme.stdio"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, client, config, log, mapping, nvim, stdio, str, _ = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["stdio"] = stdio
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["_"] = _
config.merge({client = {scheme = {stdio = {command = "mit-scheme", mapping = {start = "cs", stop = "cS"}, prompt_pattern = "[%]e][=r]r?o?r?> "}}}})
local cfg = config["get-in-fn"]({"client", "scheme", "stdio"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _1_()
  return {repl = nil}
end
state = (state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".scm"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
_2amodule_locals_2a["with-repl-or-warn"] = with_repl_or_warn
local function unbatch(msgs)
  local function _3_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return {out = str.join("", a.map(_3_, msgs))}
end
_2amodule_2a["unbatch"] = unbatch
local function format_msg(msg)
  local function _4_(_241)
    if string.match(_241, "^;Value: ") then
      return string.gsub(_241, "^;Value: ", "")
    else
      return (comment_prefix .. "(out) " .. _241)
    end
  end
  return a.map(_4_, str.split(string.gsub(string.gsub(a.get(msg, "out"), "^%s*", ""), "%s+%d+%s*$", ""), "\n"))
end
_2amodule_2a["format-msg"] = format_msg
local function eval_str(opts)
  local function _6_(repl)
    local function _7_(msgs)
      local msgs0 = format_msg(unbatch(msgs))
      opts["on-result"](a.last(msgs0))
      return log.append(msgs0)
    end
    return repl.send((opts.code .. "\n"), _7_, {["batch?"] = true})
  end
  return with_repl_or_warn(_6_)
end
_2amodule_2a["eval-str"] = eval_str
local function eval_file(opts)
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
_2amodule_2a["eval-file"] = eval_file
local function display_repl_status(status)
  return log.append({(comment_prefix .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
_2amodule_locals_2a["display-repl-status"] = display_repl_status
local function stop()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  end
end
_2amodule_2a["stop"] = stop
local function start()
  if state("repl") then
    return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _9_(err)
      return display_repl_status(err)
    end
    local function _10_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(comment_prefix .. "process exited with code " .. code)})
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(comment_prefix .. "process exited with signal " .. signal)})
      end
      return stop()
    end
    local function _13_(msg)
      return log.append(format_msg(msg))
    end
    local function _14_()
      return display_repl_status("started")
    end
    return a.assoc(state(), "repl", stdio.start({["on-error"] = _9_, ["on-exit"] = _10_, ["on-stray-output"] = _13_, ["on-success"] = _14_, ["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"})}))
  end
end
_2amodule_2a["start"] = start
local function on_load()
  return start()
end
_2amodule_2a["on-load"] = on_load
local function on_filetype()
  mapping.buf("n", "SchemeStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
  return mapping.buf("n", "SchemeStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
end
_2amodule_2a["on-filetype"] = on_filetype
local function on_exit()
  return stop()
end
_2amodule_2a["on-exit"] = on_exit