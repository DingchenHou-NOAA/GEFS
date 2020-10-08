#!/usr/bin/env python

import sys
import os

def main():
    print("main")

    for task in ["post_high", "post_low", "prdgen_high", "prdgen_low", "sigchgres", "post_cf", "prdgen_cf"]:
        print(task)
        forEachTask(task)

def forEachTask(task):
    sFileName = "jgefs_{0}.ecf".format(task)
    if os.path.exists(sFileName):
        print(sFileName)

        sLines = []
        fid = open(sFileName, "r")
        for sLine in fid:
            sLines.append(sLine)
            #sLines = fid.readlines()
        fid.close()
        #print(sLines)
        print(len(sLines))

        if os.path.exists(task):
            import shutil
            shutil.rmtree(task)
    
        os.makedirs(task)


        for iMem in range(21):
            if iMem == 0:
                sMem = "c{0:02d}".format(iMem)
            else:
                sMem = "p{0:02d}".format(iMem)
    
            sFileName_w = "{0}/jgefs_{1}_{0}.ecf".format(task, sMem)
            fid = open(sFileName_w, "w")
            for j in range(len(sLines)):
                sLine = sLines[j]
                print(sLine)
                sLine1 = sLine.replace("%MEM%",sMem)
                print(sLine1)
                fid.write(sLine1)
                fid.flush()

            fid.close()
#===========
if __name__ == '__main__':
    import sys
    main()
    print("--Done!")
