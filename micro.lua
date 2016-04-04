wifi.setmode(wifi.STATION);
wifi.sta.config("TESTE VIRUS", "winarrel");
wifi.sta.autoconnect(1);
print(wifi.sta.getip());

t_anterior = tmr.now();

fila_p = {}; -- Sequencia das senhas prioritarias a serem atendidas
fila_c = {}; -- Sequencia das senhas convencionais a serem atendidas
atendente = {} -- Lista dos atendentes associados ao seu guiche
atual_p = 1; -- posicao no vetor da ficha preferencial que sera chamada
atual_c = 1; -- posicao no vetor da ficha preferencial que sera chamada
qnt = 1; -- quantidade de fichas
P = 1; -- quantidade de fichas preferenciais
C = 1; -- quantidade de fichas convencionais
flag_c = 1;
guiche = 0; -- numero de guiches
user = ""; -- usuario que se comunica no momento

-- Criando conexao com o Exosite
conn = net.createConnection(net.UDP, 0)
conn:connect(18494,"52.8.0.240")
conn:on("sent", function(conn)
    print("Dados enviados com sucesso")
end)

function send_exosite(g, s)
    conn:send("cik=a07d0dbab11a9969c0fd961db0b5c19a07faf57e&guiche="..g.."&senha="..s)
end

srv=net.createServer(net.TCP);
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        t_atual = tmr.now();

        -- Esse if evita contar mais uma senha com apenas um solicitacao
        if (t_atual - t_anterior  >= 1000000) then        
        t_anterior = tmr.now();

        -- Identificar o usuario e atribuir um numero de guiche, caso seja um novo usuario
        -- request: User-Agent: ...
        pos = string.find(request, "Agent");
        if (pos ~= nil) then 
        pos1 = string.find(request, "\n", pos + 1);
        end
        -- Ex.: User-Agent: Mozilla sdfjdfgdjfgklj
        user = string.sub(request, pos + 7, pos1 - 1);
        i = 0; j = 0;
        for k, v in pairs(atendente) do
            j = j + 1;
            if (k ~= user) then i = i + 1; end
        end

        if (i == j) then atendente[user] = guiche; guiche = guiche + 1; print("Novo guiche") end
        
        -- Enviar a parte inicial da pagina para o servidor
        file.open("pagina_inicio.lua", "r");
        linha = file.readline();
        while(linha ~= nil) do
            client:send(linha);
            linha = file.readline();
        end
    
        pos = string.find(request, "?atend=");
        if (pos ~= nil) then
            atend = string.sub(request, pos + 7, pos + 8);
            if (string.find(atend, "C")) then
                fila_c[C] = "C" .. tostring(C);
                print(fila_c[C]);
                buf = "<p><h1>SENHA</h1></p>";
                buf = buf .. "<p><h1>" .. fila_c[C] .. "</h1></p>";
                client:send(buf);
                C = C + 1;
                qnt = qnt + 1;
            elseif (string.find(atend, "P")) then
                fila_p[P] = "P" .. tostring(P);
                print(fila_p[P]);
                buf = "<p><h1>SENHA</h1></p>";
                buf = buf .. "<p><h1>" .. fila_p[P] .. "</h1></p>";
                client:send(buf);
                P = P + 1;
                qnt = qnt + 1;
            end
        end

        pos = string.find(request, "?call");
        if (pos ~= nil) then
            if ((flag_c <= 2 and fila_c[atual_c] ~= nil) or fila_p[atual_p] == nil) then
                print("Guichê: "..atendente[user].." Senha: "..fila_c[atual_c]);
                send_exosite(atendente[user], fila_c[atual_c]);
                flag_c = flag_c + 1;
                atual_c = atual_c + 1;
            else
                print("Guichê: "..atendente[user].." Senha: "..fila_p[atual_p]);
                send_exosite(atendente[user], fila_p[atual_p]);
                atual_p = atual_p + 1;
                flag_c = 1;
            end
        end

        -- Enviar a parte final pagina para o servidor
        file.open("pagina_final.lua", "r");
        linha = file.readline();
        while(linha ~= nil) do
            client:send(linha);
            linha = file.readline();
        end
        
        client:close();
        collectgarbage();
        end
    end)
end)