pos = string.find(request, "?atend=");
                if (pos ~= nil) then
                    atend = string.sub(request, pos + 7, pos + 8);
                    if (string.find(atend, "C")) then
                        fila_c[C] = "C" .. tostring(C);
                        print(fila_c[C]);
                        buf = buf .. "<h1>SENHA</h1>";
                        buf = buf .. "<h1>" .. fila_c[C] .. "</h1>";
                        client:send(buf);
                        C = C + 1;
                    elseif (string.find(atend, "P")) then
                        fila_p[P] = "P" .. tostring(P);
                        print(fila_p[P]);
                        client:send("<h1>SENHA</h1><h1>" .. fila_p[P] .. "</h1>");
                        P = P + 1;
                    end
                end