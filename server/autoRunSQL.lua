if Config.AutoRunSQL then
    if not pcall(function()
            local fileName = "installSQL.sql"
            local file = assert(io.open(GetResourcePath(GetCurrentResourceName()) .. "/" .. fileName, "rb"))
            local sql = file:read("*all")
            file:close()

            MySQL.query.await(sql)
        end) then
        print(
            "^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0")
    end
end
