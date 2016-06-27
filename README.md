# Petrel


```
http {
    lua_package_path "/usr/local/Cellar/openresty/1.9.7.4/nginx/lua/petrel/?.lua;/usr/local/Cellar/openresty/1.9.7.4/nginx/lua/petrel/?/init.lua;;";
    init_by_lua_file lua/petrel/url.lua;
    access_by_lua_file lua/petrel/router.lua;
    lua_shared_dict cache 10m;
    resolver 223.5.5.5;


    server {
            set $template_root /usr/local/Cellar/openresty/1.9.7.4/nginx/lua/petrel/templates;
    }
}
```