function [mcs] = MergeMCS(modu, code, ant, prot)
    if strcmp(prot, "Non-HT")
        if (modu==2)&&(code==2)
            mcs = 0;
        elseif (modu==2)&&(code==4)
            mcs = 1;
        elseif (modu==4)&&(code==2)
            mcs = 2;
        elseif (modu==4)&&(code==4)
            mcs = 3;
        elseif (modu==16)&&(code==2)
            mcs = 4;
        elseif (modu==16)&&(code==4)
            mcs = 5;
        elseif (modu==64)&&(code==3)
            mcs = 6;
        elseif (modu==64)&&(code==4)
            mcs = 7;
        else
            disp("Warning Modulation/Coding Scheme NOT Found!")
        end
    elseif strcmp(prot, "HT")
        if (modu==2)&&(code==2)
            mcs = 0 + (ant-1) * 8;
        elseif (modu==4)&&(code==2)
            mcs = 1 + (ant-1) * 8;
        elseif (modu==4)&&(code==4)
            mcs = 2 + (ant-1) * 8;
        elseif (modu==16)&&(code==2)
            mcs = 3 + (ant-1) * 8;
        elseif (modu==16)&&(code==4)
            mcs = 4 + (ant-1) * 8;
        elseif (modu==64)&&(code==3)
            mcs = 5 + (ant-1) * 8;
        elseif (modu==64)&&(code==4)
            mcs = 6 + (ant-1) * 8;
        elseif (modu==64)&&(code==6)
            mcs = 7 + (ant-1) * 8;
        else
            disp("Warning Modulation/Coding Scheme NOT Found!")
        end
    elseif strcmp(prot, "VHT")
        if (modu==2)&&(code==2)
            mcs = 0;
        elseif (modu==4)&&(code==2)
            mcs = 1;
        elseif (modu==4)&&(code==4)
            mcs = 2;
        elseif (modu==16)&&(code==2)
            mcs = 3;
        elseif (modu==16)&&(code==4)
            mcs = 4;
        elseif (modu==64)&&(code==3)
            mcs = 5;
        elseif (modu==64)&&(code==4)
            mcs = 6;
        elseif (modu==64)&&(code==6)
            mcs = 7;
        elseif (modu==256)&&(code==4)
            mcs = 8;
        elseif (modu==256)&&(code==6)
            mcs = 9;
        else
            disp("Warning Modulation/Coding Scheme NOT Found!")
        end
    else
        disp("Warning Protocol NOT Found!")
    end
end