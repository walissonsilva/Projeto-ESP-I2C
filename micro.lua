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
P = 1; -- quantidade de fichas preferenciais
C = 1; -- quantidade de fichas convencionais
flag_c = 1;
guiche = 0; -- numero de guiches
user = ""; -- usuario que se comunica no momento

dofile("connection_exosite.lua")
function send_exosite(g, s)
    conn:send("cik=a07d0dbab11a9969c0fd961db0b5c19a07faf57e&guiche="..g.."&senha="..s)
end

dofile("init_display.lua")

-- A rotina para desenhar no display
function draw(t)
    dofile("head_display.lua")
    if (atendente[user] == 1) then dofile("guiche_1.lua")
    elseif (atendente[user] == 2) then dofile("guiche_2.lua")
    elseif (atendente[user] == 3) then dofile("guiche_3.lua")
    elseif (atendente[user] == 4) then dofile("guiche_4.lua")
    else dofile("guiche_5.lua") end

    if (t == "P") then dofile("senha_p.lua")
    else dofile("senha_c.lua") end

    if (string.find(string.sub(senha, 1, 1), "0")) then dofile("senha_0e.lua")
    elseif (string.find(string.sub(senha, 1, 1), "1")) then dofile("senha_1e.lua")
    elseif (string.find(string.sub(senha, 1, 1), "2")) then dofile("senha_2e.lua")
    elseif (string.find(string.sub(senha, 1, 1), "3")) then dofile("senha_3e.lua")
    elseif (string.find(string.sub(senha, 1, 1), "4")) then dofile("senha_4e.lua")
    else dofile("senha_5e.lua") end

    if (string.find(string.sub(senha, 2), "0")) then dofile("senha_0d.lua")
    elseif (string.find(string.sub(senha, 2), "1")) then dofile("senha_1d.lua")
    elseif (string.find(string.sub(senha, 2), "2")) then dofile("senha_2d.lua")
    elseif (string.find(string.sub(senha, 2), "3")) then dofile("senha_3d.lua")
    elseif (string.find(string.sub(senha, 2), "4")) then dofile("senha_4d.lua")
    elseif (string.find(string.sub(senha, 2), "5")) then dofile("senha_5d.lua")
    elseif (string.find(string.sub(senha, 2), "6")) then dofile("senha_6d.lua")
    --elseif (string.find(string.sub(senha, 2), "7")) then dofile("senha_7e.lua")
    elseif (string.find(string.sub(senha, 2), "8")) then dofile("senha_8d.lua")
    --elseif (string.find(string.sub(senha, 2), "9")) then dofile("senha_9e.lua")
    else dofile("senha_1e.lua") end
end

function display(t)
    disp:firstPage()
    repeat
       draw(t)
    until disp:nextPage() == false
end

srv=net.createServer(net.TCP);
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        t_atual = tmr.now();

        -- Esse if evita contar mais uma senha com apenas um solicitacao
        if (t_atual - t_anterior  >= 1000000) then      
            t_anterior = tmr.now();

            pos = string.find(request, "Agent");
                pos1 = string.find(request, "\n", pos + 1);
                -- Ex.: User-Agent: Mozilla sdfjdfgdjfgklj
                user = string.sub(request, pos + 7, pos1 - 1);
                i = 0; j = 0;
                for k, v in pairs(atendente) do
                    j = j + 1;
                    if (k ~= user) then i = i + 1; end
                end
            
                if (i == j) then atendente[user] = guiche; guiche = guiche + 1; print("Novo guiche") end
            pos = string.find(request, "?guiche");
            if (pos ~= nil) then
                client:send("<title>".. atendente[user] .."</title>");
            else
            -- Chamada de uma nova senha
            pos = string.find(request, "?call");
            if (pos ~= nil) then
                if ((flag_c <= 2 and fila_c[atual_c] ~= nil)) then
                    senha = string.sub(fila_c[atual_c], 2);
                    if (string.len(senha) == 1) then senha = "0"..senha; end
                    print("Guiche: "..atendente[user].." Senha: "..senha);
                    client:send("<title>C".. senha .."</title>");
                    display("C");
                    send_exosite(atendente[user], fila_c[atual_c]);
                    flag_c = flag_c + 1;
                    atual_c = atual_c + 1;
                elseif (fila_p[atual_p] ~= nil) then
                    senha = string.sub(fila_p[atual_p], 2);
                    if (string.len(senha) == 1) then senha = "0"..senha; end
                    print("Guiche: "..atendente[user].." Senha: "..senha);
                    client:send("<title>P".. senha .."</title>");
                    display("P");
                    send_exosite(atendente[user], fila_p[atual_p]);
                    atual_p = atual_p + 1;
                    flag_c = 1;
                else
                    print("Nao ha senha a ser chamada.");
                    client:send("<title>0</title>");
                    flag_c = 1;
                end
            else
                -- Identificar o usuario e atribuir um numero de guiche, caso seja um novo usuario
                -- request: User-Agent: ...
                
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
                        client:send("<h1>SENHA</h1><h1>" .. fila_c[C] .. "</h1>");
                        C = C + 1;
                    elseif (string.find(atend, "P")) then
                        fila_p[P] = "P" .. tostring(P);
                        print(fila_p[P]);
                        client:send("<h1>SENHA</h1><h1>" .. fila_p[P] .. "</h1>");
                        P = P + 1;
                    end
                end
        
                -- Enviar a parte final pagina para o servidor
                file.open("pagina_final.lua", "r");
                linha = file.readline();
                while(linha ~= nil) do
                    client:send(linha);
                    linha = file.readline();
                end
            end
            end
            client:close();
            collectgarbage();
        end
    end)
end)
