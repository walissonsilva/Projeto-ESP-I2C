-- Enviar a parte inicial da pagina para o servidor
file.open("pagina_inicio.lua", "r");
linha = file.readline();
while(linha ~= nil) do
    client:send(linha);
    linha = file.readline();
end