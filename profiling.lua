-- This script uses writes to 0x7fd, 0x7fe, and 0x7ff to determine when to store the start of an IRQ, game loop, or NMI respectively.
-- If you write the value 2 to the address when you start the area you'd like to time, you then write the value 1 to that same address
-- to stop the timer and calculate the cycles elapsed and display it on screen. For example, to time your NMI code, at the beginning of
-- your NMI routine, write 2 to 0x7ff and then after you're done with your NMI, before calling RTI, write 1 to 0x7ff and that will display
-- the number of cycles it took to complete your NMI code. Hopefully it's not too many!

--emu.speedmode("normal") -- Set the speed of the emulator

-- Declare and set variables or functions if needed

timing = false;

nminowcount = 0;
gamelooplast = 0;
irqlast = 0;

function getTypeLabel(etype)
    if etype == 1 then
        return "Blaster";
    elseif etype == 2 then
        return "Bullet";
    elseif etype == 3 then
        return "FlyBy";
    elseif etype == 4 then
        return "Player";
    else
        return "Unknown";
    end
end

function calcframes(address, size)

    value = memory.readbyte(address);
    if value == 2 then
        if address == 0x07ff then 
            nmilastcount = debugger.getcyclescount();
        elseif address == 0x07fe then 
            gamelooplast = debugger.getcyclescount();
        elseif address == 0x07fd then 
            irqlast = debugger.getcyclescount();
        end
        return

    elseif value == 1 then
        if address == 0x07ff then
            diff = debugger.getcyclescount() - nmilastcount;
            gui.text(10,10,"NMI: " .. diff);
        elseif address == 0x07fe then
            diff = debugger.getcyclescount() - gamelooplast;
            gui.text(10,20,"GL:  " .. diff);
        elseif address == 0x07fd then
            diff = debugger.getcyclescount() - irqlast;
            gui.text(10,30,"IRQ: " .. diff);
        end
    end
end



    memory.registerwrite(0x07ff, 1, calcframes);
    memory.registerwrite(0x07fe, 1, calcframes);
    memory.registerwrite(0x07fd, 1, calcframes);
--while true do
  --for i = 0,18
  --do
    --baseaddr = 0x0021 + (i*6);
    --x = memory.readbyte(baseaddr)
    --y = memory.readbyte(baseaddr+1)
    --xv = memory.readbyte(baseaddr+2)
    --if xv > 127 then 
        --xv = xv - 256
    --end
    --yv = memory.readbyte(baseaddr+3)
    --if yv > 127 then
        --yv = yv - 256
    --end
    --etype = memory.readbyte(baseaddr+4)
    --if etype ~= 0 then
        ----gui.text(10,40  + (i*10),i .. ": " ..  getTypeLabel(etype) .. " " .. x .. ", " .. y .. ": " .. xv .. ", " .. yv);
    --end
  --end
  emu.frameadvance() -- This essentially tells FCEUX to keep running

end

