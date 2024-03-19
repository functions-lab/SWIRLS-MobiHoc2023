function [modu, code] = SplitMCS(mcs, prot)
    if strcmp(prot, "Non-HT")
        switch mcs
            case 0
                modu = 2;
                code = 2;
            case 1
                modu = 2;
                code = 4;
            case 2
                modu = 4;
                code = 2;
            case 3
                modu = 4;
                code = 4;
            case 4
                modu = 16;
                code = 2;
            case 5
                modu = 16;
                code = 4;
            case 6
                modu = 64;
                code = 3;
            case 7
                modu = 64;
                code = 4;
            otherwise
                disp("Warning: Modulation and Coding Scheme NOT Found!");
        end
    elseif strcmp(prot, "HT")
        switch mod(mcs, 8)
            case 0
                modu = 2;
                code = 2;
            case 1
                modu = 4;
                code = 2;
            case 2
                modu = 4;
                code = 4;
            case 3
                modu = 16;
                code = 2;
            case 4
                modu = 16;
                code = 4;
            case 5
                modu = 64;
                code = 3;
            case 6
                modu = 64;
                code = 4;
            case 7
                modu = 64;
                code = 6;
            otherwise
                disp("Warning: Modulation and Coding Scheme NOT Found!");
        end
    elseif strcmp(prot, "VHT")
        switch mcs
            case 0
                modu = 2;
                code = 2;
            case 1
                modu = 4;
                code = 2;
            case 2
                modu = 4;
                code = 4;
            case 3
                modu = 16;
                code = 2;
            case 4
                modu = 16;
                code = 4;
            case 5
                modu = 64;
                code = 3;
            case 6
                modu = 64;
                code = 4;
            case 7
                modu = 64;
                code = 6;
            case 8
                modu = 256;
                code = 4;
            case 9
                modu = 256;
                code = 6;
            otherwise
                disp("Warning: Modulation and Coding Scheme NOT Found!");
        end
    else
        disp("Warning: Protocol NOT Found!");
        modu = nan;
        code = nan;
    end
end