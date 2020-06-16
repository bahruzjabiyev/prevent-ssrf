local params_to_exclude = "paramname1 paramname2";
local pages_to_exclude = "pagename1 pagename2";
local helper_server = "172.17.0.3"

-- Check if page is excluded
local is_page_excluded = false
local pages_arr, err = ngx.re.gmatch(pages_to_exclude, "([^ ]+)", "i")
while true do
    local m, err = pages_arr()
    if not m then
        break
    end
    if m[0] == ngx.var.uri then
        is_page_excluded = true
    end
end

if is_page_excluded then
-- If page is exluded, pass the request without inspection.
else

	-- This function is for checking charset
	local is_utf_8 = function(contenttype)
		if contenttype == nil then
			return true
		end
		charsets,err = contenttype:gmatch("[^a-z]charset", "i")
		
		local no_charset = false
		local more_than_one_charset = false
		local i = 0
		while true do
		  local m, err = charsets()
		  if i>1 then
		    more_than_one_charset = true
		    break
		  end
		  if not m then
		    if i==0 then
		      no_charset = true
		    end
		    break
		  end
		  i = i + 1
		end
		
		if more_than_one_charset then
		  return false
		else
		  return (no_charset or (not (contenttype:match("[^a-z]charset[ ]*=[ ]*utf.8")==nil)))
		end
	end

	local replace_scheme = function(str, is_url_encoded)
		if is_url_encoded then
			local schemes = {'://', ':/%2f', ':%2f/', ':%2f%2f', '%3a//', '%3a/%2f', '%3a%2f/', '%3a%2f%2f'}	
			for i = 1, 8 do
				str, n, err = ngx.re.gsub(str, schemes[i], "://" .. helper_server .. "/?url=http://", "i")
			end
		else
			str, n, err = ngx.re.gsub(str, "://", "://" .. helper_server .. "/?url=http://")
		end
		return str
	end

	local exclude_param = function(str, param)
		str, n, err = ngx.re.sub(str, "(^"..param..")=([a-zA-Z]+)://" .. helper_server .. "/.url=http", "$1=$2")
		str, n, err = ngx.re.sub(str, "(&"..param..")=([a-zA-Z]+)://" .. helper_server .. "/.url=http", "$1=$2")
		return str
	end

	-- Exit if charset is not utf-8	
	if not is_utf_8(ngx.var.content_type) then
		ngx.exit(ngx.ERROR)
	end

    -- Get the request uri
    local req_uri = ngx.var.args

	-- Search and modification starts here
    if req_uri then

        -- Modify uri arguments
		local modified_arguments = replace_scheme(req_uri, true) 

        -- Debug
        if not (modified_arguments == arguments) then
            ngx.log(ngx.ERR, "debug: newrequri: ", modified_arguments)
        end

        -- Make sure that excluded parameters remain unchanged
        local temp_arr, err = ngx.re.gmatch(params_to_exclude, "([^ ]+)", "i")
        while true do
            local m, err = temp_arr()
            if not m then
                break
            end
			modified_arguments, n, err = exclude_param(modified_arguments, m[0])
        end
		ngx.req.set_uri_args(modified_arguments)
    end

    -- Read the request body
    ngx.req.read_body()

    -- Get the request body
    local req_body = ngx.req.get_body_data()

    if req_body then

        -- Consider URL encoded versions of :// if it's url encoded, when replacing
        if (ngx.var.content_type == "application/x-www-form-urlencoded") then
			new_req_body = replace_scheme(req_body, true)
		else
			new_req_body = replace_scheme(req_body, false)
        end

		-- Debug
        if not (new_req_body == req_body) then
            ngx.log(ngx.ERR, "debug: newreqbody: ", new_req_body)
        end

        -- Make sure that excluded parameters remain unchanged
        local temp_arr, err = ngx.re.gmatch(params_to_exclude, "([^ ]+)", "i")
        while true do
            local m, err = temp_arr()
            if not m then
                break
            end
			new_req_body, n, err = exclude_param(new_req_body, m[0])
        end
		ngx.req.set_body_data(new_req_body)
    end
end
