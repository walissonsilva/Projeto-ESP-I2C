-- retrieve the current time from Google
-- tested on NodeMCU 0.9.5 build 20150108

conn=net.createConnection(net.TCP, 0) 

conn:on("connection",function(conn, payload)
    conn:send("HEAD / HTTP/1.1\r\n".. 
        "Host: google.com/\r\n"..
        "Accept: */*\r\n"..
        "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
        "\r\n\r\n") 
end)
            
conn:on("receive", function(conn, payload)
    -- Encontrar o valor da hora no payload e converter para inteiro
    -- subtraindo, devido ao fuso horario (GMT)
    hourInt = tonumber(string.sub(payload,string.find(payload,"Date: ")
           +23,string.find(payload,"Date: ")+24)) - 3;
    
    -- Se der -3 (menor que zero), por exemplo, hourInt = -3 + 24 = 21
    if (hourInt < 0) then hourInt = hourInt + 24 end

    -- Converter hourInt para string
    hour = tostring(hourInt);
    -- Encontrar o valor dos minutos (em string)
    minute = string.sub(payload,string.find(payload,"Date: ")
           +26,string.find(payload,"Date: ")+27);

    -- Imprimir o valor da hora e do minuto
    print(hour..":"..minute);

    -- Qualquer dúvida imprimir a variavel "payload"
    
    conn:close()
    end)

conn:connect(80,'google.com') 

