a = true
-- setup I2c and connect display
function init_i2c_display()
     i2c.setup(0, 2, 1, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(0x3c)
end
-- the draw() routine
function draw()
  disp:setFont(u8g_font_8x13B);
  disp:drawStr( 5, 15, "23");
  disp:drawCircle(28,8,3);
  disp:drawStr( 34, 15, "C");
  disp:setFont(u8g_font_fub30);
  disp:drawStr( 10, 57, "09:35");
  disp:setFont(u8g_font_5x7);
  disp:drawStr( 115, 33, "AM");
  disp:drawRFrame(0,18, 128, 46, 4);
  disp:drawRFrame(105, 3, 20,12 , 0);
  disp:drawBox(125, 6, 2,6);
  disp:drawBox(107, 5, 4,8);
  disp:drawBox(114, 5, 4,8);
  --disp:drawVLine(99,0, 15);
  --disp:drawVLine(98,0, 15);
  --disp:drawVLine(96,4, 11);
  --disp:drawVLine(95,4, 11);
  --disp:drawVLine(93,8, 7);
  --disp:drawVLine(92,8, 7);
  --disp:drawVLine(90,12, 3);
  --disp:drawVLine(89,12, 3);
end
  
function display()
  disp:firstPage()
  repeat
       draw()
  until disp:nextPage() == false      
  tmr.delay(50000);
  if (tmr.time() < 60) then
    display();
  end
end
init_i2c_display()
display()
