-- Configurar o I2C e o display
function init_i2c_display()
     i2c.setup(0, 1, 2, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(0x3c)
     disp:setFont(u8g.font_6x10);
end

init_i2c_display();