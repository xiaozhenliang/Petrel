local _M = {}
local mt = { __index = _M }


function _M.new(self)
    return setmetatable({ router={} }, mt)
end


function _M.add(self, uri, func)
    self.router[uri] = func
end


function _M.dispatch(self, uri)
    return self.router[uri]
end


return _M
