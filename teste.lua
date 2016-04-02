wifi.setmode(wifi.STATION);
wifi.sta.config("TESTE VIRUS", "winarrel");
wifi.sta.connect();

pin = 3; -- GPIO0 = 3 GPIO2 = 4
temp_anterior = 0;

a = true

-- Funcao para adquirir a hora por meio da internet
function hora()
    conn=net.createConnection(net.TCP, 0) 

    conn:on("connection",function(conn, payload)
            conn:send("HEAD / HTTP/1.1\r\n".. 
                "Host: google.com/\r\n"..
                "Accept: */*\r\n"..
                "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                "\r\n\r\n")
    end)
        
    conn:connect(80,'google.com')

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
end

-- Configurar o I2C e o display
function init_i2c_display()
     i2c.setup(0, 2, 1, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(0x3c)
end

-- A rotina para desenhar no display
function draw()
  disp:setFont(u8g.font_6x10);
  disp:drawStr( 5, 15, temp);
  disp:drawCircle(24,8,1);
  disp:drawStr( 26, 15, "C");
  disp:drawStr( 40, 15, "ESPBanco");
  disp:drawStr( 95, 15, hour..":"..minute);
  disp:drawRFrame(0, 20, 128, 44, 4); -- Frame da guiche
  disp:drawRFrame(0, 5, 35, 14 , 2); -- Frame da temperatura
  disp:drawRFrame(91, 5, 36, 14 , 2); -- Frame do hora
  
end

function display()
    getTemp()
    hora()
    disp:firstPage()
    repeat
       draw()
    until disp:nextPage() == false
end

function getTemp()
    status, temp, humi, temp_dec, humi_dec = dht.read(pin);
    
    if status == dht.OK then
        temp_anterior = temp;    
        -- Float firmware using this example
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    end

    temp = temp_anterior;
end

init_i2c_display()
display()

tmr.alarm(1, 10000, 1, function() display() end)